class spaceShip {
  //number vairables
  int x, y, w, health,laserCount,turretCount;
  PImage happy;
  //constructor
  spaceShip() {
    x = width/2;
    y = height/2;
    health = 100;
    happy = loadImage("spaceship.png");
    laserCount = 100;
    turretCount = 1;
  }
  //member Methods
  void display() {
    imageMode(CENTER);
    image(happy, x, y);
  }

  void move (int x, int y) {
    this.x =x;
    this.y =y;
  }
  boolean fire() {
    if (laserCount>0) {
    return true;
    
    }else {
      return false;
    }
  }

  boolean intersect(Rock r) {
    float d = dist(x,y,r.x,r.y);
    if(d<50) {
    return true;
    } else {
      return false;
    }
  }
}
