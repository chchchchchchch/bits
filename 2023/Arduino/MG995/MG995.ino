/* This example Arduino Sketch controls the complete rotation of
 * MG995 Servo motor by using its PWM and Pulse width modulation technique
 */
 
#include <Servo.h>  // include servo library to use its related functions
#define Servo_PWM 6 // A descriptive name for D6 pin of Arduino to provide PWM signal
Servo MG995_Servo;  // Define an instance of of Servo with the name of "MG995_Servo"
 
void setup() {
  Serial.begin(9600);            // Initialize UART with 9600 Baud rate
  MG995_Servo.attach(Servo_PWM); // Connect D6 of Arduino with PWM signal pin of servo motor

}

void loop() {
  Serial.println("CW");  // You can display on the serial the signal value
  MG995_Servo.write(0);  // Turn clockwise
  delay(3000);
  MG995_Servo.write(90); // Stop.
  delay(2000);
  Serial.println("CCW"); // Turn counterclockwise
  MG995_Servo.write(180);
  delay(3000);
  MG995_Servo.write(90); // Stop
  delay(2000);

}
