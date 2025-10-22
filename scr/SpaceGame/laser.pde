class Laser {
  //number vairables
  int x, y, w, h, speed;
  PImage l1;
  //constructor
  Laser(int x, int y) {
    this.x=x;
    this.y = y;
    w =4;
    h =10;
    speed =15;
    //load image here
    l1 = loadImage("laser.png");
    l1.resize(60, 75);
  }

  //member Methods
  void display() {
    rectMode(CENTER);
    image(l1, x, y);
  }

  void move () {
    y = y - speed;
  }

  boolean reachedTop() {
    if (y<0-10) {
      return true;
    } else {
      return false;
    }
  }
  boolean intersect(Rock r) {
    float d = dist(x,y,r.x,r.y);
    if(d<55) {
    return true;
    } else {
      return false;
    }
  }
}
