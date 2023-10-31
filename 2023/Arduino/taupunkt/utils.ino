void fan_I( float speed ) {

  if (speed > 0) {

    digitalWrite(RELAISPIN, HIGH);
    delay(100);
   
  } else {

    digitalWrite(RELAISPIN, LOW);    
  }

}

const float fan_O_speedMin = 0.05; // REQUIRES 0.1 TO START
const float fan_O_speedMax = 1.00;

void fan_O( float speed ) {

  //Serial.println(speed); 
  speed = 255 * speed;
  analogWrite(MOSFETPIN_1, speed);

}
