//Firework fw;
float time;
ArrayList<Firework> fw;
void setup() {
  size(1000, 700);
  background(0, 0, 20);
  fw =  new ArrayList<Firework>();
  time = 0;
}

void draw() {
  background(10, 10, 30);
  festival();
  for (int i = 0; i < fw.size(); i++) {
    fw.get(i).update();
  }
  
  //saveFrame("frames/######.tif");
}

void festival() {
  for (int i = 0; i < fw.size(); i++) {
    if (fw.get(i).t > 400) fw.remove(i);
  }
}
void mousePressed() {
  fw.add(new Firework(mouseX, height + random(200,400)));
}

class Firework {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float t;
  boolean explode;
  PVector expL;
  float etime;
  boolean preExplode;
  float fade;
  float g;

  PVector cl;

  ArrayList<PVector> oldL;

  ArrayList<Particle> expPar;
  ArrayList<Particle> par;

  Firework(float xpos, float ypos) {
    frameRate(60);
    cl = new PVector(xpos, ypos);
    location = new PVector(xpos, ypos);
    velocity = new PVector(random(-0.8, 0.8), -5);
    g = 0.02;
    acceleration = new PVector(0, g);
    t = 0;
    oldL = new ArrayList<PVector>();
    oldL.add(new PVector(xpos, ypos));
    explode = false;
    preExplode = false;
    fade = 0;
    etime = 0;
    expL = new PVector(xpos, ypos);
    expPar = new ArrayList<Particle>();
    par = new ArrayList<Particle>();
  }
  
  void update() {
    preExplodeFade();
    system();
    display();
    explotion();
    
  }

  void system() {
    PVector f = new PVector(0, -0.02);
    velocity.add(acceleration);
    cl.add(velocity);
    location.add(velocity);

    if (t < 30) {
      applyForce(f);
      location.x += sin(radians(t*30))/4.0;
    } else if (t < 120) {
      location.x += sin(radians(t*25))/4.0;
    } else if (t < 220) {
      location.x += sin(radians(t*15))/4.0;
      preExplode = true;
    } else if (t > 250) {
      explode = true;
    }
    if (t < 300) {
      t++;
    }
    if (oldL.size() < 160) {
      oldL.add(new PVector(location.x, location.y));
    }
    if (fade > 253) {
      for (int i = 0; i < oldL.size(); i++) {
        oldL.remove(i);
      }
    }
  }

  void preExplodeFade() {
    if (preExplode == true) {
      if (fade < 255) {
        fade+=1.8;
      }
    }
  }

  void explotion() {
    int expN = 14;
    float parN = 12.0;
    if (explode == true) {
      if (etime == 0) {
        expL = new PVector(cl.x, cl.y);
        for (int i = 0; i < expN; i++) {
          expPar.add(new Particle(random(expL.x - 5, expL.x + 5), random(expL.y - 5, expL.y + 5), random(-0.5, 0.5), random(-0.5, 0.5)));
          expPar.get(i).setColor(random(200, 255), random(100, 255), random(150, 200), random(150, 200));
          expPar.get(i).size = random(5, 10);
        }
        for (int i = 0; i < 4; i++) {
          for (int j = 0; j < parN*(i+1); j++) {
            par.add(new Particle(expL.x, expL.y, random(i*sin(i/8.0)+0.3,i*sin(i/8.0)+0.9)*cos(radians(j*360.0/parN/(i+1)))/1.0, random(i*sin(i/8.0)+0.3,i*sin(i/8.0)+0.9)*sin(radians(j*360.0/parN/(i+1)))/1.0));
            par.get(par.size() - 1).setG(0.0025);
            par.get(par.size() - 1).setColor(random(230,255), random(200,230), random(140,160),255);
            par.get(par.size() - 1).isOrbit = true;
          }
        }
      }
      etime++;
      if (etime < 50) {
        for (int i = 0; i < expN; i++) {
          expPar.get(i).update();
          expPar.get(i).display();
          expPar.get(i).subAlpha(etime);
        }
      }
      if (etime > 2) {
        for (int i = 0; i < par.size(); i++) {    
            par.get(i).update();
            par.get(i).airResistance();
            par.get(i).displayOrbit();
        }
      }
    }
  }

  void applyForce(PVector f) {
    velocity.add(f);
  }

  void display() {
    noStroke();

    for (float i = 1.1; i < oldL.size () - 1; i++) {
      PVector old = oldL.get((int)i);
      fill(230, 200, 160, 255.0*i/oldL.size() - fade);

      //ellipse(old.x, old.y, 5.0*i/oldL.size(), 5.0*i/oldL.size());
      ellipse(old.x, old.y, 3.0 + 2.0*sin(i/oldL.size()), 3.0 + 2.0*sin(i/oldL.size()));
    } 
    //fill(200, 255.0 - fade);
    // ellipse(location.x, location.y, 5, 5);
  }
}

class Particle {
  PVector location;
  PVector velocity;
  PVector acceleration;
  float size;
  color thisC;
  float t;
  float R, G, B, alpha;
  boolean isOrbit;
  float fade;
  ArrayList<PVector> orbit;
  float air;
  Particle(float xpos, float ypos, float xsp, float ysp) {
    location = new PVector(xpos, ypos);
    velocity = new PVector(xsp, ysp);
    acceleration = new PVector(0, 0.001);
    size = 2.0;
    R = 255;
    G = 255;
    B = 255;
    alpha = 255;
    thisC = color(255, 255, 255);
    t = 0;
    orbit = new ArrayList<PVector>();
    orbit.add(new PVector(xpos, ypos));
    isOrbit = false;
    fade = 0.0;
    air = 0.99;
  }
  void update() {
    velocity.add(acceleration);
    location.add(velocity);
    t++;
    if (isOrbit == true) {
      if (t < 500) {
        orbit.add(new PVector(location.x,location.y));
      }
      if (orbit.size() > 100) {
        orbit.remove(0);
      }
    }
    if (t > 100) {
      if (fade < 260) {
        fade+=3;
      }
    }
    if (fade > 255) {
      for (int i = 0; i < orbit.size(); i++) {
        orbit.remove(i);
      }
    }
  }
  void airResistance() {
    velocity.mult(air);
  }
  
  void applyForce(PVector f) {
    velocity.add(f);
  }  

  void setG(float sg) {
    acceleration = new PVector(0,sg);
  }

  void setColor(float sR, float sG, float sB, float sA) {
    R = sR;
    G = sG;
    B = sB;
    alpha = sA;
    thisC = color(R, G, B, alpha);
  }

  void subAlpha(float A) {
    alpha -= A;
    thisC = color(R, G, B, alpha);
  }

  void display() {
    fill(thisC);
    pushMatrix();
    resetMatrix();
    translate(location.x, location.y);
    ellipse(0, 0, size, size);
    popMatrix();
  }
  
  void displayOrbit() {
    fill(R,G,B,alpha - fade);
    for (float i = 1.0; i < orbit.size() + 1; i++) {
      pushMatrix();
      resetMatrix();
      translate(orbit.get((int)i - 1).x, orbit.get((int)i - 1).y);
      ellipse(0,0,size*i/orbit.size(), size*i/orbit.size());
      popMatrix();
    }
  }
}