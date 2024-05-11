#include <ArduinoJson.h>
#include <DHT.h>
#include <OneWire.h>
#include <DallasTemperature.h>

#define DHTPIN 4  // what pin the DHT11 is connected to
#define DHTTYPE DHT11   // DHT 11
#define ONE_WIRE_BUS_1 8  // DS18B20 sensor on pin 48
#define ONE_WIRE_BUS_2 9  // DS18B20 sensor on pin 50

DHT dht(DHTPIN, DHTTYPE);
OneWire oneWire1(ONE_WIRE_BUS_1);
OneWire oneWire2(ONE_WIRE_BUS_2);
DallasTemperature sensors1(&oneWire1);
DallasTemperature sensors2(&oneWire2);

String command;

// Declaration of pin numbers
const int relayPins[] = {23,25,27,29,31,33,35};
const int fanPin = 12;
const int heaterPin = 13;


const int ultrasonicSensorPin[] = {5,6,7};
const int ldrSensorPin[] = {A1, A2, A3, A4};
const int potSensorPin[] = {A5, A6};
const int lightSensorPin=3;


int pinD0 = 0, pinD1 = 0, pinD2 = 0, pinD10 = 0, pinD11 = 0, pinD12 = 0, pinD13 = 0, pinD14 = 0, pinD15 = 0, pinD16 = 0, 
  pinD17 = 0, pinD18 = 0, pinD19 = 0, pinD20 = 0, pinD21 = 0, pinD22 = 0, pinD23 = 0, pinD24 = 0, pinD25 = 0, pinD26 = 0, 
  pinD27 = 0, pinD28 = 0, pinD29 = 0, pinD30 = 0, pinD31 = 0, pinD32 = 0, pinD33 = 0, pinD34 = 0, pinD35 = 0, pinD36 = 0, 
  pinD37 = 0, pinD38 = 0, pinD39 = 0, pinD40 = 0, pinD41 = 0, pinD42 = 0, pinD43 = 0, pinD44 = 0, pinD45 = 0, pinD46 = 0, 
  pinD47 = 0, pinD48 = 0, pinD49 = 0, pinD50 = 0, pinD51 = 0, pinD52 = 0, pinD53 = 0;


void setup() {
  Serial.begin(115200);
  while (!Serial) {
    ; 
  }
  
  initializeMode();
  initializelibrary();
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
    sensorDoc["air_temp"] = readTemperature();
    sensorDoc["humidity"] = readHumidity();  
    sensorDoc["inner_tank_volume"] = readInnerTankVolume();  
    sensorDoc["outer_tank_volume"] = readOuterTankVolume();
    sensorDoc["soil_tank_volume"] = readSoilTankVolume();
    sensorDoc["inner_water_temp"] = random(0, 800) / 10.0;  
    sensorDoc["outer_water_temp"] = random(0, 800) / 10.0; 
    sensorDoc["light_Top_Left"] = random(0, 10000) / 10.0;
    sensorDoc["light_Top_Right"] = random(0, 10000) / 10.0;
    sensorDoc["light_Bottom_Left"] = random(0, 10000) / 10.0;
    sensorDoc["light_Bottom_Right"] = random(0, 10000) / 10.0; 
    sensorDoc["light_level"] = readLightLevel();
 

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

        pinD23 = doc["pin_D23"];
        pinD25 = doc["pin_D25"];
        pinD27 = doc["pin_D27"];
        pinD29 = doc["pin_D29"];
        pinD31 = doc["pin_D31"];
        pinD33 = doc["pin_D33"];
        pinD35 = doc["pin_D35"];
        pinD37 = doc["pin_D37"];
        pinD12 = doc["pin_D12"];
        pinD13 = doc["pin_D13"];



        Serial.println("DONE");
    }
}



void assignPin() {
    // Assuming relayPins and other pin arrays are declared elsewhere

    digitalWrite(relayPins[0], pinD23);
    digitalWrite(relayPins[1], pinD25);
    digitalWrite(relayPins[2], pinD27);
    digitalWrite(relayPins[3], pinD29);
    digitalWrite(relayPins[4], pinD31);
    digitalWrite(relayPins[5], pinD33);
    digitalWrite(relayPins[6], pinD35);
    digitalWrite(relayPins[7], pinD37);


    analogWrite(fanPin, pinD12);
    analogWrite(heaterPin, pinD13);

}


float readTemperature() {
    float temp = dht.readTemperature();
    if (isnan(temp)) {
        Serial.println("Failed to read from DHT sensor, using random data instead.");
        // Generate and return a random temperature if the sensor read fails
        return random(0, 901) / 10.0 - 20.0;
    }
    return temp;
}


float readHumidity() {
   float humidity = dht.readHumidity();
   if (isnan(humidity)) {
       Serial.println("Failed to read from DHT sensor!");
       return random(0, 1000) / 10.0;
   }
   return humidity;
}

float readTemperatureSensor1() {
    sensors1.requestTemperatures();
    float temp = sensors1.getTempCByIndex(0);
    if (temp == DEVICE_DISCONNECTED_C) {
        Serial.println("Error: Could not read temperature data from sensor 1, using random data instead.");
        // Return a random temperature if the sensor read fails
        return random(0, 901) / 10.0 - 20.0;
    }
    return temp;
}

float readTemperatureSensor2() {
    sensors2.requestTemperatures();
    float temp = sensors2.getTempCByIndex(0);
    if (temp == DEVICE_DISCONNECTED_C) {
        Serial.println("Error: Could not read temperature data from sensor 2, using random data instead.");
        // Return a random temperature if the sensor read fails
        return random(0, 901) / 10.0 - 20.0;
    }
    return temp;
}



float readDistanceAlt(int index) {
  long duration, distance;
  pinMode(ultrasonicSensorPin[index], OUTPUT);
  digitalWrite(ultrasonicSensorPin[index], LOW);
  delayMicroseconds(2);

  digitalWrite(ultrasonicSensorPin[index], HIGH);
  delayMicroseconds(10);
  digitalWrite(ultrasonicSensorPin[index], LOW);

  pinMode(ultrasonicSensorPin[index], INPUT);
  duration = pulseIn(ultrasonicSensorPin[index], HIGH);
  distance = duration / 58.2;
   return distance;
}

float readInnerTankVolume() {
    float distance = readDistanceAlt(0);
    if (distance > 300) {  // Check if the distance is beyond the valid range
        // Return a random volume if the sensor read fails
        return random(0, 3500) / 10.0;
    }
    float waterHeight = 40 - distance;
    return calculateVolumeCylinder(waterHeight, 30);
}

float readOuterTankVolume() {
    float distance = readDistanceAlt(1);
    if (distance > 300) {  // Check if the distance is beyond the valid range
        // Return a random volume if the sensor read fails
        return random(0, 3500) / 10.0;
    }
    float waterHeight = 45 - (distance - 10);
    return calculateVolumeCylinder(waterHeight, 40);
}

float readSoilTankVolume() {
    float distance = readDistanceAlt(2);
    if (distance > 300) {  // Check if the distance is beyond the valid range
        // Return a random volume if the sensor read fails
        return random(0, 40) / 10.0;
    }
    float waterHeight = 20 - (distance - 7);
    return calculateVolumeRectangular(23, 10, waterHeight);
}

float calculateVolumeRectangular(float length, float width, float height) {
   return length * width * height * 0.001;
}

float calculateVolumeCylinder(float height, float diameter) {
   float radius = diameter / 2.0;
   return PI * radius * radius * height * 0.001;
}

float readLightLevel() {
    int sensorValue = digitalRead(lightSensorPin); // lightSensorPin is pin 3
    // Assuming HIGH means bright and LOW means dark
    // You will need to calibrate these values based on your specific sensor's behavior
    if (sensorValue == HIGH) {
        return 1.0; // Bright
    } else if (sensorValue == LOW) {
        return 0.0; // Dark
    } else {
        // If the sensor reading is unreliable or fails
        Serial.println("Error: Could not read light sensor data, using random data instead.");
        return random(0, 10) / 10.0; // Random value as fallback
    }
}



void initializeMode() {

  for (int i = 0; i < 8; i++) {
    pinMode(relayPins[i], OUTPUT);
  }
  pinMode(fanPin, OUTPUT);
  pinMode(heaterPin, OUTPUT);


  for (int i = 0; i < 3; i++) {
    pinMode(ultrasonicSensorPin[i], INPUT);
  }
  for (int i = 0; i < 4; i++) {
    pinMode(ldrSensorPin[i], INPUT);
  }
  for (int i = 0; i < 2; i++) {
    pinMode(potSensorPin[i], INPUT);
  }
  pinMode(lightSensorPin, INPUT);

}
void initializelibrary() {
  dht.begin();
  sensors1.begin();
  sensors2.begin();
}
