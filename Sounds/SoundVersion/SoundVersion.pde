import ddf.minim.*;
import ddf.minim.ugens.*;

Minim minim;
AudioOutput out;
AudioSample []player = new AudioSample[12];
AudioPlayer song;

// Used for oveall rotation
float angle;
// Cube count-lower/raise to test performance
int limit = 100;
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


int count;
int last = 0;
int rand;

void setup()
{
  size(800, 600, P3D); 

  background(0);
  // Instanciation d'un nouveau troupeau
  flock = new Flock();

  minim = new Minim(this);
  
  for(int i = 0; i < 12; i++)
  {
    player[i] = minim.loadSample("note" + i + ".wav");
  }
  song = minim.loadFile("music.mp3");
  for (int i = 0; i < limit - 1; i++)
  {
    flock.addElement(new Element(random(-150, 150), random(-150, 150), random(-150, 150)));
  }
}

void draw()
{
  background(0);
  //fill(200);
  stroke(neonColor);
  fill(neonColor);
  
  // Set up some different colored lights
  pointLight(51, 102, 255, 65, 60, 100); 
  pointLight(200, 40, 60, -65, -60, -150);

  // Raise overall light in scene 
  ambientLight(70, 70, 10); 

  // Center geometry in display windwow.
  // you can changlee 3rd argument ('0')
  // to move block group closer(+) / further(-)
  translate(width/2, height/2, -200 + mouseX * 0.65);
  
  

  // Rotate around y and x axes
  //rotateY(radians(angle));
  //rotateX(radians(angle));
  
  // Mouvement du troupeau
  flock.run();
  
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
  
  count = 0;
  // Parcours des particules
  for (int i = 0; i < flock.elements.size()-1; i++)
  {
    // On prend une particule ...
    Element elem1 = flock.elements.get(i);
    PVector p1 = elem1.location;
    for (int j = i + 1; j < flock.elements.size(); j++)
    {
      // ... et on parcourt toutes les autres
      Element elem2 = flock.elements.get(j);
      PVector p2 = elem2.location;
      // Si la distance entre les deux particules ciblées est inférieure à 50 ...
      if (dist(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z) < 75)
      {
        
        if(!elem1.linesid.hasValue(j))
        {
          
           
           for(int k = 0; k < 12; k++)
          {
              if(millis() > last + player[k].length())
             {
                rand = int(random(0,12));
                last = millis();
                player[rand].trigger();
              
             }
          }
           
           elem1.linesid.append(j);
           elem2.linesid.append(i);
        }

        // ... on trace un trait
        line(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z);        
        neonColor = lerpColor(from, to, float(frameCount%100) / 100.0f);                                                                                                               
        stroke(neonColor, 170);
      }
      else if(elem1.linesid.hasValue(j))
      {
        int id = 0;
        while(elem1.linesid.get(id) != j)
        {
          id ++;
        }
        elem1.linesid.remove(id);
        id = 0;
        while(elem2.linesid.get(id) != i)
        {
          id ++;
        }
        elem2.linesid.remove(id);
      }
    }
  }
  /* if(frameCount%30 == 0 && count > 0)
   {
       if(!song.isPlaying())
       {
            song.play();
       }
       else
       {
           song.pause();
       }
       count = 0;
   }
   else
   {
     song.pause();
   }*/
}

class Line
{
  
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
  IntList linesid;
  
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
    linesid = new IntList();
  }
  
  void run(ArrayList<Element> elements)
  {
    flock(elements);
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
    location.add(velocity);
    acceleration.mult(0);
  }
  
  void render()
  {
    pushMatrix();
    translate(location.x, location.y, location.z);
    sphere(10);
    stroke(neonColor);
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