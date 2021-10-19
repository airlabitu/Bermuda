  
import processing.sound.*;

//import mqtt.*;

import oscP5.*;
import netP5.*;
  
OscP5 oscP5;
NetAddress myRemoteLocation;


//MQTTClient client;

FFT fft;
AudioIn in;
int bands = 16;//256; //was 512
int multiplier = 1024;
long timer = 0;
int interval = 1000;
int count = 0;

float[] spectrum = new float[bands];
float[] average = new float[bands];

int[] dmxkanal = { 1,2,3,7};
//int[] dmxkanal = { 2,4,5,7};

//int z=1;

void setup() {
  size(1200, 360);
  background(255);
  frameRate(25);
  strokeWeight(20);
  
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,12000);
  //myRemoteLocation = new NetAddress("intermedia.itu.dk.local",12000);
  myRemoteLocation = new NetAddress("10.29.19.30",12000);
  
  //client = new MQTTClient(this);
  //client.connect("mqtt://airmqtt.local", "bermudaFFT");

    
  // Create an Input stream which is routed into the Amplitude analyzer
  fft = new FFT(this, bands);
  in = new AudioIn(this, 0);
  
  // start the Audio Input
  in.start();
  
  // patch the AudioIn
  fft.input(in);
}      

void draw() { 
  //background(255);
  fft.analyze(spectrum);
  
  count++;
  
  // add the new spectrum values to the average array
  for(int i = 0; i < bands; i++){
    average[i] += spectrum[i];
  }
  
  // calculate the averages if interval time is hit
  if (millis() > timer + interval){
    timer = millis();
    background(255);
    for(int i = 0; i < bands; i++){
      average[i] = average[i]/count;
      line( i*40, height, i*40, height - average[i]*height*20 );
      
      // send data from selected bands
    if (i < 4){
      int val = min(255,int(average[i]* multiplier));
      OscMessage myMessage = new OscMessage("/bermudaDMX");
      myMessage.add(dmxkanal[i]); /* add an int to the osc message */
      myMessage.add(val); /* add an int to the osc message */
      oscP5.send(myMessage, myRemoteLocation); /* send the message */
    }
    }
    count = 0;
  }
  
  /*
  for(int i = 0; i < bands; i++){
  // The result of the FFT is normalized
  // draw the line for frequency band i scaling it up by 5 to get more amplitude.
  line( i*4, height, i*4, height - spectrum[i]*height*20 );
  } 
  */
  
  
  
  
  //println(message);
  
  //z=z+1;
  //if (z>3){z=1;}
  
  
  
}


void messageReceived(String topic, byte[] payload) {
 //do nothing
}

void connectionLost() {
  println("connection lost");
}
