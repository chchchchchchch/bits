#include "DHT.h"

#define DHTPIN_0 2
#define DHTPIN_I 4

#define DHTTYPE DHT22 // DHT 22  (AM2302), AM2321

DHT dht_O(DHTPIN_0, DHTTYPE);
DHT dht_I(DHTPIN_I, DHTTYPE);

void setup() {
  
  Serial.begin(9600);

  dht_O.begin();
  dht_I.begin();
  
}

void loop() {

  // Wait a few seconds between measurements.
  delay(2000);

  // Reading temperature or humidity takes about 250 milliseconds!
  // Sensor readings may also be up to 2 seconds 'old' (its a very slow sensor)
  float h_O = dht_O.readHumidity();
  float h_I = dht_I.readHumidity();
  // Read temperature as Celsius (the default)
  float t_O = dht_O.readTemperature();
  float t_I = dht_I.readTemperature();

/*
  // Check if any reads failed and exit early (to try again).
  if (isnan(h_O) || isnan(t_O)) {
    Serial.println(F("Failed to read from DHT sensor!"));
    return;
  }
*/

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
