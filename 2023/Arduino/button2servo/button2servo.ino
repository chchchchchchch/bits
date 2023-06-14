// https://mechatrofice.com/arduino/arduino-counter-code-circuit-working

const int buttonPin = 3;     // the number of the pushbutton pin
//const int ledPin =  9;      // the number of the LED pin

// servo library
#include <Servo.h>
const int servoPin = 7; // digital pin that servor motor is attached to
int servoValue = 0; // value used to drive servo motor
Servo servoMotor; // create servo object to control a servo

// variables will change:
int buttonState = 0;         // variable for reading the pushbutton status
int count_value = 0;
int prestate = 0;
void setup() {
 
/*// initialize the LED pin as an output:
  pinMode(ledPin, OUTPUT);*/
  // initialize digital pin LED_BUILTIN as an output.
  pinMode(LED_BUILTIN, OUTPUT);
  // initialize the pushbutton pin as an input:
  pinMode(buttonPin, INPUT);

  servoMotor.attach(servoPin);
  servoMotor.write(0);

  Serial.begin(9600);
}

void loop() {
  // read the state of the pushbutton value:
  buttonState = digitalRead(buttonPin);

  // check if the pushbutton is pressed. If it is, then the buttonState is HIGH:
  if ( buttonState == HIGH && prestate == 0 ) {
    //count_value++;
    count_value = count_value + 5;
    servoValue = count_value;
    Serial.println(count_value);
/*
    // turn LED on
    digitalWrite(ledPin, HIGH);
    delay(100);
    // turn LED off
    digitalWrite(ledPin, LOW);
*/
    servoMotor.write(servoValue);
    delay(100);

    prestate = 1;
  } else if ( count_value > 185 ) {
    count_value = 0;
    servoValue = count_value;
    servoMotor.write(servoValue);
    delay(100);      
  } else if ( buttonState == LOW ) {
    prestate = 0;
  }
}
