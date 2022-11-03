/* SETUP/TEST BLUETOOTH MOUSE EMULATION
   https://github.com/T-vK/ESP32-BLE-Mouse
   https://github.com/sobrinho/ESP32-BLE-Abs-Mouse
   -------------------------------- */

//#include <BleMouse.h>
//BleMouse bleMouse("ESP32_Mouse", "PPHL", 80);

#include <BleAbsMouse.h>
#include <BleConnectionStatus.h>
BleAbsMouse bleAbsMouse("ESP32_Mouse", "PPHL", 80);

int wMax = 720;
int hMax = 1280;

void setup() {

  Serial.begin(115200);
  Serial.println("Starting BLE work!");
  //bleMouse.begin();
  bleAbsMouse.begin();
}

/* ---------------------------------- */

void loop() {

  if (bleAbsMouse.isConnected()) {

    bleAbsMouse.click(5000, 5000);
/*
    bleAbsMouse.move(2000, 3000);
    bleAbsMouse.click(5000, 5000);

    for (int i = 0; i <= 7000; i = i + 5) {
      delay(20);
      Serial.println("move.");
      bleAbsMouse.move(2000 + i, 3000);
      bleAbsMouse.release();
    }
*/
    delay(3000);

    /*
        bleMouse.move(wMax * -10, hMax * -1);
        Serial.println(wMax * -1);
        delay(1000);

        for (int i = 0; i <= 50; i++) {
          bleMouse.move(1, 0);
          delay(100);
        }

        for (int i = 0; i <= 50; i++) {
          bleMouse.move(0,1);
          delay(100);
        }
    */

    /*
        bleMouse.press();
        for (int i = 0; i <= 100; i++) {
          bleMouse.move(-2, 0);
          //Serial.println("move");
          delay(50);
        }

        //bleMouse.release();
        delay(2000);
        Serial.println("back");
        bleMouse.move(100, 50);
        delay(50);
    */

    /*
           bleMouse.press();
           for (int i = 0; i <= 100; i++) {
             bleMouse.move(5, 0);
             Serial.println("move");
             delay(100);
           }

           bleMouse.release();
           delay(2000);
           Serial.println("back");
           bleMouse.move(100, -20);
    */

  }

}
