//Henry Griffin | 17 sept 2025 | SpaceGame
import processing.sound.*;
spaceShip happy;
ArrayList<Rock> rocks = new ArrayList<Rock>();
ArrayList<Laser> lasers = new ArrayList<Laser>();
ArrayList<Star> stars = new ArrayList<Star>();
ArrayList<PowerUp> powups = new ArrayList<PowerUp>();
Timer rockTimer, puTimer;
int score, rocksPassed, level;
PImage start, gameOver, go1;
SoundFile LaserS1;
boolean play;
float rockSpeedMultiplier;

void setup() {
  //size (500, 500);
  fullScreen();
  background(20);
  happy = new spaceShip();
  puTimer = new Timer(5000);
  rockTimer = new Timer(1000);
  rockTimer.start();
  score = 0;
  rocksPassed = 0;
  start = loadImage("StartS.png");
  play = false;
  go1= loadImage("GameoverS.png");
  LaserS1= new SoundFile(this, "Laser1.wav");
  level = 1;
  rockSpeedMultiplier = 1.0;
}


void draw() {
  if (play == false) {
    startScreen();
  } else {
    background(20);
    if (puTimer.isFinished()) {
      powups.add(new PowerUp());
      puTimer.start();
    }
    int multiple = 1; 
    if (score > 0 && 500 * multiple <= score) {
      level = score / 500 + 1;
      multiple++; 
      rockSpeedMultiplier = 1.0 + (level - 1) * 0.2; // Increase speed gradually
      rockTimer.totalTime = 1000/level; // Minimum 300ms
    }
    //powerup display and mover
    for (int i = 0; i<powups.size(); i++) {
      PowerUp pu = powups.get(i);
      pu.display();
      pu.move();
      //check bottom


      if (pu.intersect(happy)) {
        powups.remove(pu);
        if (pu.type =='H') {
          happy.health+=100;
        } else {
          if (pu.type =='T') {
            happy.turretCount+=1;
            if (happy.turretCount>5) {
              happy.turretCount = 5;
            }
          } else if (pu.type == 'A') {
            happy.laserCount+=100;
          }
        }
      }
    }

    //distribute stars
    stars.add(new Star());
    //display and remove
    for (int i = 0; i < stars.size(); i++) {
      Star star = stars.get(i);
      star.display();
      star.move();
      if (star.reachedBottom()) {
        stars.remove(star);
        i--;
      }
      //   println("Stars" + stars.size());
    }
    //Distribution of rocks
    if (rockTimer.isFinished()) {
      rocks.add(new Rock());
      rockTimer.start();
    }
    //display of all the rocks
    for (int i = 0; i < rocks.size(); i++) {
      Rock rock = rocks.get(i);
      rock.display();
      rock.move();
      if (happy.intersect(rock)) {
        rocks.remove(rock);
        score += rock.diam;
        happy.health-=10;
      }

      if (rock.reachedBottom()) {
        rocksPassed++;
        rocks.remove(rock);
        i--;
      }
      // println("Rocks:" + rocks.size());
    }
    //display and remove unwated lasers
    for (int i = 0; i < lasers.size(); i++) {
      Laser laser = lasers.get(i);
      if (laser.reachedTop()) {
        lasers.remove(laser);
        i--;
        continue;
      }
      for (int j = 0; j<rocks.size(); j++) {
        Rock r = rocks.get(j);
        laser.display();
        laser.move();
        if (laser.intersect(r)) {
          score += 25;
          lasers.remove(laser);
          r.diam -= 70;
          if (r.diam<5) {
            rocks.remove(r);
          }
        }

        //println("Lasers:" + lasers.size());
      }
    }
    if (happy.health<1) {
      gameOver();
    }
    happy.display();
    happy.move(mouseX, mouseY);
    infoPanel();
  }
  println("health: " + happy.health);
}
void mousePressed() {
  lasers.add(new Laser(happy.x, happy.y));
  happy.laserCount--;
  LaserS1.play();
}
void infoPanel() {
  rectMode(CENTER);
  fill(255, 255, 255, 127);
  rect(width/2, height-25, width, 70);
  fill(0);
  textSize (30);
  text("score: " + score, 75, height-20);
  text("Rocks Passed: " + rocksPassed, 300, height-17);
  text("Health: " + happy.health, 550, height-17);
  text("Ammo: " + happy.laserCount, 800, height-17);
  fill(255);
  rect(50, height-100, 100, 10);
  fill(255, 0, 0);
  rect(50, height-100, happy.health, 10);
  text("Level: " + level, 50, height -175);
}
void startScreen() {
  image(start, 0, 0);

  fill(255);
  textSize (30);
  textAlign(CENTER, BOTTOM);
  text("click mouse to start!", width/2, height/2);
  //
  if (mousePressed) {
    play = true;
  }
}
void gameOver() {
  image(go1, width/2, height/2);
  play = false;
  fill(255);
  text("You achieved a score of: " + score, width/2, height/2);
  noLoop();
}
