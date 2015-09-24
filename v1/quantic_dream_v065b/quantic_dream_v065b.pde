// Used for oveall rotation
float angle;
// Cube count-lower/raise to test performance
int limit = 40;
// Tableau d'éléments
Flock flock;

color red = color(255,0,0);
color green = color(0,255, 0);
color blue = color(0,0,255);
color from = color(0,0,0);
color to = blue;
color backFrom = color(0,0,0);
color backTo = color(0,0,0);
color back = color(0,0,0);
color neonColor;

Agent[] movers; // The thunderbolts 
int randHue; // storing random hue values 

PGraphics pg;
PShader blur;


void setup()
{
  size(1440, 800, P3D); 
  //background(0);
  // Instanciation d'un nouveau troupeau
  flock = new Flock();
  
  blur = loadShader("blur.glsl");

  
  for (int i = 0; i < limit - 1; i++)
  {
    flock.addElement(new Element(random(-150,150), random(-150,150), random(-150,150), 10));
  }
  
  movers = new Agent[255]; // the more Agents, the denser the thunderstorm 
  
  randHue = (int) random(361); 


  for (int i = 0; i < movers.length; i++) { 
    movers[i] = new Agent(5+i, 1+i, randHue+i*int(random(10)), 100/(i+1)); 
  } 
}


void draw()
{
  //background(0);
  //fill(200);
  
  //fill(0);
  pushMatrix();
    if(frameCount%60 == 0)
    {
      backFrom = to;
      backTo = color(random(80,256),random(80,256),random(80,256));
    }
    back = lerpColor(from, to, float(frameCount%100) / 100.0f);
    //fill(0, 5);
    translate(width/2,height/2,-1000);
    rectMode(CENTER);
    //rect(0,0,5000,5000);
  popMatrix();
  
  for (Agent m : movers) { 
    m.run(); // display and update the thunderbolts 
  } 
  
  stroke(neonColor);
  fill(neonColor);
  
  // Set up some different colored lights
  //pointLight(51, 102, 255, 65, 60, 100); 
  //pointLight(200, 40, 60, -65, -60, -150);
  //ambientLight(random(0,256),random(0,256),random(0,256));

  // Raise overall light in scene 
  //ambientLight(70, 70, 10); 

  // Center geometry in display windwow.
  // you can changlee 3rd argument ('0')
  // to move block group closer(+) / further(-)
  translate(width/2, height/2, -200 + mouseY * 0.65);
  
  // Rotate around y and x axes
  rotateY(radians(angle));
  //rotateX(radians(angle));
  rotateX(-PI/6);
  rotateY(PI/3+mouseX/float(width)*5 + PI);
  rotateX(-(PI/3+mouseY/float(height)*5 + PI));

  
  // Mouvement du troupeau
  flock.run();
  
  // Used in rotate function calls above
  angle += 0.8;
  if(frameCount%600 == 0)
  {
   //background(0, 20, 80);  
    randHue = (int) random(361); 
    /*for (int i = 0; i < movers.length; i++) { 
      movers[i].erase( randHue+i*int(random(10)) ); 
    }*/
  }
  if(frameCount%60 == 0)
  {
    backFrom = to;
    backTo = color(random(128,256),random(128,256),random(128,256));
    
  }
  back = lerpColor(from, to, float(frameCount%100) / 100.0f);
  fill(back, 2);
  
  if(frameCount%100 == 0)
  {
    from = to;
    to = color(random(128,256),random(128,256),random(128,256));
  }
  filter(blur); 
  //filter(BLUR,2);
  // Parcours des particules
  for (int i = 0; i < flock.elements.size()-1; i++)
  {
    // On prend une particule ...
    PVector p1 = flock.elements.get(i).location;
    Element e1 = flock.elements.get(i);
    
    for (int j = i; j < flock.elements.size(); j++)
    {
      // ... et on parcourt toutes les autres
      PVector p2 = flock.elements.get(j).location;
      Element e2 = flock.elements.get(j);
      // Si la distance entre les deux particules ciblées est inférieure à 50 ...
      if (dist(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z) < 250)
      {
        e1.link(e2);
        e1.linkDuration++;
        if (e1.linkDuration > 2000)
        {
          e1.linkDuration = 0;
          e1.createChild();
        }
        // ... on trace un trait
        strokeWeight(6);
        line(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z);        
        neonColor = lerpColor(from, to, float(frameCount%100) / 100.0f);
        stroke(neonColor, 170);
      }
      else
      {
        e1.unlink(e2);
      }
    }
  }
  
  for (int i = 0; i < flock.elements.size()-1; i++)
  {
    if (flock.elements.get(i).childElements.size() != 0)
    {
      PVector p1 = flock.elements.get(i).location;
      for (int j = 0; j < flock.elements.get(i).childElements.size()-1; j++)
      {
        PVector p2 = flock.elements.get(i).childElements.get(j).location;
        if (dist(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z) < 300)
        {
          strokeWeight(6);
          line(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z);        
          neonColor = lerpColor(from, to, float(frameCount%100) / 100.0f);
          stroke(neonColor, 170);
        }
      }
    }
  }
}


class Flock
{
  ArrayList<Element> elements;
  
  Flock()
  {
    elements = new ArrayList<Element>();
  }
  
  void run()
  {
    for (Element e : elements)
    {
      e.run(elements);
    }
  }
  
  void addElement(Element e)
  {
    elements.add(e);
  }
}

class Element
{
  float x, y, z; // Coordonnées de la position de l'élément
  PVector location; // Position de l'élément
  PVector velocity; // Vecteur directionnel de la particule
  PVector acceleration; // Accélération de la particule
  float r;  
  float maxforce; // Force de direction maximale
  float maxspeed; // Vitesse maximale
  float radius;
  
  ArrayList<Element> linkedElements;
  int linkDuration;
  ArrayList<Child> childElements;
  
  Element (float posX, float posY, float posZ, float radius)
  {
    linkedElements = new ArrayList<Element>();
    childElements = new ArrayList<Child>();
    
    x = posX;
    y = posY;
    z = posZ;
    location = new PVector(x, y, z);
    this.radius = radius * random(0.5, 2.5);
    
    acceleration = new PVector(0, 0, 0);
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle), cos(angle));
    location = new PVector(x, y, z);
    r = 2.0;
    maxspeed = 5f * random(0.1, 6);
    maxforce = 2.5 * random(0.1, 6);
  }
  
  void run(ArrayList<Element> elements)
  {
    flock(elements);
    update();
    render();
    if (childElements.size() != 0)
    {
      for (Child c : childElements)
      {
        c.update();
        c.render();
      }
    }
  }
  
  void applyForce(PVector force)
  {
    acceleration.add(force);
  }
  
  void flock(ArrayList<Element> elements)
  {
    PVector sep = separate(elements);
    sep.mult(1.5);
    applyForce(sep);
  }
  
  void link(Element e)
  {
    linkedElements.add(e);
  }
  
  void unlink(Element e)
  {
    if (linkedElements.contains(e))
    {
      for (int i = 0; i < linkedElements.size()-1; i++)
      {
        if (linkedElements.get(i) == e)
          linkedElements.remove(i);
      }
    }
  }
  
  void createChild()
  {
    childElements.add(new Child(location.x, location.y + 5, location.z, 2, this));
    println("Child created");
  }
  
  void update()
  {
    velocity.add(acceleration);
    velocity.limit(maxspeed);
    if(location.x > 1200 || location.y > 1200 || location.z >1200 || location.x < -1200 || location.y < -1200 || location.z < -1200)
    {
      velocity.mult(-1);
    }
    location.add(velocity);
    acceleration.mult(0);
  }
  
  void render()
  {
    pushMatrix();
      stroke(neonColor, 2);
      //noStroke();
      fill(neonColor);
      translate(location.x, location.y, location.z);
      sphereDetail(15);
      if (int(random(0,4)) <= 2)
        sphere(radius);
      else
        box(radius*1.5);
    popMatrix();
  }
  
  PVector separate (ArrayList<Element> elements)
  {
    float desiredseparation = 35.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // Pour chaque particule ...
    for (Element other : elements)
    {
      // ... on vérifie 
      float d = PVector.dist(location, other.location);
      // Si la distance est entre 0 et un montant arbitraire
      if ((d > 0) && (d < desiredseparation))
      {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(location, other.location);
        diff.normalize();  // ?
        diff.div(d);  // ?
        steer.add(diff);  // ?
        count++;  // Compte des particules
      }
    }
    // ?
    if (count > 0)
    {
      steer.div((float)count);
    }

    // Si le vecteur est supérieur à 0
    if (steer.mag() > 0)
    {
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    
    return steer;
  }
}

class Child extends Element
{
  Element parent;
  
  Child(float posX, float posY, float posZ, float radius, Element parent)
  {
    super(posX, posY, posZ, radius);
    this.parent = parent;
  }
}

class Agent { 
  PVector loc, vel; 
  PVector prevLoc; 
  float step; 
  int hue;  
  float thickness, alpha; 
  Agent(float _step, float _thickness, int _hue, float _alpha) { 
    hue = _hue; 
    alpha = _alpha; 
    loc = new PVector(width/2, height/2); 
    vel = new PVector(0, 0); 
    prevLoc = loc.get(); 
    step = _step; 
    thickness = _thickness; 
  } 
  void run() { 
    prevLoc = loc.get(); 
    // Velocity direction 
    //vel = PVector.random2D(); <-- this doesn't work in Processing.js! 
    vel.x = random(-1.0,1.0); 
    vel.y = random(-1.0,1.0); 
    // Velocity magnitude 
    vel.mult(step); 
    // Add velocity to Location 
    loc.add(vel); 
    offScreen(); // boundary behaviour 
    display(); 
  } 
  void display() {  
    stroke(hue, 100, 100, alpha); 
    strokeWeight(thickness); 
    line(prevLoc.x, prevLoc.y, loc.x, loc.y); 
  } 

  void offScreen() { 
    if (loc.x > width) {  
      loc.x = 0;  
      prevLoc.x = loc.x; 
    } 


    if (loc.x < 0) {  
      loc.x = width;  
      prevLoc.x = loc.x; 
    } 


    if (loc.y > height) {  
      loc.y = 0;  
      prevLoc.y = loc.y; 
    } 

    if (loc.y < 0) {  
      loc.y = height;  
      prevLoc.y = loc.y; 
    } 
  } 

  void erase(int _hue) {  // method to set back location and hue of the bolt 
    loc.mult(0);  
    loc.x = width/2;  
    loc.y = height/2; 
    hue = _hue; 

  } 

} 

class Cloud extends Agent { 
  float rad; 
  Cloud(float _step, float _alpha, float _rad) { 
    super(_step, 0, 0, _alpha); 
    rad = _rad; 

  } 
  void display()  { 
    noStroke();
    fill(hue, 0, 0, alpha); 
    ellipse(loc.x, loc.y, rad, rad); 
  } 
} 