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
      ;
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
