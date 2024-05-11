#include "DHT.h"
#include <LiquidCrystal_I2C.h>

#define DHT_PIN 4
#define DHT_TYPE DHT11
DHT dhtSensor(DHT_PIN, DHT_TYPE);
float temperature = 0.0;
float humidity = 0.0;

int lcdColumns = 16;
int lcdRows = 2;

LiquidCrystal_I2C lcdDisplay(0x27, lcdColumns, lcdRows);

int fanPin = 6;
int heaterPin = 7;

uint8_t degreeSymbol[8] = {B00000, B11000, B11000, B00000, B00000, B00000, B00000, B00000};
uint8_t temperatureIcon[8] = {B00100, B01010, B01010, B01110, B01110, B11111, B11111, B01110};
uint8_t humidityIcon[8] = {B00100, B00100, B01010, B01010, B10001, B10001, B10001, B01110};
uint8_t fanIcon[8] = {B00000, B11011, B11011, B00100, B11011, B11011, B00000, B00000};
uint8_t heaterIcon[8] = {B00000, B10001, B10001, B11111, B10001, B10001, B10001, B00000};

void setup() {
  Serial.begin(9600);
  dhtSensor.begin();
  lcdDisplay.init();
  lcdDisplay.backlight();

  lcdDisplay.createChar(1, degreeSymbol);
  lcdDisplay.createChar(2, temperatureIcon);
  lcdDisplay.createChar(3, humidityIcon);
  lcdDisplay.createChar(4, fanIcon);
  lcdDisplay.createChar(5, heaterIcon);

  pinMode(fanPin, OUTPUT);
  pinMode(heaterPin, OUTPUT);

  delay(500); 
}

void loop() {
  displaySensorData();
  controlFan(temperature);
  controlHeater(temperature);
}


void controlHeater(float currentTemperature) {
  if (currentTemperature < 15) {
    digitalWrite(heaterPin, HIGH);
    lcdDisplay.setCursor(14, 0);
    lcdDisplay.write(heaterIcon);
  } else {
    digitalWrite(heaterPin, LOW);
  }
}

void controlFan(float currentTemperature) {
  const int maxTemp = 50;
  const int minTemp = 20;
  const int maxFanSpeed = 255;
  const int minFanSpeed = 0;

  if (currentTemperature > minTemp) {
    // Calculate the slope of the line
    float slope = float(maxFanSpeed - minFanSpeed) / (maxTemp - minTemp);
    // Calculate the fan speed
    int fanSpeed = minFanSpeed + slope * (currentTemperature - minTemp);

    // Clamp the fan speed to maxFanSpeed
    fanSpeed = min(fanSpeed, maxFanSpeed);

    analogWrite(fanPin, fanSpeed);
    lcdDisplay.setCursor(15, 0);
    lcdDisplay.write(fanIcon);
  } else {
    analogWrite(fanPin, 0);
  }
}



void displaySensorData() {
  delay(2000);
  lcdDisplay.clear();

  temperature = dhtSensor.readTemperature();
  humidity = dhtSensor.readHumidity();

  if (isnan(temperature) || isnan(humidity)) {
    Serial.println(F("Failed to read from DHT sensor!"));
    return;
  }
  Serial.print(F("TEMP: "));
  Serial.print(temperature);
  Serial.print("   ");
  Serial.print(F("HUMI: "));
  Serial.print(humidity);
  Serial.println(F(" %"));

  lcdDisplay.setCursor(0, 0);
  lcdDisplay.print(F("Temp: "));
  lcdDisplay.print(temperature);
  lcdDisplay.write(degreeSymbol);
  lcdDisplay.print(F("C"));

  lcdDisplay.setCursor(0, 1);
  lcdDisplay.print(F("Hum : "));
  lcdDisplay.print(humidity);
  lcdDisplay.print(F(" %"));
}
