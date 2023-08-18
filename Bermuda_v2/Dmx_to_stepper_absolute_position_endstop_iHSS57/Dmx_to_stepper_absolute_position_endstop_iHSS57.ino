// This code is developed at AIR LAB ITU (airlab.itu.dk) by Halfdan Hauch Jensen (halj@itu.dk).
// It uses an Arduino UNO with a DMX shield, a stepper motor with a IHSS57 driver, and some additional components, to make a DMX controlled winch (motor)

/*
  Parts:
  - Arduino UNO
  - DMX shield (CTC-DRA-13-R2)
  - 3 state switch
  - 2 x pushbuttons (endstop)
  - Stepper motor (57HS76-3004A08-D21 HL TNC)
  - Power supply 36v DC 6.5 Amp
  - various hardware parts for the physical constructions
  - various wires and and connectors
*/

#include <AccelStepper.h>
#include <DMXSerial.h>

#define DMX_ADDRESS 2   // ## defines the DMX address

const int stepPin = 8;
const int directionPin = 9;

const int TOTAL_DISTANCE = 10000; // total travel distance while running DMX commands

AccelStepper stepper(AccelStepper::DRIVER, stepPin, directionPin);

int newPosition = 0;

void setup() {
  
  //Serial.begin(9600);
  stepper.setMaxSpeed(3000);      // ## max speed // higher number faster max speed
  stepper.setAcceleration(3000);  // ## acceleration // higher number faster acceleration
  stepper.setCurrentPosition(0);
  
  pinMode(7, INPUT_PULLUP); // initialize button endstop button pin

  // if endstop is not pressed - move up until it pressed
  stepper.setSpeed(-500); 
  while(digitalRead(7) == HIGH){
    stepper.runSpeed();
  }
  delay(500);

  // move down until endstop is released
  stepper.setSpeed(500);
  while(digitalRead(7) == LOW){
    stepper.runSpeed();
  }
  delay(500);
  
  // move a bit down to get to the final 0 point
  stepper.setCurrentPosition(0);
  stepper.moveTo(2000); // ## distance to move down
  while(stepper.distanceToGo() != 0){
    stepper.run();
  }
  stepper.setCurrentPosition(0);
  delay(500);

  
  // After all stepper init is done, setup the DMX shield
  // NB : THIS MUST HAPPEN AFTER THE STEPPER ENDSTOP SEQUENCE IS DONE, ELSE IT WILL MAKE ERRORS
  
  // put your setup code here, to run once:
  DMXSerial.init(DMXReceiver);
  // set a default value
  DMXSerial.write(DMX_ADDRESS, 0);

}

void loop() {

    // Read DMX and move stepper as long as the endstop is not pressed 
    if (digitalRead(7) == HIGH){ // 
      // put your main code here, to run repeatedly:
      unsigned long lastPacket = DMXSerial.noDataSince();
      // check if DMX is still being received
      if (lastPacket < 5000) {
        newPosition = map(DMXSerial.read(DMX_ADDRESS), 0, 255, 0, TOTAL_DISTANCE); // ## calculate new position based on DMX data
        stepper.moveTo(newPosition); // go to new position (this is negative since the direction have inverted by some reasión at this point)
      }
      stepper.run();
    }

}
