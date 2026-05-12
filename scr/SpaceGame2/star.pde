class Star {
  int x, y, w, speed, brightness;

  Star() {
    x = int(random(width));
    y = -10;
    w = int(random(2, 5));
    speed = int(random(2, 9));
    brightness = int(random(160, 255));
  }

  void display () {
    stroke(brightness, brightness, 255, 110);
    strokeWeight(1);
    line(x, y - speed, x, y + speed);
    noStroke();
    fill(brightness);
    ellipse(x, y, w, w);
  }

  void move () {
    y+=speed;
  }

  boolean reachedBottom() {
    return y>height+10;
  }
}
