/*
 © 2020 Alex Harding
 
 Physics Clock by Alex Harding
 
 www.alexharding.io
 https://hackaday.io/project/176037-concrete-physics-clock
 https://github.com/arcadeperfect/Physics-Clock-Processing
 
 Originally based on Dan Shiffman's "boxes" example for his Box2D wrapper for processing:
 https://github.com/shiffman/Box2D-for-Processing/tree/master/Box2D-for-Processing/dist/box2d_processing/examples/Boxes
 
 */



// Class to handle the functionality of the falling numbers
// Originally derrived from Dans Shiffman's example

class Number {

  // We need to keep track of a Body and a width and height
  Body bdy;

  int value;

  int filter_group;
  int filter_mask_bits;

  color thisTextColor;
  float body_w; // width of body
  float body_h; // height of body
  float text_x;
  float text_y;
  float yOff;

  float previousX;  // check for movement, delete if no movement for too long
  float previousY;
  int lastMoved;
  int stillLife = 1000*60*screenSaverTime;

  int secCol;
  String kind;
  float hue = 0;

  float previousMillis;
  //int initTime;
  int initMillis;
  int totalLife;

  float density;
  float friction;
  float txtSize;
  float restitution;


  Number(float x, float y, String time_kind) {

    lastMoved = millis();
    previousMillis = 0;
    lifeCount += 1;
    initMillis = millis();
    kind = time_kind;
    secCol = int(random(0, 255));
    textAlign(CENTER, CENTER);

    switch(kind) {

      case("second"):

      value = second();
      colorMode(RGB);
      txtSize = secondSize;
      thisTextColor = color(255, 255, 255);
      density = second_density;
      friction = second_friction;
      restitution = second_restitution;
      totalLife = 1000*60*60; //seconds last 1 hour
      break;

      case("minute"):

      value = minute();
      txtSize = minuteSize;
      density = minute_density;
      friction = minute_friction;
      restitution = minute_restitution;
      totalLife = 1000*60*60*3; //minutes last 3 hours
      filter_mask_bits = edgeMask;
      break;

      case("hour"):
      value = hour();
      txtSize = hourSize;
      colorMode(RGB);
      thisTextColor = color(0, 255, 255);
      density = hour_density;
      friction = hour_friction;
      totalLife = 1000*60*60*5; //hours last 5 hours
      restitution = hour_restitution;
      filter_mask_bits = edgeMask;
      break;
    }

    getTextBounds(str(value));

    // Add the box to the box2d world
    makeBody(new Vec2(x, y), body_w, body_h);
  }

  // This function removes the particle from the box2d world
  void killBody() {
    box2d.destroyBody(bdy);
    deathCount ++;
    println("death", deathCount);
  }

  // Is the particle ready for deletion?
  boolean done() {
    // Let's find the screen position of the particle
    Vec2 pos = box2d.getBodyPixelCoord(bdy);

    // Is it off the bottom of the screen? // or off to the side?

    if (pos.y > height+body_w*body_h || pos.x < 0-body_w*body_h || pos.x > width+body_w*body_h) {
      killBody();
      return true;

      // Had number moved within screensaver duration, and is screensaver set to true?
    } else if (screenSaver && millis() - lastMoved > stillLife) {
      killBody();
      return true;

      // Has number reached max life and is killAfterLifetime set to true?
    } else if (killAfterLifetime && millis() - initMillis > totalLife) {
      println(millis() - initMillis);
      killBody();
      return true;
    }
    return false;
  }


  void display() {

    setMasks();

    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(bdy);
    // Get its angle of rotation
    float a = bdy.getAngle();

    // draw the text
    pushMatrix();
    textAlign(CENTER, CENTER);
    translate(pos.x, pos.y);
    rotate(-a);
    noFill();
    stroke(200);
    translate(0, -yOff);
    fill(175);
    textFont(numberFont);
    setColours();
    String txt = str(value);
    textSize(txtSize);

    text(txt, 0, 0);
    colorMode(RGB);
    popMatrix();

    // check for movement (for screensaver reasons)
    float thresh = 0.1;
    if (abs(previousX - pos.x) > thresh || abs(previousY - pos.y) > thresh) {

      lastMoved = millis();
    }
    previousX = pos.x;
    previousY = pos.y;
  }


  // Add the rectangle to the box2d world
  void makeBody(Vec2 center, float w_, float h_) {

    // Define a polygon (this is what we use for a rectangle)
    PolygonShape sd = new PolygonShape();
    float box2dW = box2d.scalarPixelsToWorld(w_/2);
    float box2dH = box2d.scalarPixelsToWorld(h_/2);
    sd.setAsBox(box2dW, box2dH);

    // Define a fixture
    FixtureDef fd = new FixtureDef();
    fd.shape = sd;
    // Parameters that affect physics
    fd.density = density;
    fd.friction = friction;
    fd.restitution = restitution;

    fd.filter.groupIndex = (1);
    fd.filter.maskBits = filter_mask_bits;

    // Define the body and make it from the shape
    BodyDef bd = new BodyDef();
    bd.type = BodyType.DYNAMIC;
    bd.position.set(box2d.coordPixelsToWorld(center));

    bdy = box2d.createBody(bd);
    bdy.createFixture(fd);

    // Give it some initial random velocity
    bdy.setLinearVelocity(new Vec2(random(-5, 5), random(2, 5)));
    bdy.setAngularVelocity(random(-5, 5));
  }

  void getTextBounds(String txt) {

    textFont(numberFont);
    textSize(txtSize);
    float txtW = textWidth(txt);
    float txtH = textAscent();
    yOff = txtSize*0.05;
    body_w = txtW-txtH*0.2;
    body_h = txtH*0.86;
  }

  void setMasks() {
    switch(kind) {
      case("second"):
      break;

      case("minute"):
      if (millis() - initMillis > 1000*60) {
        Filter filt = new Filter();
        filt.groupIndex = 1;
        filt.maskBits = 0;
        bdy.getFixtureList().setFilterData(filt);
      }
      break;

      case("hour"):
      if (millis() - initMillis > 1000*60*60) {
        Filter filt = new Filter();
        filt.groupIndex = 1;
        filt.maskBits = 0;
        bdy.getFixtureList().setFilterData(filt);
      }

      if (millis() - initMillis > 1000*60*3) {
      }
      break;
    }
  }

  void setColours() {
    float sat;
    switch(kind) {

      // second colours

      case("second"):
      fill(255);
      break;


      // minute colours

      case("minute"):
      colorMode(HSB);

      // remap age in milliseconds to a descending saturation value
      // 60000 milis = 1 minute
      // so it is map(age-in-millis, start age, end age, start saturation, end saturation)
      // this will fade from start saturation to end saturation over the specified number of millis

      sat = map(millis()-initMillis, 0, 60000*6, 150, 0); // remap across 4 minutes

      sat = constrain(sat, 0, 255);

      fill(210, sat, 255);
      noStroke();
      colorMode(RGB);
      break;


      // hour colours

      case("hour"):

      colorMode(HSB);

      // remap age in milliseconds to a descending saturation value
      // 60000 milis = 1 minute
      // so it is map(age-in-millis, start age, end age, start saturation, end saturation)
      // this will fade from start saturation to end saturation over the specified number of millis

      sat = map(millis()-initMillis, 0, 60000*60*4, 200, 0); // remap across 60*4 minutes   

      sat = constrain(sat, 0, 255);


      fill(100, sat, 255);
      noStroke();
      colorMode(RGB);

      break;
    }
  }
}
