/* SIMPLE SETUP TO USE
   GROVE THUMB JOYSTICK WITH ESP32
   --------------------      -----
   GND                   ->  GND
   VCC                   ->  3V3
   X                     ->  D12
   Y                     ->  D13
   -------------------------------- */

int X, Y;

void setup() {

  Serial.begin(9600);
}

/* ---------------------------------- */

void loop() {

  X = analogRead(12);
  Y = analogRead(13);

  if ( Y < 1800 ) {

    Serial.print( "TOP (" );
    Serial.print( Y );
    Serial.print( ") " );
  }
  if ( Y > 2000 ) {

    Serial.print("BOTTOM (");
    Serial.print( Y );
    Serial.print( ") " );
  }

  if ( X < 1800 ) {

    Serial.print( "LEFT (" );
    Serial.print( X );
    Serial.print( ") " );
  }

  if ( X > 2000 ) {

    Serial.print( "RIGHT (" );
    Serial.print( X );
    Serial.print( ") " );

  }

  if ( Y < 1800 ||
       Y > 2000 ||
       X < 1800 ||
       X > 2000 ) {

    Serial.println("");

  }

  delay(10);

}
