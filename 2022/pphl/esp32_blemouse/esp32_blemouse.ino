/* SETUP/TEST BLUETOOTH MOUSE EMULATION
   https://github.com/T-vK/ESP32-BLE-Mouse
   -------------------------------- */

#include <BleMouse.h>

BleMouse bleMouse("ESP32_Mouse", "PPHL", 80);

void setup() {

  Serial.begin(115200);
  Serial.println("Starting BLE work!");
  bleMouse.begin();

}

/* ---------------------------------- */

void loop() {

  if (bleMouse.isConnected()) {

    unsigned long startTime;

    bleMouse.press();
    for (int i = 0; i <= 100; i++) {
      bleMouse.move(-1, 0);
      Serial.println("move");
      delay(100);
    }

    bleMouse.release();
    delay(2000);
    Serial.println("back");
    bleMouse.move(100, -20);

  }

}
