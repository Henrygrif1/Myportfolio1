class Rock {
  //number vairables
  int x, y, diam, speed;
  PImage r1;
  //constructor
  Rock() {
    x = int (random(width));
    y = -100;
    diam = int(random(175, 225));
    speed = int(random(5, 10));
    if (random(10)>6.6) {
      r1 = loadImage("rock1.png");
    } else if (random(10)>5.0) {
      r1 = loadImage("rock2.png");
    } else {
      r1 = loadImage("rock3.png");
    }
  }
  //member Methods
  void display() {
    imageMode(CENTER);
    r1.resize(diam, diam);
    image(r1, x, y);
  }

  void move () {
    y = y + int(speed * rockSpeedMultiplier);
  }

  boolean reachedBottom() {
    if (y>height+100) {
      return true;
    } else {
      return false;
    }
  }
}
