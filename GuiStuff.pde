// This file contains two classes that together define the GUI for 'Channels mode':
//
//   ChannelGUI - this class is instantiated once for each Channel
//   GUI - whole interface, contains the separate GUIs for each channel.

import controlP5.*;

class ChannelGUI{
  
  int chID, xpos, ypos, cwidth;
  ControlP5 cp5;
  Accordion accordion;
  CheckBox lampCheck;
  PApplet main;
  LampArray LA; 
  int[] lampChannels;

  ChannelGUI(int id, int x, int y, PApplet context, LampArray LA, int[] lampChannels){
    chID = id;
    main = context;
    this.LA = LA;
    this.lampChannels = lampChannels;
    
    cp5 = new ControlP5(main);
    xpos = x;
    ypos = y;
    cwidth = 50;
  }
  
  void create(){
    
    Group g1 = cp5.addGroup("Channel " + str(chID))
                  .setBackgroundColor(color(0, 64))
                  .setBackgroundHeight(150)
                  ;
                  
    cp5.addSlider("hue")
       .setPosition(20,20)
       .setSize(int(eRadius),20)
       .setRange(0,100)
       .setValue(50)
       .moveTo(g1)
       ;
    cp5.addSlider("sat")
       .setPosition(20,40)
       .setSize(int(eRadius),20)
       .setRange(0,100)
       .setValue(50)
       .moveTo(g1)
       ;
      cp5.addSlider("bri")
       .setPosition(20,60)
       .setSize(int(eRadius),20)
       .setRange(0,100)
       .setValue(50)
       .moveTo(g1)
       ;
       lampCheck = cp5.addCheckBox("lampCheck")
           .setPosition(5,100)
           .setSize(10,10)
           .setItemsPerRow(4)
           .setSpacingColumn(20)
           .addItem("0",0)
           .addItem("1",1)
           .addItem("2",2)
           .addItem("3",3)
           .addItem("4",4)
           .addItem("5",4)
           .addItem("6",4)
           .addItem("7",4)
           .moveTo(g1)
           ;
           
    Group mc1 = cp5.addGroup("Single Hits")
                  .setBackgroundColor(color(0, 64))
                  .setBackgroundHeight(50)
                  .setWidth(100)
                  ;
                  
    cp5.addBang("switch")
       .setPosition(0,10)
       .setSize(int(eRadius/2.0),10)
       .moveTo(mc1)
       .plugTo(this, "switchOn")
       ;
    cp5.addBang("pulse")
       .setPosition(40,10)
       .setSize(int(eRadius/2.0),10)
       .moveTo(mc1)
       .plugTo(this, "pulse")
       ;
    cp5.addBang("loop")
       .setPosition(0,40)
       .setSize(int(eRadius/2.0),10)
       .moveTo(mc1)
       .plugTo(this, "loopp")
       ;
    cp5.addBang("sweep")
       .setPosition(40,40)
       .setSize(int(eRadius/2.0),10)
       .moveTo(mc1)
       .plugTo(this, "sweep")
       ;
    Group bd = cp5.addGroup("Beat detection")
                  .setBackgroundColor(color(0, 0))
                  .setBackgroundHeight(50)
                  .setWidth(10)
                  ;
                  
    cp5.addSlider("range")
       .setPosition(20,10)
       .setSize(int(eRadius),10)
       .setRange(0,20)
       .setValue(5)
       .moveTo(bd)
       ;
    accordion = cp5.addAccordion("acc")
                   .setPosition(20,40)
                   .setBackgroundColor(color(0, 0))
                   .setWidth(int(eRadius)*2)
                   .setHeight(320)
                   .addItem(g1)
                   .addItem(mc1)
                   .addItem(bd)
                   ;
    accordion.open(0);
    //accordion.open(1);
    accordion.open(2);
    accordion.setCollapseMode(Accordion.MULTI);
    
    cp5.setPosition(xpos,ypos);
  }
  
  void setLock(String element, boolean theValue) {
    cp5.getController(element).setLock(theValue);
    if(theValue) {
      int inactive = ControlP5.getColor().getBackground();
      cp5.getController(element).setColorForeground(inactive);
    } else {
      int active = ControlP5.getColor().getForeground();
      cp5.getController(element).setColorForeground(active);
    }
  }
  
  void setLampsInChannel(int[] lampChannels){
    this.lampChannels = lampChannels;
  }
  
  void clear(){
    cp5.remove("Channel "+str(this.chID));
    cp5.remove("Test controls");
    cp5.remove("Beat detection");
    cp5.remove("Single Hits");
  }
  
  float[] getHSB(){
    float h1 = this.cp5.getController("hue").getValue();
    float s1 = this.cp5.getController("sat").getValue();
    float b1 = this.cp5.getController("bri").getValue();
    float[] sliderValues = {h1,s1,b1}; 
    return sliderValues;
  }
  
  //void pushAction(Action action){    
  //  for (int i=0; i<lampChannels.length; i++){
  //    int ch = lampChannels[i];
  //    if (ch==this.chID){
  //      LA.lamps[i].setAction(action);
  //    }
  //  }
  //}
  
  void pulse(){
    float[] sv = getHSB();
    //pushAction(ta);
    for (int i=0; i<lampChannels.length; i++){
      //Action ta = ;
      int ch = lampChannels[i];
      if (ch==this.chID){
        LA.lamps[i].setAction(new Pulse(150, sv[0], sv[1], sv[2]));
      }
    }
    
  }
  void loopp(){
    float[] sv = getHSB();
    //Action ta = new Loop(200, sv[0], sv[1], sv[2]);
   // pushAction(ta);
    for (int i=0; i<lampChannels.length; i++){
      //Action ta = ;
      int ch = lampChannels[i];
      if (ch==this.chID){
        LA.lamps[i].setAction(new Loop(200, sv[0], sv[1], sv[2]));
      }
    }
  }
  void sweep(){
    float[] sv = getHSB();
    //Action ta = new Sweep(100, sv[0], sv[1], sv[2]);
    //pushAction(ta);
    for (int i=0; i<lampChannels.length; i++){
      //Action ta = ;
      int ch = lampChannels[i];
      if (ch==this.chID){
        LA.lamps[i].setAction(new Sweep(100, sv[0], sv[1], sv[2]));
      }
    }
  }
  void switchOn(){
    float[] sv = getHSB();
    //Action ta = new StaticBlock(sv[0], sv[1], sv[2]);
    //pushAction(ta);
    for (int i=0; i<lampChannels.length; i++){
      //Action ta = ;
      int ch = lampChannels[i];
      if (ch==this.chID){
        LA.lamps[i].setAction(new StaticBlock(sv[0], sv[1], sv[2]));
      }
    }    
  }
}

class GUI{
  int nChannels;
  ChannelGUI[] channels;
  PApplet main;
  
  GUI(int n, PApplet context, LampArray LA, int[] lampChannels){
    nChannels = n;
    channels = new ChannelGUI[nChannels];
    main = context;
    
    for (int i=0; i<nChannels; i++){
      channels[i] = new ChannelGUI(i, 20+ i*width/9, 0, main, LA, lampChannels);
    }   
  }
  void create(){
    for (int i=0; i<nChannels; i++){
      channels[i].create();
    }   
  }
  void clear(){
    for (int i=0; i<nChannels; i++){
      channels[i].clear();
    }
  }
  void updateLampChannels(int[] lampChannels){
    for (int i=0; i<nChannels; i++){
      channels[i].setLampsInChannel(lampChannels);
    }
  }
}
