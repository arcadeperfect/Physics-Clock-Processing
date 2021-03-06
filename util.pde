/*

© 2021 Alex Harding

Physics Clock by Alex Harding

www.alexharding.io
https://hackaday.io/project/176037-concrete-physics-clock
https://github.com/arcadeperfect/phys-clock

Originally based on Dan Shiffman's "boxes" example for his Box2D wrapper for processing:
https://github.com/shiffman/Box2D-for-Processing/tree/master/Box2D-for-Processing/dist/box2d_processing/examples/Boxes

*/

// Utility functions

void vLine(PVector p1, PVector p2) {
  line(p1.x, p1.y, p2.x, p2.y);
}

void vPoint(PVector p) {
  point(p.x, p.y);
}

void magLine(PVector pos, PVector dir, float mag) {

  // draw line from pos with diretion dir and magnitude mag

  pushMatrix();
  translate(pos.x, pos.y);
  line(0, 0, dir.x*mag, dir.y*mag);
  popMatrix();
}

float vDist(PVector p1, PVector p2) {
  return dist(p1.x, p1.y, p2.x, p2.y);
}
