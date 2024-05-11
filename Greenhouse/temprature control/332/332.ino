// #include "DHT.h"
// #include <LiquidCrystal_I2C.h>

// #define DHTPIN 4
// #define DHTTYPE DHT11
// DHT dht(DHTPIN, DHTTYPE);
// float temp = 0;
// float humi = 0;

// int lcdColumns = 16;
// int lcdRows = 2;
// //If 0x3f address is not work, then change the address to 0x27
// LiquidCrystal_I2C lcd (0x27, lcdColumns, lcdRows); 

// int buzzer = 5;
// int fan = 6;
// int heater = 7;
// int rgb[3] = {9, 10, 11};

// uint8_t buzz[8] = {B00001, B00011, B00111, B11111, B11111, B00111, B00011, B00001};
// uint8_t degree[8] = {B00000, B11000, B11000, B00000, B00000, B00000, B00000, B00000};
// uint8_t tem[8] = {B00100, B01010, B01010, B01110, B01110, B11111, B11111, B01110};
// uint8_t hum[8] = {B00100, B00100, B01010, B01010, B10001, B10001, B10001, B01110};
// uint8_t fanEmoji[8] = {B00000, B11011, B11011, B00100, B11011, B11011, B00000, B00000};
// uint8_t heaterEmoji[8] = {B00000, B10001, B10001, B11111, B10001, B10001, B10001, B00000};

// void setup() {
//   // put your setup code here, to run once:
//   Serial.begin(9600);
//   dht.begin();
//   lcd.init();
//   lcd.backlight();

//   lcd.createChar(0, buzz);
//   lcd.createChar(1, degree);
//   lcd.createChar(2, tem);
//   lcd.createChar(3, hum);
//   lcd.createChar(4, fanEmoji);
//   lcd.createChar(5, heaterEmoji);

//   pinMode(fan, OUTPUT);
//   pinMode(heater, OUTPUT);
//   pinMode(buzzer, OUTPUT);
//   for (int i = 0; i < 3; i++) {
//     pinMode(rgb[i], OUTPUT);
//   }
//   int t = 100;
// delay(500); 
//  for (int r = 0; r < 3; r++) {
//     setColor(148, 0, 211);
//     delay(t);
//     setColor(0, 0, 255);
//     delay(t);
//     setColor(0, 191, 255);
//     delay(t);
//     setColor(0, 255, 0);
//     delay(t);
//     setColor(255, 255, 0);
//     delay(t);
//     setColor(255, 127, 0);
//     delay(t);
//     setColor(255, 0, 0);
//     delay(t);
//   }
// }

// void loop() {
//   // put your main code here, to run repeatedly:
//   printData();
//   if (temp < 15 ) {
//     setColor(0, 0, 255);
//     analogWrite(fan, 0);
//     digitalWrite(heater, HIGH); 
    
//     lcd.setCursor(14, 0);
//     lcd.write(0); 
//     lcd.setCursor(15, 0);
//     lcd.write(5);        
        
//     tone(buzzer, 1000);
//     delay(400);
//     noTone(buzzer);
//     delay(400);    
//   }
//   else if (temp > 20 && temp < 25) {
//     setColor(255, 255, 255);
//     analogWrite(fan, 51);
//     lcd.setCursor(15, 0);
//     lcd.write(4);
// noTone(buzzer);    
//   }
//   else if (temp > 25 && temp < 30) {
//     setColor(0, 255, 0);
//     analogWrite(fan, 102);
//     lcd.setCursor(15, 0);
//     lcd.write(4);
// noTone(buzzer);    
//   }
//   else if (temp > 30 && temp < 35) {
//     setColor(255, 255, 0);
//     analogWrite(fan, 153);
//     lcd.setCursor(15, 0);
//     lcd.write(4);
//     noTone(buzzer);
//   }
//   else if (temp > 35 && temp < 40) {
//     setColor(255, 90, 0);
//     analogWrite(fan, 204);
//     lcd.setCursor(15, 0);
//     lcd.write(4);
//     noTone(buzzer);
//   }
//   else if (temp > 40 && temp < 50) {
//     setColor(255, 0, 0);
//     analogWrite(fan, 255);    
//     lcd.setCursor(14, 0);
//     lcd.write(0);
//     lcd.setCursor(15, 0);
//     lcd.write(4);
//     tone(buzzer, 1000);
//   }
// }

// void printData() {

//   delay(2000);
//   lcd.clear();

//   temp = dht.readTemperature();
//   humi = dht.readHumidity();

//   if (isnan(temp) || isnan(humi)) {
//     Serial.println(F("Failed to read from DHT sensor!"));
//     return;
//   }
//   Serial.print(F("TEMP: "));
//   Serial.print(temp);
//   Serial.print("   ");
//   Serial.print(F("HUMI: "));
//   Serial.print(humi);
//   Serial.println(F(" %"));

//   lcd.setCursor(0, 0);
//   lcd.print(F("Temp: "));
//   lcd.print(temp);
//   lcd.write(1);
//   lcd.print(F("C"));

//   lcd.setCursor(0, 1);
//   lcd.print(F("Hum : "));
//   lcd.print(humi);
//   lcd.print(F(" %"));
// }

// void setColor(int r, int g, int b) {
//   analogWrite(rgb[0], r);
//   analogWrite(rgb[1], g);
//   analogWrite(rgb[2], b);
// }


#include "DHT.h"
#include <LiquidCrystal_I2C.h>
#include <OneWire.h>
#include <DallasTemperature.h>

#define DHTPIN 4 // DHT11 sensor pin
#define DHTTYPE DHT11
#define ONE_WIRE_BUS 5 // DS18B20 sensor pin

DHT dht(DHTPIN, DHTTYPE);
OneWire oneWire(ONE_WIRE_BUS);
DallasTemperature sensors(&oneWire);

float dhtTemp = 0;
float dsTemp = 100;

int lcdColumns = 16;
int lcdRows = 2;
LiquidCrystal_I2C lcd(0x27, lcdColumns, lcdRows); // LCD I2C address

// Define control pins
int reley = 3; //reley
int heater = 7; //heater
int fan = 6; //fan

uint8_t degree[8] = {B00000, B11000, B11000, B00000, B00000, B00000, B00000, B00000};

void setup() {
  Serial.begin(9600);
  dht.begin();
  sensors.begin();

  lcd.init();
  lcd.backlight();
  lcd.createChar(1, degree);

  pinMode(reley, OUTPUT);
  pinMode(heater, OUTPUT);
  pinMode(fan, OUTPUT);
}

void loop() {
  dhtTemp = dht.readTemperature();
  sensors.requestTemperatures(); // Send the command to get temperatures
//   dsTemp = sensors.getTempCByIndex(0);

  if (isnan(dhtTemp) || isnan(dsTemp)) {
    Serial.println(F("Failed to read from sensors!"));
    return;
  }

  // Implementing the specified logic
  if (dhtTemp < 15 && dsTemp > 50) {
    digitalWrite(reley, HIGH);
    digitalWrite(heater, LOW);
    digitalWrite(fan, LOW);
  } else if (dhtTemp > 45) {
    digitalWrite(reley, LOW);
    digitalWrite(heater, LOW);
    digitalWrite(fan, HIGH);
  } else if (dhtTemp < 15 && dsTemp < 50) {
    digitalWrite(reley, LOW);
    digitalWrite(heater, HIGH);
    digitalWrite(fan, LOW);
  } else {
    // Default state when none of the conditions are met
    digitalWrite(reley, LOW);
    digitalWrite(heater, LOW);
    digitalWrite(fan, LOW);
  }

  // Display data on LCD
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(F("DHT Temp: "));
  lcd.print(dhtTemp);
  lcd.write(1); // degree symbol
  lcd.print(F("C"));

  lcd.setCursor(0, 1);
  lcd.print(F("DS Temp: "));
  lcd.print(dsTemp);
  lcd.write(1); // degree symbol
  lcd.print(F("C"));

  // Serial print for debugging
  Serial.print(F("DHT Temp: "));
  Serial.print(dhtTemp);
  Serial.print(F(" C, DS Temp: "));
  Serial.print(dsTemp);
  Serial.println(F(" C"));

  delay(2000); // Delay for stability
}
