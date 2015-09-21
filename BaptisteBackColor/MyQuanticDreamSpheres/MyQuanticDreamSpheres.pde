PGraphics pg;

float colorR;
float colorG;
float colorB;

float backR = random(128, 255);
float backG = random(128, 255);
float backB = random(128, 255);
  
float randI;

/*
void setup() {
  size(640, 360);
  pg = createGraphics(400, 200);

}

void draw() {
  fill(0, 12);
  rect(0, 0, width, height);
  
  fill(255);
  noStroke();
  ellipse(mouseX, mouseY, 60, 60);
  
  pg.beginDraw();
  pg.background(51);
  pg.noFill();
  pg.stroke(255);
  pg.ellipse(mouseX-120, mouseY-60, 60, 60);
  pg.endDraw();
  
  // Draw the offscreen buffer to the screen with image() 
  //image(pg, 120, 60); 
}
*/

Flock flock;
ArrayList<PVector> points = new ArrayList<PVector>();
ArrayList<PVector> velocities = new ArrayList<PVector>();

void setup() {
  size(800, 600);
  flock = new Flock();
  // Add an initial set of boids into the system
  /*for (int i = 0; i < 150; i++) {
  }*/
  for (int i = 0; i < 80; i++)
  {
    flock.addBoid(new Boid(width/2,height/2));
    //points.add(new PVector(random(width), random(height)));
    //velocities.add(new PVector(random(-1,1), random(-1,1)));
  }
  
  colorR = random(128, 255);
  colorG = random(128, 255);
  colorB = random(128, 255);
  
  randI = random(0,1);
  
}

void draw()
{
  //background(255);
  randI +=0.1;
  fill(colorR+50*cos(randI), colorG+50*cos(randI), colorB+50*cos(randI), 5);
  rect(0, 0, width, height);

  flock.run();
  for (int i = 0; i < flock.boids.size()-1; i++)
  {
    //PVector p1 = points.get(i);
    PVector p1 = flock.boids.get(i).location;
    for (int j = i; j < flock.boids.size(); j++)
    {
      //PVector p2 = points.get(j);
      PVector p2 = flock.boids.get(j).location;
      if (dist(p1.x, p1.y, p2.x, p2.y)<50)
      {
        line(p1.x, p1.y, p2.x, p2.y);
      }
    }
  }
  move();
}

void move()
{
   for (int i = 0; i < points.size()-1; i++)
   {
    PVector p = points.get(i);
    PVector v = velocities.get(i);
    p.add(v);
    if(p.x > width)p.x -= width;
    if(p.y > height)p.y -= height;
    if(p.x < 0)p.x += width;
    if(p.y < 0)p.y += height;
   }
}

// Add a new boid into the System
void mousePressed()
{
  flock.addBoid(new Boid(mouseX,mouseY));
}

// The Flock (a list of Boid objects)
class Flock
{
  ArrayList<Boid> boids; // An ArrayList for all the boids

  Flock()
  {
    boids = new ArrayList<Boid>(); // Initialize the ArrayList
  }

  void run()
  {
    for (Boid b : boids)
    {
      b.run(boids);  // Passing the entire list of boids to each boid individually
    }
  }

  void addBoid(Boid b)
  {
    boids.add(b);
  }
}

// The Boid class
class Boid
{
  PVector location;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed

  Boid(float x, float y)
  {
    acceleration = new PVector(0, 0);

    // This is a new PVector method not yet implemented in JS
    // velocity = PVector.random2D();

    // Leaving the code temporarily this way so that this example runs in JS
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));
    velocities.add(velocity);

    location = new PVector(x, y);
    r = 2.0;
    maxspeed = 56;
    maxforce = 0.03;
  }

  void run(ArrayList<Boid> boids)
  {
    flock(boids);
    update();
    borders();
    render();
  }

  void applyForce(PVector force)
  {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<Boid> boids)
  {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    // Arbitrarily weight these forces
    sep.mult(1.5);
    ali.mult(1.0);
    coh.mult(1.0);
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }

  // Method to update location
  void update()
  {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    location.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target)
  {
    PVector desired = PVector.sub(target, location);  // A vector pointing from the location to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);

    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }

  void render()
  {
    // Draw a triangle rotated in the direction of velocity
    float theta = velocity.heading2D() + radians(90);
    // heading2D() above is now heading() but leaving old syntax until Processing.js catches up
    
    //fill(255, 10);
    //stroke(255);
    pushMatrix();
    translate(location.x, location.y);
    rotate(theta);
    /*beginShape(TRIANGLES);
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape();*/
   
   fill(colorR, colorG, colorB, 255);
   ellipse(0, 0, 2, 2);
    
    //velocities.clear();
    for (int i = 0; i < 80; i++)
    {
      velocities.add(new PVector(location.x, location.y));
    }
    popMatrix();
  }

  // Wraparound
  void borders()
  {
    if (location.x < -r) location.x = width+r;
    if (location.y < -r) location.y = height+r;
    if (location.x > width+r) location.x = -r;
    if (location.y > height+r) location.y = -r;
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Boid> boids)
  {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids)
    {
      float d = PVector.dist(location, other.location);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation))
      {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(location, other.location);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0)
    {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
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

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList<Boid> boids)
  {
    float neighbordist = 50;
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

  // Cohesion
  // For the average location (i.e. center) of all nearby boids, calculate steering vector towards that location
  PVector cohesion (ArrayList<Boid> boids)
  {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all locations
    int count = 0;
    for (Boid other : boids)
    {
      float d = PVector.dist(location, other.location);
      if ((d > 0) && (d < neighbordist))
      {
        sum.add(other.location); // Add location
        count++;
      }
    }
    if (count > 0)
    {
      sum.div(count);
      return seek(sum);  // Steer towards the location
    } 
    else
    {
      return new PVector(0, 0);
    }
  }
}