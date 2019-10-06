boolean LIVE = true; // Live mode, set to false to play song from mp3 for testing
// Parameters for channels mode:
int bdOnOff = 1;  // set this to zero if you don't want channels to default to beat detection
boolean useRange = false;  // set this to true if you want to use the range slider in channels mode to select the response frequency
                           // if false: channel 7 responds to kick, channel responds to snare, and channel 5 responds to hithat (in theory!)

// ControlP5 is a library for processing GUI controls
import controlP5.*;
ControlP5 bp5;  // controller object bp5 to contain controls for specific modes (changes dynamically according to mode)
ControlP5 bp6;  // controller bp6 is the 'SELECT MODE' radio button control.

// Library beat detection:
import ddf.minim.*;
import ddf.minim.analysis.*;
Minim minim;
AudioPlayer song;
BeatDetect beat;
AudioInput in;
int mode = 0;
int bdActionFlag = 1;

// for the lamp display and GUI: 
int[] lampChannels = {-1,-1,-1,-1,-1,-1,-1,-1};  // initially no lamps in any channel
float eRadius;
float lRadius;
GUI G;
LampArray LA;  // on-screen lamps, which should behave identically to the real lmaps
OPC opc; // library for Fancecandy control

float globalH, globalS, globalB;
float globalHmin, globalSmin, globalBmin;
float globalSpeed, globalI;

float newH;
float newS;
float newB;
int counter;
int transitionSpeed;
    

void setup()
{
  size(1500, 600);
  noStroke();
  opc = new OPC(this, "127.0.0.1", 7890);

  frameRate(10);
  colorMode(HSB, 100);
  ellipseMode(RADIUS);
  eRadius = 50;
  lRadius = 5;
  LA = new LampArray(8, eRadius, lRadius, opc, false);
  
  bp6 = new ControlP5(this);       
  bp6.addRadioButton("modeSelect")
         .setPosition(1350,450)
         .setSize(40,20)
         .setItemsPerRow(1)
         .setSpacingColumn(50)
         .addItem("unmapped",1)       // Mode 1 is 'Unmapped' - basically rainbow fade from the OPC documentation, with adjustable parameters.
         .addItem("stochastic",2)     // Mode 2 is 'Stochastic' - lamps take a random colours between two specified boundaries
         .addItem("alternate",3)      // Mode 3 is 'Alternate' - fade smoothly between two colours with alternate lamps 180 degress out of phase.  
         .addItem("unmapped fast",4)  // Mode 4 is 'Unmapped fast' - faster version of mode 1.
         .addItem("channels",5)       // Mode 5 is 'Channels' - separate control interface where lamps can be assigned to channels for beat detection (or played manually).
         ;
         
  textSize(20);
  fill(100,0,100);
  text("SELECT MODE:", 1300, 400);
  
  // initialise beat detector differently depending on global 'LIVE' (in Live mode detects beat from microphone input buffere, otherwsie from mp3):
  minim = new Minim(this);
  if (LIVE){
    in = minim.getLineIn(Minim.STEREO, 2048);
    beat = new BeatDetect(in.bufferSize(), in.sampleRate());
  }
  else {
    song = minim.loadFile("days.mp3", 2048);
    beat = new BeatDetect(song.bufferSize(), song.sampleRate());
  }
}

// Function updates bp5 controller according to mode selected on bp6 controller: 
//     Note: each mode has different parameters and so different GUI controls required).
//     This function is vast and clunky. Although it works it would be much better to have
//     separate controller classes for each mode which are created on mode select. I will do
//     this when I have time.
void modeSelect(int a)
{
  int oldMode = mode;
  mode = a;
  
  if (oldMode==1){
    bp5.remove("speed");
    bp5.remove("i parameter");
    bp5.remove("saturation");
    bp5.remove("brightness");
  }
  else if (oldMode==4){
    bp5.remove("speed");
    bp5.remove("i parameter");
    bp5.remove("saturation");
    bp5.remove("brightness");
  }
  else if (oldMode==2){
    bp5.remove("speed");
    bp5.remove("H min");
    bp5.remove("H max");
    bp5.remove("S min");
    bp5.remove("S max");
    bp5.remove("B min");
    bp5.remove("B max");
  }
  else if (oldMode==3){
    bp5.remove("speed");
    bp5.remove("H1");
    bp5.remove("H2");
    bp5.remove("S1");
    bp5.remove("S2");
    bp5.remove("B1");
    bp5.remove("B2");
    bp5.remove("transition time");
  }
  else if (oldMode==5){
    G.clear();
    bp5.remove("Beat detection");
    bp5.remove("Beat sens.");
    bp5.remove("radioButton");
  }
  
  if (mode==1){
    
    globalS = globalB = 100;
    globalSpeed = 0.003;
    globalI = 0.1;
    
    bp5 = new ControlP5(this);
    bp5.addSlider("speed")
       .setPosition(300,50)
       .setSize(20,350)
       .setRange(0,0.03)
       .setValue(globalSpeed)
       .plugTo(this, "adjustSpeed")
       ;
        bp5.addSlider("i parameter")
       .setPosition(400,50)
       .setSize(20,350)
       .setRange(0,0.125)
       .setValue(globalI)
       .plugTo(this, "adjustI")
       ;
        bp5.addSlider("saturation")
       .setPosition(500,50)
       .setSize(20,350)
       .setRange(0,100)
       .setValue(globalS)
       .plugTo(this, "adjustS")
       ;
       bp5.addSlider("brightness")
       .setPosition(600,50)
       .setSize(20,350)
       .setRange(0,100)
       .setValue(globalB)
       .plugTo(this, "adjustB")
       ;
    LA = new LampArray(8, eRadius, lRadius, opc, false);
  }
  else if (mode==4){
    
    globalS = globalB = 100;
    globalSpeed = 0.03;
    globalI = 0.1;
    
    bp5 = new ControlP5(this);
    bp5.addSlider("speed")
       .setPosition(300,50)
       .setSize(20,350)
       .setRange(0.03,0.3)
       .setValue(globalSpeed)
       .plugTo(this, "adjustSpeed")
       ;
        bp5.addSlider("i parameter")
       .setPosition(400,50)
       .setSize(20,350)
       .setRange(0,0.125)
       .setValue(globalI)
       .plugTo(this, "adjustI")
       ;
        bp5.addSlider("saturation")
       .setPosition(500,50)
       .setSize(20,350)
       .setRange(0,100)
       .setValue(globalS)
       .plugTo(this, "adjustS")
       ;
       bp5.addSlider("brightness")
       .setPosition(600,50)
       .setSize(20,350)
       .setRange(0,100)
       .setValue(globalB)
       .plugTo(this, "adjustB")
       ;
    LA = new LampArray(8, eRadius, lRadius, opc, false);
  }
  else if (mode==2){
    
    globalH = globalS = globalB = 100;
    globalHmin = globalBmin = globalSmin = 90;
    globalSpeed = 0.0;
    
    newH = random(globalHmin, globalH);
    newS = random(globalSmin, globalS);
    newB = random(globalBmin, globalB);
    
    bp5 = new ControlP5(this);
    bp5.addSlider("speed")
       .setPosition(300,50)
       .setSize(20,350)
       .setRange(0,5.0)
       .setValue(globalSpeed)
       .plugTo(this, "adjustSpeed")
       ;
        bp5.addSlider("H min")
       .setPosition(400,50)
       .setSize(20,350)
       .setRange(0,100)
       .setValue(globalHmin)
       .plugTo(this, "adjustHmin")
       ;
        bp5.addSlider("H max")
       .setPosition(500,50)
       .setSize(20,350)
       .setRange(0,100)
       .setValue(globalH)
       .plugTo(this, "adjustH")
       ;
       bp5.addSlider("S min")
       .setPosition(600,50)
       .setSize(20,350)
       .setRange(0,100)
       .setValue(globalSmin)
       .plugTo(this, "adjustSmin")
       ;
        bp5.addSlider("S max")
       .setPosition(700,50)
       .setSize(20,350)
       .setRange(0,100)
       .setValue(globalS)
       .plugTo(this, "adjustS")
       ;
        bp5.addSlider("B min")
       .setPosition(800,50)
       .setSize(20,350)
       .setRange(0,100)
       .setValue(globalBmin)
       .plugTo(this, "adjustBmin")
       ;
       bp5.addSlider("B max")
       .setPosition(900,50)
       .setSize(20,350)
       .setRange(0,100)
       .setValue(globalB)
       .plugTo(this, "adjustB")
       ;
    LA = new LampArray(8, eRadius, lRadius, opc, false);
  }
  else if (mode==3){
    counter = 0;
    globalH = globalS = globalB = 100;
    globalHmin = globalBmin = globalSmin = 90;
    globalSpeed = 0.0;
    
    newH = random(globalHmin, globalH);
    newS = random(globalSmin, globalS);
    newB = random(globalBmin, globalB);
    
    bp5 = new ControlP5(this);
    bp5.addSlider("speed")
       .setPosition(300,50)
       .setSize(20,350)
       .setRange(0,1.0)
       .setValue(globalSpeed)
       .plugTo(this, "adjustSpeed")
       ;
        bp5.addSlider("H1")
       .setPosition(400,50)
       .setSize(20,350)
       .setRange(0,100)
       .setValue(globalHmin)
       .plugTo(this, "adjustHmin")
       ;
        bp5.addSlider("H2")
       .setPosition(700,50)
       .setSize(20,350)
       .setRange(0,100)
       .setValue(globalH)
       .plugTo(this, "adjustH")
       ;
       bp5.addSlider("S1")
       .setPosition(500,50)
       .setSize(20,350)
       .setRange(0,100)
       .setValue(globalSmin)
       .plugTo(this, "adjustSmin")
       ;
        bp5.addSlider("S2")
       .setPosition(800,50)
       .setSize(20,350)
       .setRange(0,100)
       .setValue(globalS)
       .plugTo(this, "adjustS")
       ;
        bp5.addSlider("B1")
       .setPosition(600,50)
       .setSize(20,350)
       .setRange(0,100)
       .setValue(globalBmin)
       .plugTo(this, "adjustBmin")
       ;
       bp5.addSlider("B2")
       .setPosition(900,50)
       .setSize(20,350)
       .setRange(0,100)
       .setValue(globalB)
       .plugTo(this, "adjustB")
       ;
       bp5.addSlider("transition time")
       .setPosition(1000,50)
       .setSize(20,350)
       .setRange(0,1000)
       .setValue(100)
       .plugTo(this, "adjustT")
       ;
    LA = new LampArray(8, eRadius, lRadius, opc, false);
  }
  else if (mode==5){
    // for beat detection:
    bp5 = new ControlP5(this);
    bp5.addBang("Beat detection")
         .setPosition(1400,50)
         .setSize(50,20)
         .plugTo(this, "switchBD")
         ;
    bp5.addSlider("Beat sens.")
       .setPosition(1400,100)
       .setSize(20,200)
       .setRange(0,1000)
       .setValue(128)
       .plugTo(this, "adjustSensitivity")
       ;
    bp5.addRadioButton("radioButton")
           .setPosition(1400,330)
           .setSize(40,20)
           .setItemsPerRow(1)
           .setSpacingColumn(50)
           .addItem("pulse",1)
           .addItem("loop",2)
           .addItem("sweep",3)
           .plugTo(this, "bdAction")
           ;
      LA = new LampArray(8, eRadius, lRadius, opc, true);
      G = new GUI(8, this, LA, lampChannels);
      G.create();
      G.channels[7].lampCheck.activateAll();
      //G.channels[7].cp5.getController("hue").setValue(0.0);
  }
}

// functions for setting global variable values from within bp5 controller
void adjustSpeed(float s){
  globalSpeed = s;
}
void adjustS(float s){
  globalS = s;
}
void adjustB(float b){
  globalB = b;
}
void adjustH(float h){
  globalH = h;
}
void adjustI(float i){
  globalI = i;
}
void adjustSmin(float s){
  globalSmin = s;
}
void adjustBmin(float b){
  globalBmin = b;
}
void adjustHmin(float h){
  globalHmin = h;
}
void adjustT(float h){
  transitionSpeed = int(h);
}

// Draw function that is called in the draw() loop below.
// Write/draw to lamps (both real lamps via OPC and on-screen lamps via LampArray.
// Write differently according to mode selected.
// Again this would be much nicer to refactor out a draw function for each mode (like for mode 5). 
// ....Future improvement!
void modeDraw(){
  
  //if (mode==0){}
  if (mode==1){
    
    for (int i = 0; i < 24+ (64*7); i++) {
      float hue = (millis() * globalSpeed + i * globalI) % 100; 
      opc.setPixel(i, color(hue, globalS, globalB));
      
      // wierd mapping
      int pixel = i%63;
      if (pixel<24){LA.getLed(i).update(hue,globalS,globalB);}
    }
  }
  if (mode==4){
    
    for (int i = 0; i < 24+ (64*7); i++) {
      float hue = (millis() * globalSpeed + i * globalI) % 100; 
      opc.setPixel(i, color(hue, globalS, globalB));
      
      // wierd mapping
      int pixel = i%63;
      if (pixel<24){LA.getLed(i).update(hue,globalS,globalB);}
    }
  }
  else if (mode==2){
    
    for (int lamp=0; lamp<8; lamp++){
      
      float trigger = random(0,1);
      if (trigger < globalSpeed){
        if (globalHmin>globalH){
          newH = globalH;
        }
        else{
          newH = random(globalHmin, globalH);
        }
        if (globalSmin>globalS){
          newS = globalS;
        }
        else{
          newS = random(globalSmin, globalS);
        }
        if (globalBmin>globalB){
          newB = globalB;
        }
        else{
          newB = random(globalBmin, globalB);
        }
        for (int i = 0; i < 24; i++) { 
          opc.setPixel(i + 64*lamp, color(newH, newS, newB));
          LA.getLampLed(lamp,i).update(newH, newS, newB);
        }
      }
      else {
        for (int i = 0; i < 24; i++) { 
          LA.getLampLed(lamp,i).update(newH, newS, newB);
        }
      }

    }
  }
  else if(mode==3){
    IntList g1 = new IntList();
    g1.append(0);
    g1.append(2);
    g1.append(4);
    g1.append(6);
    IntList g2 = new IntList();
    g2.append(1);
    g2.append(3);
    g2.append(5);
    g2.append(7);
    
    int switchLength = transitionSpeed;
    color cf = color(globalHmin, globalSmin, globalBmin);
    color ct = color(globalH, globalS, globalB);
    
    if (counter==0){
      if (random(0,1)<globalSpeed){
        counter++;
      }
      standardMode3(g1,g2);
    }
    else{
      // switch inprogress
      color c1 = lerpColor(cf,ct,float(counter)/float(switchLength));
      color c2 = lerpColor(ct,cf,float(counter)/float(switchLength));
      counter++;
       
      for (int lamp=0; lamp<8; lamp++){
        if (g1.hasValue(lamp)){
          for (int i = 0; i < 24; i++) { 
            opc.setPixel(i + 64*lamp, c1);
            LA.getLampLed(lamp,i).updateC(c1);
          }
        }
        else if (g2.hasValue(lamp)){
          for (int i = 0; i < 24; i++) { 
            opc.setPixel(i + 64*lamp, c2);
            LA.getLampLed(lamp,i).updateC(c2);
          }
        } 
      }
      if (counter>=switchLength){
        float oldH = globalH;
        float oldS = globalS;
        float oldB = globalB;
        globalH = globalHmin;
        globalS = globalSmin;
        globalB = globalBmin;
        globalHmin = oldH;
        globalSmin = oldS;
        globalBmin = oldB;
        counter=0;
      }
    }

  }
  else if(mode==5){
         LA.update();
         if (bdOnOff==1){ 
            detectBeat(); 
          }
  }
  opc.writePixels();
}

// Set background (default) state for mode 3:
void standardMode3(IntList g1, IntList g2){
      for (int lamp=0; lamp<8; lamp++){
        if (g1.hasValue(lamp)){
          for (int i = 0; i < 24; i++) { 
            opc.setPixel(i + 64*lamp, color(globalHmin, globalSmin, globalBmin));
            LA.getLampLed(lamp,i).update(globalHmin, globalSmin, globalBmin);
          }
        }
        else if (g2.hasValue(lamp)){
          for (int i = 0; i < 24; i++) { 
            opc.setPixel(i + 64*lamp, color(globalH, globalS, globalB));
            LA.getLampLed(lamp,i).update(globalH, globalS, globalB);
          }
        }
      }
}

// Standard processing draw loop:
void draw(){
  background(0);
  
  textSize(15);
  fill(100,0,100);
  text("SELECT MODE:", 1350, 425);
  
  modeDraw();
}


// All code from here related the beat detections and needs looking over!
void switchBD() {
  if(bdOnOff==0) {
    bdOnOff=1;
    if (!LIVE){song.play();}
  }
  else if (bdOnOff==1){
    bdOnOff=0;
    if(!LIVE){song.pause();}
  }
}

void bdAction(int a){
  bdActionFlag = a;
}

void detectBeat(){
    if (LIVE){
      beat.detect(in.mix);
    }
    else{
      beat.detect(song.mix);
    }
    int ci = 0;
    if (useRange){
      for (ChannelGUI ch : G.channels){
        int rd = int(ch.cp5.getController("range").getValue());
        if ( beat.isRange(rd,rd+5,1) ){
          if (bdActionFlag==1){
            G.channels[ci].pulse();
          }
          else if (bdActionFlag==2){
            G.channels[ci].loopp();
          }
          else if (bdActionFlag==3){
            G.channels[ci].sweep();
          }
        }
      }
    }
    else{
        if ( beat.isKick() ){
          if (bdActionFlag==1){
            G.channels[7].pulse();
          }
          else if (bdActionFlag==2){
            G.channels[7].loopp();
          }
          else if (bdActionFlag==3){
            G.channels[7].sweep();
          }
        if ( beat.isSnare() ){
          if (bdActionFlag==1){
            G.channels[6].pulse();
          }
          else if (bdActionFlag==2){
            G.channels[6].loopp();
          }
          else if (bdActionFlag==3){
            G.channels[6].sweep();
          }
         if ( beat.isHat() ){
          if (bdActionFlag==1){
            G.channels[5].pulse();
          }
          else if (bdActionFlag==2){
            G.channels[5].loopp();
          }
          else if (bdActionFlag==3){
            G.channels[5].sweep();
          }
        }
      }
      ci ++;
    }
    }
    //if ( beat.isKick() ) eRadius = 80;
    //if ( beat.isHat() ) eRadius2 = 80;
    ////if ( beat.isSnare() ) eRadius3 = 80;
    //if ( beat.isRange(1,5,1) ) {
    //  G.channels[0].pulse();
    //}
    //if ( beat.isRange(6,10,1) ) {
    //  G.channels[1].pulse();
    //}
    //if ( beat.isRange(11,20,1) ) {
    //  G.channels[2].pulse();
    //}  
}


void adjustSensitivity(float sens) {
  beat.setSensitivity(int(sens));
  //println("a slider event. setting background to "+sens);
}


// Event listener needs to go in main context (is there a fix, or best here?):
  void controlEvent(ControlEvent theEvent) {
    int channel = -1;
    if (theEvent.isFrom(G.channels[0].lampCheck)) {
      channel = 0;
    }
    else if (theEvent.isFrom(G.channels[1].lampCheck)) {
      channel = 1;
    }
    else if (theEvent.isFrom(G.channels[2].lampCheck)) {
      channel = 2;
    }
    else if (theEvent.isFrom(G.channels[3].lampCheck)) {
      channel = 3;
    }
    else if (theEvent.isFrom(G.channels[4].lampCheck)) {
      channel = 4;
    }
    else if (theEvent.isFrom(G.channels[5].lampCheck)) {
      channel = 5;
    }
    else if (theEvent.isFrom(G.channels[6].lampCheck)) {
      channel = 6;
    }
    else if (theEvent.isFrom(G.channels[7].lampCheck)) {
      channel = 7;
    }
    if (channel!=-1){
      for (int i=0; i<8; i++){
        int was = lampChannels[i];
        int newFlag = int(G.channels[channel].lampCheck.getArrayValue())[i];
        if (newFlag==0 && was==channel){
          lampChannels[i] = -1;
        }
        else if (newFlag==1 && was!=channel){
          lampChannels[i] = channel; // also need to uncheck box in old channel..
          if (was!=-1){
            G.channels[was].lampCheck.toggle(i);
          }
        }
      }
    }
    G.updateLampChannels(lampChannels);
  }
