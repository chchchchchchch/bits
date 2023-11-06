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

float h_MAX = 70.0; // max. Luftfeuchte Außen
float t_MIN = 16.0; // min. Temperatur Innen

float dT = 5.0;     // Temp. Delta für Taupunktberechnung
float dp;
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

  //valPoti = round(analogRead(POTIPIN))/1023.0;
  valPoti = round(analogRead(POTIPIN)/10.23)/100.0;
  fan_O(valPoti);

/*
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
  float t_O = dht_O.readTemperature();
  float t_I = dht_I.readTemperature();

//// Check if any reads failed and exit early (to try again).
//if (isnan(h_O) || isnan(t_O)) {
//  Serial.println(F("Failed to read from DHT sensor!"));
//  return;
//}

/*
  float a, b;
  if (t_O >= 0) {
    a = 7.5;
    b = 237.3;
  } else {
    a = 7.6;
    b = 240.7;
  }

  float sgp = 6.1078 * pow(10, (a * t_O) / (b + t_O));
  float gp = (t_O / 100) * sgp;
  float v = log10(gp / 6.1078);

  dp = (b * v) / (a - v);

  if (t_I > t_MIN) { // Temperatur Innen ok
      fan_O(0.05);
  } else {           // Temperatur Innen zu niedrig
      fan_O(0);
  }

  if ((dp - dT) < t_I) { // Taupunkt optimal
    //fan_I(1.0);
    //fan_O(1.0);
  } else {
    //fan_I(0);
  }
  if (h_O > h_MAX) { // Feuchte Aussen zu hoch
      fan_I(0);
  }
*/
  Serial.print("h_O:");
  Serial.print(h_O);
  Serial.print("|");
  Serial.print("t_O:");
  Serial.print(t_O);
  Serial.print("|");
  Serial.print("h_I:");
  Serial.print(h_I);
  Serial.print("|");
  Serial.print("t_I:");
  Serial.print(t_I);
  Serial.println();

  Serial.print("(dp - dT): ");
  Serial.println((dp - dT));

  // Wait a few seconds between measurements.
  //delay(60000);
  delay(2000);

}
