

 
 #include <Servo.h> // Library import
 
 Servo myservo;// create servo object

const int  buttonPin = 9;    // the pin that the switch is attached to
const int ledPin = 13;       // the pin that the LED is attached to
const int servoPin = 4;

int pos = 0;    // variable to store the servo position 
int angerLevel = 0;
int peaceLevel = 0; //everytime the buffer overflows on this variable, angerLevel will decrease by one. 

// Variables will change:
int buttonPushCounter = 0;   // counter for the number of button presses
int buttonState = 0;         // current state of the button
int lastButtonState = 0;     // previous state of the button






void setup() {
  myservo.attach(servoPin);
  myservo.write(179);
  // initialize the button pin as a input:
  pinMode(buttonPin, INPUT);
  // initialize the LED as an output:
  pinMode(ledPin, OUTPUT);
  // initialize serial communication:
  Serial.begin(9600);
}


void loop() {
  // read the pushbutton input pin:
  buttonState = digitalRead(buttonPin);
  
  peaceLevel=peaceLevel+1;
  
    // if the state has changed, increment the counter
    if (buttonState == HIGH) {
      
     angerLevel++;
     
     digitalWrite(ledPin, HIGH);
       delay((1000/angerLevel)+200); //doesnt perform exactly as expected. order of operations problem?
         myservo.write(0);
       delay((400/angerLevel)+350);
       
     digitalWrite(ledPin, LOW);
         myservo.write(179);
     delay(250); //prevents loop from starting over before switch is fully off. 
     
    } 
    
  if (peaceLevel >= 1000 && angerLevel > 0 ) {
    angerLevel--;
    peaceLevel = 0; } //machine gradually calms down over time. every 1000 cycles / about 5 seconds. 
  Serial.println(peaceLevel);
 

 
  
}//end Loop









