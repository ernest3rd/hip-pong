// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain

// Pong
// https://youtu.be/IIrC5Qcb2G4

class Puck {
  float x = width/2;
  float y = height/2;
  float xspeed;
  float yspeed;
  float r = 15;
  float maxSpeed = 8;

  Puck() {
    reset(true);
  }

  void checkPaddleLeft(Paddle p) {
    if (y - r < p.y + p.h/2 && y + r > p.y - p.h/2 && x - r < p.x + p.w/2) {
      if (x > p.x) {
        float diff = y - (p.y - p.h/2);
        float rad = radians(45);
        float angle = map(diff, 0, p.h, -rad, rad);
        xspeed = maxSpeed * cos(angle);
        yspeed = maxSpeed * sin(angle);
        x = p.x + p.w/2 + r;
        maxSpeed++;
        hitSound();
      }
    }
  }
  void checkPaddleRight(Paddle p) {
    if (y - r < p.y + p.h/2 && y + r > p.y - p.h/2 && x + r > p.x - p.w/2) {
      if (x < p.x) {
        //xspeed *= -1;
        float diff = y - (p.y - p.h/2);
        float angle = map(diff, 0, p.h, radians(225), radians(135));
        xspeed = maxSpeed * cos(angle);
        yspeed = maxSpeed * sin(angle);
        x = p.x - p.w/2 - r;
        maxSpeed++;
        hitSound();
      }
    }
  }




  void update() {
    x = x + xspeed;
    y = y + yspeed;
  }

  void reset(boolean hard) {
    x = width/2;
    y = height/2;
    float angle = random(-PI/4, PI/4);
    //angle = 0;
    maxSpeed = 10;
    xspeed = maxSpeed * cos(angle);
    yspeed = maxSpeed * sin(angle);

    if (random(1) < 0.5) {
      xspeed *= -1;
    }
  }

  void edges() {
    if (y < r+10 || y > height - r - 10) {
      yspeed *= -1;
      hitSound();
    }

    if (x > width + r) {
      leftscore++;
      scoreSound();
      reset(false);
    }

    if (x < -r) {
      rightscore++;
      scoreSound();
      reset(false);
    }
  }


  void show() {
    fill(255);
    rectMode(CENTER);
    rect(x,y,r*2,r);
    rect(x,y,r,r*2);
    //rect(x,y,r*1.5,r*1.5);
    //ellipse(x, y, r*2, r*2);
  }
}