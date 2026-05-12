class Portal {
  float x, y;

  Portal(float x, float y) {
    this.x = x;
    this.y = y;
  }

  void display() {
    noFill();
    strokeWeight(5);
    stroke(83, 255, 190, 210);
    ellipse(x, y, 120, 170);
    stroke(255, 218, 73, 160);
    ellipse(x, y, 82, 122);
    noStroke();

    fill(83, 255, 190, 45);
    ellipse(x, y, 95, 145);

    fill(255);
    textAlign(CENTER, CENTER);
    textSize(16);
    text("SECRET", x, y - 100);
  }

  boolean intersect(spaceShip s) {
    return dist(x, y, s.x, s.y) < 82;
  }
}
