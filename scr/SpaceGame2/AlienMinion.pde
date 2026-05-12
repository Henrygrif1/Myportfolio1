class AlienMinion {
  float x, y, speedX, speedY, speedBoost;
  int health, maxHealth;

  AlienMinion(float x, float y, int health, float speedBoost) {
    this.x = x;
    this.y = y;
    this.health = health;
    maxHealth = health;
    this.speedBoost = speedBoost;
    speedX = random(4, 7) * speedBoost;
    speedY = random(3, 5) * speedBoost;
    if (random(1) < 0.5) {
      speedX *= -1;
    }
  }

  void display() {
    rectMode(CENTER);
    noStroke();

    fill(21, 110, 95);
    ellipse(x, y, 88, 48);
    fill(83, 255, 190);
    ellipse(x, y - 8, 48, 22);
    fill(255, 218, 73);
    ellipse(x - 18, y + 4, 10, 10);
    ellipse(x + 18, y + 4, 10, 10);

    fill(83, 150, 255);
    triangle(x - 44, y + 8, x - 72, y + 32, x - 30, y + 22);
    triangle(x + 44, y + 8, x + 72, y + 32, x + 30, y + 22);

    drawHealthBar();
  }

  void drawHealthBar() {
    float amount = constrain(health / float(maxHealth), 0, 1);
    rectMode(CORNER);
    fill(255, 255, 255, 45);
    rect(x - 38, y - 42, 76, 6);
    fill(83, 255, 190);
    rect(x - 38, y - 42, 76 * amount, 6);
  }

  void move() {
    x += speedX;
    y += speedY;

    if (x < 85 || x > width - 85) {
      speedX *= -1;
    }

    if (y < 120 || y > height - HUD_HEIGHT - 165) {
      speedY *= -1;
    }
  }

  boolean intersect(Laser laser) {
    return laser.x > x - 52 && laser.x < x + 52 && laser.y > y - 35 && laser.y < y + 40;
  }

  boolean intersect(spaceShip s) {
    return dist(x, y, s.x, s.y) < 68;
  }
}
