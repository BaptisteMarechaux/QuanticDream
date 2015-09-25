import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ddf.minim.*; 
import ddf.minim.analysis.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class quantic_dream_v066b extends PApplet {




Minim minim;
AudioPlayer song;
BeatDetect beat;

//Pour gradients
int Y_AXIS = 1;
int X_AXIS = 2;

int eRadius;

// Used for oveall rotation
float angle;
// Cube count-lower/raise to test performance
int limit = 40;
// Tableau d'\u00e9l\u00e9ments
Flock flock;

int red = color(255,0,0);
int green = color(0,255, 0);
int blue = color(0,0,255);
int from = color(0,0,0);
int to = blue;
int backFrom = color(0,0,0);
int backTo = color(0,0,0);
int back = color(0,0,0);
int neonColor;

Agent[] movers; // The thunderbolts 
int randHue; // storing random hue values 

PGraphics pg;
PShader blur;

float depth = 0;
boolean run = true;
int nbframeCount = 0;
boolean reset = false;
boolean pressUp = false;
boolean pressDown = false;

PImage blackGrad;
PImage rainbowGrad;


public void setup()
{
  
   
  //background(0);
  blackGrad = loadImage("BlackGrad.png");
  rainbowGrad = loadImage("Rainbow.png");
  // Instanciation d'un nouveau troupeau
  flock = new Flock();
  
  blur = loadShader("blur.glsl");

  minim = new Minim(this);
  song = minim.loadFile("Intro.mp3", 2048);
  song.play();
  song.loop();
  // a beat detection object song SOUND_ENERGY mode with a sensitivity of 10 milliseconds
  beat = new BeatDetect();
  ellipseMode(RADIUS);
  eRadius = 0;
  for (int i = 0; i < limit - 1; i++)
  {
    flock.addElement(new Element(random(-150,150), random(-150,150), random(-150,150), 10));
  }
  
  movers = new Agent[255]; // the more Agents, the denser the thunderstorm 
  
  randHue = (int) random(361); 


  for (int i = 0; i < movers.length; i++) { 
    movers[i] = new Agent(5+i, 1+i, randHue+i*PApplet.parseInt(random(10)), 100/(i+1)); 
  } 
}


public void draw()
{
  if(reset)
  background(0);
  //fill(200);
  
  beat.detect(song.mix);
  float a = map(eRadius, 20, 80, 60, 255);
  fill(255,255,255, a);
  if ( beat.isOnset() ){
    eRadius = 50;
    backTo = color(random(50,256),random(50,256),random(50,256));
  }
  
  int divWidth = 3, divHeight = 3;
  
  ellipse(50, 50, eRadius, eRadius);
  ellipse(50, height - 50, eRadius, eRadius);
  ellipse(width - 50,50, eRadius, eRadius);
  ellipse(width - 50, height - 50, eRadius, eRadius);
  
  eRadius *= 0.95f;
  if ( eRadius < 0) eRadius = 0;
  //fill(0);
  
  if(run){
    pushMatrix();
      if(frameCount%60 == 0)
      {
        backFrom = to;
        backTo = color(random(50,256),random(50,256),random(50,256));
      }
      back = lerpColor(from, to, PApplet.parseFloat(frameCount%100) / 100.0f);
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
  }
  // Set up some different colored lights
  //pointLight(51, 102, 255, 65, 60, 100); 
  //pointLight(200, 40, 60, -65, -60, -150);
  //ambientLight(random(0,256),random(0,256),random(0,256));

  // Raise overall light in scene 
  //ambientLight(70, 70, 10); 

  // Center geometry in display windwow.
  // you can changlee 3rd argument ('0')
  // to move block group closer(+) / further(-)
  //translate(width/2, height/2, -200 + mouseY * 0.65);
  
  if(pressUp){
    depth+=2;
  }
  if(pressDown){
    depth-=2;
  }
  
  pushMatrix();
  
  translate(width/2, height/2, -200 + depth * 4);
  
  // Rotate around y and x axes
  rotateY(radians(angle));
  if(run){
    // Used in rotate function calls above
    angle += 0.8f;
  }
  
  rotateX(-PI/6);
  rotateY(PI/3+mouseX/PApplet.parseFloat(width)*5 + PI);
  rotateX(-(PI/3+mouseY/PApplet.parseFloat(height)*5 + PI));

  
  // Mouvement du troupeau
  flock.run();
  
  if(run){
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
      float r = random(20,256);
      float g = random(20,256);
      float b = random(20,256);
      while(r+g+b < 255)
      {
        r = random(20,256);
        g = random(20,256);
        b = random(20,256);
      }
      
      backTo = color(r,g,b);
      
    }
    back = lerpColor(from, to, PApplet.parseFloat(frameCount%100) / 100.0f);
    fill(back, 2);
    
    if(frameCount%100 == 0)
    {
      from = to;
      to = color(random(20,256),random(20,256),random(20,256));
    }
  }
    filter(blur); 
    //filter(BLUR,2);
  if(run){
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
        // Si la distance entre les deux particules cibl\u00e9es est inf\u00e9rieure \u00e0 50 ...
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
          neonColor = lerpColor(from, to, PApplet.parseFloat(frameCount%100) / 100.0f);
          stroke(neonColor, 170);
        }
        else
        {
          e1.unlink(e2);
        }
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
          neonColor = lerpColor(from, to, PApplet.parseFloat(frameCount%100) / 100.0f);
          stroke(neonColor, 170);
        }
      }
    }
  }
  
   popMatrix();  
}

public void setGradient(int x, int y, float w, float h, int c1, int c2, int axis ) {

  noFill();

  if (axis == Y_AXIS) {  // Top to bottom gradient
    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      int c = lerpColor(c1, c2, inter);
      stroke(c);
      line(x, i, x+w, i);
    }
  }  
  else if (axis == X_AXIS) {  // Left to right gradient
    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      int c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, y, i, y+h);
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
  
  public void run()
  {
    for (Element e : elements)
    {
      e.run(elements);
    }
  }
  
  public void addElement(Element e)
  {
    elements.add(e);
  }
}

class Element
{
  float x, y, z; // Coordonn\u00e9es de la position de l'\u00e9l\u00e9ment
  PVector location; // Position de l'\u00e9l\u00e9ment
  PVector velocity; // Vecteur directionnel de la particule
  PVector acceleration; // Acc\u00e9l\u00e9ration de la particule
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
    this.radius = radius * random(0.5f, 2.5f);
    
    acceleration = new PVector(0, 0, 0);
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle), cos(angle));
    location = new PVector(x, y, z);
    r = 2.0f;
    maxspeed = 5f * random(0.1f, 6);
    maxforce = 2.5f * random(0.1f, 6);
  }
  
  public void run(ArrayList<Element> elements)
  {
    flock(elements);
    if(run)
    update();
    render();
    if (childElements.size() != 0)
    {
      for (Child c : childElements)
      {
        if(run)
        c.update();
        c.render();
      }
    }
  }
  
  public void applyForce(PVector force)
  {
    acceleration.add(force);
  }
  
  public void flock(ArrayList<Element> elements)
  {
    PVector sep = separate(elements);
    sep.mult(1.5f);
    applyForce(sep);
  }
  
  public void link(Element e)
  {
    linkedElements.add(e);
  }
  
  public void unlink(Element e)
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
  
  public void createChild()
  {
    childElements.add(new Child(location.x, location.y + 5, location.z, 10 * random(0.5f, 2.5f), this));
    println("Child created");
  }
  
  public void update()
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
  
  public void render()
  {
    pushMatrix();
      stroke(neonColor, 2);
      //noStroke();
      fill(neonColor);
      neonColor += 255 - location.x;
       if ( beat.isOnset() ){
        neonColor = color(255);
      }
      translate(location.x, location.y, location.z);
      sphereDetail(15);
      if (PApplet.parseInt(random(0,4)) <= 2)
        sphere(radius);
      else
        box(radius*1.5f);
    popMatrix();
  }
  
  public PVector separate (ArrayList<Element> elements)
  {
    float desiredseparation = 35.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // Pour chaque particule ...
    for (Element other : elements)
    {
      // ... on v\u00e9rifie 
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

    // Si le vecteur est sup\u00e9rieur \u00e0 0
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
  public void run() { 
    prevLoc = loc.get(); 
    // Velocity direction 
    //vel = PVector.random2D(); <-- this doesn't work in Processing.js! 
    vel.x = random(-1.0f,1.0f); 
    vel.y = random(-1.0f,1.0f); 
    // Velocity magnitude 
    vel.mult(step); 
    // Add velocity to Location 
    loc.add(vel); 
    offScreen(); // boundary behaviour 
    display(); 
  } 
  public void display() {  
    stroke(hue, 100, 100, alpha); 
    strokeWeight(thickness); 
    line(prevLoc.x, prevLoc.y, loc.x, loc.y); 
  } 

  public void offScreen() { 
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

  public void erase(int _hue) {  // method to set back location and hue of the bolt 
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
  public void display()  { 
    noStroke();
    fill(hue, 0, 0, alpha); 
    ellipse(loc.x, loc.y, rad, rad); 
  } 
} 

public void keyPressed() 
{ 
   if (key == 'p') {
     run = !run;
     if(run){
       frameCount = nbframeCount;
     }else{
      nbframeCount= frameCount; 
     }
   }
   if (key == 'r') {
     reset = !reset;
   } 
   
   switch(key) {
    case 'z':
      pressUp = true;
          break;
    case 's':
      pressDown = true;
      break;
      
    case  ' ':
    saveFrame("capture_####.png");
    break;
   default:
    // !CODED:
    break;
  } // switch
} 

public void keyReleased() {
  switch(key) {
    case 'z':
      pressUp = false;
          break;
    case 's':
      pressDown = false;
          break;
 
    default:
    // !CODED:
    break;
  } // switch
}
  public void settings() {  size(1500, 800, P3D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--stop-color=#cccccc", "quantic_dream_v066b" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
