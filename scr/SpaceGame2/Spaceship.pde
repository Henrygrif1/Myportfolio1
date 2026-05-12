class spaceShip {
  int x, y, w, health, laserCount, turretCount;
  PImage happy;

  spaceShip() {
    x = width/2;
    y = height/2;
    health = 100;
    happy = loadImage("spaceship.png");
    laserCount = 100;
    turretCount = 1;
  }

  void display() {
    imageMode(CENTER);
    noStroke();

    fill(255, 218, 73, 165);
    triangle(x - 10, y + 44, x + 10, y + 44, x, y + 86);
    fill(255, 128, 34, 135);
    triangle(x - 6, y + 44, x + 6, y + 44, x, y + 72);

    image(happy, x, y);
  }

  void move (int x, int y) {
    this.x = x;
    this.y = y;
  }

  boolean fire() {
    return laserCount>0;
  }

  boolean intersect(Rock r) {
    float d = dist(x, y, r.x, r.y);
    return d<50;
  }
}
