class RotatingBoundryController {
  ArrayList<PVector> boundaryPoints = new ArrayList<PVector>();

  EdgeController edges;
  LineBoundaryList bounds;

  PVector center;
  PVector source;
  PVector target;
  PVector search = new PVector();

  PVector north = new PVector(0, -1);
  PVector east = new PVector(1, 0);
  PVector south = new PVector(0, 1);
  PVector west = new PVector(-1, 0);

  float a1 = 45+90;

  //float a1 = 0;

  Ray ray1;
  Ray ray2;
  Ray tempRay;



  RotatingBoundryController() {  

    bounds = new LineBoundaryList();
    center = new PVector(width/2, height/2);
    edges = new EdgeController();
    ray1 = new Ray(center, PVector.fromAngle(0), true);
    ray2 = new Ray(center, PVector.fromAngle(HALF_PI), false);
    println("init rotating boundary controller");
  }

  void update(PVector down) {

    //fov = map(mouseX, 0, width, 0, 360);

    stroke(0);
    strokeWeight(1);


    float tempFOV = radians(floorBoundaryAngle/2);

    ray1.setAngle(new PVector(down.x, down.y).rotate(-tempFOV));
    ray2.setAngle(new PVector(down.x, down.y).rotate(tempFOV));


    /////// get source point /////

    source = ray1.checkCorners();
    if (source != null) {
      //vPoint(i1);
    } else {
      source = ray1.checkEdges();
    }


    /////// get target point //////

    target = ray2.checkCorners();
    if (target != null) {
      //vPoint(i1);
    } else {
      target = ray2.checkEdges();
    }

    // run recursive search, create verts for boundaries;
    this.bounds.clear();              // every frame we reset the list and build from scratch. is this unnecesary overhead?
    this.boundaryPoints.clear();
    this.boundaryPoints.add(source);  // add source (intersection of ray 1 and an edge) as first vert
    this.recSearch(source);           // recursively find corners until we hit target (intersection of ray 2 and an edge)
    PVector previousPoint = source;   // for use when loop through


    /////// SET THE BOUNDARIES ///////

    // loop through the verteces in boundaryPoints and connect them with boundaries
    // relies on the points being correctly ordered in the array

    for (PVector p : boundaryPoints) {

      if (p!= source) {
        LineBoundary l = new LineBoundary(previousPoint, p, 1);
        //l.update(previousPoint, p);
        bounds.add(l);
        //vLine(previousPoint, p);
        previousPoint = p;
      }
    }

    /////// DRAW THINGS FOR DEBUGGING ///////

    if (debug) {
      stroke(255);

      strokeWeight(20);
      bounds.draw();

      //draw angles
      magLine(source, search, 20);

      vPoint(source);
      stroke(0, 255, 0);
      vPoint(target);

      ray1.draw();
      ray2.draw();

      for (PVector p : boundaryPoints) {
        if (debug) {
          strokeWeight(12);
          stroke(255, 0, 0);
          vPoint(p);
        }
      }
    }

    ///// DRAW FLOOR ONLY /////  

    if (!debug && drawFloor) {
      bounds.draw();
    }

    ///// DRAW TEMP RAY /////
  }

  void drawTempRay() {
    tempRay.draw();
    strokeWeight(10);
    stroke(0, 0, 255);
    vPoint(tempRay.pos);
    stroke(0, 0, 255);
    vPoint(tempRay.checkEdges());
  }

  void addTempRay(PVector tempSource) {

    tempRay = new Ray(tempSource, down, false);
  }


  // resursive search function
  // trace the edges of the screen to find the next vertex for the dynamic boundaries

  PVector recSearch(PVector source) {
    PVector search = new PVector();

    if (source.x == 0 && source.y >0) {
      //println("left");
      search = north;
    }
    if (source.x < width && source.y ==0) {
      //println("top");
      search = east;
    }
    if (source.x == width && source.y <height) {
      //println("right");
      search = south;
    }
    if (source.x >0 && source.y == height) {
      //println("bottom");
      search = west;
    }

    // is target on search vector
    if (ipov(target, source, search)) {
      //yes, return target, draw line
      //vLine(source, target);
      boundaryPoints.add(target);
      return target;
    } else {

      // no, search again from next corner
      PVector newSearch;
      PVector newSource = new PVector();
      if (search == north) {
        newSearch = east;
        newSource = edges.n_w;
      }
      if (search == east) {
        newSearch = south;
        newSource = edges.n_e;
      }
      if (search == south) {
        newSearch = west;
        newSource = edges.s_e;
      }
      if (search == west) {
        newSearch = north;
        newSource = edges.s_w;
      }
      //vLine(source, newSource);
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

      //println(edges.n_e);
      if (ipov(edges.n_e, pos, dir)) {

        strokeWeight(20);
        //vPoint(edges.n_e);
        print("ne ");
        return edges.n_e;
      }
      if (ipov(edges.n_w, pos, dir)) {

        strokeWeight(20);
        //vPoint(edges.n_w);
        print("nw ");
        return edges.n_w;
      }
      if (ipov(edges.s_e, pos, dir)) {

        strokeWeight(20);
        //vPoint(edges.s_e);
        return edges.s_e;
      }
      if (ipov(edges.s_w, pos, dir)) {

        strokeWeight(20);
        //vPoint(edges.s_w);
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

        //vPoint(a);
        return(a);
      }
      PVector b = isIntersecting(edges.east, pos, dir);
      if (b != null) {

        if (h) {
          edges.east.draw();
        }

        //vPoint(b);
        return(b);
      }
      PVector c = isIntersecting(edges.south, pos, dir);
      if (c != null) {
    
        if (h) {
          edges.south.draw();
        }

        //vPoint(c);
        return(c);
      }
      PVector d = isIntersecting(edges.west, pos, dir);
      if (d != null) {
      
        if (h) {
          edges.west.draw();
        }

        //vPoint(d);
        return(d);
      }
      return null;
    }

    void draw() {
      strokeWeight(1);
      if (!h) {
        stroke(0, 255, 0);
      } else {
        stroke(255);
      }
      magLine(pos, dir, 200);

      text(dir.x, width/3, height/3);
      text(dir.y, width-width/3, height/3);
    }

    void setAngle(PVector a) {
      //dir = PVector.fromAngle(radians(a));
      dir = a;
    }
  }
  PVector isIntersecting(Edge wl, PVector pos, PVector dir) {

    // test if a ray defined by a point and a direction intersects with an edge
    // return the point of intersection or null

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

    // point = point we want to test
    // pos = origin of ray
    // dir = direction of ray


    float a = (pos.x - point.x) / dir.x;
    float b = (pos.y - point.y) / dir.y;

    if (dir.x == 0) {
      //println(b); 
      if (b<=0) {
        return point.x == pos.x;
      }
    }
    if (dir.y == 0) {
      //println(a); 
      if (a<=0) {
        return point.y == pos.y;
      }
    }


    if (abs((pos.x - point.x) / dir.x - (pos.y - point.y) / dir.y)<0.01) {
      //println(a, b);
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
