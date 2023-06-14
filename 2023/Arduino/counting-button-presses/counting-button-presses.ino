// https://forum.arduino.cc/t/counting-button-presses/119881/4

// Counts number of button presses
// output count to serial
// blink a led according to count

byte switchPin = 3;                    // switch is connected to pin 2
byte ledPin = 13;                      // led on pin 13
byte buttonPresses = 0;                // how many times the button has been pressed 
byte lastPressCount = 0;               // to keep track of last press count

void setup() {
  pinMode(switchPin, INPUT);          // Set the switch pin as input
  digitalWrite(switchPin, HIGH);      // set pullup resistor
  Serial.begin(9600);                 // Set up serial communication at 9600bps
}

void loop(){
  if (digitalRead(switchPin) == LOW)  // check if button was pressed
  {
    buttonPresses++;                  // increment buttonPresses count
    delay(250);                       // debounce switch
  }
  if (buttonPresses == 4) buttonPresses = 0;         // rollover every fourth press
  if (lastPressCount != buttonPresses)              // only do output if the count has changed
  {
    Serial.print ("Button press count = ");          // out to serial
    Serial.println(buttonPresses, DEC);
    for (byte n = 0; n <= 5 * buttonPresses; n++)    // lets blink
    {
      digitalWrite(ledPin, HIGH);      // turn on led
      delay(500);                      // wait half a second
      digitalWrite(ledPin, LOW);       // turn off led
      delay(500);                      // wait again
    }
    lastPressCount = buttonPresses;    // track last press count
  }
}
