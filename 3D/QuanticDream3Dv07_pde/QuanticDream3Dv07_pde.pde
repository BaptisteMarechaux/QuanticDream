// Used for oveall rotation
float angle;
// Cube count-lower/raise to test performance
int limit = 60;
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

boolean run = true;
int nbframeCount = 0;

float eyeX, eyeY, eyeZ;
float ang = 0;
int d = 600;
boolean pressUp = false;
boolean pressDown = false;

void setup()
{
  size(800, 600, P3D); 
  background(0);
  // Instanciation d'un nouveau troupeau
  flock = new Flock();
  
  for (int i = 0; i < limit - 1; i++)
  {
    flock.addElement(new Element(random(-150,150), random(-150,150), random(-150,150)));
  }
  
  eyeX = width/2;
  eyeY = height/2;
  eyeZ = d;
}

void draw()
{
  if(pressUp){
    ang+= 0.5;
  }
  if(pressDown){
    ang-= 0.5;
  }
   if (ang>=360)
        ang=0;
     eyeY = (height/2)-d*(sin(radians(ang)));
     eyeZ = d*cos(radians(ang));
  
  if (eyeZ<0)
    camera(eyeX, eyeY, eyeZ, 
    width/2, height/2, 0, 
    0, -1, 0);
  else
    camera(eyeX, eyeY, eyeZ, 
    width/2, height/2, 0, 
    0, 1, 0);
    
    
  //background(0);
  //fill(200);
  
  if(frameCount%60 == 0)
    {
      backFrom = to;
      backTo = color(random(0,256),random(0,256),random(0,256));
    }
    back = lerpColor(from, to, float(frameCount%100) / 100.0f);
    fill(back, 5);
    
  if(run){
    
    pushMatrix();
      translate(width/2,height/2,-1000);
      rectMode(CENTER);
      rect(0,0,2000,2000);
    popMatrix();
    pushMatrix();
      translate(width,-500,0);
      rectMode(CENTER);
      rotateX(180);
      rect(0,0,2000,2000);
    popMatrix();
    pushMatrix();
      translate(width/2,height/2,1000);
      rectMode(CENTER);
      rect(0,0,2000,2000);
    popMatrix();
    pushMatrix();
      translate(width,500,0);
      rectMode(CENTER);
      rotateX(180);
      rect(0,0,2000,2000);
    popMatrix();
  }else{
    background(0);
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
  //rotateY(radians(angle));
  //rotateX(radians(angle));
  rotateX(-PI/6);
  rotateY(PI/3+mouseX/float(height)*5 + PI);
  // Mouvement du troupeau
  flock.run();
  
  if(run){
    // Used in rotate function calls above
    angle += 0.2;
      
    if(frameCount%60 == 0)
    {
      backFrom = to;
      backTo = color(random(0,256),random(0,256),random(0,256));
    }
    back = lerpColor(from, to, float(frameCount%100) / 100.0f);
    fill(back, 2);
    
    if(frameCount%100 == 0)
    {
      from = to;
      to = color(random(0,256),random(0,256),random(0,256));
    }
    // Parcours des particules
    for (int i = 0; i < flock.elements.size()-1; i++)
    {
      // On prend une particule ...
      PVector p1 = flock.elements.get(i).location;
      
      for (int j = i; j < flock.elements.size(); j++)
      {
        // ... et on parcourt toutes les autres
        PVector p2 = flock.elements.get(j).location;
        // Si la distance entre les deux particules ciblées est inférieure à 50 ...
        if (dist(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z) < 75)
        {
          // ... on trace un trait
          strokeWeight(5);
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
  
  Element (float posX, float posY, float posZ)
  {
    x = posX;
    y = posY;
    z = posZ;
    location = new PVector(x, y, z);
    
    acceleration = new PVector(0, 0, 0);
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle), cos(angle));
    location = new PVector(x, y, z);
    r = 2.0;
    maxspeed = 2.5f;
    maxforce = 0.03;
  }
  
  void run(ArrayList<Element> elements)
  {
    flock(elements);
    if(run)
      update();
    render();
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
  
  void update()
  {
    velocity.add(acceleration);
    velocity.limit(maxspeed);
        if(location.x > 400 || location.y > 400 || location.z > 400 || location.x < -400 || location.y < -400 || location.z < -400)
    {
      velocity.mult(-1);
    }
    else{
      
    }
    location.add(velocity);
    acceleration.mult(0);
  }
  
  void render()
  {
    pushMatrix();
    translate(location.x, location.y, location.z);
    sphereDetail(15);
    sphere(10);
    stroke(neonColor);
    noStroke();
    fill(neonColor);
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

void keyPressed() 
{ 
   if (key == 'p') {
     run = !run;
     if(run){
       frameCount = nbframeCount;
     }else{
      nbframeCount= frameCount; 
     }
   }   
   
   switch(key) {
    // Move camera
   case CODED:
    if (keyCode == UP) {
      pressUp = true;
    }
    if (keyCode == DOWN) {
      pressDown = true;
    }
    break;
 
   default:
    // !CODED:
    break;
  } // switch
} 

void keyReleased() {
  switch(key) {
    // Move camera
  case CODED:
    if (keyCode == UP) {
      pressUp = false;
    }
    if (keyCode == DOWN) {
      pressDown = false;
    }
    break;
 
    default:
    // !CODED:
    break;
  } // switch
}