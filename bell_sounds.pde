
/***************************
* import 4 bike sounds from somewhere. 
* play them depending on what number comes through. 
*****************************/

import processing.net.*;
import processing.sound.*;

Server server;
PFont f;
String incomingMessage = "";

SoundFile bell0;
SoundFile bell1;
SoundFile bell2;
SoundFile bell3;

int zeroCount;
int oneCount;
int twoCount;
int threeCount;


boolean isTitles = false;
boolean fade = false;

int time;
int wait = 5000;

int fadeAmount;


void setup() {
  background(0);
  
  size(1200, 800);
  server = new Server(this, 5000); 
  f = createFont("Arial",16,true);

  bell0 = new SoundFile(this, "173000__keykrusher__bicycle-bell-2.wav");
  bell1 = new SoundFile(this, "9218__melack__timbre.wav");
  bell2 = new SoundFile(this,"323125__geraldfiebig__bicycle-bell-from-bikekitchen-augsburg-05.wav");
  bell3 = new SoundFile(this, "124501__stereostereo__st-bell-bike.aiff");
  bell0.amp(1.0);
  bell1.amp(1.0);
  bell2.amp(1.0);
  bell3.amp(1.0);
  fadeAmount = 30;
  time = millis();//store the current time
}


void draw() { 
  if(fade){
    noStroke();
    fill(0, fadeAmount);
    rect(0, 0, width, height);
  }else{
    noStroke();
    fill(0, 0);
    rect(0, 0, width, height);
  }

  

  Client client = server.available();

  if(client!=null){
    

    incomingMessage = client.readString();
    incomingMessage = incomingMessage.trim();
    println("client says: "+incomingMessage);

    if(incomingMessage.equals("titlesStart") == true){
      isTitles = true;
      
    } else if(incomingMessage.equals("titlesEnd") == true){
      background(0);
      isTitles = false;
    }

    

    if(isTitles){
      if(!incomingMessage.equals("titlesStart")){
        fill(255,255,255);
        textFont(f);
        textAlign(CENTER);
        text(incomingMessage, width/2,height/2);
        fade  = true;
        fadeAmount = 5;        
        
        // this does nothing.
        /*if(millis() - time >= wait){
          fade  = true;
          time = millis();//also update the stored time
        }*/
        
      } 
    }else{
      fade = false;
    }
    

    if(incomingMessage.equals("0") == true){
      fade = false;
      println("ding0: "+incomingMessage);
      zeroCount+=1;
      println("zeroCount: "+zeroCount);
      bell0.play();
      drawLine(255,255,255,zeroCount);

    } else if(incomingMessage.equals("1") == true){
      fade = false;
      println("ding1: "+incomingMessage);
      oneCount+=1;
      println("oneCount: "+oneCount);
      bell1.play();
      drawLine(26,237,170,oneCount);
      
      
    }else if(incomingMessage.equals("2") == true){
      fade = false;
      println("ding2: "+incomingMessage); 
      twoCount+=1;
      println("twoCount: "+twoCount);
      bell2.play();
      drawLine(244,66,197,twoCount);
      
      
    }else if(incomingMessage.equals("3") == true){
      fade = false;
      println("ding2: "+incomingMessage);
      threeCount+=1;
      println("threeCount: "+threeCount);
      bell3.play();
      drawLine(237, 143, 49,threeCount); 
    }

    //// DISCONNECTION /////////////////////////////////////////

    if (incomingMessage.equals("exitrn")) {
      
      client.write("You will be disconnected now.rn\n");
      println(client.ip() + " has been disconnected\n");
      server.disconnect(client);
      zeroCount = 0;
      oneCount = 0;
      twoCount = 0;
      threeCount = 0;
      delay(5000); // 5 seconds
      fadeAmount = 50;
      fade = true;


    } 
  }
  //println(zeroCount+" - "+oneCount+" - "+twoCount+" - "+threeCount);

}

void drawLine(int r, int g, int b,int weightC){

  stroke(r, g, b,255);
  strokeWeight(weightC);
  line(random(width), 0, random(width), height);
}


void serverEvent(Server server,Client client){
  incomingMessage = "A new client has connected: "+ client.ip();
}