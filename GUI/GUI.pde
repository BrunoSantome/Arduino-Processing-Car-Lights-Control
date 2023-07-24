
import controlP5.*;
ControlP5 cp5;

import processing.serial.*; //Importamos la librería Serial
Serial port; //Serial port name

int tab = 1;//Keeps track of current tab | [1]-->[monitorization] | [2]-->[Logs] 
int mode = 2;//Keeps current mode | [1]-->[manual] | [2]-->[Auto] 
int lightValue = 200;//Keep track of light value
//int umbralDay = 800;//Keep track of umbral value for day mode
//int umbralNight = 300;//Keep track of umbral value for night mode
boolean isUnderUmbralNight = false;
boolean isOverUmbralDay = false;
int stepUmbralChange = 10;//steps when changing umbrales 


boolean posicion = false;
boolean cortas = false;//keep track of on-off state of cortas
boolean largas = false;//keep track of on-off state of largas
boolean umbrales = false;
int xLightDetections = 515;//keeps track of xValue for lightDetectionGraph
ArrayList<PVector> lightDetections = new ArrayList();//saves up to 50 values of lightDetectionGraph

int xDistanceDetections = 515;//keeps track of xValue for distanceDetectionGraph
ArrayList<PVector> distanceDetections = new ArrayList();//saves up to 50 values of distanceDetectionGraph

int secondsSinceStart;


int[] serialInArray = new int[1];    // Where we'll put what we receive
int serialCount = 0;                 // A count of how many bytes we receive        
boolean firstContact = false;        // Whether we've heard from the microcontroller

PrintWriter logFile;//Create file where we will save the logs

int xAyuda = 0;

int lastTab = 1;

int time;
int valueCountedUp = 0;
boolean countingDownNight = false;
boolean countDownStartNight = true;
boolean canPerformNight = false;

boolean countingDownDay = false;
boolean countDownStartDay = true;
boolean canPerformDay = false;

void setup()
{
  println(Serial.list()); //Visualiza los puertos serie disponibles en la consola de abajo
  port = new Serial(this, Serial.list()[0], 9600); //Abre el puerto serie COM3
  delay(1000);
  logFile = createWriter("logFile.txt"); //Create file to save the logs 
  size(800, 600); //Creamos una ventana de 800 píxeles de anchura por 600 píxeles de altura 
  cp5 = new ControlP5(this);
  cp5.addSlider("UMBRAL MAXIMO").setPosition(120, 500).setSize(180, 40).setRange(650,1000);
  cp5.addSlider("UMBRAL MINIMO").setPosition(450, 500).setSize(180, 40).setRange(200,600);
 
}


 
void draw()
{  
  /*
  println("countingDownNight"+countingDownNight); 
  println("countDownStartNight"+countDownStartNight);
  println("canPerformNight"+canPerformNight);*/
  background(53, 83, 91);//white background
  //DRAW LOGO
  PImage logo=loadImage("assets/logo.png");
  image(logo,210,20,300,100);
  
  //show tab selected between monitorization and logs
  switch(tab){
    case 1:
    showMonitorization();
    break;
  case 2:
    showLogs();
    cp5.hide();
    break;
 
  }
  
 
}
 



 
void keyPressed()//When key pressed--handle states
{
   switch(key) {
  case '1': //Change to monitorization tab
    tab = 1;
    break;
  case '2': //Change to history tab
    tab = 2;
    break;
  case 'M': //Change to manual mode
    if(mode == 2)  writeLog(logFile, "MODO MANUAL");
    mode = 1;
    break;
  case 'm': //Change to manual mode
    if(mode == 2)  writeLog(logFile, "MODO MANUAL");
    mode = 1;
    break;
  case 'A': //Change to auto mode
   if(mode == 1)  writeLog(logFile, "MODO AUTOMATICO");
    mode = 2;
    break;
  case 'a': //Change to auto mode
   if(mode == 1)  writeLog(logFile, "MODO AUTOMATICO");
    mode = 2;
    break;    
  case 'C': //ON-OFF Cortas
    if(mode == 1){//if in manual mode
      if(cortas) writeLog(logFile, "CORTAS OFF");
      if(!cortas) writeLog(logFile, "CORTAS ON");
      cortas = !cortas;
      port.write('C');//send order to arduino
    }
    break;
    case 'c': //ON-OFF Cortas
    if(mode == 1){//if in manual mode
      if(cortas) writeLog(logFile, "CORTAS OFF");
      if(!cortas) writeLog(logFile, "CORTAS ON");
      cortas = !cortas;
      port.write('C');//send order to arduino
    }
    break;
    case 'L': //ON-OFF Largas
    if(largas) writeLog(logFile, "LARGAS OFF");
    if(!largas) writeLog(logFile, "LARGAS ON");
    largas = !largas; 
    port.write('L');//send order to arduino
    break;
   case 'l': //ON-OFF Largas
    if(largas) writeLog(logFile, "LARGAS OFF");
    if(!largas) writeLog(logFile, "LARGAS ON");
    largas = !largas; 
    port.write('L');//send order to arduino
    break;
  }
}



//-------------MONITORIZATION TAB HANDLING DOWN HERE-------------
//Func Description: draws and manages the monitorization
void showMonitorization(){
  
  //Draw menu with monitorization selected
  drawMenuMonitorizationSelected();
  //Draw active lights panel
  drawLightPanel();
  //manage each mode depending on 
  switch(mode){
    case 1://manual
    showMonitorizationManual();
    cp5.hide();
    break;
  case 2://automatic
    showMonitorizationAuto();
     cp5.show();
   
    break;
  default:
    break;
  }
}

//Draws the visualization of active lights
void drawLightPanel(){
  //rgb(255,255,0)--> yellow
  //Posición Indicator -- ALWAYS ON
  fill(255,255,0);
  strokeWeight(1);
  PImage lucesPosicionSymbol =loadImage("assets/lucesPosicion.png");
  rect(300, 200, 120, 50);
  image(lucesPosicionSymbol,335,200,50,50);

  //Cortas Indicator
  if(cortas){
    fill(50,205,50); // rgb green
    strokeWeight(1);
  }else{
    fill(200,200,200);
    strokeWeight(0);
  }
  PImage lucesCortasSymbol =loadImage("assets/lucesCortas.png");
  rect(300, 290, 120, 50);
  image(lucesCortasSymbol,335,290,50,50);
 
  //Largas Indicator
  if(largas){
    fill(0,150,255); //rgb blue
    strokeWeight(1);
  }else{
    fill(200,200,200);
    strokeWeight(0);
  }
  PImage lucesLargasSymbol =loadImage("assets/lucesLargas.png");
  rect(300, 380, 120, 50);
  image(lucesLargasSymbol,330,380,50,50);
}

//Function Description: Draws the menu highlighting the selected Monitorization tab
void drawMenuMonitorizationSelected(){
  textSize(19);
  fill(255,77,77);
  text("1: Monitorización", 230, 140);
  fill(170,170,170);
  text("2: Historial", 400, 140);
  //stroke(30,42,100);
  //strokeWeight(5);
  //line(260, 100, 500, 100);
 // strokeWeight(2);
 // line(500, 100, 675, 100);
}
//Func Description: draws and manages the manual mode
void showMonitorizationManual(){
  drawManualAutoIndicatorManualSelected();
  drawManualLightControl();
  //drawDistanceSensorDetection();
  //drawDistanceDetectionGraph(240);
  
  
}

//Func Description: draws the indication of mode with manual mode selected
void drawManualAutoIndicatorManualSelected(){
  textSize(19);
  fill(255,77,77);
  text("M: Manual", 55, 200);
  fill(170,170,170);
  text("A: Auto", 55, 240);
}

//Func Description: draws the controls to handle lights
void drawManualLightControl(){
  //fill(30,42,100);
  //strokeWeight(1);
  //rect(50, 200, 200, 50);
  //textSize(22);
  //fill(255, 255, 255);
  //text("C: Cortas", 100, 235);
  
  fill(50,205,50);
  strokeWeight(1);
  rect(50, 290, 140, 50);
  fill(255,255,255);
  text("C: Cortas", 80, 325);
  
  fill(0,150,255);
  strokeWeight(1);
  rect(50, 380, 140, 50);
  fill(255,255,255);
  text("L: Largas", 80, 415);
  
 
}
//Func Description: draws and manages the manual mode
void showMonitorizationAuto(){
  
  drawManualAutoIndicatorAutoSelected();
  int umbralDay = (int) cp5.getController("UMBRAL MAXIMO").getValue();
  int umbralNight = (int) cp5.getController("UMBRAL MINIMO").getValue();
  if(lightValue < umbralNight || lightValue > umbralDay){//exceeding either umbralDay or umbralNight
      if(lightValue > umbralNight) {
        if(!cortas){
          println("ACTIVANDO CORTASSS");
          cortas = true;//entering umbralNight
          writeLog(logFile, "CORTAS ON");
          port.write('C');
        }
       
      }
      else if(lightValue < umbralDay){//entering umbralDay 
        if(cortas){
           println("Apagando CORTAS");
           writeLog(logFile, "CORTAS OFF");
           port.write('C');
           cortas = false; 
         
        }
     
      }
  }

  drawAutoLightControl();
  //drawDistanceSensorDetection();
  //drawLightSensorDetection();
  drawLightDetectionGraph(240,umbralNight,umbralDay);
  //drawDistanceDetectionGraph(240);
 
  
}

//Func Description: draws the indication of mode with auto mode selected
void drawManualAutoIndicatorAutoSelected(){
  textSize(19);
  fill(170, 170, 170);
  text("M: Manual", 55, 200);
  fill(255,77,77);
  text("A: Auto", 55, 240);
}

//Func Description: draws the light control available in auto mode
void drawAutoLightControl(){
  //textSize(22);
  //fill(30,42,100);
  //strokeWeight(1);
  //rect(50, 290, 200, 50);
  //fill(255, 255, 255);
  //text("C: Cortas", 100, 325);
  
 fill(0,150,255);
  strokeWeight(1);
  rect(50, 380, 140, 50);
  fill(255,255,255);
  text("L: Largas", 80, 415);
}


//Func Descriptions: draws the monitorization for distance detection --shows in both modes


void drawLightDetectionGraph(int xLength,int umbralNight, int umbralDay){

  //size(600,400);
  //draw black screen background
  fill(255,77,77);
  //stroke(0);
  //rect(515,230,240,130);
  rect(515,230,240,130);
  //draw chart text
  textSize(9);
  fill(255,255,255);
  text("1100", 517, 240);
  fill(255,255,255);
  text("0", 517, 360);
  textSize(10);
  fill(0,0,0);
  text("Oscuridad", 460, 240);
  fill(0,0,0);
  text("t(s)", 740, 375);
  //draw umbral lines
  stroke(0, 234, 255);
  strokeWeight(1);
  int umbralDayAdjusted = (((1100-umbralDay)*(360-230))/1100)+230;
  line(515, umbralDayAdjusted, 515+240, umbralDayAdjusted);
  stroke(170, 170, 170);
  int umbralNightAdjusted = (((1100-umbralNight)*(360-230))/1100)+230;
  line(515, umbralNightAdjusted, 515+240, umbralNightAdjusted);
  
  if(xLightDetections > 515+xLength){//take care of overflowing our screen black area
    xLightDetections = 515;
  }
  xLightDetections++;//step in x for next value
  int lightValueAdjusted = (((1100-lightValue)*(360-230))/1100)+230;
  lightDetections.add(new PVector(xLightDetections,lightValueAdjusted));//add value to array
  if( lightDetections.size() > 50 ) lightDetections.remove(0);//remove oldest value
  for( int i = 0; i<lightDetections.size()-1; i++){
    stroke(255,255,0,map(i,0,lightDetections.size()-1,0,255));
    strokeWeight(1);
    if( lightDetections.get(i).x < lightDetections.get(i+1).x) 
    line(lightDetections.get(i).x,lightDetections.get(i).y, lightDetections.get(i+1).x,lightDetections.get(i+1).y);
  }
  textSize(9);
  fill(255,255,0);
  text(lightValue, lightDetections.get(lightDetections.size()-1).x, lightDetections.get(lightDetections.size()-1).y);
  if(countingDownDay){
    textSize(11);
    fill(170,170,170);
    text((valueCountedUp/1000)+1, lightDetections.get(lightDetections.size()-1).x+22, lightDetections.get(lightDetections.size()-1).y);
  }
  if(countingDownNight){
    textSize(11);
    fill(170,170,170);
    text((valueCountedUp/1000)+1, lightDetections.get(lightDetections.size()-1).x+18, lightDetections.get(lightDetections.size()-1).y);
  }
}


//-------------LOG TAB HANDLING FROM HERE DOWN-------------
//Func Description: draws the hisory logs
void showLogs(){
  drawMenuLogsSelected();
  drawLogs();
}

//Function Description: Draws the menu highlighting the selected Monitorization tab
void drawMenuLogsSelected(){
  textSize(19);
  fill(170,170,170);
  text("1: Monitorización", 230, 140);
  fill(255,77,77);
  text("2: Historial", 400, 140);
 // stroke(30,422,100);
  //strokeWeight(2);
  //line(260, 100, 500, 100);
  //strokeWeight(5);
  //line(500, 100, 675, 100);
}

//Func Description: draws the last logs
void drawLogs(){
  //build the black rectangle for logs
  fill(102,102,102);
  stroke(255,77,77);
  strokeWeight(3);
  rect(170,150,420,405);
  //get the last lines
  ArrayList<String> lines = parseFile("logFile.txt");
  int logLimit = 30;
  textSize(12);
  fill(255,255,255);
  int yLogPosition = 170;
  int xLogPosition = 180;
  for(int i = lines.size()-1, logCount = 0; i >= 0 && logCount < logLimit; i--){
     text(lines.get(i), xLogPosition, yLogPosition);
     yLogPosition+=13;
     logCount++;
  }
}

//Function Description: write a message to a file
void writeLog(PrintWriter file, String message){
   file.print("["+day()+"/"+month()+"/"+year()+"||"+hour( )+":"+minute( )+":"+second( )+"]    =====>   "+message+"\n");
   file.flush();
}

//Function Description: reads a each line giving back a list of strings
ArrayList<String> parseFile(String fileName){
  BufferedReader reader = createReader(fileName);//Open the file
  String line = null;
  ArrayList<String> result = new ArrayList<String>();
  try {
    while ((line = reader.readLine()) != null) {
      result.add(line);
    }
    reader.close();
  } catch (IOException e) {
    e.printStackTrace();
  }
  return result;
}


void serialEvent(Serial myPort) {
  
  int inByte = myPort.read();  

     if (firstContact == false) {
        myPort.clear();      
        firstContact = true;
        myPort.write('Z');
   }else{
     serialInArray[serialCount] = inByte;
     serialCount++; //<>//
  
    if (serialCount >= 1 ) {     
      myPort.write('Z');
      lightValue = serialInArray[0]*4;
      if(lightValue < 300){
        lightValue = lightValue - 80;
      }
      serialCount = 0;
      
    } 
  }
} //<>//
