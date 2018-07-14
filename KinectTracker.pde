// Daniel Shiffman
// Tracking the average location beyond a given depth threshold
// Thanks to Dan O'Sullivan

// https://github.com/shiffman/OpenKinect-for-Processing
// http://shiffman.net/p5/kinect/
import org.openkinect.processing.*;

class KinectTracker {

  Kinect kinect;
  // Depth threshold
  int threshold = 745;
  int thresholdRadius = 100;
  
  int kinect_id;
  boolean hasHuman = false;

  // Raw location
  PVector loc;

  // Interpolated location
  PVector lerpedLoc;

  // Depth data
  int[] depth;
   
  KinectTracker(PApplet _p, int kinect_id, boolean mirror) {
    kinect = new Kinect(_p);
    // This is an awkard use of a global variable here
    // But doing it this way for simplicity
    this.kinect_id = kinect_id;
    kinect.activateDevice(kinect_id);
    kinect.initDepth();
    kinect.enableMirror(mirror);
    // Make a blank image
    //splay = createImage(kinect.width, kinect.height, RGB);
    // Set up the vectors
    loc = new PVector(0, 0);
    lerpedLoc = new PVector(0, 0);
  }

  void track() {
    // Get the raw depth as array of integers
    depth = kinect.getRawDepth();

    // Being overly cautious here
    if (depth == null) return;

    float sumX = 0;
    float sumY = 0;
    float count = 0;

    for (int x = 0; x < kinect.width; x++) {
      for (int y = 200; y < 300; y++) {
        
        int offset =  x + y*kinect.width;
        // Grabbing the raw depth
        int rawDepth = depth[offset];

        // Testing against threshold
        if (rawDepth > threshold-thresholdRadius && rawDepth < threshold+thresholdRadius) {
          sumX += x;
          sumY += y;
          count++;
        }
      }
    }
    // As long as we found something
    if (count != 0) {
      loc = new PVector(sumX/count/kinect.width, sumY/count/kinect.height);
      hasHuman = true;
    }
    else{
      hasHuman = false;
    }

    // Interpolating the location, doing it arbitrarily for now
    lerpedLoc.x = PApplet.lerp(lerpedLoc.x, loc.x, 0.6f);
    lerpedLoc.y = PApplet.lerp(lerpedLoc.y, loc.y, 0.6f);
  }

  PVector getLerpedPos() {
    return lerpedLoc;
  }

  PVector getPos() {
    return loc;
  }

  void display() {
    int[] depths = kinect.getRawDepth();
    PImage dimg = kinect.getDepthImage();
    PImage img = createImage(kinect.width, kinect.height, 0);

    // Going to rewrite the depth image to show which pixels are in threshold
    // A lot of this is redundant, but this is just for demonstration purposes
    img.loadPixels();
    for (int y = 0; y < img.height; y++) {
      for (int x = 0; x < img.width; x++) {
        int offset = x + y * img.width;
        // Raw depth
        int rawDepth = depths[offset];
        if(y<200 || y>300){
          img.pixels[offset] = 0x00000000;
        }
        else if (rawDepth > threshold-thresholdRadius && rawDepth < threshold+thresholdRadius) {
          // A red color instead
          img.pixels[offset] = 0xffaa5555;
        }
        else{
          img.pixels[offset] = dimg.pixels[offset];
        }
      }
    }
    img.updatePixels();

    // Draw the image
    image(img,0,0);
  }

  int getThreshold() {
    return threshold;
  }

  void setThreshold(int t) {
    threshold =  t;
  }
  
  boolean seesHuman(){
    return hasHuman;
  }
  
  void swapKinect(){
    kinect_id = kinect_id == 0 ? 1 : 0;
    kinect.activateDevice(kinect_id);
  }
}