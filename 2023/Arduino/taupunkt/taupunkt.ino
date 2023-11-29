#include "DHT.h"
#include <WiFiNINA.h>
#include <ArduinoHttpClient.h>
#include "conf.h"

#define DHTPIN_0 2
#define DHTPIN_I 4
#define DHTTYPE DHT22 // DHT 22  (AM2302), AM2321

DHT dht_O(DHTPIN_0, DHTTYPE);
DHT dht_I(DHTPIN_I, DHTTYPE);

const int SWITCHPIN   = 12;
const int MOSFETPIN_O =  9;
const int MOSFETPIN_I = 10;
const int analogInPin = 0; // TMP

// --- Internal ------------------------------------------------------
int RUNMODE = 0;  //-1=OFF | 0=IDLE | 1=ENTFEUCHTUNG | 2=LUEFTUNG
int lueftung_CountWaitIntervals = 0;
int lueftung_CountRunIntervals = 0;
int lueftung_Status = 0; //0=passive. 1=waiting. 2=running
float humi_I;
float humi_O;
float temp_I;
float temp_O;
float taup_I;
float taup_O;
float taup_delta;

WiFiSSLClient wifi;
HttpClient client = HttpClient(wifi, server, port);
int status = WL_IDLE_STATUS;
String contentType = "application/x-www-form-urlencoded";
String postData;

// --- FanValues -----------------------------------------------------
String FANMODE;
const float fan_speedMin = 0.03;
const float fan_speedMax = 1.00;
float fan_speedNow   = 0.0; // REMEMBER TO CHECK
float fan_O_speedNow = 0.0; // REMEMBER TO CHECK
float fan_I_speedNow = 0.0; // REMEMBER TO CHECK

String FAN_I,FAN_O;

// --- WeatherValues -------------------------------------------------
float temp_O_CORRECTION =  -3.0;
float temp_I_CORRECTION =   0.0;

float temp_I_MIN     =  10.0; // min. Temperatur Innen
float temp_O_MIN     = -10.0; // min. Temperatur Außen
//float humi_MAX     =  62.0; // max. Luftfeuchte

float taup_DIF       =   6.0; // minimaler Taupunktunterschied, bei dem das Relais schaltet
float HYSTERESE      =   3.0; // Abstand von Ein- und Ausschaltpunkt

// --- Timings ------------------------------------------------------
float loop_Interval   =  2 *60; // Loop-/Messinterval in Sekunden

int lueftung_WaitInterval = 60 *60;   // Lüftung alle x Sekunden (z.B. alle 60 Minuten)
int lueftung_RunInterval  =  5 *60;   // für y Sekunden          (z.B.  für  5 Minuten)

// --- Logging ------------------------------------------------------
bool p = true;                        // Do serial print


void setup() {

  //TCCR1B = TCCR1B & 0b11111000 | 0x01;
  dht_O.begin();
  dht_I.begin();

  pinMode(SWITCHPIN, INPUT_PULLUP);
  pinMode(MOSFETPIN_O,OUTPUT);
  pinMode(MOSFETPIN_I,OUTPUT);

  if(p) Serial.begin(9600);

  while (status != WL_CONNECTED) {
    if(p) Serial.print("Attempting to connect to Network named: ");
    if(p) Serial.println(ssid);
    status = WiFi.begin(ssid, pass);
    delay(10000);
  }
  if(p) Serial.print("SSID: ");
  if(p) Serial.println(WiFi.SSID());
  IPAddress ip = WiFi.localIP();
  IPAddress gateway = WiFi.gatewayIP();
  if(p) Serial.print("IP Address: ");
  if(p) Serial.println(ip);

}

void loop() {

  // --- checkSwitch -------------------------------------------
  if(digitalRead(SWITCHPIN) == HIGH) {
    if(p && RUNMODE != -1) Serial.println("--- SILENT ON ------------------");
    RUNMODE = -1;
  } else {
    if(p && RUNMODE == -1) Serial.println("--- SILENT OFF -----------------");
    RUNMODE = 0;
  }


  if(RUNMODE != -1) {
    
    // --- checkSensors -------------------------------------------    
    // Reading temperature or humidity takes about 250 milliseconds!
    // Sensor readings may also be up to 2 seconds 'old' (its a very slow sensor)
    humi_O = dht_O.readHumidity();
    humi_I = dht_I.readHumidity();
    // Read temperature as Celsius (the default)
    temp_O = dht_O.readTemperature() + temp_O_CORRECTION;
    temp_I = dht_I.readTemperature() + temp_I_CORRECTION;

    taup_O = taupunkt(temp_O,humi_O);
    taup_I = taupunkt(temp_I,humi_I);
    taup_delta = taup_I - taup_O;
               
    // --- checkModeConditions -------------------------------------------
    if ( (temp_I < temp_I_MIN ) || (temp_O < temp_O_MIN ) ) {                 // zu kalt
      RUNMODE = 0;                                                            //   IDLE/WAIT (M0)
    } else {                                                                  // nicht zu kalt
      if (taup_delta >= taup_DIF) {                                           //   taup_delta passt
        RUNMODE = 1;                                                          //     ENTFEUCHTUNG (M1)
      } else if ( RUNMODE == 1 &&                                             
                  (taup_delta < taup_DIF) && 
                  (taup_delta > (taup_DIF - HYSTERESE)) ) {                   //   taup_delta passt immernoch
        RUNMODE = 1;                                                          //     ENTFEUCHTUNG Keep running (M1)
      } else {                                                                //   sonst
        RUNMODE = 2;                                                          //     INTERVALLLUEFTUNG (M2)
      } 
    }
  //if (humi_O > humi_MAX+10 )                 RUN = false;                   // Könnte wieder rein

    // --- collect postData ----------------------------------------------

    postData = "temp_O:" + String(temp_O)
               + "|"
               + "humi_O:" + String(humi_O)
               + "|"
               //+ "taup_O:" + String(taup_O)
               //+ "|"
               + "temp_I:" + String(temp_I)
               + "|"
               + "humi_I:" + String(humi_I);
               //+ "|"
               //+ "taup_I:" + String(taup_I);

  // --- activateModes-------------------------------------------------------
    if ( RUNMODE == 0 ) {          // Switch or stay IDLE (M0)
      fan(MOSFETPIN_I, 0.0);FAN_I="0";
      fan(MOSFETPIN_O, 0.0);FAN_O="0";
      lueftung_Status = 0;
    } 
    else if ( RUNMODE == 1) {      // Switch or stay ENTFEUCHTUNG (M1)
      fan(MOSFETPIN_I, 1.0);FAN_I="1";
      fan(MOSFETPIN_O, 1.0);FAN_O="1";
      lueftung_Status = 0;
    } 
    else if (RUNMODE == 2) {       // Switch or stay LUEFTUNG (M2)
      if(lueftung_Status == 0) {          //passive
        lueftung_Status = 1;              
        lueftung_CountWaitIntervals = 0;
        lueftung_CountRunIntervals = 0;
        fan(MOSFETPIN_I, 0.0);FAN_I="0";
        fan(MOSFETPIN_O, 0.0);FAN_O="0";
      } 
      else if (lueftung_Status == 1) {    //waiting
        lueftung_CountWaitIntervals++;
        if( (loop_Interval*lueftung_CountWaitIntervals) >= lueftung_WaitInterval ) {
          lueftung_Status = 2;
          lueftung_CountWaitIntervals = 0;
        }
        fan(MOSFETPIN_I, 0.0);FAN_I="0";
        fan(MOSFETPIN_O, 0.0);FAN_O="0";
        if(p) Serial.print( "LUEFTUNG (M2) WAITING: "); 
        if(p) Serial.print( (loop_Interval*lueftung_CountWaitIntervals)/60.0 ); 
        if(p) Serial.println( " Minuten" );
      } 
      else if (lueftung_Status == 2) {    //runnning
        lueftung_CountRunIntervals++;
        if( (loop_Interval*lueftung_CountRunIntervals) >= lueftung_RunInterval ) {
          lueftung_Status = 1;
          lueftung_CountRunIntervals = 0;
        }
        fan(MOSFETPIN_I, 0.0);FAN_I="0";
        fan(MOSFETPIN_O, 1.0);FAN_O="1";
        if(p) Serial.print( "LUEFTUNG (M2) RUNNING: "); 
        if(p) Serial.print( (loop_Interval*lueftung_CountRunIntervals)/60.0 ); 
        if(p) Serial.println( " Minuten" );
      }
    }

    delay(loop_Interval*1000);    // Standard Loop-Interval

  } else { // SILENT
    lueftung_Status = 0;
    fan(MOSFETPIN_I, 0.0);
    fan(MOSFETPIN_O, 0.0); 
    delay(1000);
  }
  // ------------------------------------------------------------------------
  postData = postData
           + "|"
           + "RUNMODE:" + String(RUNMODE)
           + "|"
           + "FAN_O:" + String(FAN_O)
           + "|"
           + "FAN_I:" + String(FAN_I);

  // --- post to Server -----------------------------------------------------
  if(p) Serial.println(postData);

  postData = "dht=" + postData;
  if ( client.connect(server, port) ) {
  //if(p) Serial.println("connected");    
    client.post("/dht.php", contentType, postData);
  // show the status code and body of the response
  //int statusCode = client.responseStatusCode();
  //String response = client.responseBody();
  //Serial.print("Status code: ");Serial.println(statusCode);
  //Serial.print("Response: ");Serial.println(response);
  }
  if ( client.connected() ) {
    client.stop();
  }

} // END loop
