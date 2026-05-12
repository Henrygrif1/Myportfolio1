class PowerUp {
  int x, y, w, speed;
  PImage puIamge;
  char type;

  PowerUp() {
    x = int(random(width));
    y = -100;
    w = 100;
    speed = int(random(1, 10));

    if (random(10)>5) {
      puIamge = loadImage("Ammo.png");
      type = 'A';
    } else {
      puIamge = loadImage("Health.png");
      type = 'H';
    }
  }

  void display() {
    imageMode(CENTER);
    noStroke();
    stroke(255, 218, 73, 160);
    strokeWeight(2);
    line(x - 48, y - 38, x - 36, y - 38);
    line(x - 42, y - 44, x - 42, y - 32);
    line(x + 42, y + 35, x + 54, y + 35);
    line(x + 48, y + 29, x + 48, y + 41);
    noStroke();
    image(puIamge, x, y);
  }

  void move () {
    y = y + speed;
  }

  boolean reachedBottom() {
    return y>height+100;
  }

  boolean intersect(spaceShip s) {
    float d = dist(x, y, s.x, s.y);
    return d<50;
  }
}
