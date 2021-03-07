/*

© 2020 Alex Harding

Physics Clock by Alex Harding

www.alexharding.io
https://hackaday.io/project/176037-concrete-physics-clock
https://github.com/arcadeperfect/Physics-Clock-Processing

Originally based on Dan Shiffman's "boxes" example for his Box2D wrapper for processing:
https://github.com/shiffman/Box2D-for-Processing/tree/master/Box2D-for-Processing/dist/box2d_processing/examples/Boxes

*/


class RotatingBoundryController {
  ArrayList<PVector> boundaryPoints = new ArrayList<PVector>();

  EdgeController edges;
  LineBoundaryList bounds;

  PVector cnt;
  PVector src;
  PVector trg;
  PVector sch = new PVector();

  final PVector n = new PVector(0, -1);
  final PVector e = new PVector(1, 0);
  final PVector s = new PVector(0, 1);
  final PVector w = new PVector(-1, 0);

  Ray ray1;
  Ray ray2;

  RotatingBoundryController() {  

    bounds = new LineBoundaryList();
    cnt = new PVector(width/2, height/2);
    edges = new EdgeController();
    ray1 = new Ray(cnt, PVector.fromAngle(0), true);
    ray2 = new Ray(cnt, PVector.fromAngle(HALF_PI), false);
    println("init rotating boundary controller");
    
  }

  void update(PVector down) {

    //fov = map(mouseX, 0, width, 0, 360);

    stroke(0);
    strokeWeight(1);

    float tempFOV = radians(floorBoundaryAngle/2);

    ray1.setAngle(new PVector(down.x, down.y).rotate(-tempFOV));
    ray2.setAngle(new PVector(down.x, down.y).rotate(tempFOV));

    src = ray1.checkCorners();
    if (src != null) {
      //vPoint(i1);
    } else {
      src = ray1.checkEdges();
    }

    trg = ray2.checkCorners();
    if (trg != null) {
      //vPoint(i1);
    } else {
      trg = ray2.checkEdges();
    }

    this.bounds.clear();             
    this.boundaryPoints.clear();
    this.boundaryPoints.add(src);  
    this.recSearch(src);        
    PVector previousPoint = src;

    for (PVector p : boundaryPoints) {

      if (p!= src) {
        LineBoundary l = new LineBoundary(previousPoint, p, 1);
        //l.update(previousPoint, p);
        bounds.add(l);
        //vLine(previousPoint, p);
        previousPoint = p;
      }
    }

    if (debug) {
      stroke(255);

      strokeWeight(20);
      bounds.draw();

      //draw angles
      magLine(src, sch, 20);

      vPoint(src);
      stroke(0, 255, 0);
      vPoint(trg);

      ray1.drawRay();
      ray2.drawRay();

      for (PVector p : boundaryPoints) {
        if (debug) {
          strokeWeight(12);
          stroke(255, 0, 0);
          vPoint(p);
        }
      }
    }

    if (!debug && drawFloor) {
      bounds.draw();
    }
  }


  PVector recSearch(PVector source) {
    PVector search = new PVector();

    if (source.x == 0 && source.y >0) {
      search = n;
    }
    if (source.x < width && source.y ==0) {
      search = e;
    }
    if (source.x == width && source.y <height) {
      search = s;
    }
    if (source.x >0 && source.y == height) {
      search = w;
    }

    if (ipov(trg, source, search)) {
      boundaryPoints.add(trg);
      return trg;
    } else {

      PVector newSearch;
      PVector newSource = new PVector();
      if (search == n) {
        newSearch = e;
        newSource = edges.n_w;
      }
      if (search == e) {
        newSearch = s;
        newSource = edges.n_e;
      }
      if (search == s) {
        newSearch = w;
        newSource = edges.s_e;
      }
      if (search == w) {
        newSearch = n;
        newSource = edges.s_w;
      }
      boundaryPoints.add(newSource);
      recSearch(newSource);
    }
    return null;
  }

  class Ray {

    PVector pos;
    PVector dir;
    boolean h;

    Ray(PVector _pos, PVector _dir, boolean _highlight) {

      h = _highlight;
      pos = _pos;
      dir = _dir;
      h = false;
    }

    PVector checkCorners() {

      if (ipov(edges.n_e, pos, dir)) {
        strokeWeight(20);
        print("ne ");
        return edges.n_e;
      }
      if (ipov(edges.n_w, pos, dir)) {
        strokeWeight(20);
        print("nw ");
        return edges.n_w;
      }
      if (ipov(edges.s_e, pos, dir)) {
        strokeWeight(20);
        return edges.s_e;
      }
      if (ipov(edges.s_w, pos, dir)) {
        strokeWeight(20);
        return edges.s_w;
      }
      return null;
    }

    PVector checkEdges() {
      PVector a = isIntersecting(edges.north, pos, dir);
      if (a != null) {
        if (h) {
          edges.north.draw();
        }
        return(a);
      }
      PVector b = isIntersecting(edges.east, pos, dir);
      if (b != null) {
        if (h) {
          edges.east.draw();
        }
        return(b);
      }
      PVector c = isIntersecting(edges.south, pos, dir);
      if (c != null) {
        if (h) {
          edges.south.draw();
        }
        return(c);
      }
      PVector d = isIntersecting(edges.west, pos, dir);
      if (d != null) {
        if (h) {
          edges.west.draw();
        }
        return(d);
      }
      return null;
    }

    void drawRay() {
      strokeWeight(1);
      if (!h) {
        stroke(0, 255, 0);
      } else {
        stroke(255);
      }
      float lineMag = 200;
      magLine(pos, dir, lineMag);
      textSize(10);
      PVector textPos = PVector.add(pos, PVector.mult(dir, lineMag));
      text(dir.x, textPos.x-20, textPos.y);
      text(dir.y, textPos.x+20, textPos.y);
    }

    void setAngle(PVector a) {
      dir = a;
    }
  }

  PVector isIntersecting(Edge wl, PVector pos, PVector dir) {

    float x1 = wl.pos1.x;      // rename variables to match those of algorithm aka Dan Schiffman 
    float y1 = wl.pos1.y;      // for convenience
    float x2 = wl.pos2.x;
    float y2 = wl.pos2.y;
    float x3 = pos.x;
    float y3 = pos.y;
    float x4 = pos.x + dir.x;
    float y4 = pos.y + dir.y;
    float den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    if (den == 0) {
      return null;
    } else {
      float t = ((x1 -x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / den;
      float u = -((x1 - x2) * (y1 -y3) - (y1 - y2) * (x1 - x3)) / den;
      if (t > 0 && t < 1 && u > 0) {                        // intersection found
        PVector impact = new PVector();
        impact.x = x1 + t * (x2 - x1);
        impact.y = y1 + t * (y2 - y1);
        return impact;
      } else {
        return null;
      }
    }
  }

  boolean ipov(PVector point, PVector pos, PVector dir) {

    float a = (pos.x - point.x) / dir.x;
    float b = (pos.y - point.y) / dir.y;

    if (dir.x == 0) {
      if (b<=0) {
        return point.x == pos.x;
      }
    }
    if (dir.y == 0) {
      if (a<=0) {
        return point.y == pos.y;
      }
    }


    if (abs((pos.x - point.x) / dir.x - (pos.y - point.y) / dir.y)<0.01) {
      if (a <= 0) {
        return true;
      }
    }
    return false;
  }
  class Edge {
    PVector pos1 = new PVector();
    PVector pos2 = new PVector();

    Edge(PVector _pos1, PVector _pos2) {
      pos1 = _pos1;
      pos2 = _pos2;
    }

    void draw() {
      vLine(pos1, pos2);
    }
  }

  class EdgeController {

    Edge north;
    Edge east;
    Edge south;
    Edge west;

    PVector n_e;
    PVector n_w;
    PVector s_e;
    PVector s_w;

    EdgeController() {

      n_w = new PVector(0, 0);
      n_e = new PVector(width, 0);
      s_e = new PVector(width, height);
      s_w = new PVector(0, height);

      north = new Edge(n_w, n_e);
      east = new Edge(n_e, s_e);
      south = new Edge(s_e, s_w);
      west = new Edge(s_w, n_w);
    }

    void draw() {

      strokeWeight(10);
      north.draw();
      east.draw();
      south.draw();
      west.draw();
    }
  }
}
