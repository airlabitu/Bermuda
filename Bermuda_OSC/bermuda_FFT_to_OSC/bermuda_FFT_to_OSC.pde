  
import processing.sound.*;

import mqtt.*;

MQTTClient client;

FFT fft;
AudioIn in;
int bands = 16;//256; //was 512
int multiplier = 1024;
long timer = 0;
int interval = 1000;
int count = 0;

float[] spectrum = new float[bands];
float[] average = new float[bands];

int[] dmxkanal = { 2,4,5};

int z=1;

void setup() {
  size(1200, 360);
  background(255);
  frameRate(25);
  strokeWeight(20);
  
  
    client = new MQTTClient(this);
  client.connect("mqtt://airmqtt.local", "bermudaFFT");

    
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
  
  
  int val = min(255,int(spectrum[z]* multiplier));
  String message = dmxkanal[z-1]+","+val;
  client.publish("airlab_bermuda", message);
  println(message);
  
  z=z+1;
  if (z>3){z=1;}
  
  
}


void messageReceived(String topic, byte[] payload) {
 //do nothing
}

void connectionLost() {
  println("connection lost");
}
