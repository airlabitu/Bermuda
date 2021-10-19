import controlP5.*;
import processing.serial.*;

import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress myRemoteLocation;

Serial MyPort; // Serial object



void setup() {
  size(900, 800);
  background(0);
  noStroke();
  println(Serial.list());
  frameRate(1);
  
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);

  

  
  
  // --- CONNECTION TO SERIAL DEVICES ---
  for (int i = 0; i < Serial.list().length; i++){ // Arduino connected to universe 2
    println(Serial.list()[i]);
    if (Serial.list()[i].indexOf("/dev/tty.usb") != -1) {
      println("Serial connection to: ", Serial.list()[i]);
      MyPort = new Serial(this, Serial.list()[i], 9600);
    }
  }
  /*
  MyPort.write("4c255w");
  MyPort.write(""+1 + "c" + 255 + "w");
  MyPort.write(""+2 + "c" + 0 + "w");
  MyPort.write(""+3 + "c" + 0 + "w");
  */
}




void draw() {
  //MyPort.write((DimmBlockAddresses[i]) + "c" + (int)(a[i]*255) + "w");
  //MyPort.write("4c255w");
  //MyPort.write(""+1 + "c" + 0 + "w");
  //MyPort.write(""+2 + "c" + 0 + "w");
  //MyPort.write(""+3 + "c" + 0 + "w");
}

/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  if(theOscMessage.checkAddrPattern("/bermudaDMX")==true) {
    /* check if the typetag is the right one. */
    if(theOscMessage.checkTypetag("ii")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      int DMXAddress = theOscMessage.get(0).intValue();  
      int DMXValue = theOscMessage.get(1).intValue();
      
      //MyPort.write("4c255w"); // plano spot alpha channel
      MyPort.write(""+ DMXAddress + "c" + DMXValue + "w");
      println(" DMX address: "+DMXAddress+", "+DMXValue);
      return;
    }  
  } 
  /* print the address pattern and the typetag of the received OscMessage */
  print("### received an osc message.");
  print(" addrpattern: "+theOscMessage.addrPattern());
  println(" typetag: "+theOscMessage.typetag());
}

void mouseReleased(){
  //MyPort.write(""+7 + "c" + 10 + "w");
}