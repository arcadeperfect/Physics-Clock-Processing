/*

© 2020 Alex Harding

Physics Clock by Alex Harding

www.alexharding.io
https://hackaday.io/project/176037-concrete-physics-clock
https://github.com/arcadeperfect/Physics-Clock-Processing

Originally based on Dan Shiffman's "boxes" example for his Box2D wrapper for processing:
https://github.com/shiffman/Box2D-for-Processing/tree/master/Box2D-for-Processing/dist/box2d_processing/examples/Boxes

*/

// A lot of this is adapted from Dan Shiffman's examples

// Box2D collider that can be defined with 2 verts and a width, ie like a processing line
// Wrapper around Box2D box collider, essentially a very long thin box
// Can also be moved

class LineBoundary {



  Body bdy;
  BodyDef bdef;
  PolygonShape shpdef;

  float w;
  float h = 5;
  float a;
  PVector pos;
  PVector p1;
  PVector p2;

  int filter_group_index;

  LineBoundary(PVector _p1, PVector _p2, int _filter_group_index) {

    filter_group_index = _filter_group_index;

    p1 = _p1;
    p2 = _p2;
    //w = _w;

    setAngleFromPoints(p1, p2);
    setPosFromPoints(p1, p2);
    this.setWidthFromPoints(p1, p2);

    // Define the polygon
    PolygonShape sd = new PolygonShape();
    // Figure out the box2d coordinates
    float box2dW = box2d.scalarPixelsToWorld(w)/2;
    float box2dH = box2d.scalarPixelsToWorld(h)/2;
    // We're just a box
    sd.setAsBox(box2dW, box2dH);


    // Create the body
    BodyDef bd = new BodyDef();
    bd.type = BodyType.STATIC;
    bd.position.set(box2d.coordPixelsToWorld(new Vec2(pos.x, pos.y)));
    bd.angle= a;
    bdy = box2d.createBody(bd);

    // Attached the shape to the body using a Fixture
    bdy.createFixture(sd, 1);

    //  bdy.getFixtureList().setFilterData(new Filter(0x2,0x2,0x2));
    //}
    Filter filt = new Filter();
    //filt.maskBits = 1;
    filt.groupIndex = filter_group_index;
    filt.categoryBits = 0x0004;
    bdy.getFixtureList().setFilterData(filt);
  }

  void setTransform(PVector _pos, float _a) {
    pos = _pos;
    a = _a;
    bdy.setTransform(box2d.coordPixelsToWorld(new Vec2(pos.x, pos.y)), -a);
  }

  void setScale(float _w, float _h) {
    w = _w;
    h = _h;
    float box2dW = box2d.scalarPixelsToWorld(w/2);
    float box2dH = box2d.scalarPixelsToWorld(h/2);
    shpdef.setAsBox(box2dW, box2dH);
    bdy.destroyFixture(bdy.getFixtureList());
    bdy.createFixture(shpdef, 1);
  }

  void setAngle(float _a) {
    a = _a;
    bdy.setTransform(box2d.coordPixelsToWorld(new Vec2(pos.x, pos.y)), radians(_a));
  }

  void setAngleFromPoints(PVector p1, PVector p2) {
    a = radians(atan2(p2.y - p1.y, p2.x - p1.x) * 180 / PI);
  }

  void setPosFromPoints(PVector p1, PVector p2) {
    pos = PVector.add(PVector.mult(PVector.sub(p2, p1), 0.5), p1);
  }

  void setWidthFromPoints(PVector p1, PVector p2) {
    w = vDist(p1, p2);
  }

  void killBody() {
    box2d.destroyBody(bdy);
  }



  ////// CALL THIS TO SET POSITION AS A LINE ///////
  void update(PVector _p1, PVector _p2) {
    p1 = _p1;
    p2 = _p2;
    this.setPosFromPoints(p1, p2);
    this.setAngleFromPoints(p1, p2);
    this.setWidthFromPoints(p1, p2);

    this.setTransform(pos, a);
    this.setScale(w/2, h/2);
  }

  void draw() {
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(a);
    rectMode(CENTER);
    //fill(200);
    rect(0, 0, w, h);
    popMatrix();
  }
}
