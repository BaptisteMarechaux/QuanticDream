// Déclaration d'un troupeau de particules
Flock flock;


color red = color(255,0,0);
color green = color(0,255, 0);
color blue = color(0,0,255);

color from = color(0,0,0);
color to = blue;

void setup()
{
  // Définition de la taille de la fenêtre
  size(800, 600);
  // Instanciation d'un nouveau troupeau
  flock = new Flock();

  // Ajout de 80 particules dans le troupeau
  for (int i = 0; i < 80; i++)
  {
    flock.addBoid(new Boid(width/2,height/2));
  }
  
}

void draw()
{
  // Couleur du fond
  //background(255);
  // Tracé persistent de chaque objet dessiné
  fill(255, 5);
  // Ligne utile
  rect(0, 0, width, height);
  
  // Mouvement du troupeau
  flock.run();
  
  if(frameCount%100 == 0)
  {
    from = to;
    to = color(random(0,256),random(0,256),random(0,256));
  }
  // Parcours des particules
  for (int i = 0; i < flock.boids.size()-1; i++)
  {
    // On prend une particule ...
    PVector p1 = flock.boids.get(i).location;
    for (int j = i; j < flock.boids.size(); j++)
    {
      // ... et on parcourt toutes les autres
      PVector p2 = flock.boids.get(j).location;
      // Si la distance entre les deux particules ciblées est inférieure à 50 ...
      if (dist(p1.x, p1.y, p2.x, p2.y)<50)
      {
        // ... on trace un trait
        line(p1.x, p1.y, p2.x, p2.y);
        color neonColor;
        
        neonColor = lerpColor(from, to, float(frameCount%100) / 100.0f);
        stroke(neonColor,170);
      }
    }
  }
}

// Ajoute une nouvelle particule lors du clic de la souris
void mousePressed()
{
  flock.addBoid(new Boid(mouseX,mouseY));
}

// Classe Troupeau
class Flock
{
  // Liste de particules
  ArrayList<Boid> boids;

  // Constructeur
  Flock()
  {
    // Initialisation de la liste de particules
    boids = new ArrayList<Boid>();
  }

  // Envol des particules
  void run()
  {
    // Pour chaque particule ...
    for (Boid b : boids)
    {
      // ... on déclenche son mouvement en lui donnant toute la liste de particules
      b.run(boids);
    }
  }

  // Ajout d'une particule
  void addBoid(Boid b)
  {
    boids.add(b);
  }
}

// Classe Particule
class Boid
{
  PVector location;  // Position de la particule
  PVector velocity;  // Vecteur directionnel de la particule
  PVector acceleration;  // Accélération de la particule
  float r;  
  float maxforce;    // Force de direction maximale
  float maxspeed;    // Vitesse maximale

  // Constructeur
  Boid(float x, float y)
  {
    acceleration = new PVector(0, 0);

    // This is a new PVector method not yet implemented in JS
    // velocity = PVector.random2D();

    // Leaving the code temporarily this way so that this example runs in JS
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));

    // Position de la particule
    location = new PVector(x, y);
    // Définition des variables
    r = 2.0;
    maxspeed = 2.5f;
    maxforce = 0.03;
  }

  // Méthode d'envol de la particule
  void run(ArrayList<Boid> boids)
  {
    flock(boids);
    update();
    borders();
    render();
  }

  // Méthode d'application d'une force
  void applyForce(PVector force)
  {
    // On pourrait ajouter la masse ici
    acceleration.add(force);
  }

  // On ajoute une nouvelle accéleration à chaque appel selon trois critères
  void flock(ArrayList<Boid> boids)
  {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    // Multiplication arbitraire des forces
    sep.mult(1.5);
    ali.mult(1.4);
    coh.mult(0.7);
    // Ajout des vecteurs de force à l'accéleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }

  // Méthode de mise à jour de la position de la particule
  void update()
  {
    //Mise à jour de la direction
    velocity.add(acceleration);
    // Limite de la vitesse
    velocity.limit(maxspeed);
    location.add(velocity);
    // Reset de l'accélération à 0 à chaque cycle
    acceleration.mult(0);
  }

  // Méthode qui calcule et applique une force de direction vers une cible
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target)
  {
    // Vecteur qui pointe de la position de la particule à la position ciblée
    PVector desired = PVector.sub(target, location);
    // Mise à l'échelle de la vitesse maximale
    desired.normalize();
    desired.mult(maxspeed);

    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(maxspeed);

    // Application de la force selon la une vitesse minimale
    PVector steer = PVector.sub(desired, velocity);
    // Limite maximale de la force
    steer.limit(maxforce);
    return steer;
  }

  void render()
  {
    // Ligne qui modifie qqch
    //stroke(255);
    
    pushMatrix();  // ?
    translate(location.x, location.y);
    // Création d'un cercle
    int rand = int(random(1,4));
    if(rand == 1)
      ellipse(0, 0, random(5,10), random(5,10));
    else if(rand == 2)
       triangle(0, 0, 0, random(5,10), random(5,10), random(5,10));
    else
       rect(0, 0, 0, 0, random(5,10), random(5,10), random(5,10), random(5,10));
    
    fill(0,0,0);
    popMatrix();  // ?
  }

  // Quand une particule sort d'un côté de l'écran, elle revient du côté opposé
  void borders()
  {
    if (location.x < -r) location.x = width+r;
    if (location.y < -r) location.y = height+r;
    if (location.x > width+r) location.x = -r;
    if (location.y > height+r) location.y = -r;
  }

  // Méthode d'évitement des particules entre elles
  PVector separate (ArrayList<Boid> boids)
  {
    float desiredseparation = 35.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // Pour chaque particule ...
    for (Boid other : boids)
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

  // Méthode d'alignement des particules et d'homogénisation de la vitesse
  PVector align (ArrayList<Boid> boids)
  {
    float neighbordist = 40;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids)
    {
      float d = PVector.dist(location, other.location);
      if ((d > 0) && (d < neighbordist))
      {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0)
    {
      sum.div((float)count);
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // sum.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } 
    else
    {
      return new PVector(0, 0);
    }
  }

  // Méthode de cohésion du troupeau selon la position moyenne
  PVector cohesion (ArrayList<Boid> boids)
  {
    float neighbordist = 35;
    // On commence avec un vecteur vide puis on y ajoute toutes les positions
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids)
    {
      float d = PVector.dist(location, other.location);
      if ((d > 0) && (d < neighbordist))
      {
        // Ajout de la position d'une particule
        sum.add(other.location);
        count++;
      }
    }
    if (count > 0)
    {
      sum.div(count);
      // Les particules se groupent vers la position
      return seek(sum);
    } 
    else
    {
      return new PVector(0, 0);
    }
  }
}