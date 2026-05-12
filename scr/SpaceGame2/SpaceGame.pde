//Henry Griffin | 17 sept 2025 | SpaceGame
import processing.sound.*;
spaceShip happy;
ArrayList<Rock> rocks = new ArrayList<Rock>();
ArrayList<Laser> lasers = new ArrayList<Laser>();
ArrayList<BossLaser> bossLasers = new ArrayList<BossLaser>();
ArrayList<BossMinion> bossMinions = new ArrayList<BossMinion>();
ArrayList<AlienMinion> alienMinions = new ArrayList<AlienMinion>();
ArrayList<SecretKey> secretKeys = new ArrayList<SecretKey>();
ArrayList<Portal> portals = new ArrayList<Portal>();
ArrayList<SecretBarrierLaser> barrierLasers = new ArrayList<SecretBarrierLaser>();
ArrayList<Star> stars = new ArrayList<Star>();
ArrayList<PowerUp> powups = new ArrayList<PowerUp>();
Timer rockTimer, puTimer;
final int MAX_HEALTH = 100;
final int HUD_HEIGHT = 96;
final int HUD_PADDING = 28;
final int BOSS_LEVEL = 8;
final int BOSS_MAX_HEALTH = 300;
final int BOSS_FORM_TWO_HEALTH = 450;
final int SECRET_BOSS_HEALTH = 650;

int score, rocksPassed, level;
int alertTimer, bossHealth, bossShootTimer, bossForm, activeMinionWave, currentBossMaxHealth;
int radialCooldown, radialChargeTimer, restartDelay, keySpawnTimer, barrierCooldown;
boolean play, gameEnded, gameWon, bossActive, bossBattleStarted, minionPhase, minionsReleased;
boolean formTwoWaveOneReleased, formTwoWaveTwoReleased, radialCharging;
boolean hasSecretKey, portalActive, secretBossStarted, alienPhase, secretWaveOneReleased, secretWaveTwoReleased, secretVictory;
boolean secretPortalReady;
float rockSpeedMultiplier, bossX, bossY, bossSpeedX, bossSpeedY;
String alertText;
color alertColor;

void setup() {
  //size (500, 500);
  fullScreen();
  background(20);
  happy = new spaceShip();
  puTimer = new Timer(5000);
  rockTimer = new Timer(1000);
  rockTimer.start();
  score = 0;
  rocksPassed = 0;
  play = false;
  gameEnded = false;
  gameWon = false;
  bossActive = false;
  bossBattleStarted = false;
  minionPhase = false;
  minionsReleased = false;
  formTwoWaveOneReleased = false;
  formTwoWaveTwoReleased = false;
  hasSecretKey = false;
  portalActive = false;
  secretBossStarted = false;
  alienPhase = false;
  secretWaveOneReleased = false;
  secretWaveTwoReleased = false;
  secretVictory = false;
  secretPortalReady = false;
  level = 1;
  rockSpeedMultiplier = 1.0;
  bossForm = 1;
  activeMinionWave = 0;
  currentBossMaxHealth = BOSS_MAX_HEALTH;
  bossHealth = currentBossMaxHealth;
  bossX = width/2;
  bossY = 140;
  bossSpeedX = 5;
  bossSpeedY = 3;
  bossShootTimer = 0;
  radialCooldown = 150;
  radialChargeTimer = 0;
  radialCharging = false;
  barrierCooldown = 120;
  keySpawnTimer = 360;
  restartDelay = 0;
  alertText = "";
  alertTimer = 0;
  alertColor = color(255, 218, 73);
}


void draw() {
  if (play == false) {
    if (gameWon) {
      if (restartDelay > 0) {
        restartDelay--;
      }
      winScreen();
    } else if (gameEnded) {
      if (restartDelay > 0) {
        restartDelay--;
      }
      gameOverScreen();
    } else {
      startScreen();
    }
  } else {
    drawSpaceBackground();
    if (puTimer.isFinished()) {
      powups.add(new PowerUp());
      puTimer.start();
    }
    int multiple = 1; 
    if (score > 0 && 500 * multiple <= score) {
      level = score / 500 + 1;
      multiple++; 
      rockSpeedMultiplier = 1.0 + (level - 1) * 0.2; // Increase speed gradually
      rockTimer.totalTime = 1000/level; // Minimum 300ms
    }
    updateSecretKeyAndPortal();
    if (level >= BOSS_LEVEL && bossBattleStarted == false) {
      startBossBattle();
    }
    //powerup display and mover
    for (int i = 0; i<powups.size(); i++) {
      PowerUp pu = powups.get(i);
      pu.display();
      pu.move();
      //check bottom


      if (pu.reachedBottom()) {
        powups.remove(i);
        i--;
        continue;
      }

      if (pu.intersect(happy)) {
        powups.remove(i);
        i--;
        if (pu.type =='H') {
          happy.health = min(MAX_HEALTH, happy.health + 35);
        } else {
          if (pu.type =='T') {
            happy.turretCount+=1;
            if (happy.turretCount>5) {
              happy.turretCount = 5;
            }
          } else if (pu.type == 'A') {
            happy.laserCount+=100;
          }
        }
      }
    }

    //distribute stars
    stars.add(new Star());
    //display and remove
    for (int i = 0; i < stars.size(); i++) {
      Star star = stars.get(i);
      star.display();
      star.move();
      if (star.reachedBottom()) {
        stars.remove(star);
        i--;
      }
      //   println("Stars" + stars.size());
    }
    if (bossActive) {
      updateBoss();
      updateBossLasers();
      updateBarrierLasers();
      drawBoss();
    }
    if (minionPhase) {
      updateBossMinions();
      drawMinionPhaseLabel();
    }
    if (alienPhase) {
      updateAlienMinions();
      drawAlienPhaseLabel();
    }

    //Distribution of rocks
    if (bossActive == false && minionPhase == false && alienPhase == false && rockTimer.isFinished()) {
      rocks.add(new Rock());
      rockTimer.start();
    }
    //display of all the rocks
    for (int i = 0; i < rocks.size(); i++) {
      Rock rock = rocks.get(i);
      rock.display();
      rock.move();
      if (happy.intersect(rock)) {
        rocks.remove(rock);
        score += rock.diam;
        happy.health = max(0, happy.health - 10);
      }

      if (rock.reachedBottom()) {
        rocksPassed++;
        score += 5;
        showAlert("+5 DODGE BONUS", color(255, 218, 73));
        rocks.remove(rock);
        i--;
      }
      // println("Rocks:" + rocks.size());
    }
    //display and remove unwanted lasers
    for (int i = lasers.size() - 1; i >= 0; i--) {
      Laser laser = lasers.get(i);
      laser.display();
      laser.move();

      if (laser.reachedTop()) {
        lasers.remove(i);
        continue;
      }

      if (alienPhase && laserHitsAlien(laser)) {
        lasers.remove(i);
        continue;
      }

      if (minionPhase && laserHitsMinion(laser)) {
        lasers.remove(i);
        continue;
      }

      if (bossActive && laserHitsBoss(laser)) {
        bossHealth -= 10;
        score += 10;
        showAlert("BOSS HIT", color(255, 218, 73));
        lasers.remove(i);

        handleBossDamage();
        if (gameWon) {
          return;
        }
        continue;
      }

      for (int j = rocks.size() - 1; j >= 0; j--) {
        Rock r = rocks.get(j);
        if (laser.intersect(r)) {
          score += 25;
          showAlert("+25 ROCK BLAST", color(83, 200, 255));
          lasers.remove(i);
          r.diam -= 70;
          if (r.diam<5) {
            rocks.remove(j);
          }
          break;
        }
      }
    }
    if (happy.health<1) {
      play = false;
      gameEnded = true;
      restartDelay = 45;
      gameOverScreen();
      return;
    }
    happy.display();
    happy.move(mouseX, mouseY);
    drawAlert();
    infoPanel();
  }
}

void drawSpaceBackground() {
  background(8, 11, 28);
  for (int y = 0; y < height; y += 4) {
    float shade = map(y, 0, height, 16, 34);
    stroke(8, 11, shade);
    line(0, y, width, y);
  }

  noStroke();
  fill(36, 77, 143, 30);
  ellipse(width * 0.18, height * 0.25, width * 0.55, height * 0.42);
  fill(83, 150, 255, 18);
  ellipse(width * 0.82, height * 0.45, width * 0.42, height * 0.32);
}

boolean mouseOverPlayAgainButton() {
  return mouseX > width/2 - 110 && mouseX < width/2 + 110 && mouseY > height/2 + 118 && mouseY < height/2 + 172;
}

void drawScreenButton(String label, float x, float y, float w, float h) {
  rectMode(CENTER);
  noStroke();
  fill(83, 150, 255, 215);
  rect(x, y, w, h);
  fill(255, 218, 73);
  rect(x - w/2 + 5, y, 10, h);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(24);
  text(label, x, y - 2);
}
void mousePressed() {
  if (gameWon && secretPortalReady && restartDelay <= 0 && mouseOverPlayAgainButton()) {
    startSecretBossBattle();
  } else if ((gameEnded || gameWon) && restartDelay <= 0 && mouseOverPlayAgainButton()) {
    resetGame();
  } else if (play && happy.fire()) {
    lasers.add(new Laser(happy.x, happy.y));
    happy.laserCount--;
  }
}

void resetGame() {
  happy = new spaceShip();
  rocks.clear();
  lasers.clear();
  bossLasers.clear();
  bossMinions.clear();
  alienMinions.clear();
  secretKeys.clear();
  portals.clear();
  barrierLasers.clear();
  stars.clear();
  powups.clear();
  score = 0;
  rocksPassed = 0;
  level = 1;
  rockSpeedMultiplier = 1.0;
  bossActive = false;
  bossBattleStarted = false;
  minionPhase = false;
  minionsReleased = false;
  formTwoWaveOneReleased = false;
  formTwoWaveTwoReleased = false;
  hasSecretKey = false;
  portalActive = false;
  secretBossStarted = false;
  alienPhase = false;
  secretWaveOneReleased = false;
  secretWaveTwoReleased = false;
  secretVictory = false;
  secretPortalReady = false;
  gameWon = false;
  bossForm = 1;
  activeMinionWave = 0;
  currentBossMaxHealth = BOSS_MAX_HEALTH;
  bossHealth = currentBossMaxHealth;
  bossX = width/2;
  bossY = 140;
  bossSpeedX = 5;
  bossSpeedY = 3;
  bossShootTimer = 0;
  radialCooldown = 150;
  radialChargeTimer = 0;
  radialCharging = false;
  barrierCooldown = 120;
  keySpawnTimer = 360;
  restartDelay = 0;
  alertText = "";
  alertTimer = 0;
  alertColor = color(255, 218, 73);
  rockTimer.totalTime = 1000;
  rockTimer.start();
  puTimer.start();
  gameEnded = false;
  gameWon = false;
  play = true;
  loop();
}



void updateSecretKeyAndPortal() {
  if (bossActive || minionPhase || alienPhase || secretBossStarted || secretPortalReady) {
    return;
  }

  if (bossBattleStarted == false && level >= 1 && level <= BOSS_LEVEL && hasSecretKey == false && portalActive == false && secretKeys.size() == 0) {
    keySpawnTimer--;
    if (keySpawnTimer <= 0) {
      secretKeys.add(new SecretKey());
      keySpawnTimer = int(random(520, 820));
    }
  }

  for (int i = secretKeys.size() - 1; i >= 0; i--) {
    SecretKey key = secretKeys.get(i);
    key.display();
    key.move();

    if (key.intersect(happy)) {
      secretKeys.remove(i);
      hasSecretKey = true;
      keySpawnTimer = 999999;
      showAlert("SECRET KEY FOUND", color(255, 218, 73));
    } else if (key.reachedBottom()) {
      secretKeys.remove(i);
    }
  }

  if (portalActive && play) {
    for (int i = portals.size() - 1; i >= 0; i--) {
      Portal portal = portals.get(i);
      portal.display();

      if (portal.intersect(happy)) {
        startSecretBossBattle();
      }
    }
  }
}

void startSecretBossBattle() {
  bossBattleStarted = true;
  secretBossStarted = true;
  hasSecretKey = false;
  portalActive = false;
  secretPortalReady = false;
  secretVictory = false;
  play = true;
  gameWon = false;
  gameEnded = false;
  bossActive = true;
  bossForm = 3;
  activeMinionWave = 0;
  currentBossMaxHealth = SECRET_BOSS_HEALTH;
  bossHealth = currentBossMaxHealth;
  bossX = width/2;
  bossY = 155;
  bossSpeedX = 11;
  bossSpeedY = 8;
  bossShootTimer = 24;
  radialCooldown = 95;
  radialChargeTimer = 0;
  radialCharging = false;
  barrierCooldown = 70;
  rocks.clear();
  secretKeys.clear();
  portals.clear();
  bossLasers.clear();
  bossMinions.clear();
  alienMinions.clear();
  barrierLasers.clear();
  showAlert("SECRET BOSS", color(83, 255, 190));
}

void startAlienPhase(int wave) {
  bossActive = false;
  alienPhase = true;
  activeMinionWave = wave;
  bossLasers.clear();
  barrierLasers.clear();
  alienMinions.clear();

  if (wave == 1) {
    secretWaveOneReleased = true;
    alienMinions.add(new AlienMinion(width/2 - 230, 170, 45, 1.45));
    alienMinions.add(new AlienMinion(width/2, 245, 45, 1.45));
    alienMinions.add(new AlienMinion(width/2 + 230, 170, 45, 1.45));
    showAlert("ALIEN ESCORT", color(83, 255, 190));
  } else {
    secretWaveTwoReleased = true;
    alienMinions.add(new AlienMinion(width/2 - 270, 155, 55, 1.85));
    alienMinions.add(new AlienMinion(width/2 - 90, 255, 55, 1.85));
    alienMinions.add(new AlienMinion(width/2 + 90, 255, 55, 1.85));
    alienMinions.add(new AlienMinion(width/2 + 270, 155, 55, 1.85));
    showAlert("ALIEN SWARM", color(83, 255, 190));
  }
}

void updateAlienMinions() {
  for (int i = alienMinions.size() - 1; i >= 0; i--) {
    AlienMinion alien = alienMinions.get(i);
    alien.display();
    alien.move();

    if (alien.intersect(happy) && frameCount % 18 == 0) {
      happy.health = max(0, happy.health - 5);
      showAlert("ALIEN HIT", color(83, 255, 190));
    }
  }

  if (alienMinions.size() == 0) {
    endAlienPhase();
  }
}

boolean laserHitsAlien(Laser laser) {
  for (int i = alienMinions.size() - 1; i >= 0; i--) {
    AlienMinion alien = alienMinions.get(i);
    if (alien.intersect(laser)) {
      alien.health -= 10;
      score += 20;
      showAlert("ALIEN HIT", color(83, 255, 190));

      if (alien.health <= 0) {
        alienMinions.remove(i);
        score += 95;
        showAlert("ALIEN DOWN", color(255, 218, 73));
      }
      return true;
    }
  }
  return false;
}

void endAlienPhase() {
  alienPhase = false;
  activeMinionWave = 0;
  bossActive = true;
  bossX = width/2;
  bossY = 155;
  bossSpeedX = 12;
  bossSpeedY = 9;
  bossShootTimer = 22;
  radialCooldown = 80;
  barrierCooldown = 65;
  showAlert("VOID BOSS RETURNS", color(83, 255, 190));
}

void drawAlienPhaseLabel() {
  rectMode(CORNER);
  noStroke();
  fill(9, 14, 31, 220);
  rect(width/2 - 175, 16, 350, 44);

  fill(83, 255, 190);
  textAlign(CENTER, CENTER);
  textSize(18);
  text("ALIEN WAVE " + activeMinionWave, width/2, 38);
}

void startBossBattle() {
  bossBattleStarted = true;
  bossActive = true;
  bossForm = 1;
  activeMinionWave = 0;
  currentBossMaxHealth = BOSS_MAX_HEALTH;
  bossHealth = currentBossMaxHealth;
  bossX = width/2;
  bossY = 145;
  bossSpeedX = 7;
  bossSpeedY = 4;
  bossShootTimer = 35;
  rocks.clear();
  bossLasers.clear();
  bossMinions.clear();
  showAlert("BOSS INCOMING", color(255, 59, 76));
}



void handleBossDamage() {
  if (bossForm == 1 && bossHealth <= BOSS_MAX_HEALTH/2 && minionsReleased == false) {
    startMinionPhase(1);
    return;
  }

  if (bossForm == 3 && bossHealth <= currentBossMaxHealth * 2/3 && secretWaveOneReleased == false) {
    startAlienPhase(1);
    return;
  }

  if (bossForm == 3 && bossHealth <= currentBossMaxHealth/3 && secretWaveTwoReleased == false) {
    startAlienPhase(2);
    return;
  }

  if (bossForm == 2 && bossHealth <= currentBossMaxHealth * 2/3 && formTwoWaveOneReleased == false) {
    startMinionPhase(2);
    return;
  }

  if (bossForm == 2 && bossHealth <= currentBossMaxHealth/3 && formTwoWaveTwoReleased == false) {
    startMinionPhase(3);
    return;
  }

  if (bossHealth <= 0) {
    if (bossForm == 1) {
      startSecondForm();
    } else {
      winBossFight();
    }
  }
}

void startSecondForm() {
  bossForm = 2;
  currentBossMaxHealth = BOSS_FORM_TWO_HEALTH;
  bossHealth = currentBossMaxHealth;
  bossActive = true;
  minionPhase = false;
  bossX = width/2;
  bossY = 145;
  bossSpeedX = 10;
  bossSpeedY = 7;
  bossShootTimer = 30;
  radialCooldown = 120;
  radialChargeTimer = 0;
  radialCharging = false;
  bossLasers.clear();
  bossMinions.clear();
  showAlert("FINAL FORM", color(255, 59, 76));
}

void winBossFight() {
  score += 800;
  bossActive = false;
  minionPhase = false;
  bossLasers.clear();
  bossMinions.clear();
  alienMinions.clear();
  barrierLasers.clear();
  secretVictory = bossForm == 3;
  secretPortalReady = hasSecretKey && secretVictory == false;
  if (secretPortalReady) {
    portalActive = true;
    portals.clear();
    portals.add(new Portal(width/2, height/2 + 5));
  }
  play = false;
  gameWon = true;
  restartDelay = 60;
  winScreen();
}

void startMinionPhase(int wave) {
  bossActive = false;
  minionPhase = true;
  activeMinionWave = wave;
  bossLasers.clear();
  bossMinions.clear();

  if (wave == 1) {
    minionsReleased = true;
    bossMinions.add(new BossMinion(width/2 - 180, 170, 40, 1.0));
    bossMinions.add(new BossMinion(width/2, 240, 40, 1.0));
    bossMinions.add(new BossMinion(width/2 + 180, 170, 40, 1.0));
    showAlert("MINIONS DEPLOYED", color(255, 59, 76));
  } else if (wave == 2) {
    formTwoWaveOneReleased = true;
    bossMinions.add(new BossMinion(width/2 - 240, 150, 45, 1.35));
    bossMinions.add(new BossMinion(width/2 - 80, 240, 45, 1.35));
    bossMinions.add(new BossMinion(width/2 + 80, 240, 45, 1.35));
    bossMinions.add(new BossMinion(width/2 + 240, 150, 45, 1.35));
    showAlert("FAST MINION WAVE", color(255, 59, 76));
  } else {
    formTwoWaveTwoReleased = true;
    bossMinions.add(new BossMinion(width/2 - 260, 150, 50, 1.65));
    bossMinions.add(new BossMinion(width/2 - 130, 260, 50, 1.65));
    bossMinions.add(new BossMinion(width/2, 185, 50, 1.65));
    bossMinions.add(new BossMinion(width/2 + 130, 260, 50, 1.65));
    bossMinions.add(new BossMinion(width/2 + 260, 150, 50, 1.65));
    showAlert("FINAL MINION WAVE", color(255, 59, 76));
  }
}

void updateBossMinions() {
  for (int i = bossMinions.size() - 1; i >= 0; i--) {
    BossMinion minion = bossMinions.get(i);
    minion.display();
    minion.move();

    if (minion.intersect(happy) && frameCount % 20 == 0) {
      happy.health = max(0, happy.health - 4);
      showAlert("MINION HIT", color(255, 59, 76));
    }
  }

  if (bossMinions.size() == 0) {
    endMinionPhase();
  }
}

boolean laserHitsMinion(Laser laser) {
  for (int i = bossMinions.size() - 1; i >= 0; i--) {
    BossMinion minion = bossMinions.get(i);
    if (minion.intersect(laser)) {
      minion.health -= 10;
      score += 15;
      showAlert("MINION HIT", color(83, 200, 255));

      if (minion.health <= 0) {
        bossMinions.remove(i);
        score += 75;
        showAlert("MINION DOWN", color(255, 218, 73));
      }
      return true;
    }
  }
  return false;
}

void endMinionPhase() {
  minionPhase = false;
  activeMinionWave = 0;
  bossActive = true;
  bossX = width/2;
  bossY = 145;

  if (bossForm == 2) {
    bossSpeedX = 10;
    bossSpeedY = 7;
    bossShootTimer = 30;
    radialCooldown = 100;
    radialChargeTimer = 0;
    radialCharging = false;
  } else {
    bossSpeedX = 8;
    bossSpeedY = 5;
    bossShootTimer = 25;
  }

  showAlert("BOSS RETURNS", color(255, 218, 73));
}

void drawMinionPhaseLabel() {
  rectMode(CORNER);
  noStroke();
  fill(9, 14, 31, 220);
  rect(width/2 - 175, 16, 350, 44);

  fill(255, 218, 73);
  textAlign(CENTER, CENTER);
  textSize(18);
  if (bossForm == 3) {
    text("ALIEN WAVE " + activeMinionWave, width/2, 38);
  } else if (bossForm == 2) {
    text("DEFEAT WAVE " + activeMinionWave, width/2, 38);
  } else {
    text("DEFEAT THE MINIONS", width/2, 38);
  }
}

void updateBoss() {
  bossX += bossSpeedX;
  bossY += bossSpeedY;

  if (bossX < 130 || bossX > width - 130) {
    bossSpeedX *= -1;
  }

  if (bossY < 120 || bossY > height - HUD_HEIGHT - 210) {
    bossSpeedY *= -1;
  }

  bossShootTimer--;
  if (bossShootTimer <= 0) {
    bossLasers.add(new BossLaser(bossX - 45, bossY + 48));
    bossLasers.add(new BossLaser(bossX + 45, bossY + 48));

    if (bossForm == 3) {
      bossLasers.add(new BossLaser(bossX, bossY + 65));
      bossLasers.add(new BossLaser(bossX - 80, bossY + 40));
      bossLasers.add(new BossLaser(bossX + 80, bossY + 40));
      bossShootTimer = 24;
    } else if (bossForm == 2) {
      bossLasers.add(new BossLaser(bossX, bossY + 65));
      bossShootTimer = 30;
    } else {
      bossShootTimer = 28;
    }
  }

  if (bossForm >= 2) {
    updateRadialAttack();
  }

  if (bossForm == 3) {
    updateBarrierAttack();
  }

  if (dist(happy.x, happy.y, bossX, bossY) < 130 && frameCount % 25 == 0) {
    happy.health = max(0, happy.health - 5);
    showAlert("BOSS COLLISION", color(255, 59, 76));
  }
}


void updateRadialAttack() {
  if (radialCharging) {
    radialChargeTimer--;
    if (radialChargeTimer <= 0) {
      fireRadialLasers();
      radialCharging = false;
      radialCooldown = 170;
    }
  } else {
    radialCooldown--;
    if (radialCooldown <= 0) {
      radialCharging = true;
      radialChargeTimer = 55;
      showAlert("RADIAL BLAST CHARGING", color(255, 218, 73));
    }
  }
}

void fireRadialLasers() {
  for (int i = 0; i < 12; i++) {
    float angle = TWO_PI / 12 * i;
    bossLasers.add(new BossLaser(bossX, bossY, cos(angle) * 8, sin(angle) * 8));
  }
  showAlert("RADIAL BLAST", color(255, 59, 76));
}

void drawRadialIndicator() {
  if (radialCharging) {
    float pulse = map(radialChargeTimer, 55, 0, 170, 55);

    noFill();
    stroke(255, 218, 73, 190);
    strokeWeight(4);
    ellipse(bossX, bossY, pulse, pulse);

    stroke(255, 59, 76, 160);
    strokeWeight(2);
    line(bossX - pulse/2, bossY, bossX + pulse/2, bossY);
    line(bossX, bossY - pulse/2, bossX, bossY + pulse/2);
    noStroke();

    fill(255, 218, 73);
    textAlign(CENTER, CENTER);
    textSize(16);
    text("CHARGING", bossX, bossY - 78);
  }
}


void updateBarrierAttack() {
  barrierCooldown--;
  if (barrierCooldown <= 0) {
    if (random(1) < 0.5) {
      float x = random(140, width - 140);
      barrierLasers.add(new SecretBarrierLaser(x, 80, x, height - HUD_HEIGHT - 20));
    } else {
      float y = random(140, height - HUD_HEIGHT - 140);
      barrierLasers.add(new SecretBarrierLaser(40, y, width - 40, y));
    }
    barrierCooldown = 120;
    showAlert("LASER WALL", color(83, 255, 190));
  }
}

void updateBarrierLasers() {
  for (int i = barrierLasers.size() - 1; i >= 0; i--) {
    SecretBarrierLaser wall = barrierLasers.get(i);
    wall.display();
    wall.update();

    if (wall.intersect(happy) && frameCount % 12 == 0) {
      happy.health = max(0, happy.health - 7);
      showAlert("LASER WALL HIT", color(83, 255, 190));
    }

    if (wall.finished()) {
      barrierLasers.remove(i);
    }
  }
}

void updateBossLasers() {
  for (int i = bossLasers.size() - 1; i >= 0; i--) {
    BossLaser bossLaser = bossLasers.get(i);
    bossLaser.display();
    bossLaser.move();

    if (bossLaser.intersect(happy)) {
      happy.health = max(0, happy.health - 12);
      showAlert("BOSS LASER HIT", color(255, 59, 76));
      bossLasers.remove(i);
      continue;
    }

    if (bossLaser.reachedBottom()) {
      bossLasers.remove(i);
    }
  }
}

void drawBoss() {
  rectMode(CENTER);
  noStroke();

  fill(255, 59, 76, 70);
  triangle(bossX - 120, bossY + 25, bossX + 120, bossY + 25, bossX, bossY + 125);

  if (bossForm == 3) {
    fill(20, 92, 85);
    rect(bossX, bossY, 195, 96);
    fill(83, 255, 190);
    rect(bossX, bossY - 28, 150, 36);
  } else if (bossForm == 2) {
    fill(50, 32, 105);
    rect(bossX, bossY, 180, 92);
    fill(130, 70, 210);
    rect(bossX, bossY - 26, 140, 38);
  } else {
    fill(120, 30, 62);
    rect(bossX, bossY, 150, 78);
    fill(184, 44, 83);
    rect(bossX, bossY - 22, 118, 32);
  }

  fill(255, 218, 73);
  rect(bossX - 38, bossY - 4, 26, 18);
  rect(bossX + 38, bossY - 4, 26, 18);

  fill(83, 150, 255);
  triangle(bossX - 75, bossY + 39, bossX - 135, bossY + 78, bossX - 75, bossY + 5);
  triangle(bossX + 75, bossY + 39, bossX + 135, bossY + 78, bossX + 75, bossY + 5);

  drawRadialIndicator();
  drawBossHealthBar();
}

void drawBossHealthBar() {
  int barW = 360;
  int barH = 18;
  int barX = width/2 - barW/2;
  int barY = 34;
  float bossPercent = constrain(bossHealth / float(currentBossMaxHealth), 0, 1);

  rectMode(CORNER);
  noStroke();
  fill(9, 14, 31, 230);
  rect(barX - 18, barY - 22, barW + 36, 58);

  fill(255);
  textAlign(CENTER, TOP);
  textSize(16);
  if (bossForm == 3) {
    text("VOID GATEKEEPER", width/2, barY - 18);
  } else if (bossForm == 2) {
    text("ASTEROID KING - FINAL FORM", width/2, barY - 18);
  } else {
    text("ASTEROID KING", width/2, barY - 18);
  }

  fill(255, 255, 255, 35);
  rect(barX, barY, barW, barH);
  fill(255, 59, 76);
  rect(barX, barY, barW * bossPercent, barH);
}

boolean laserHitsBoss(Laser laser) {
  return laser.x > bossX - 95 && laser.x < bossX + 95 && laser.y > bossY - 60 && laser.y < bossY + 95;
}

void showAlert(String message, color c) {
  alertText = message;
  alertColor = c;
  alertTimer = 45;
}

void drawAlert() {
  if (alertTimer > 0) {
    textAlign(CENTER, CENTER);
    textSize(28);
    fill(red(alertColor), green(alertColor), blue(alertColor), alertTimer * 5);
    text(alertText, width/2, height - HUD_HEIGHT - 45);
    alertTimer--;
  }
}

void infoPanel() {
  int panelY = height - HUD_HEIGHT;
  rectMode(CORNER);
  noStroke();
  fill(9, 14, 31, 210);
  rect(0, panelY, width, HUD_HEIGHT);

  stroke(83, 150, 255);
  strokeWeight(3);
  line(0, panelY, width, panelY);
  noStroke();

  drawScoreCard(HUD_PADDING, panelY + 18, 190, 60, "SCORE", str(score), color(255, 218, 73));
  drawScoreCard(HUD_PADDING + 210, panelY + 18, 190, 60, "LEVEL", str(level), color(83, 150, 255));
  drawScoreCard(HUD_PADDING + 420, panelY + 18, 230, 60, "ROCKS PASSED", str(rocksPassed), color(190, 203, 218));

  drawHealthBar(width - 390, panelY + 20, 170, 18);
  drawAmmoBar(width - 185, panelY + 20, 150, 18);
}

void drawScoreCard(int x, int y, int w, int h, String label, String value, color accent) {
  rectMode(CORNER);
  fill(255, 255, 255, 24);
  stroke(255, 255, 255, 70);
  strokeWeight(2);
  rect(x, y, w, h);

  noStroke();
  fill(accent);
  rect(x, y, 6, h);

  textAlign(LEFT, TOP);
  fill(190, 203, 218);
  textSize(14);
  text(label, x + 18, y + 9);

  fill(255);
  textSize(28);
  text(value, x + 18, y + 27);
}

void drawHealthBar(int x, int y, int w, int h) {
  float healthPercent = constrain(happy.health / float(MAX_HEALTH), 0, 1);

  textAlign(LEFT, TOP);
  fill(255);
  textSize(16);
  text("HEALTH", x, y);

  fill(255, 255, 255, 35);
  rect(x, y + 25, w, h);

  color healthColor = lerpColor(color(255, 59, 76), color(51, 224, 139), healthPercent);
  fill(healthColor);
  rect(x, y + 25, w * healthPercent, h);

  fill(255);
  textAlign(RIGHT, TOP);
  text(happy.health + "%", x + w, y);
}

void drawAmmoBar(int x, int y, int w, int h) {
  float ammoPercent = constrain(happy.laserCount / 100.0, 0, 1);

  textAlign(LEFT, TOP);
  fill(255);
  textSize(16);
  text("AMMO", x, y);

  fill(255, 255, 255, 35);
  rect(x, y + 25, w, h);

  fill(83, 150, 255);
  rect(x, y + 25, w * ammoPercent, h);

  fill(255);
  textAlign(RIGHT, TOP);
  text(happy.laserCount, x + w, y);
}
void startScreen() {
  drawSpaceBackground();

  rectMode(CENTER);
  noStroke();
  fill(9, 14, 31, 225);
  rect(width/2, height/2, 660, 420);

  stroke(83, 150, 255);
  strokeWeight(4);
  line(width/2 - 285, height/2 - 158, width/2 + 285, height/2 - 158);
  noStroke();

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(66);
  text("SPACE GAME", width/2, height/2 - 108);

  fill(255, 218, 73);
  textSize(24);
  text("Blast rocks. Grab powerups. Dodge for bonus points.", width/2, height/2 - 48);

  fill(190, 203, 218);
  textSize(20);
  text("Move with the mouse", width/2, height/2 + 2);
  text("Click to shoot", width/2, height/2 + 34);
  text("Find a key to open a secret boss portal", width/2, height/2 + 66);

  drawScreenButton("LAUNCH", width/2, height/2 + 145, 220, 54);

  if (mousePressed) {
    resetGame();
  }
}
void gameOverScreen() {
  drawSpaceBackground();

  rectMode(CENTER);
  noStroke();
  fill(9, 14, 31, 235);
  rect(width/2, height/2, 560, 360);

  stroke(83, 150, 255);
  strokeWeight(4);
  line(width/2 - 240, height/2 - 130, width/2 + 240, height/2 - 130);
  noStroke();

  fill(255, 218, 73);
  textAlign(CENTER, CENTER);
  textSize(56);
  text("GAME OVER", width/2, height/2 - 78);

  fill(255);
  textSize(34);
  text("Final Score: " + score, width/2, height/2 - 10);

  fill(190, 203, 218);
  textSize(22);
  text("Rocks Passed: " + rocksPassed, width/2, height/2 + 42);
  text("Level Reached: " + level, width/2, height/2 + 76);

  if (restartDelay > 0) {
    drawScreenButton("GAME OVER", width/2, height/2 + 145, 220, 54);
  } else {
    drawScreenButton("PLAY AGAIN", width/2, height/2 + 145, 220, 54);
  }
}

void winScreen() {
  drawSpaceBackground();

  rectMode(CENTER);
  noStroke();
  fill(9, 14, 31, 235);
  rect(width/2, height/2, 620, 380);

  stroke(255, 218, 73);
  strokeWeight(4);
  line(width/2 - 270, height/2 - 138, width/2 + 270, height/2 - 138);
  noStroke();

  fill(255, 218, 73);
  textAlign(CENTER, CENTER);
  textSize(58);
  text("YOU WIN!", width/2, height/2 - 88);

  fill(255);
  textSize(32);
  if (secretPortalReady) {
    text("The key opens a hidden portal", width/2, height/2 - 28);
  } else if (secretVictory) {
    text("The Void Gatekeeper is defeated", width/2, height/2 - 28);
  } else {
    text("The Asteroid King is defeated", width/2, height/2 - 28);
  }

  fill(190, 203, 218);
  textSize(22);
  if (secretPortalReady) {
    if (portals.size() > 0) {
      portals.get(0).display();
    }
  } else {
    text("Final Score: " + score, width/2, height/2 + 28);
    text("Rocks Passed: " + rocksPassed + "   Level: " + level, width/2, height/2 + 64);
  }

  if (restartDelay > 0) {
    if (secretPortalReady) {
      drawScreenButton("PORTAL READY", width/2, height/2 + 145, 240, 54);
    } else {
      drawScreenButton("VICTORY", width/2, height/2 + 145, 220, 54);
    }
  } else {
    if (secretPortalReady) {
      drawScreenButton("ENTER PORTAL", width/2, height/2 + 145, 240, 54);
    } else {
      drawScreenButton("PLAY AGAIN", width/2, height/2 + 145, 220, 54);
    }
  }
}
