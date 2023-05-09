/*
© 2020 Alex Harding

Physics Clock by Alex Harding

www.alexharding.io
https://hackaday.io/project/176037-concrete-physics-clock
https://github.com/arcadeperfect/Physics-Clock-Processing

Originally based on Dan Shiffman's "boxes" example for his Box2D wrapper for processing:
https://github.com/shiffman/Box2D-for-Processing/tree/master/Box2D-for-Processing/dist/box2d_processing/examples/Boxes

*/


// Helper class to manage lists of line boundaries

class LineBoundaryList {
  ArrayList<LineBoundary> bounds = new ArrayList<LineBoundary>();
  LineBoundaryList() {
  }

  void add(LineBoundary l) {
    bounds.add(l);
  }

  void remove(LineBoundary l) {
    l.killBody();
    bounds.remove(l);
  }

  void clear() {
    for (LineBoundary l : bounds) {
      l.killBody();
    }
    bounds.clear();
  }

  void draw() {
    for (LineBoundary l : bounds) {
      strokeWeight(2);
      fill(255);
      l.draw();
    }
  }
}
