void fan_I( float speed ) {

  if ( speed > 0 ) {

    digitalWrite(RELAISPIN, HIGH);
    delay(100);
   
  } else {

    digitalWrite(RELAISPIN, LOW);    
  }

}

void fan_O( float speed ) {

  if ( speed > 0.0 &&
       speed < fan_O_speedMin ) {
       speed = fan_O_speedMin;
  }

  if ( speed > fan_O_speedMax ) {
       speed = fan_O_speedMax;
  }

  if ( speed != fan_O_speedNow &&
       speed >= fan_O_speedMin ) {

    if ( speed < fan_O_speedMin && speed > 0.0 ) {
         // SPIN UP
         Serial.println("SPIN UP FAN");
         analogWrite(MOSFETPIN_1, 0.1);
         delay(2000);
    }
    
    Serial.print("SET NEW SPEED: ");
    Serial.println(speed);
    fan_O_speedNow = speed; // REMEMBER
    
    analogWrite(MOSFETPIN_1, speed * 255);
    
  } else if ( speed < fan_O_speedMin &&
              speed != fan_O_speedNow ) {
    
    analogWrite(MOSFETPIN_1, 0.0);
    Serial.println("STOP FAN");
    fan_O_speedNow = speed; // REMEMBER
  }
}
