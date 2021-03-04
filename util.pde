


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
