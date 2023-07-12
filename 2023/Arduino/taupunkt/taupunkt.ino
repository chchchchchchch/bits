// Lüfter mit Poti, Arduino Uno und MOSFET steuern 
// Sketch von Tobias Tippelt, 2020

const int Gate = 9; // Digitalen (und PWM fähigen) Pin 9 am Arduino für MOSFET Ansteuerung festlegen
const int Poti = A0; // Einlesen des Spannungswertes am Potentiometer
int potiWert = 0; // Poti-Wert initial auf 0 setzen
float potiWertAnzeige = 0; // Variable für seriellen Monitor definieren

void setup() {
  // put your setup code here, to run once:

  TCCR1B = TCCR1B & 0b11111000 | 0x01;

  pinMode(Gate,OUTPUT);
  Serial.begin(9600); // Festlegung der Datenrate in Bit pro Sekunde (Baud) für die serielle Datenübertragung, muss dann am seriellen Monitor rechts unten auch eingestellt werden
  Serial.println("Lüftersteuerung Programmstart");

}


void loop() {
  // put your main code here, to run repeatedly:

  potiWert = analogRead(Poti)/2.7; // analogRead liest Werte beim Uno zwischen 0 und 1023 ein, analog Write gibt jedoch nur Werte zwischen 0 und 255 aus
  analogWrite(Gate, potiWert); // Am Pin 9 das PWM Signal zur MOSFET Ansteuerung ausgeben

//potiWertAnzeige =((float)potiWert/255.0)*100.0; // Umrechnung des AnalogWrite Wertes in Prozent, also quasi "Ansteuerungsgrad" des Lüfters
//Serial.print("Lüfter wird mit "); // Am seriellen Monitor den aktuell eingelesenen Poti-Wert ausgeben (serieller Monitor lässt sich in der Arduino Oberfläche rechts oben öffnen)
//Serial.println(" % angesteuert.");
  Serial.print("potiWert: ");
  Serial.println(potiWert); 
  
}
