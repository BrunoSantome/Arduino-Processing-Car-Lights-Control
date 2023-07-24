/*For light sensor*/


const int lightAnalogSensorPin = 5;
int LAPSE;
int DISTANCE;
int rafagaDelay = 200;
const int posicion = 10;
const int shortPin = 9;
const int longPin = 11;

int umbralMin = 450;
int umbralMax = 900;

bool autoMode = false;
bool shortIsOn = false;
bool longIsOn = false;
bool posicionOn = false; 

char GUI_Order = 0;


int light;

void setup() {
  pinMode(posicion,OUTPUT);
  pinMode(shortPin, OUTPUT);
  pinMode(longPin, OUTPUT);
  // put your setup code here, to run once:
  Serial.begin(9600);
 
  
}
void loop() {
  
  digitalWrite(posicion, HIGH);
  if(Serial.available() > 0){/*Wait for GUI to send data*/
    GUI_Order = Serial.read();
    autoMode = false;
    /*BEHAVE ACCORDING TO ORDER*/
    switch(GUI_Order) {
     
      case 'C': //ON-OFF Cortas
        if(shortIsOn) digitalWrite(shortPin, LOW);
        else digitalWrite(shortPin, HIGH);
        shortIsOn = !shortIsOn;
        break;
      case 'L': //ON-OFF Largas
        if(longIsOn) digitalWrite(longPin, LOW);
        else digitalWrite(longPin, HIGH);
        longIsOn = !longIsOn;
        break;
      case 'Z': //Send data
        light = analogRead(lightAnalogSensorPin)/4;
        Serial.write(light);       
        delay(50);      
      default:
        break;
     
    }
 
  }
    while (Serial.available() <= 0) {
    light = analogRead(lightAnalogSensorPin)/4;
    Serial.println(light * 4);
    autoMode = true;
    if (autoMode){
         if(light*4 > umbralMax){          
        digitalWrite(shortPin, HIGH);
          }
  
        if(light*4 < umbralMin){          
          digitalWrite(shortPin, LOW);
           }
        
    }
    delay(1000);
  }

}
