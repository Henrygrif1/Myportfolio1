class PowerUp {
  //number vairables
  int x, y, w, speed;
  PImage puIamge;
  char type;
  color c1;
  //constructor
  PowerUp() {
    x = int (random(width));
    y = -100;
    w = 100;
    speed = int(random(5, 10));
    speed = int(random(1, 10));

    if (random(10)>5) {
      puIamge = loadImage("Ammo.png");
      type = 'A';// This is AMMO
    } else {
      puIamge = loadImage("Health.png");
      type = 'H';// This is health
  }
  }
  //member Methods
  void display() {
    fill(c1);
    image(puIamge, x, y);
    fill(255);
    textAlign(CENTER);
    text(type, x, y);
    //imageMode(CENTER);
    //r1.resize(diam, diam);
    //image(r1, x, y);
  }

  void move () {
    y = y + speed;
  }

  boolean reachedBottom() {
    if (y>height+100) {
      return true;
    } else {
      return false;
    }
  }
  boolean intersect(spaceShip s) {
    float d = dist(x, y, s.x, s.y);
    if (d<50) {
      return true;
    } else {
      return false;
    }
  }
}
