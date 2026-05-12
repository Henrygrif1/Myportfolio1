class Rock {
  int x, y, diam, speed;
  PImage r1;

  Rock() {
    x = int(random(width));
    y = -100;
    diam = int(random(175, 225));
    speed = int(random(5, 10));

    float rockType = random(10);
    if (rockType>6.6) {
      r1 = loadImage("rock1.png");
    } else if (rockType>5.0) {
      r1 = loadImage("rock2.png");
    } else {
      r1 = loadImage("rock3.png");
    }
  }

  void display() {
    imageMode(CENTER);
    noStroke();
    tint(215, 215, 215);
    image(r1, x, y, diam, diam);
    noTint();
  }

  void move () {
    y = y + int(speed * rockSpeedMultiplier);
  }

  boolean reachedBottom() {
    return y>height+100;
  }
}
