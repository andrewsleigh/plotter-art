//Andrew Sleigh
//2019-07-30
//https://andrewsleigh.com


// Derived from simple_vector_tests_7
// testing HPGL library
// https://github.com/ciaron/HPGLGraphics




import controlP5.*;
ControlP5 cp5; // Declare ControlP5 object  - mine is called cp5

//// PDF export  ----------------------------------------------------
//import processing.pdf.*;
//boolean record;


// -----------------------------------------------------------------------------
// HPGL Library
import hpglgraphics.*;
HPGLGraphics hpgl;


PVector startPoint;
//PVector originalVector;



//Current rows and cols
int row = 0;
int col = 0;
int cols = 36; //Total cols. Current column is stored in 'col'
int rows = 36; //Total rows. Current row is stored in 'row'


// defaults for initial points
float localWindSpeed = 10;
float locationJitter = 1;
float effectOfWinds = 1;

// make an array of vectors to subject to our wind source 
PVector[] windTargets = new PVector[cols*rows];


int targetSpacing = 17;
int canvasWidth = 594 * 2;
int canvasHeight = 420 * 2;

// work out the border offset from the spacing and size of the canvas

float gridStartX = 0.5 * (canvasWidth - (targetSpacing *(cols - 1)));
float gridStartY = 0.5 * (canvasHeight - (targetSpacing *(rows - 1)));
;


// wind sources
PVector windStartPoint1;
PVector windVector1;

PVector windStartPoint2;
PVector windVector2;


PVector windStartPoint3;
PVector windVector3;


// calculate effect of distant winds
float maxPossibleDistanceFromWindSource;

float distanceFromWindSource1;
float proportionalDistanceFromWindSource1;

float distanceFromWindSource2;
float proportionalDistanceFromWindSource2;

float distanceFromWindSource3;
float proportionalDistanceFromWindSource3;

// create an empty Array of mouse position PVectors
PVector[] mousePositions = new PVector[6];

// ArrayList<PVector> mousePositions = new ArrayList<PVector>(); // this is better for arrays of unknown size

// do it a dumber way
//PVector mouseWind1Start;
//PVector mouseWind1End;
//PVector mouseWind2Start;
//PVector mouseWind2End;
//PVector mouseWind3Start;
//PVector mouseWind3End;

int mouseClickCounter = 0;


// controlling which winds are set

int windSetter = -1; // can't use 0 as default value

Boolean mouseWind1Set = false;
Boolean mouseWind2Set = false;
Boolean mouseWind3Set = false;

void settings() {
  // As of Processing 3.0, to use variables as the parameters to size() function, place the size() function within the settings() function (instead of setup()).
  size(canvasWidth, canvasHeight);
}


void setup() {

  // GUI -----------------------------------------------------------------
  cp5 = new ControlP5(this); // Initialise ControlP5 object (called cp5)

  cp5.addSlider("LocalWindSpeed") 
    .setPosition(10, 10)
    .setSize(200, 20)
    .setRange(1, 20) 
    .setValue(10)
    ;

  cp5.addSlider("LocationJitter") 
    .setPosition(10, 40)
    .setSize(200, 20)
    .setRange(0, 5) 
    .setValue(1)
    ;

  cp5.addSlider("effectOfWinds") 
    .setPosition(10, 70)
    .setSize(200, 20)
    .setRange(0, 5) 
    .setValue(1)
    ;

  cp5.addButton("Clear Wind 1")
    .setValue(0)
    .setPosition(10, 100)
    .setSize(60, 19)
    ;

  cp5.addButton("Set Wind 1")
    .setValue(0)
    .setPosition(100, 100)
    .setSize(60, 19)
    ;



  cp5.addButton("Clear Wind 2")
    .setValue(0)
    .setPosition(10, 130)
    .setSize(60, 19)
    ;

  cp5.addButton("Set Wind 2")
    .setValue(0)
    .setPosition(100, 130)
    .setSize(60, 19)
    ;

  cp5.addButton("Clear Wind 3")
    .setValue(0)
    .setPosition(10, 160)
    .setSize(60, 19)
    ;

  cp5.addButton("Set Wind 3")
    .setValue(0)
    .setPosition(100, 160)
    .setSize(60, 19)
    ;


  maxPossibleDistanceFromWindSource = sqrt(sq(width) + (height));


  //startPoint = new PVector(200, 250); // chenge the y value here to move it closer or futher away from the wind source
  //originalVector = new PVector(10, 15); 
  
  // initialise the mouse winds to 0,0 vectors
  for (int m=0; m < mousePositions.length; m++) {
    mousePositions[m] = new PVector(0, 0);
  }
  
  

}


void draw() {
  // noLoop();
  background(200);
  // translate(gridStartX, gridStartY);
  frameRate(20);


    // HPGL (Roland DXY-1350A) coordinate ranges:
  // A4 : 11040 x 7721 (297 x 210 mm)
  // A3 : 16158 x 11040 (420 x 297 mm)
  
  HPGLGraphics hpgl = (HPGLGraphics) createGraphics(width, height, HPGLGraphics.HPGL);
  hpgl.setPaperSize("A4");
  hpgl.setPath("output.hpgl");
  
  // (most) things between begin- and endRecord are written to the .hpgl file
  beginRecord(hpgl);


  //if (record) {
  //  // Note that #### will be replaced with the frame number. Fancy!
  //  beginRecord(PDF, "frame-####.pdf");
  //}

  // draw those lines
  if (mouseWind1Set) {
    stroke(150, 0, 250);
    line(mousePositions[0].x, mousePositions[0].y, mousePositions[1].x, mousePositions[1].y);
    windStartPoint1 = new PVector(mousePositions[0].x, mousePositions[0].y); 
    windVector1 = PVector.sub(mousePositions[1], mousePositions[0]);
  }

  if (mouseWind2Set) {
    stroke(0, 150, 250);
    line(mousePositions[2].x, mousePositions[2].y, mousePositions[3].x, mousePositions[3].y);
    windStartPoint2 = new PVector(mousePositions[2].x, mousePositions[2].y); 
    windVector2 = PVector.sub(mousePositions[3], mousePositions[2]);
  }

  if (mouseWind3Set) {
    stroke(250, 150, 0);
    line(mousePositions[4].x, mousePositions[4].y, mousePositions[5].x, mousePositions[5].y);
    windStartPoint3 = new PVector(mousePositions[4].x, mousePositions[4].y); 
    windVector3 = PVector.sub(mousePositions[5], mousePositions[4]);
  }


  // draw array of targets affected by wind
  stroke(50);
  row = 0;
  col = 0;

  for (int j=0; j < windTargets.length; j++) {


    if (row < rows && col < cols) {
      // get the start point for the current target
      startPoint = new PVector(gridStartX + row*targetSpacing, gridStartY + col*targetSpacing);



      // set the vector for that member of the array

      localWindSpeed = (cp5.getValue("LocalWindSpeed"));


      windTargets[j] = new PVector(localWindSpeed, localWindSpeed);

      // get the distance from this point to the wind source
      if (mouseWind1Set) {
        distanceFromWindSource1 = startPoint.dist(windStartPoint1);
        proportionalDistanceFromWindSource1 = sq(1 - (distanceFromWindSource1 / maxPossibleDistanceFromWindSource));
        PVector windVectorMod1 = PVector.mult(windVector1, proportionalDistanceFromWindSource1);
        PVector windVectorMod1WithEffect = PVector.mult(windVectorMod1, effectOfWinds);
        windTargets[j].add(windVectorMod1WithEffect);
      }

      if (mouseWind2Set) {

        distanceFromWindSource2 = startPoint.dist(windStartPoint2);
        proportionalDistanceFromWindSource2 = sq(1 - (distanceFromWindSource2 / maxPossibleDistanceFromWindSource));
        PVector windVectorMod2 = PVector.mult(windVector2, proportionalDistanceFromWindSource2);
        PVector windVectorMod2WithEffect = PVector.mult(windVectorMod2, effectOfWinds);
        windTargets[j].add(windVectorMod2WithEffect);
      }

      if (mouseWind3Set) {
        distanceFromWindSource3 = startPoint.dist(windStartPoint3);
        proportionalDistanceFromWindSource3 = sq(1 - (distanceFromWindSource3 / maxPossibleDistanceFromWindSource));
        PVector windVectorMod3 = PVector.mult(windVector3, proportionalDistanceFromWindSource3);
        PVector windVectorMod3WithEffect = PVector.mult(windVectorMod3, effectOfWinds);
        windTargets[j].add(windVectorMod3WithEffect);
      }


      // add some noise

      locationJitter = (cp5.getValue("LocationJitter"));


      float xNoise = random(-locationJitter, locationJitter);
      float yNoise = random(-locationJitter, locationJitter);

      line(startPoint.x + xNoise, startPoint.y + yNoise, startPoint.x+windTargets[j].x + xNoise, startPoint.y+windTargets[j].y + yNoise); 

      //increment for next iteration
      if (col < cols) {
        row ++;
        if (row >= rows) {
          col++;
          row = 0;
        }
      }
    }
  }


// hpgl lib
endRecord();

  //if (record) {
  //  endRecord();
  //  record = false;
  //}
}


//void keyPressed() {
//  if (key == 'p' || key == 'P') {
//    record = true;
//  }
//}


// from https://www.kasperkamperman.com/blog/processing-code/controlp5-library-example1/
void controlEvent(ControlEvent theEvent) {

  if (theEvent.isController()) { 
    if (theEvent.getController().getName() == "Clear Wind 1") { 
      mouseWind1Set = false;
    }

    if (theEvent.getController().getName() == "Set Wind 1") { 
      windSetter = 0;
    }

    if (theEvent.getController().getName() == "Clear Wind 2") { 
      mouseWind2Set = false;
    }
    if (theEvent.getController().getName() == "Set Wind 2") { 
      windSetter = 2;
    }

    if (theEvent.getController().getName() == "Clear Wind 3") { 
      mouseWind3Set = false;
    }
    if (theEvent.getController().getName() == "Set Wind 3") { 
      windSetter = 4;
    }
  }
}


void mouseClicked() {

  if ((mouseX > gridStartX) && (mouseY > gridStartY)) {



    switch(windSetter) {
    case 0:
      println("Wind 1 Start selected");
      mousePositions[windSetter].set(mouseX, mouseY);
      windSetter = 1;
      break;

    case 1:
      println("Wind 1 End selected");
      mousePositions[windSetter].set(mouseX, mouseY);
      windSetter = -1;
      mouseWind1Set = true;
      break;

    case 2:
      println("Wind 2 Start selected");
      mousePositions[windSetter].set(mouseX, mouseY);
      windSetter = 3;
      break;

    case 3:
      println("Wind 2 End selected");
      mousePositions[windSetter].set(mouseX, mouseY);
      windSetter = -1;
      mouseWind2Set = true;
      break;

    case 4:
      println("Wind 3 Start selected");
      mousePositions[windSetter].set(mouseX, mouseY);
      windSetter = 5;
      break;

    case 5:
      println("Wind 3 End selected");
      mousePositions[windSetter].set(mouseX, mouseY);
      windSetter = -1;
      mouseWind3Set = true;
      break;


      //if (mouseClickCounter < 2) {
      //  mousePositions[mouseClickCounter].set(mouseX, mouseY);
      //  mouseClickCounter += 1;
      //}
      //mouseWind1Set = true;



    default:
      println("No wind selected");
      //mouseWind1Set = false;
      break;
    }
  }

  //if (mouseClickCounter < 6) {

  //  mousePositions[mouseClickCounter].set(mouseX, mouseY);
  //  if (mouseClickCounter == 1) {
  //    mouseWind1Set = true;
  //  }
  //  if (mouseClickCounter == 3) {
  //    mouseWind2Set = true;
  //  }
  //  if (mouseClickCounter == 5) {
  //    mouseWind3Set = true;
  //  }

  //  mouseClickCounter += 1;
  //}
}
