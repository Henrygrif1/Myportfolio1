class SecretKey {
  float x, y, speed;

  SecretKey() {
    x = random(90, width - 90);
    y = -40;
    speed = random(3, 6);
  }

  void display() {
    rectMode(CENTER);
    noStroke();
    fill(255, 218, 73);
    ellipse(x - 14, y, 24, 24);
    fill(8, 11, 28);
    ellipse(x - 14, y, 10, 10);
    fill(255, 218, 73);
    rect(x + 10, y, 34, 8);
    rect(x + 22, y + 8, 8, 12);
    rect(x + 34, y + 8, 8, 12);
  }

  void move() {
    y += speed;
  }

  boolean reachedBottom() {
    return y > height + 50;
  }

  boolean intersect(spaceShip s) {
    return dist(x, y, s.x, s.y) < 50;
  }
}
