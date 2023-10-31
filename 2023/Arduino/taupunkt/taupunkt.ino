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

float h_MAX = 70.0; // max. Luftfeuchte Innen
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

  valPoti = analogRead(POTIPIN)/1023.0; // analogRead liest Werte beim Uno zwischen 0 und 1023 ein, analog Write gibt jedoch nur Werte zwischen 0 und 255 aus
  fan_O(valPoti);

/*
  if ( valPoti > 0.9 ) {
    fan_I(1);
  } else {
    fan_I(0);    
  }
*/

  // Wait a few seconds between measurements.
  delay(2000);

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

  if ((dp - dT) < t_I) {
    //FAN_I = 1;
    //fan_I(1);
    Serial.println("fan_I ON");
  } else {
    //FAN_I = 0;
    //fan_I(0);
    Serial.println("fan_I OFF");
  }
  if (h_O > h_MAX)  fan_I(0); // Feuchte aussen zu hoch




  Serial.print(F("Humidity outside: "));
  Serial.print(h_O);
  Serial.print(F("%  temperature outside: "));
  Serial.print(t_O);
  Serial.print(F("°C "));
  Serial.println("");

  Serial.print(F("Humidity inside: "));
  Serial.print(h_I);
  Serial.print(F("%  temperature inside: "));
  Serial.print(t_I);
  Serial.print(F("°C "));
  Serial.println("");

}
