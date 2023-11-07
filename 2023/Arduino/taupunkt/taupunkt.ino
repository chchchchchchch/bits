#include "DHT.h"

#define DHTPIN_0 2
#define DHTPIN_I 4
#define DHTTYPE DHT22 // DHT 22  (AM2302), AM2321

DHT dht_O(DHTPIN_0, DHTTYPE);
DHT dht_I(DHTPIN_I, DHTTYPE);

const int RELAISPIN   =  7;
const int MOSFETPIN_1 =  9;
const int MOSFETPIN_2 = 10;

const int POTIPIN = A0; // Einlesen des Spannungswertes am Potentiometer
float valPoti = 0; // Poti-Wert initial auf 0 setzen

float fan_O_speedNow = 0.00; // REMEMBER TO CHECK
const float fan_O_speedMin = 0.03;
const float fan_O_speedMax = 1.00;

float h_MAX      =  70.0; // max. Luftfeuchte Außen
float tp_DIF     =   5.0; // minimaler Taupunktunterschied, bei dem das Relais schaltet
float HYSTERESE  =   1.0; // Abstand von Ein- und Ausschaltpunkt
float t_I_MIN    =  16.0; // min. Temperatur Innen
float t_O_MIN    = -10.0; // min. Temperatur Innen

float t_O_OFFSET =  -3.0;
float t_I_OFFSET =   0.0;

bool RUN;

float h_I;
float h_O;
float t_I;
float t_O;

void setup() {

  TCCR1B = TCCR1B & 0b11111000 | 0x01;

  Serial.begin(9600);

  dht_O.begin();
  dht_I.begin();

  pinMode(RELAISPIN, OUTPUT);
  pinMode(MOSFETPIN_1,OUTPUT);

}

void loop() {

// TESTING --------------------------------------
/*
  //valPoti = round(analogRead(POTIPIN))/1023.0;
  valPoti = round(analogRead(POTIPIN)/10.23)/100.0;
  fan_O(valPoti);


  if ( valPoti > 0.9 ) {
    fan_I(1);
  } else {
    fan_I(0);    
  }
*/

// ----------------------------------------------

  // Reading temperature or humidity takes about 250 milliseconds!
  // Sensor readings may also be up to 2 seconds 'old' (its a very slow sensor)
  float h_O = dht_O.readHumidity();
  float h_I = dht_I.readHumidity();
  // Read temperature as Celsius (the default)
  float t_O = dht_O.readTemperature() + t_O_OFFSET;
  float t_I = dht_I.readTemperature() - t_I_OFFSET;

  float tp_O = taupunkt(t_O, h_O);
  float tp_I = taupunkt(t_I, h_I);
  float tp_delta = tp_I - tp_O;
  
  if (tp_delta > (tp_DIF + HYSTERESE)) RUN = true;
  if (tp_delta < (tp_DIF)) RUN = false;
  if (t_I < t_I_MIN ) RUN = false;
  if (t_O < t_O_MIN ) RUN = false;
  
  if ( RUN == true ) {
      //fan_I(1.0);
      fan_O(1.0);    
  } else {
      //fan_I(0);     
  }

  Serial.print("h_O:");
  Serial.print(h_O);
  Serial.print("|");
  Serial.print("t_O:");
  Serial.print(t_O);
  Serial.print("|");
  Serial.print("tp_O:");
  Serial.print(tp_O);
  Serial.print("|");
  Serial.print("h_I:");
  Serial.print(h_I);
  Serial.print("|");
  Serial.print("t_I:");
  Serial.print(t_I);
  Serial.print("|");
  Serial.print("tp_I:");
  Serial.print(tp_I);
  Serial.print("|");
  Serial.print("RUN:");
  Serial.print(RUN);
  Serial.println();


  // Wait a few seconds between measurements.
  //delay(60000);
  delay(10000);

}
