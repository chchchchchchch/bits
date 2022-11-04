/* EMULATE BLE MOUSE VIA
   GROVE THUMB JOYSTICK WITH ESP32
   --------------------      -----
   GND                   ->  GND
   VCC                   ->  3V3
   X                     ->  D12
   Y                     ->  D13
   --------------------------------
   https://github.com/T-vK/ESP32-BLE-Mouse
   -------------------------------- */

#include <BleMouse.h>
BleMouse bleMouse("ESP32_Joymouse", "PPHL", 80);

int X, Y;
int moveX, moveY, d;

void setup() {

  Serial.begin(9600);
  bleMouse.begin();

}

/* ---------------------------------- */

void loop() {

  if (bleMouse.isConnected()) {

    X = analogRead(12);
    Y = analogRead(13);

    moveX = 0;
    moveY = 0;

    if ( Y < 1800 ) {

      d = -1;
      //moveY = 2*d;
      moveY = sqrt(1800 - Y) * d;
      /*Serial.print( "TOP (" );
        Serial.print( moveY );
        Serial.print( ") " );*/
    }
    if ( Y > 2000 ) {

      d = 1;
      //moveY = 2*d;
      moveY = sqrt(Y - 2000) * d;
      /*Serial.print("BOTTOM (");
        Serial.print( moveY );
        Serial.print( ") " );*/
    }

    if ( X < 1800 ) {

      d = -1;
      //moveX = 2*d;
      moveX = sqrt(1800 - X) * d;
      /*Serial.print( "LEFT (" );
        Serial.print( moveX );
        Serial.print( ") " );*/
    }

    if ( X > 2000 ) {

      d = 1;
      //moveX = 2*d;
      moveX = sqrt(X - 2000) * d;
      /*Serial.print( "RIGHT (" );
        Serial.print( moveX );
        Serial.print( ") " );*/
    }

    if ( Y < 1800 ||
         Y > 2000 ||
         X < 1800 ||
         X > 2000 ) {

      //Serial.println("");
      //Serial.println("-----");
      Serial.print("moveX: ");
      Serial.print(moveX);
      Serial.print(" | moveY: ");
      Serial.println(moveY);
      bleMouse.move(moveX, moveY);
      //Serial.println("-----");
    }

    delay(50);

  }

}
