class SecretBarrierLaser {
  float x1, y1, x2, y2;
  int warningTimer, lifeTimer;

  SecretBarrierLaser(float x1, float y1, float x2, float y2) {
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;
    warningTimer = 30;
    lifeTimer = 60;
  }

  void display() {
    if (warningTimer > 0) {
      stroke(255, 218, 73, 160);
      strokeWeight(3);
    } else {
      stroke(83, 255, 190, 220);
      strokeWeight(10);
      line(x1, y1, x2, y2);
      stroke(255, 255, 255, 160);
      strokeWeight(3);
    }
    line(x1, y1, x2, y2);
    noStroke();
  }

  void update() {
    if (warningTimer > 0) {
      warningTimer--;
    } else {
      lifeTimer--;
    }
  }

  boolean intersect(spaceShip s) {
    if (warningTimer > 0) {
      return false;
    }
    return distToLine(s.x, s.y) < 28;
  }

  float distToLine(float px, float py) {
    float dx = x2 - x1;
    float dy = y2 - y1;
    float lengthSq = dx * dx + dy * dy;
    float t = ((px - x1) * dx + (py - y1) * dy) / lengthSq;
    t = constrain(t, 0, 1);
    float closestX = x1 + t * dx;
    float closestY = y1 + t * dy;
    return dist(px, py, closestX, closestY);
  }

  boolean finished() {
    return warningTimer <= 0 && lifeTimer <= 0;
  }
}
