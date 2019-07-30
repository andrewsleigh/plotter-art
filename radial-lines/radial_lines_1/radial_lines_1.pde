//Andrew Sleigh
//2019-07-30
//https://andrewsleigh.com

// make an array of vectors to subject to our lines
int numberOfLines = 100;
float lineLength;
PVector lineOrigin;
float centerOffset = 10;
float originRandomnessX = 10;
float originRandomnessY = 10;
float lengthRandomness = 10;
float rotationRandomness = 0.02;

import controlP5.*;
ControlP5 cp5; // Declare ControlP5 object  - mine id called cp5
// PDF export  ----------------------------------------------------
import processing.pdf.*;
boolean record;

// PVector[] radialLines = new PVector[numberOfLines];

// A3 sizing
int canvasWidth = 594 * 2;
int canvasHeight = 420 * 2;

// noise
float lengthNoiseStart = 100;
float lengthNoiseOffset = 0.0;


void settings() {
  // As of Processing 3.0, to use variables as the parameters to size() function, place the size() function within the settings() function (instead of setup()).
  size(canvasWidth, canvasHeight);
}

void setup() {

  // GUI -----------------------------------------------------------------
  cp5 = new ControlP5(this); // Initialise ControlP5 object (called cp5)

  cp5.addSlider("numberOfLines") 
    .setPosition(10, 10)
    .setSize(200, 20)
    .setNumberOfTickMarks(50)
    .setRange(1, 200) 
    .setValue(10)
    ;

  cp5.addSlider("lineLength") 
    .setPosition(10, 40)
    .setSize(200, 20)   
    .setRange(-200, 500) 
    .setValue(10)
    ;

  cp5.addSlider("lengthRandomness") 
    .setPosition(10, 70)
    .setSize(200, 20)   
    .setRange(0, 2) 
    .setValue(0)
    ;

  cp5.addSlider("lengthNoiseOffset") 
    .setPosition(10, 100)
    .setSize(200, 20)   
    .setRange(0, 0.5) 
    .setValue(0)
    ;
    
    
    
    
 cp5.addSlider("centerOffset") 
    .setPosition(10, 130)
    .setSize(200, 20)   
    .setRange(-100, 500) 
    .setValue(0)
    ;
  
  cp5.addSlider("originRandomnessX") 
    .setPosition(10, 160)
    .setSize(200, 20)   
    .setRange(0, 40) 
    .setValue(0)
    ;

  cp5.addSlider("originRandomnessY") 
    .setPosition(10, 190)
    .setSize(200, 20)   
    .setRange(0, 40) 
    .setValue(0)
    ;
    
  cp5.addSlider("rotationRandomness") 
    .setPosition(10, 220)
    .setSize(200, 20)   
    .setRange(0, 0.5) 
    .setValue(0)
    ;    
    
    
    
}




void draw() {

  background(200);
  frameRate(30);
  
    if (record) {
    // Note that #### will be replaced with the frame number. Fancy!
    beginRecord(PDF, "frame-####.pdf");
  }

  numberOfLines = round((cp5.getValue("numberOfLines")));


  stroke(000);
  pushMatrix();

  // move origin to center
  translate(canvasWidth/2, canvasHeight/2);



  for (int i=0; i < numberOfLines; i++) {
    
    centerOffset = (cp5.getValue("centerOffset"));
    lineLength = (cp5.getValue("lineLength"));
    lengthRandomness = (cp5.getValue("lengthRandomness"));
    originRandomnessX = (cp5.getValue("originRandomnessX"));
    originRandomnessY = (cp5.getValue("originRandomnessY"));
    rotationRandomness = (cp5.getValue("rotationRandomness"));
    lengthNoiseOffset = (cp5.getValue("lengthNoiseOffset"));


    // move along noise spectrum
   // lengthNoiseOffset += .2;
   lengthNoiseStart += lengthNoiseOffset;

    lineOrigin = new PVector(0, 0);
    lineOrigin.set(random(-originRandomnessX, originRandomnessX), random(-originRandomnessY, originRandomnessY));
    
    
    
    
    lineOrigin.add(centerOffset,0);

    
    lineLength = (lineLength + (lineLength * noise(lengthNoiseStart))) * (1 + random(-lengthRandomness, lengthRandomness));


    line(lineOrigin.x, lineOrigin.y, lineLength, 0);
    rotate((2*PI/numberOfLines) * (1 + random(-rotationRandomness, rotationRandomness)));
  }

  popMatrix();
  
  if (record) {
    endRecord();
    record = false;
  }
}


void keyPressed() {
  if (key == 'p' || key == 'P') {
    record = true;
  }
}
