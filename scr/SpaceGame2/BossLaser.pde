class BossLaser {
  float x, y, dx, dy;

  BossLaser(float x, float y) {
    this(x, y, 0, 11);
  }

  BossLaser(float x, float y, float dx, float dy) {
    this.x = x;
    this.y = y;
    this.dx = dx;
    this.dy = dy;
  }

  void display() {
    float beamLength = 34;
    float angle = atan2(dy, dx);
    float x1 = x - cos(angle) * beamLength/2;
    float y1 = y - sin(angle) * beamLength/2;
    float x2 = x + cos(angle) * beamLength/2;
    float y2 = y + sin(angle) * beamLength/2;

    stroke(255, 59, 76, 190);
    strokeWeight(5);
    line(x1, y1, x2, y2);

    stroke(255, 218, 73, 140);
    strokeWeight(2);
    line(x1, y1, x2, y2);
    noStroke();
  }

  void move() {
    x += dx;
    y += dy;
  }

  boolean reachedBottom() {
    return x < -40 || x > width + 40 || y < -40 || y > height + 40;
  }

  boolean intersect(spaceShip s) {
    return dist(x, y, s.x, s.y) < 42;
  }
}
