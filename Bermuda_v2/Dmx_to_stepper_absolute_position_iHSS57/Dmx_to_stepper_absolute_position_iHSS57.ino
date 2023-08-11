// - - - - -
// Code by Halfdan Hauch Jensen, Intermedia Lab IT University of Copenhagen
// halj@itu.dk
// 
// Example code for controlling a motor over DMX
// Software: The code uses the AccelStepper & DMXSerial library
// Hardware: DMX shield (CTC-DRA-13-R2), Motor driver (H-Bridge L298N)
//    - Connections: see documentation in sketch folder
// 
// DMX Address 1 maps to aboslute position of stepper motor, mapped from DMX 0-255 to motor steps 0 - 1000 (STEPPER_TOTAL_DISTANCE)
// - - - - -

/*
Motor controller iHSS57
step setting 
*/

#include <AccelStepper.h>
#include <DMXSerial.h>
/*
#define HALFSTEP 8
#define motorPin1  8    // INA on ULN2003 ==> Blue   on 28BYJ-48
#define motorPin2  10   // INC on ULN2004 ==> Pink   on 28BYJ-48
#define motorPin3  9    // INB on ULN2003 ==> Yellow on 28BYJ-48
#define motorPin4  11   // IND on ULN2003 ==> Orange on 28BYJ-48
*/

const int stepPin = 8;
const int directionPin = 9;

#define DMX_ADDRESS 2   // ## defines the DMX address

//AccelStepper stepper(HALFSTEP, motorPin1, motorPin3, motorPin2, motorPin4);
AccelStepper stepper(AccelStepper::DRIVER, stepPin, directionPin);

// SETTINGS
// 230 cm travel in approc 9 sec
// stepper driver - (5000 steps/revolution) 5:off 6:off 7:on 8:off
// code - STEPPER_TOTAL_DISTANCE = 100000 

const int STEPPER_TOTAL_DISTANCE = 100000;
int newPosition = 0;

int state = 0; 
// 0 : free movement
// 1 : stopping
// 2 : retract from stop button
// 3 : set to new zero

void setup () {


  DMXSerial.init(DMXReceiver);
  // set a default value
  DMXSerial.write(DMX_ADDRESS, 0);
  
  stepper.setMaxSpeed(5000);  // max speed
  stepper.setAcceleration(10000); // acceleration
  //stepper.moveTo(1000); // absolute position to move to, just for testing at start up.  

  pinMode(4, INPUT_PULLUP);
    
}


void loop() {
  int sensorVal = digitalRead(4);
  stepper.run();
  switch(state){
    case 0:
      if (sensorVal == 1){
        // Calculate how long no data packet was received
        unsigned long lastPacket = DMXSerial.noDataSince();
        // check if DMX is still being received
        if (lastPacket < 5000) { 
          newPosition = map(DMXSerial.read(DMX_ADDRESS), 0, 255, 0, STEPPER_TOTAL_DISTANCE); // calculate new position based on DMX data
        stepper.moveTo(newPosition); // go to new position
        }
      }

      else { // button is pressed
        stepper.stop();
        stepper.setCurrentPosition(100);
        state = 1;
      }
      break;
    
    case 1:
      stepper.run();
      stepper.moveTo(0);
      //if (sensorVal == 1) state = 2;
      
      /*if (!stepper.isRunning()){ // wait for stepper to stop (it de-accelerates)
        state = 2;
      }*/
      //stepper.run();
      break;
    
    case 2:
      //stepper.run();
      //stepper.setCurrentPosition(0);
      //stepper.moveTo(200);
      //stepper.move(500);
      //stepper.run();
      //state = 3;
      break;
    
    /*
    case 3:
      if (!stepper.isRunning()){
        stepper.setCurrentPosition(0);
        state = 4;
      }
      break;
    
    case 4:
      if (sensorVal = 0) state = 0;
      break;
    */
  }

  /*
  // Calculate how long no data packet was received
  unsigned long lastPacket = DMXSerial.noDataSince();
  
  // check if DMX is still being received
  if (lastPacket < 5000) { 
    newPosition = map(DMXSerial.read(DMX_ADDRESS), 0, 255, 0, STEPPER_TOTAL_DISTANCE); // calculate new position based on DMX data
    stepper.moveTo(newPosition); // go to new position
  }
  */
}
