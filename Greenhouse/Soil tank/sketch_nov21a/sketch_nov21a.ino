#include <Servo.h>

// Pin Definitions
const int irLedPin = 2;             // Pin for IR LED
const int irPhototransistorPin = 3; // Pin for IR Phototransistor
const int relayPin = 4;             // Pin for relay module control

// Constants
const unsigned long readInterval = 1000; // Interval to read sensor (in milliseconds)
const int calibrationSamples = 100;      // Number of samples for calibration
const int movingAverageWindow = 10;      // Window size for moving average filter
const int relayOnValue = LOW;            // Relay ON state
const int relayOffValue = HIGH;          // Relay OFF state

// Variables
int dustThreshold;                       // Threshold for dust detection
int dustValues[movingAverageWindow];     // Array to store recent dust values
int dustIndex = 0;                       // Current index for dust values array
bool isDustDetected = false;             // Flag for dust detection
unsigned long lastReadTime = 0;          // Last time the sensor was read

void setup() {
  Serial.begin(9600);                       // Initialize Serial communication
  pinMode(irLedPin, OUTPUT);                // Set IR LED pin as output
  pinMode(irPhototransistorPin, INPUT);     // Set IR Phototransistor pin as input
  pinMode(relayPin, OUTPUT);                // Set relay module control pin as output
  digitalWrite(irLedPin, HIGH);             // Turn on IR LED
  digitalWrite(relayPin, relayOffValue);    // Ensure relay is off initially
  calibrateDustSensor();                    // Calibrate dust sensor
}

void loop() {
  unsigned long currentTime = millis();

  if (currentTime - lastReadTime >= readInterval) {
    lastReadTime = currentTime;
    readAndProcessSensor();
  }

  // Other non-blocking code can go here
}

void readAndProcessSensor() {
  int dustValue = analogRead(irPhototransistorPin);  // Read value from IR Phototransistor
  dustValues[dustIndex] = dustValue;                // Store current value in array
  dustIndex = (dustIndex + 1) % movingAverageWindow;// Update index for next reading

  int averageDustValue = calculateMovingAverage();  // Calculate moving average of values

  isDustDetected = (averageDustValue > dustThreshold);
  controlRelay(isDustDetected);                     // Control relay based on detection

  Serial.print("Dust Value: ");
  Serial.print(dustValue);
  Serial.print(", Average: ");
  Serial.print(averageDustValue);
  Serial.print(", Threshold: ");
  Serial.print(dustThreshold);
  Serial.println(isDustDetected ? ", Dust Detected!" : ", No Dust.");
}

void calibrateDustSensor() {
  long total = 0;
  for (int i = 0; i < calibrationSamples; i++) {
    total += analogRead(irPhototransistorPin);
    delay(10); // Small delay for sensor reading stabilization
  }
  dustThreshold = total / calibrationSamples * 1.1; // 10% above average as threshold
  Serial.print("Calibrated Dust Threshold: ");
  Serial.println(dustThreshold);
}

int calculateMovingAverage() {
  long total = 0;
  for (int i = 0; i < movingAverageWindow; i++) {
    total += dustValues[i];
  }
  return total / movingAverageWindow;
}

void controlRelay(bool dustDetected) {
  digitalWrite(relayPin, dustDetected ? relayOnValue : relayOffValue);
}
