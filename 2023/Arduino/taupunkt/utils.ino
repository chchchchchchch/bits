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

// https://github.com/MakeMagazinDE/Taupunktluefter/blob/1eb6624/Taupunkt_Lueftung.ino
float taupunkt(float t, float r) {
  
  float a, b;
  if (t >= 0) {
    a = 7.5;
    b = 237.3;
  } else if (t < 0) {
    a = 7.6;
    b = 240.7;
  }
  
  // Sättigungsdampfdruck in hPa
  float sdd = 6.1078 * pow(10, (a*t)/(b+t));
  
  // Dampfdruck in hPa
  float dd = sdd * (r/100);
  
  // v-Parameter
  float v = log10(dd/6.1078);
  
  // Taupunkttemperatur (°C)
  float tt = (b*v) / (a-v);
  return { tt };  

}
