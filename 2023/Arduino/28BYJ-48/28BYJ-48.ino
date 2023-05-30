/* Example sketch to control a 28BYJ-48 stepper motor with ULN2003 driver board,
   AccelStepper and Arduino UNO: continuous rotation.
   More info: https://www.makerguides.com */
/* https://www.pjrc.com/teensy/td_libs_AccelStepper.html
   https://www.airspayce.com/mikem/arduino/AccelStepper/Bounce_8pde-example.html
*/

// Include the AccelStepper library:
#include <AccelStepper.h>

// Motor pin definitions:
#define motorPin1  8      // IN1 on the ULN2003 driver
#define motorPin2  9      // IN2 on the ULN2003 driver
#define motorPin3  10     // IN3 on the ULN2003 driver
#define motorPin4  11     // IN4 on the ULN2003 driver

// Define the AccelStepper interface type; 4 wire motor in half step mode:
#define MotorInterfaceType 8

// Initialize with pin sequence IN1-IN3-IN2-IN4 for using the AccelStepper library with 28BYJ-48 stepper motor:
AccelStepper stepper = AccelStepper(MotorInterfaceType, motorPin1, motorPin3, motorPin2, motorPin4);

void setup()
{  
  //start serial connection
  Serial.begin(9600);
  
  // Change these to suit your stepper if you want
  stepper.setMaxSpeed(500);
  //stepper.setAcceleration(1000);
  stepper.setAcceleration(500);
  //stepper.setSpeed(10);
  stepper.moveTo(2038);
}
 
void loop()
{

    // If at the end of travel go to the other end
    if (stepper.distanceToGo() == 0) {
      stepper.moveTo(-stepper.currentPosition());
      //Serial.println("TURN");
      delay(500);
    }
    //Serial.println(stepper.distanceToGo());
    stepper.run();

/*
     stepper.move(1000);
     stepper.run();
     Serial.println(stepper.currentPosition());
     if (stepper.currentPosition()%1000 == 0) {
         delay(1000);
     }
*/

}
