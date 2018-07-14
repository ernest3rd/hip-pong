// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain

// Pong
// https://youtu.be/IIrC5Qcb2G4

import org.openkinect.processing.*;

// The kinect stuff is happening in another class

class Paddle {
  float x;
  float pad;
  float w = 20;
  float h = 100;
  float y;
  float acceleration;
  int col;
  float ychange = 0;
  public boolean active;
  float activityMeter = 0;
  
  KinectTracker kinect;

  Paddle(int _x, int _y, int kinectID, PApplet _p) {
    x = _x;
    y = _y;
    active = false;
    kinect = new KinectTracker(_p, kinectID, kinectID == 1);
    col = kinectID == 1 ? 0xffffffff : 0xffffffff;
  }
  
  void setActive(boolean state){
    active = state;
  }
  
  void activate(){
    activityMeter+=2;
    if(activityMeter > h){
      setActive(true);
    }
  }

  void update(float scaleX, float scaleY) {
    kinect.track();
    
    if(kinect.seesHuman()){
      y = map(kinect.getLerpedPos().x, 0, 1, -100*scaleY, height + 100*scaleY);
      
      if(activityMeter < 100){
        activityMeter+=2;
      }
      else{
        setActive(true);
      }
    }
    else{
      y = PApplet.lerp(y, height/2, 0.2f);
     if(activityMeter > 0){
       activityMeter--;
     }
     setActive(false);
    }
    
    if(y < h/2){
      y = h/2;
    }
    if(y > height-h/2){
      y = height-h/2;
    }
  }


  void move(float steps) {
    //ychange = steps;
  }

  void show() {
    noStroke();
    rectMode(CENTER);
    
    if(!active){
      fill(0x66ffffff);
      ellipse(x,y,activityMeter, activityMeter);
    }
    else {
      fill(col);
    }
    
    rect(x, y, w, h);
  }
  
  void swapKinect(){
    kinect.swapKinect();
  }
  
  void reset(){
    setActive(false);
    activityMeter = 0;
  }
}