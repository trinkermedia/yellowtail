/**
 * Yellowtail
 * by Golan Levin (www.flong.com). 
 * 
 * Click, drag, and release to create a kinetic gesture.
 * 
 * Yellowtail (1998-2000) is an interactive software system for the gestural 
 * creation and performance of real-time abstract animation. Yellowtail repeats 
 * a user's strokes end-over-end, enabling simultaneous specification of a 
 * line's shape and quality of movement. Each line repeats according to its 
 * own period, producing an ever-changing and responsive display of lively, 
 * worm-like textures.
 * 
 */


//FullScreen fs; 


Gesture gestureArray[];
TuioClient tuioClient;
final int nGestures = 20;  // Number of gestures
final int minMove = 3;     // Minimum travel for a new point
int currentGestureID;

Polygon tempP;
int tmpXp[];
int tmpYp[];




float cursor_size = 15;
float object_size = 60;
float table_size = 760;
float scale_factor = 1;
PFont font;



int searchGestureID (int id) {
  int index = -1;
  for (int i = 0; i < gestureArray.length; i++) {
    Gesture temp = gestureArray[i];
    if (temp.ID == id)  return i;
  }  
  return index;
}


void setup() {
  //PApplet.main(new String[] { "--display=1", "--present", "projectName" }); 

  size(800, 600, OPENGL);
  background(0, 0, 0);
  noStroke();

  // Create the fullscreen object
  //fs = new FullScreen(this); 
  //fs.enter(); 
  // enter fullscreen mode


    //setFullScreen( true );        // get fullscreen exclusive mode 
  //createFullScreenKeyBindings();  // let ctrl+f switch between window/fullscreen mode

  //aeaeaee
  int id_control = 0;
  ////

  currentGestureID = -1;
  gestureArray = new Gesture[nGestures];
  for (int i = 0; i < nGestures; i++) {
    gestureArray[i] = new Gesture(width, height, id_control++);
  }
  clearGestures();

  tuioClient  = new TuioClient(this);
  //startFullscreen(); /* call this early in setup */ 

  hint(ENABLE_NATIVE_FONTS);
  font = createFont("Arial", 18);
  scale_factor = height/table_size;




}


void draw() {
  background(0);

  updateGeometry();
  fill(255, 255, 245);
  for (int i = 0; i < nGestures; i++) {
    renderGesture(gestureArray[i], width, height);
  }

  ////////////////////////////////////////////////////////////////////////
  // DEBUG!!!!
  ////////////////////////////////////////////////////////////////////////


  //background(255);
  textFont(font,18*scale_factor);
  float obj_size = object_size*scale_factor; 
  float cur_size = cursor_size*scale_factor; 

  TuioCursor[] tuioCursorList = tuioClient.getTuioCursors();
  for (int i=0;i<tuioCursorList.length;i++) {
    TuioCursor tcur = tuioCursorList[i];
    TuioPoint[] pointList = tcur.getPath();

    if (pointList.length>0) {
      stroke(0,0,255);
      TuioPoint start_point = pointList[0];
      for (int j=0;j<pointList.length;j++) {

        TuioPoint end_point = pointList[j];
        line(start_point.getScreenX(width),start_point.getScreenY(height),end_point.getScreenX(width),end_point.getScreenY(height));
        start_point = end_point;
        
        ///////////////////////////////////////////////////////////////
        // tentativa!!!!
        ///////////////////////////////////////////////////////////////
        
        if (j == 0) {
          println("addiei!");
          currentGestureID = (currentGestureID+1) % nGestures;
          Gesture G = gestureArray[currentGestureID];
          G.clear();
          G.clearPolys();
          G.addPoint(end_point.getScreenX(width),end_point.getScreenY(height));
        } 
        else {
          println("dragguiei!");
          if (currentGestureID >= 0) {
            Gesture G = gestureArray[currentGestureID];
            if (G.distToLast(end_point.getScreenX(width),end_point.getScreenY(height)) > minMove) {
              G.addPoint(end_point.getScreenX(width),end_point.getScreenY(height));
              G.smooth();
              G.compile();
            }
          }
        }
        
        ///////////////////////////////////////////////////////////////
        // FIM
        ///////////////////////////////////////////////////////////////
        
      }

      stroke(192,192,192);
      fill(192,192,192);
      ellipse( tcur.getScreenX(width), tcur.getScreenY(height),cur_size,cur_size);
      fill(0);
      text(""+ tcur.getFingerID(),  tcur.getScreenX(width)-5,  tcur.getScreenY(height)+5);
    }
  }

  ////////////////////////////////////////////////////////////////////////

}

void mousePressed() {
  currentGestureID = (currentGestureID+1) % nGestures;
  Gesture G = gestureArray[currentGestureID];
  G.clear();
  G.clearPolys();
  G.addPoint(mouseX, mouseY);
}


void mouseDragged() {
  //println("ae ae ae ae");
  if (currentGestureID >= 0) {
    Gesture G = gestureArray[currentGestureID];
    if (G.distToLast(mouseX, mouseY) > minMove) {
      G.addPoint(mouseX, mouseY);
      G.smooth();
      G.compile();
    }
  }
}


void keyPressed() {
  if (key == '+' || key == '=') {
    if (currentGestureID >= 0) {
      float th = gestureArray[currentGestureID].thickness;
      gestureArray[currentGestureID].thickness = min(96, th+1);
      gestureArray[currentGestureID].compile();
    }
  } 
  else if (key == '-') {
    if (currentGestureID >= 0) {
      float th = gestureArray[currentGestureID].thickness;
      gestureArray[currentGestureID].thickness = max(2, th-1);
      gestureArray[currentGestureID].compile();
    }
  } 
  else if (key == ' ') {
    clearGestures();
  }
}


void renderGesture(Gesture gesture, int w, int h) {
  if (gesture.exists) {
    if (gesture.nPolys > 0) {
      Polygon polygons[] = gesture.polygons;
      int crosses[] = gesture.crosses;

      int xpts[];
      int ypts[];
      Polygon p;
      int cr;

      beginShape(QUADS);
      int gnp = gesture.nPolys;
      for (int i=0; i<gnp; i++) {

        p = polygons[i];
        xpts = p.xpoints;
        ypts = p.ypoints;

        vertex(xpts[0], ypts[0]);
        vertex(xpts[1], ypts[1]);
        vertex(xpts[2], ypts[2]);
        vertex(xpts[3], ypts[3]);

        if ((cr = crosses[i]) > 0) {
          if ((cr & 3)>0) {
            vertex(xpts[0]+w, ypts[0]);
            vertex(xpts[1]+w, ypts[1]);
            vertex(xpts[2]+w, ypts[2]);
            vertex(xpts[3]+w, ypts[3]);

            vertex(xpts[0]-w, ypts[0]);
            vertex(xpts[1]-w, ypts[1]);
            vertex(xpts[2]-w, ypts[2]);
            vertex(xpts[3]-w, ypts[3]);
          }
          if ((cr & 12)>0) {
            vertex(xpts[0], ypts[0]+h);
            vertex(xpts[1], ypts[1]+h);
            vertex(xpts[2], ypts[2]+h);
            vertex(xpts[3], ypts[3]+h);

            vertex(xpts[0], ypts[0]-h);
            vertex(xpts[1], ypts[1]-h);
            vertex(xpts[2], ypts[2]-h);
            vertex(xpts[3], ypts[3]-h);
          }

          // I have knowingly retained the small flaw of not
          // completely dealing with the corner conditions
          // (the case in which both of the above are true).
        }
      }
      endShape();
    }
  }
}

void updateGeometry() {
  Gesture J;
  for (int g=0; g<nGestures; g++) {
    if ((J=gestureArray[g]).exists) {
      if (g!=currentGestureID) {
        advanceGesture(J);
      } 
      else if (!mousePressed) {
        advanceGesture(J);
      }
    }
  }
}

void advanceGesture(Gesture gesture) {
  // Move a Gesture one step
  if (gesture.exists) { // check
    int nPts = gesture.nPoints;
    int nPts1 = nPts-1;
    Vec3f path[];
    float jx = gesture.jumpDx;
    float jy = gesture.jumpDy;

    if (nPts > 0) {
      path = gesture.path;
      for (int i = nPts1; i > 0; i--) {
        path[i].x = path[i-1].x;
        path[i].y = path[i-1].y;
      }
      path[0].x = path[nPts1].x - jx;
      path[0].y = path[nPts1].y - jy;
      gesture.compile();
    }
  }
}

void clearGestures() {
  for (int i = 0; i < nGestures; i++) {
    gestureArray[i].clear();
  }
}





///////////////////////////////////////////////////////////////////
// these callback methods are called whenever a TUIO event occurs
///////////////////////////////////////////////////////////////////

// called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur) {
  println("add tuio " + tcur.getX()+" "+tcur.getY());
  println("mouse " + mouseX+" "+mouseY);

  //  currentGestureID = (currentGestureID+1) % nGestures;
  //  Gesture G = gestureArray[currentGestureID];
  //  G.clear();
  //  G.clearPolys();
  //  G.addPoint(tcur.getScreenX(width), tcur.getScreenY(height));

}

// called when a cursor is moved
void updateTuioCursor (TuioCursor tcur) {

  println("upd tuio " + tcur.getX()*width +" "+tcur.getY()*height);
  println("mouse " + mouseX+" "+mouseY); 
  // println("update cursor "+tcur.getFingerID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY()
  //        +" "+tcur.getMotionSpeed()+" "+tcur.getMotionAccel());

  //tcur.getScreenX(width), tcur.getScreenY(height)

  //  if (currentGestureID >= 0) {
  //    Gesture G = gestureArray[currentGestureID];
  //    if (G.distToLast(tcur.getScreenX(width), tcur.getScreenY(height)) > minMove) {
  //      G.addPoint(tcur.getScreenX(width), tcur.getScreenY(height));
  //      G.smooth();
  //      G.compile();
  //    }
  //  }        
}

// called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur) {
  println("remove cursor "+tcur.getFingerID()+" ("+tcur.getSessionID()+")");
}

// called after each message bundle
// representing the end of an image frame
void refresh(long timestamp) { 
  //redraw();
}







