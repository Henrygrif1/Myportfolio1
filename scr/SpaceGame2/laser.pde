class Laser {
  int x, y, w, h, speed;
  PImage l1;

  Laser(int x, int y) {
    this.x=x;
    this.y = y;
    w =4;
    h =10;
    speed =15;
    l1 = loadImage("laser.png");
    l1.resize(60, 75);
  }

  void display() {
    imageMode(CENTER);
    noStroke();
    stroke(83, 200, 255, 120);
    strokeWeight(3);
    line(x, y + 28, x, y - 28);
    noStroke();
    image(l1, x, y);
  }

  void move () {
    y = y - speed;
  }

  boolean reachedTop() {
    return y<0-10;
  }

  boolean intersect(Rock r) {
    float d = dist(x, y, r.x, r.y);
    return d<55;
  }
}
