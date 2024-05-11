#include <Servo.h> 

Servo horizontalServo;
int horizontalAngle = 180;
int horizontalMaxAngle = 175;
int horizontalMinAngle = 5;
// 65 degrees MAX

Servo verticalServo;
int verticalAngle = 45;
int verticalMaxAngle = 60;
int verticalMinAngle = 1;

// LDR pin connections
// name = analogpin;
int ldrTopLeft = A0; // LDR top left - BOTTOM LEFT <--- BDG
int ldrTopRight = A3; // LDR top right - BOTTOM RIGHT
int ldrBottomLeft = A1; // LDR bottom left - TOP LEFT
int ldrBottomRight = A3; // LDR bottom right - TOP RIGHT

void setup() {
  horizontalServo.attach(9);
  verticalServo.attach(10);
  horizontalServo.write(horizontalAngle);
  verticalServo.write(verticalAngle);
  delay(2500);
}

void loop() {
  int lightTopLeft = analogRead(ldrTopLeft); // top left
  int lightTopRight = analogRead(ldrTopRight); // top right
  int lightBottomLeft = analogRead(ldrBottomLeft); // bottom left
  int lightBottomRight = analogRead(ldrBottomRight); // bottom right

  int delayTime = 10;
  int tolerance = 90; 
  int avgTop = (lightTopLeft + lightTopRight) / 2; // average value top
  int avgBottom = (lightBottomLeft + lightBottomRight) / 2; // average value bottom
  int avgLeft = (lightTopLeft + lightBottomLeft) / 2; // average value left
  int avgRight = (lightTopRight + lightBottomRight) / 2; // average value right

  int verticalDifference = avgTop - avgBottom; // check the difference of up and down
  int horizontalDifference = avgLeft - avgRight; // check the difference of left and right

  if (-1 * tolerance > verticalDifference || verticalDifference > tolerance) {
    if (avgTop > avgBottom) {
      verticalAngle = ++verticalAngle;
      if (verticalAngle > verticalMaxAngle) {
        verticalAngle = verticalMaxAngle;
      }
    } else if (avgTop < avgBottom) {
      verticalAngle = --verticalAngle;
      if (verticalAngle < verticalMinAngle) {
        verticalAngle = verticalMinAngle;
      }
    }
    verticalServo.write(verticalAngle);
  }

  if (-1 * tolerance > horizontalDifference || horizontalDifference > tolerance) {
    if (avgLeft > avgRight) {
      horizontalAngle = --horizontalAngle;
      if (horizontalAngle < horizontalMinAngle) {
        horizontalAngle = horizontalMinAngle;
      }
    } else if (avgLeft < avgRight) {
      horizontalAngle = ++horizontalAngle;
      if (horizontalAngle > horizontalMaxAngle) {
        horizontalAngle = horizontalMaxAngle;
      }
    } else if (avgLeft == avgRight) {
      delay(5000);
    }
    horizontalServo.write(horizontalAngle);
  }

  delay(delayTime);
}
