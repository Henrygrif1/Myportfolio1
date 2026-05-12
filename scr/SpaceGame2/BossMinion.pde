class BossMinion {
  float x, y, speedX, speedY, speedBoost;
  int health, maxHealth;

  BossMinion(float x, float y) {
    this(x, y, 40, 1.0);
  }

  BossMinion(float x, float y, int health, float speedBoost) {
    this.x = x;
    this.y = y;
    this.health = health;
    maxHealth = health;
    this.speedBoost = speedBoost;
    speedX = random(3, 6) * speedBoost;
    speedY = random(2, 4) * speedBoost;
    if (random(1) < 0.5) {
      speedX *= -1;
    }
  }

  void display() {
    rectMode(CENTER);
    noStroke();

    if (speedBoost > 1.4) {
      fill(50, 32, 105);
      rect(x, y, 84, 50);
      fill(130, 70, 210);
      rect(x, y - 14, 62, 18);
    } else {
      fill(80, 22, 50);
      rect(x, y, 76, 46);
      fill(184, 44, 83);
      rect(x, y - 13, 54, 16);
    }

    fill(255, 218, 73);
    rect(x - 18, y + 3, 12, 10);
    rect(x + 18, y + 3, 12, 10);

    fill(83, 150, 255);
    triangle(x - 38, y + 20, x - 65, y + 43, x - 38, y);
    triangle(x + 38, y + 20, x + 65, y + 43, x + 38, y);

    drawHealthBar();
  }

  void drawHealthBar() {
    float amount = constrain(health / float(maxHealth), 0, 1);
    rectMode(CORNER);
    fill(255, 255, 255, 45);
    rect(x - 34, y - 42, 68, 6);
    fill(255, 59, 76);
    rect(x - 34, y - 42, 68 * amount, 6);
  }

  void move() {
    x += speedX;
    y += speedY;

    if (x < 80 || x > width - 80) {
      speedX *= -1;
    }

    if (y < 120 || y > height - HUD_HEIGHT - 170) {
      speedY *= -1;
    }
  }

  boolean intersect(Laser laser) {
    return laser.x > x - 48 && laser.x < x + 48 && laser.y > y - 35 && laser.y < y + 42;
  }

  boolean intersect(spaceShip s) {
    return dist(x, y, s.x, s.y) < 70;
  }
}
