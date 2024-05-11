const int Relay_pin = 7;          // relay control pin connected to digital pin 7
const int Pump_on_time = 330000;    // pump on time in milliseconds(5.5 min)
const int Wait_time = 900000;      // wait time between pump cycles in milliseconds ( 15 min)

void setup()
{
  Serial.begin(9600);
  pinMode(Relay_pin, OUTPUT);
}

void loop()
{
  pump_con();
  delay(Wait_time);
}

void pump_con()
{
  digitalWrite(Relay_pin, HIGH);    // Activate the relay (turn on the pump)
  delay(Pump_on_time);
  digitalWrite(Relay_pin, LOW);     // Deactivate the relay (turn off the pump)
}