// Daniel Shiffman
// http://codingtra.in
// http://patreon.com/codingtrain

// Pong
// https://youtu.be/IIrC5Qcb2G4

boolean enableP2 = true;

int gameState;
final int WAITING_FOR_PLAYERS = 0;
final int WAITING_FOR_P1 = 1;
final int WAITING_FOR_P2 = 2;
final int READY_TO_START_GAME = 3;
final int GAME = 4;
final int GAMEOVER = 5;

int startCountdown;

Puck[] pucks;

Paddle player1;
Paddle player2;

float rotation = 0;
float logoScale = 1;

int leftscore = 0;
int rightscore = 0;

float scaleX, scaleY;

PFont fontNormal, fontCountdown, fontScore;

void setup() {
  //frameRate(10);
  fullScreen();
  //size(640, 480);
  scaleX = width / 100;
  scaleY = height / 100;
  // Other
  
  // Fonts
  fontNormal = loadFont("PressStart2P-Regular-32.vlw");
  fontCountdown = loadFont("PressStart2P-Regular-150.vlw");
  fontScore = loadFont("PressStart2P-Regular-150.vlw");
  
  initSound();
  
  gameState = WAITING_FOR_PLAYERS;
  
  pucks = new Puck[1];
  for(int i=0; i<pucks.length; i++){
    pucks[i] = new Puck();
  }
    
  player1 = new Paddle(int(5 * scaleX), int(height/2), 0, this);
  player2 = new Paddle(width - int(5 * scaleX), int(height/2), 1, this);
}

void draw() {
  background(0xff0013a5);
  rectMode(CORNER);
  fill(255);
  noStroke();
  rect(0,0, width, 10);
  rect(0,height-10, width, 10);
  fill(0x77ffffff);
  rect(width/2-5, 0, 10, height);
  strokeWeight(10);
  stroke(0x77ffffff);
  strokeCap(SQUARE);
  drawDashedLine(width/4, 0, width/4, height, 40);
  drawDashedLine(width/4*3, 0, width/4*3, height, 40);
  
  // Update positions of paddles
  
  player1.update(scaleX, scaleY);
  
  if(enableP2){
    player2.update(scaleX, scaleY);
  }
  
  player1.x = int(5 * scaleX) + 4.5 * scaleX * leftscore;
  player2.x = width - (int(5 * scaleX) + 4.5 * scaleX * rightscore);
  /*
  pushMatrix();
  translate(100,100);
  player1.kinect.display();
  popMatrix();
  
  pushMatrix();
  translate(width/2+50,100);
  player2.kinect.display();
  popMatrix();
  */
  if(gameState == WAITING_FOR_PLAYERS){
    fill(255);
    textFont(fontNormal);
    
    pushMatrix();
    rotation-=sin(frameCount/30.0)/10.0;
    translate(width/2, height/2);
    scale((sin(frameCount/10.0)+1)+1);
    rotate(rotation);
    text("HIP\nPONG", 0, 0);
    popMatrix();
    
    if(!player1.active){
      if(player1.kinect.seesHuman()){
        renderText("ACTIVATING PLAYER", 0);
      }
      else{
        renderText("WAITING FOR PLAYER", 0);
      }
    }
    else {
      renderText("PLAYER 1 READY", 0);
    }
    if(!player2.active){
      if(player2.kinect.seesHuman()){
        renderText("ACTIVATING PLAYER", 1);
      }
      else{
        renderText("WAITING FOR PLAYER", 1);
      }
    }
    else{
      renderText("PLAYER 2 READY", 1);
    }
    
    if(player1.active && player2.active){
      gameState = READY_TO_START_GAME;
      startCountdown = 200;
      playRandomSong(5);
    }
  }
  else if(gameState == READY_TO_START_GAME){
    fill(255);
    textFont(fontCountdown);
    textAlign(CENTER, CENTER);
    renderText(""+int(startCountdown/40.0), 0);
    renderText(""+int(startCountdown/40.0), 1);
    
    startCountdown--;
    if(startCountdown < 0){
      gameState = GAME;
      pucks[0].reset(true);
    }
    
  }
  else if(gameState == GAME){
    fill(0x77ffffff);
    textFont(fontScore);
    textAlign(CENTER, CENTER);
    renderText(""+leftscore, 0);
    renderText(""+rightscore, 1);
    
    fill(255);
    textFont(fontNormal);
    if(!player1.active){
      renderText("LOST CONNECTION TO PLAYER", 0);
    }
    if(!player2.active){
      renderText("LOST CONNECTION TO PLAYER", 1);
    }
    for(int i=0; i<pucks.length; i++){
      pucks[i].checkPaddleRight(player2);
      pucks[i].checkPaddleLeft(player1);
      pucks[i].edges();
      pucks[i].update();
      pucks[i].show();
    }
    
    if(leftscore >= 5 || rightscore >= 5){
      gameState = GAMEOVER;
      startCountdown = 60*5;
      playWinningSong(2);
    }
  }
  else if(gameState == GAMEOVER){
    fill(255);
    textFont(fontNormal);
    textAlign(CENTER, CENTER);
    if(leftscore > rightscore){
      renderText("WINNER", 0);
      renderText("LOSER", 1);
    }
    else {
      renderText("LOSER", 0);
      renderText("WINNER", 1);
    }
    
    startCountdown--;
    if(startCountdown < 0){
      gameState = WAITING_FOR_PLAYERS;
      player1.reset();
      player2.reset();
      leftscore = 0;
      rightscore = 0;
    }
  }
  
  // draw paddles
  player1.show();
  player2.show();
  
  //textFont(fontNormal);
  //text(frameRate, width/2+100, height-40);
}

void keyPressed(){
  println(keyCode);
  if(keyCode == 32){
    gameState = GAME;
  }
  else if(keyCode == 83){
    // Swap kinects
    playRandomSong(60);
    //player1.swapKinect();
    //player2.swapKinect();
  }
}

void renderText(String text, int side){
  pushMatrix();
  if(side == 0){
    translate(37.5*scaleX, height/2);
    rotate(radians(90));
  }
  else {
    translate(width - 37.5*scaleX, height/2);
    rotate(radians(-90));
  }
  
  textAlign(CENTER, CENTER);
  text(text, 0, 0);
  
  popMatrix();
}

void drawDashedLine(float x1, float y1, float x2, float y2, int dashes){
  for (int i = 0; i <= dashes; i++) {
    float dx1 = lerp(x1, x2, i/(float)dashes);
    float dy1 = lerp(y1, y2, i/(float)dashes);
    float dx2 = lerp(x1, x2, (i+0.5)/(float)dashes);
    float dy2 = lerp(y1, y2, (i+0.5)/(float)dashes);
 
    line(dx1, dy1, dx2, dy2);
  }
}