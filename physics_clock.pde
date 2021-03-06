/*

© 2021 Alex Harding

Physics Clock by Alex Harding

www.alexharding.io
https://hackaday.io/project/176037-concrete-physics-clock
https://github.com/arcadeperfect/phys-clock

Originally based on Dan Shiffman's "boxes" example for his Box2D wrapper for processing:
https://github.com/shiffman/Box2D-for-Processing/tree/master/Box2D-for-Processing/dist/box2d_processing/examples/Boxes

*/


import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;

/*------------------------------------------------------------------- */
/*----------------------- Editable parameters ----------------------- */

boolean drawFloor = true;         // visualise floor
boolean debug = false;            // various debug visualisations
boolean mouseControll = true;     // controll gravity direction with mouse

float floorBoundaryAngle = 110;   // how wide the floor is, measured as an angle from a point in the center. This can be animated at runtime.

// second number parameters

float secondSize = 50;
float second_density = 1;
float second_friction = 0.3;
float second_restitution = 0.5;

// minute number parameters

float minuteSize = 100*1;
float minute_density = 25;
float minute_friction = 0.3;
float minute_restitution = 0.4;

// hour number parameters

float hourSize = 200;
float hour_density = 52;
float hour_friction = 0.3;
float hour_restitution = 0.3;

// gravity multiplyer

float gravMult = 10;

/*------------------------------------------------------------------- */
/*------------------------------------------------------------------- */

int lastMillis = 0;
PFont numberFont;
int previous_purge;

// box2d collision masks -- used to prevent current hour and minute from falling off the world until they are no longer needed
int edgeMask = 0x0004;
int floorMask = 0x0001;

// A reference to our box2d world
Box2DProcessing box2d;

RotatingBoundryController rot_bounds;
PVector down = new PVector();
ArrayList<Number> numbers;

int hour;
int previous_hour;

int minute; 
int previous_minute;

int second;
int previous_second;

boolean init;

int deathCount = 0;
int lifeCount = 0;


void setup() {

  //fullScreen(P3D);
  size(800, 800, P3D);

  numberFont = createFont("Consolas", 500);   // use any font but the collision boxes for the numbers might not line up

  textSize(200);
  fill(255, 0, 0);
  stroke(0, 255);

  frameRate(60);  // needed to work in big sur for some reason
  pixelDensity(2); // only for macs

  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();

  rot_bounds = new RotatingBoundryController();   // controls the floor

  // Create ArrayLists	
  numbers = new ArrayList<Number>();

  previous_minute = minute();
  previous_second = second();
  previous_hour = hour();

  init = true; // so we can know when we're running the first time later on

  // static edge boundaries - used for detecting intersections
  LineBoundary b1 = new LineBoundary(new PVector(0, 0), new PVector(width, 0), 0);
  LineBoundary b2 = new LineBoundary(new PVector(width, 0), new PVector(width, height), 0);
  LineBoundary b3 = new LineBoundary(new PVector(width, height), new PVector(0, height), 0);
  LineBoundary b4 = new LineBoundary(new PVector(0, height), new PVector(0, 0), 0);
}


void draw() {

  background(0);

  // We must always step through time!
  box2d.step(1.0/60, 8, 3);
  //box2d.step();


/*------------------------------------------------------------------- */
/*----------------------- Gravity controller ------------------------ */

  // for debugging, you can control it with mouse position

  if (mouseControll) {
    PVector mouseVector = PVector.fromAngle(map(mouseX, 0, width, 0, TWO_PI));
    down = mouseVector;
  } else {
    
  // Otherwise set this vector with whatever input source you want, ie. IMU or knob
  
    down = new PVector(0, 1); // default to screen down
  }

/*------------------------------------------------------------------- */
/*------------------------------------------------------------------- */


  box2d.setGravity(down.x*gravMult, -down.y*gravMult);
  rot_bounds.update(down);  // update rotatingBoundaryController, to update down vector also to draw bounds if desired (todo refactor)


  // init with hour and minute (runs only on first loop)
  
  if (init) {  
    Number s = new Number(width/2-(width/4), 30, "second");
    numbers.add(s);
    Number h = new Number(width/2, 30, "hour");
    numbers.add(h);
    Number m = new Number(width/2+(width/4), 30, "minute");
    numbers.add(m);
    init = false;

  }


  // Create second instance once per second
  if (second() != previous_second) {
    //if(millis() - lastMillis > 250){
    Number p = new Number(width/2, 30, "second");
    numbers.add(p);
    previous_second = second();
    //lastMillis = millis();
  }

  //// Create minutes
  if (minute() != previous_minute) {
    Number p = new Number(width/2, 30, "minute");
    numbers.add(p);
    previous_minute = minute();
  }

  //// Create hours
  if (hour() != previous_hour) {
    Number p = new Number(width/2, 30, "hour");
    numbers.add(p);
    previous_hour = hour();
  }


  // Display all the numbers
  for (Number b : numbers) {
    b.display();
  }


  // Boxes that leave the screen, we delete them
  // (note they have to be deleted from both the box2d world and our list)
  for (int i = numbers.size()-1; i >= 0; i--) {
    Number b = numbers.get(i);
    if (b.done()) {
      numbers.remove(i);
    }
  }

  // Display some numbers for debugging
  if (debug) {
    textSize(10);
    fill(255);
    text(lifeCount, 5, 20);
    text(deathCount, 5, 40);
    text(numbers.size(), 5, 60);
  }
}
