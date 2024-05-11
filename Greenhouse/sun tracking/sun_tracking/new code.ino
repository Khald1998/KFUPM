#include <Servo.h>

// LDR pin connections
int ldrUpper = A2;   // Upper LDR
int ldrLower = A1;   // Lower LDR
int ldrLeft = A3;    // Left LDR
int ldrRight = A0;   // Right LDR

// Calibration offsets
int offsetUpper = 0;
int offsetLower = 0;
int offsetLeft = 0;
int offsetRight = 0;

// Servo
Servo verticalServo;
int servoPin = 9;
int servoPos = 90;  // Start at middle position (90 degrees)
int servoMin = 0;   // Minimum servo position
int servoMax = 180; // Maximum servo position

// Timing
unsigned long previousMillis = 0;
const long interval = 1000; // Interval at which to print (1000 milliseconds or 1 second)

void setup() {
  // Initialize Serial communication
  Serial.begin(9600);

  // Set LDR pins as input
  pinMode(ldrUpper, INPUT);
  pinMode(ldrLower, INPUT);
  pinMode(ldrLeft, INPUT);
  pinMode(ldrRight, INPUT);

  // Attach the servo
  verticalServo.attach(servoPin);

  // Reset servo to default position
  servoPos = 0; // Default position (can be changed as needed)
  verticalServo.write(servoPos);

  // Calibration
  calibrateLDRs();
}

void calibrateLDRs() {
  int baseline = analogRead(ldrRight);
  offsetUpper = baseline - analogRead(ldrUpper);
  offsetLower = baseline - analogRead(ldrLower);
  offsetLeft = baseline - analogRead(ldrLeft);
}

void loop() {
  // Read and calibrate LDR values
  int upperValue = analogRead(ldrUpper) + offsetUpper;
  int lowerValue = analogRead(ldrLower) + offsetLower;
  int leftValue = analogRead(ldrLeft) + offsetLeft;
  int rightValue = analogRead(ldrRight);

  // Determine the direction with the highest light
  int highestLight = max(upperValue, lowerValue);

  // Move servo based on the highest light direction
  if (highestLight == upperValue) {
    moveServoRight();
  } else if (highestLight == lowerValue) {
    moveServoLeft();
  }

  // Get current time
  unsigned long currentMillis = millis();

  // Check if it's time to print
  if (currentMillis - previousMillis >= interval) {
    // Save the last time you printed
    previousMillis = currentMillis;

    // Print LDR values to Serial Monitor
    Serial.print("Upper LDR: ");
    Serial.print(upperValue);
    Serial.print("\tLower LDR: ");
    Serial.print(lowerValue);
    Serial.print("\tLeft LDR: ");
    Serial.print(leftValue);
    Serial.print("\tRight LDR: ");
    Serial.println(rightValue);

    // Print the current servo position
    Serial.print("Servo Position: ");
    Serial.println(servoPos);
  }
}

void moveServoRight() {
  servoPos = min(servoPos + 1, servoMax);
  verticalServo.write(servoPos);
  delay(100); // 5 ms delay for each degree
}

void moveServoLeft() {
  servoPos = max(servoPos - 1, servoMin);
  verticalServo.write(servoPos);
  delay(100); // 5 ms delay for each degree
}
