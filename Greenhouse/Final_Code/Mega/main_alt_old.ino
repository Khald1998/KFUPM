#include <ArduinoJson.h>
#include <Servo.h>
#include <DHT.h>
#include <OneWire.h>
#include <DallasTemperature.h>

#define DHTPIN 46  // what pin the DHT11 is connected to
#define DHTTYPE DHT11   // DHT 11
DHT dht(DHTPIN, DHTTYPE);
#define ONE_WIRE_BUS_1 48  // DS18B20 sensor on pin 48
#define ONE_WIRE_BUS_2 50  // DS18B20 sensor on pin 50

OneWire oneWire1(ONE_WIRE_BUS_1);
OneWire oneWire2(ONE_WIRE_BUS_2);

DallasTemperature sensors1(&oneWire1);
DallasTemperature sensors2(&oneWire2);

String command;
// Declaration of pin numbers
const int relayPumpPins[] = {22, 24, 26, 28, 2, 3, 4, 5};
const int relayLightPin = 5;
const int ultrasonicTrigPins[] = { 38, 42,34};
const int ultrasonicEchoPins[] = { 36, 40,32};
const int servoPins[] = {9, 10};
const int fanPin = 11;
const int heaterPin = 12;
const int ldrPins[] = {A8, A9, A10, A13, A14};
const int potPins[] = {A11, A12};

const int sig=32;

// Add more pin declarations as needed
const int lightPin=29;
// Servo objects
Servo servo1;
Servo servo2; 
int pinD22 = 0; // relay Pump (OUTPUT)
int pinD24 = 0;// relay Pump (OUTPUT)
int pinD26 = 0; // relay Pump (OUTPUT)
int pinD28 = 0; // relay Pump (OUTPUT)
int pinD2 = 0; // relay Pump (OUTPUT)
int pinD3 = 0; // relay Pump (OUTPUT)
int pinD4 = 0; // relay Pump (OUTPUT)
int pinD5 = 0; // relay Light (OUTPUT)
int pinD11 = 0; // fan (OUTPUT) (pwm pin)
int pinD12 = 0; // heater (OUTPUT) (pwm pin)
int pin_D9 = 0; // Servo Moter (pwm pin)
int pin_D10 = 0; // Servo Moter (pwm pin)

void setup() {
  Serial.begin(115200);
  while (!Serial) {
    ; 
  }
  initializePins();
  randomSeed(analogRead(0));
}

void loop() {
  dataExchange();
  assignPin();
}

void dataExchange() {
  if (Serial.available() > 0) {
    command = Serial.readStringUntil("\n");
    command.trim();
    if (command.equals("GET")) {
      sendData();
    } else if (command.equals("POST")) {
      readData();
    }
  }
}

void sendData() {
    StaticJsonDocument<256> sensorDoc;
    // sensorDoc["air_temp"] = readTemperature();
    // sensorDoc["humidity"] = readHumidity();
    // sensorDoc["inner_tank_volume"] = readInnerTankVolume();  
  //   sensorDoc["outer_tank_volume"] = readOuterTankVolume();
  //   sensorDoc["soil_tank_volume"] = readSoilTankVolume();
  //  sensorDoc["inner_water_temp"] = readTemperatureSensor1();  
  //  sensorDoc["outer_water_temp"] = readTemperatureSensor2();
  //  sensorDoc["light_Top_Left"] = analogRead(ldrPins[0]); 
  //  sensorDoc["light_Top_Right"] = analogRead(ldrPins[1]); 
  //  sensorDoc["light_Bottom_Left"] = analogRead(ldrPins[2]); 
  //  sensorDoc["light_Bottom_Right"] = analogRead(ldrPins[3]); 
    // sensorDoc["light_level"] = digitalRead(lightPin);

    sensorDoc["air_temp"] = random(0, 901) / 10.0 - 20.0;  
    sensorDoc["humidity"] = random(0, 1000) / 10.0;  
    sensorDoc["inner_tank_volume"] = random(0, 1000) / 10.0;  
    sensorDoc["outer_tank_volume"] = random(0, 1000) / 10.0; 
    sensorDoc["soil_tank_volume"] = random(0, 50) / 10.0;
    sensorDoc["inner_water_temp"] = random(0, 1000) / 10.0;  
    sensorDoc["outer_water_temp"] = random(0, 1000) / 10.0; 
    sensorDoc["light_Top_Left"] = random(0, 1000) / 10.0;
    sensorDoc["light_Top_Right"] = random(0, 1000) / 10.0;
    sensorDoc["light_Bottom_Left"] = random(0, 1000) / 10.0;
    sensorDoc["light_Bottom_Right"] = random(0, 1000) / 10.0; 
    sensorDoc["light_level"] = random(0, 10) / 10.0; 

    serializeJson(sensorDoc, Serial);
    Serial.println();

    String command;
    while (Serial.available() <= 0) {
        // Wait for the next command
    }

    command = Serial.readStringUntil('\n');
    command.trim();
    if (command.equals("DONE")) {
        // Command processing
    }
}

void readData() {
    Serial.println("READY");
    while (!Serial.available()) {
        // Wait for data
    }

    String incomingData = Serial.readStringUntil('\n');
    if (incomingData.length() > 0) {
        StaticJsonDocument<256> doc;
        DeserializationError error = deserializeJson(doc, incomingData);

        if (error) {
            Serial.println("JSON deserialize error");
            return;
        }

        pinD22 = doc["pin_D22"];
        pinD24 = doc["pin_D24"];
        pinD26 = doc["pin_D26"];
        pinD28 = doc["pin_D28"];
        pinD2 = doc["pin_D2"];
        pinD3 = doc["pin_D3"];
        pinD4 = doc["pin_D4"];
        pinD5 = doc["pin_D5"];
        pinD11 = doc["pin_D11"];
        pinD12 = doc["pin_D12"];
        pinD11 = doc["pin_D9"];
        pinD12 = doc["pin_D10"];
        Serial.println("DONE");
    }
}

void initializePins() {
  dht.begin();
  sensors1.begin();
  sensors2.begin();
  for (int i = 0; i < 7; i++) {
    pinMode(relayPumpPins[i], OUTPUT);
  }
  pinMode(relayLightPin, OUTPUT);

  for (int i = 0; i < 3; i++) {
    pinMode(ultrasonicTrigPins[i], OUTPUT);
    pinMode(ultrasonicEchoPins[i], INPUT);
  }

  servo1.attach(servoPins[0]);
  servo2.attach(servoPins[1]);

  pinMode(fanPin, OUTPUT);
  pinMode(heaterPin, OUTPUT);

  for (int i = 0; i < 5; i++) {
    pinMode(ldrPins[i], INPUT);
  }
  pinMode(lightPin,INPUT);
  pinMode(sig, OUTPUT);

}

void assignPin() {
    digitalWrite(relayPumpPins[0], pinD22);
    digitalWrite(relayPumpPins[1], pinD24);
    digitalWrite(relayPumpPins[2], pinD26);
    digitalWrite(relayPumpPins[3], pinD28);
    digitalWrite(relayPumpPins[4], pinD2);
    digitalWrite(relayPumpPins[5], pinD3);
    digitalWrite(relayPumpPins[6], pinD4);
    digitalWrite(relayLightPin, pinD5);
    servo1.write(pinD11); 
    servo2.write(pinD12);
}

float readTemperature() {
   float temp = dht.readTemperature();
   if (isnan(temp)) {
       Serial.println("Failed to read from DHT sensor!");
       return 0.0;
   }
   return temp;
}

float readHumidity() {
   float humidity = dht.readHumidity();
   if (isnan(humidity)) {
       Serial.println("Failed to read from DHT sensor!");
       return 0.0;
   }
   return humidity;
}

float readTemperatureSensor1() {
   sensors1.requestTemperatures();
   float temp = sensors1.getTempCByIndex(0);
   if (temp == DEVICE_DISCONNECTED_C) {
       Serial.println("Error: Could not read temperature data from sensor 1");
       return 0.0;
   }
   return temp;
}

float readTemperatureSensor2() {
   sensors2.requestTemperatures();
   float temp = sensors2.getTempCByIndex(0);
   if (temp == DEVICE_DISCONNECTED_C) {
       Serial.println("Error: Could not read temperature data from sensor 2");
       return 0.0;
   }
   return temp;
}

float readDistance(int index) {
   digitalWrite(ultrasonicTrigPins[index], LOW);
   delayMicroseconds(2);
   digitalWrite(ultrasonicTrigPins[index], HIGH);
   delayMicroseconds(10);
   digitalWrite(ultrasonicTrigPins[index], LOW);
   float duration = pulseIn(ultrasonicEchoPins[index], HIGH);
   float distance = duration * 0.034 / 2; 
   return distance;
}

float readDistanceAlt(int index) {
  long duration, distance;
  pinMode(sig, OUTPUT);
  digitalWrite(sig, LOW);
  delayMicroseconds(2);

  digitalWrite(sig, HIGH);
  delayMicroseconds(10);
  digitalWrite(sig, LOW);

  pinMode(sig, INPUT);
  duration = pulseIn(sig, HIGH);
  distance = duration / 58.2;
   return distance;
}

float readInnerTankVolume() {
   float waterHeight = 40 - readDistance(0);
   return calculateVolumeCylinder(waterHeight, 30);
}

float readOuterTankVolume() {
   float waterHeight = 45 - (readDistance(1)-10);
   return calculateVolumeCylinder(waterHeight, 40);
}

float readSoilTankVolume() {
  float waterHeight = 20 - (readDistanceAlt(2)-7);
  return calculateVolumeRectangular(23, 10, waterHeight);
}

float calculateVolumeRectangular(float length, float width, float height) {
   return length * width * height * 0.001;
}

float calculateVolumeCylinder(float height, float diameter) {
   float radius = diameter / 2.0;
   return PI * radius * radius * height * 0.001;
}


