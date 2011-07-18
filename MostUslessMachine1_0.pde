
 
 #include <Servo.h> // Library import
 #include <avr/sleep.h>
 #include <avr/wdt.h>
 
 #ifndef cbi
 #define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
 #endif
 #ifndef sbi
 #define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))
 #endif

 Servo myservo; // create servo object

	const int  buttonPin = 9;    // the pin that the switch is attached to
	const int ledPin = 13;       // the pin that the LED is attached to
	const int servoPin = 4;      // the pin the servo is attached to

	int pos = 0;    // variable to store the servo position 
	int angerLevel = 0;
	int peaceLevel = 0; //everytime the buffer overflows, angerLevel will decrease by one. 

	// Variables will change:
	int buttonPushCounter = 0;   // counter for the number of button presses
	int buttonState = 0;         // current state of the button
	int lastButtonState = 0;     // previous state of the button

	volatile boolean f_wdt=1;




//********* you may need to change these values depending on your construction********


	boolean debugSerial = false; //Change to true for serial debuging output

	int servoClosedValue = 179; // closed is 179 degrees
	int servoOpenValue = 0; // open is 0 degrees


//***************************************************************************************




void setup() 
{
  	myservo.attach(servoPin);
 	myservo.write(179);
  	// initialize the button pin as a input:
  	pinMode(buttonPin, INPUT);
  	// initialize the LED as an output:
  	pinMode(ledPin, OUTPUT);
  	// initialize serial communication:
  
  if (debugSerial == true)
  	{
     	Serial.begin(9600);   
  	}
  
    	// CPU Sleep Modes 
  		// SM2 SM1 SM0 Sleep Mode
  		// 0    0  0 Idle
  		// 0    0  1 ADC Noise Reduction
 	 	// 0    1  0 Power-down
 	 	// 0    1  1 Power-save
 		// 1    0  0 Reserved
  		// 1    0  1 Reserved
  		// 1    1  0 Standby(1)

  	cbi( SMCR,SE );      // sleep enable, power down mode
  	cbi( SMCR,SM0 );     // power down mode
  	sbi( SMCR,SM1 );     // power down mode
  	cbi( SMCR,SM2 );     // power down mode

  	setup_watchdog(5);
  	
} //end Setup


byte state = 0;




void loop() {
  
if (f_wdt==1) 
    {  // wait for timed out watchdog / flag is set when a watchdog timeout occurs
    		f_wdt=0;       // reset flag 
  
      	// read the pushbutton input pin:
      		buttonState = digitalRead(buttonPin);
  
      		peaceLevel=peaceLevel+1;
  
      // if the state has changed, increment the counter
    if (buttonState == HIGH) 
      	{
       		state=1; 
       		angerLevel++;
       		
       		digitalWrite(ledPin, HIGH);
       			delay((1000/angerLevel)+200); //doesnt perform exactly as expected. order of operations problem?
       	  	myservo.write(servoOpenValue);
    			delay((400/angerLevel)+350);
       		digitalWrite(ledPin, LOW);
       		myservo.write(servoClosedValue);
       			delay(250); //prevents loop from starting over before switch is fully off. 
       	} 
    
    if (peaceLevel >= 25 && angerLevel > 0 ) 
      	{
      		angerLevel--;
      		peaceLevel = 0; 
      	} //machine gradually calms down over time. Every 25 watch dog cycles (1/4 second), drops anger level. 
      
    if (debugSerial == true)
    	{
            Serial.println(peaceLevel);  
    	}
      
    }

	pinMode(ledPin, INPUT);//set as input to save power
   	system_sleep();
   	pinMode(ledPin, OUTPUT);//return ledPin to former state
  
   
} //end Loop















// ****************************************************************  
// set system into the sleep state 
// system wakes up when wtchdog is timed out
void system_sleep() {

  cbi(ADCSRA,ADEN);                    // switch Analog to Digitalconverter OFF

  set_sleep_mode(SLEEP_MODE_PWR_DOWN); // sleep mode is set here
  sleep_enable();

  sleep_mode();                        // System sleeps here

    sleep_disable();                     // System continues execution here when watchdog timed out 
    sbi(ADCSRA,ADEN);                    // switch Analog to Digitalconverter ON

}


//****************************************************************
// 0=16ms, 1=32ms,2=64ms,3=128ms,4=250ms,5=500ms
// 6=1 sec,7=2 sec, 8=4 sec, 9= 8sec
void setup_watchdog(int ii) {

  byte bb;
  int ww;
  if (ii > 9 ) ii=9;
  bb=ii & 7;
  if (ii > 7) bb|= (1<<5);
  bb|= (1<<WDCE);
  ww=bb;
 // Serial.println(ww);


  MCUSR &= ~(1<<WDRF);
  // start timed sequence
  WDTCSR |= (1<<WDCE) | (1<<WDE);
  // set new watchdog timeout value
  WDTCSR = bb;
  WDTCSR |= _BV(WDIE);


}
//****************************************************************  
// Watchdog Interrupt Service / is executed when  watchdog timed out
ISR(WDT_vect) {
  f_wdt=1;  // set global flag
}









