/* SIMPLE SETUP TO USE
   GROVE THUMB JOYSTICK WITH ESP32
   --------------------      -----
   GND                   ->  GND
   VCC                   ->  3V3
   X                     ->  D12
   Y                     ->  D13
*/

void setup() {

  Serial.begin(9600);

}

void loop() {

  if (analogRead(12) > 2000 ) {

    Serial.print("TOP");
  }
  if (analogRead(12) < 1000 ) {

    Serial.print("BOTTOM");
  }

  if (analogRead(13) > 2000 ) {

    Serial.print("RIGHT");
  }

  if (analogRead(13) < 1000 ) {

    Serial.print("LEFT");
  }

  Serial.println("");
  Serial.println("------------------");
  delay(100);


}
