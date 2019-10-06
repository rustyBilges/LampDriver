// All this code deals with Lamp objects, and an array of Lamp objects (LampArray) - as seen on-screen. 
// For most modes (1-4) this code is only called in order to animate the on-screen lamps.

// However, in mode 5 this code is called is used to updated both the on-screen and real-world lamps simultaneously.
// I think this approach is nicer (although it could do with improving!) and ensures the behaviour onscreen is the same as on the actual lamps.
// Modes 1-4 were implemented in a rush so code was written separately to drive the OPC pixels individually.


class LampArray{
  int n;
  Lamp[] lamps;
  boolean withPixels;
  
  LampArray(int n, float eRadius, float lRadius, OPC opc, boolean withPixels){
    this.n = n;
    this.withPixels = withPixels;
    
    lamps = new Lamp[n];
    for (int i=0; i<8; i++){
      lamps[i] = new Lamp((i+1)*width/10, height-(eRadius*1.5), eRadius, lRadius, opc, i, withPixels);
    }
  }
  void update(){
    for (Lamp lamp : lamps){
      lamp.update();
    }
  }
  Led getLed(int i){
    int lampID = int(i/63);
    int pixel = i%63;
    return lamps[lampID].leds[pixel];
  }
  Led getLampLed(int la, int le){
    return lamps[la].leds[le];
  }
}



class Lamp { 
  int lampID;
  float xpos, ypos, radius; 
  Led[] leds;
  Action action, previousAction;
  boolean withPixels;
  
  Lamp (float x, float y, float r, float l, OPC opc, int id, boolean withPixels) {
    this.withPixels = withPixels;
    lampID = id;
    xpos = x;
    ypos = y;  
    radius = r;
    action = new StaticBlock(0,0,0);
    previousAction = new StaticBlock(0,0,0);
    
    leds = new Led[24];
    for (int i=0; i<24; i++){
      leds[i] = new Led(x+(r*cos(i*PI/12)),y+(r*sin(i*PI/12)),l, opc, lampID, i, withPixels);
    }
  } 
  
  void setAction(Action newAction){
    this.previousAction = this.action.copy();
    this.action = newAction;
  }
  
  void update() {
    this.action.updateLamp(this);
  }
  void revertToPrevious(){
    this.action = previousAction;
  }
} 

class Led { 
  int ledID;
  float xpos, ypos, radius; 
  float h, s, b;
  boolean withPixels;
  OPC opc;
  Led (float x, float y, float r, OPC opc, int lampID, int id, boolean withPixels) {
    this.withPixels = withPixels;
    this.ledID = 64*lampID + id;
    this.opc = opc;
    xpos = x;
    ypos = y;  
    radius = r;
    //opc.led(ledID,int(xpos),int(ypos));
  } 
  void update(float h, float s, float b) {
    this.h = h;
    this.s = s;
    this.b = b;
    fill(h,s,b);
    ellipse(xpos, ypos, radius, radius);
    if (withPixels){opc.setPixel(this.ledID, color(h,s,b));}
  } 
  void updateC(color c) {
    
    fill(c);
    ellipse(xpos, ypos, radius, radius);
    if (withPixels){opc.setPixel(this.ledID, c);}
  }
} 

interface Action{
  Action copy();
  void updateLamp(Lamp lamp);
  void incrementCounter(Lamp lamp);
  float getH();
}

class StaticBlock implements Action{
  int actionSpeed, actionCounter;
  float h, s, b;
  
  StaticBlock(float h, float s, float b){
    actionCounter = 0;
    this.h = h;
    this.s = s;
    this.b = b;
  }
  Action copy(){
    Action newAction = new StaticBlock(this.h, this.s, this.b);
    return newAction;
  }
  void updateLamp(Lamp lamp){  
    for (int i=0; i<24; i++){
      lamp.leds[i].update(h,s,b);
    }
  }
  void incrementCounter(Lamp lamp){
    print("No effect for statis block colour.");
  }
  float getH(){return this.h;}
}

class Pulse implements Action{
  int actionSpeed, actionCounter;
  float h, s, b;
  float actionLimit;
  
  Pulse(int speed, float h, float s, float b){
    actionSpeed = speed;
    actionCounter = 0;
    actionLimit = 1000.0;
    this.h = h;
    this.s = s;
    this.b = b;
  }
  Action copy(){
    Action newAction = new Pulse(this.actionSpeed, this.h, this.s, this.b);
    return newAction;
  }
  
  void updateLamp(Lamp lamp){ 
    float newb = b*actionCounter/actionLimit;
    for (int i=0; i<24; i++){
      lamp.leds[i].update(h,s, newb);
    }
    incrementCounter(lamp);
  }
  void incrementCounter(Lamp lamp){
    actionCounter += actionSpeed;
    if (actionCounter>=int(actionLimit)){
      lamp.revertToPrevious();
    }
  }
  float getH(){return this.h;}
}

class Loop implements Action{
  int actionSpeed, actionCounter;
  float h, s, b;
  float actionLimit;
  
  Loop(int speed, float h, float s, float b){
    actionSpeed = speed;
    actionCounter = 0;
    actionLimit = 1000.0;
    this.h = h;
    this.s = s;
    this.b = b;
  }
  Action copy(){
    Action newAction = new Loop(this.actionSpeed, this.h, this.s, this.b);
    return newAction;
  }
  
  void updateLamp(Lamp lamp){  
    for (int i=0; i<24; i++){
      float prog = (i+23*(actionCounter/1000.0))%23;
      float newb = b*sq((23-prog)/23.);
      lamp.leds[i].update(h,s,newb);
    }
    incrementCounter(lamp);
  }
  void incrementCounter(Lamp lamp){
    actionCounter += actionSpeed;
    if (actionCounter>=int(actionLimit)){
      lamp.revertToPrevious();
    }
  }
  float getH(){return this.h;}
}

class Sweep implements Action{
  int actionSpeed, actionCounter;
  float h, s, b;
  float actionLimit;
  
  Sweep(int speed, float h, float s, float b){
    actionSpeed = speed;
    actionCounter = 0;
    actionLimit = 1000.0;
    this.h = h;
    this.s = s;
    this.b = b;
  }
  Action copy(){
    Action newAction = new Sweep(this.actionSpeed, this.h, this.s, this.b);
    return newAction;
  }
  
  void updateLamp(Lamp lamp){
    int upper = int(12*actionCounter/1000.0)+1;
    for (int i=0; i<upper; i++){
      float newb = b*actionCounter/1000.0;
      int index = i%23;
      lamp.leds[23-index].update(h,s,newb);
      lamp.leds[index].update(h,s,newb);
    }
    incrementCounter(lamp);
  }
  void incrementCounter(Lamp lamp){
    actionCounter += actionSpeed;
    if (actionCounter>=int(actionLimit)){
      lamp.revertToPrevious();
    }
  }
  float getH(){return this.h;}
}
