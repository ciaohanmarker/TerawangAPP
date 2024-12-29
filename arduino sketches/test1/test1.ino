#include <SoftwareSerial.h>

// Create a SoftwareSerial instance for communication with HC-05
SoftwareSerial BTSerial(10, 11); // RX, TX on pins 10 and 11 (TX on Arduino to RX on HC-05 via voltage divider)

void setup() {
  // Initialize serial communication with the PC
  Serial.begin(9600);

  // Initialize Bluetooth serial communication with the HC-05 module
  BTSerial.begin(9600);  // Set baud rate for HC-05

  // Optional: Indicator LED (can be any pin or LED_BUILTIN)
  pinMode(LED_BUILTIN, OUTPUT);

  // Let the app know Bluetooth is ready
  BTSerial.println("Bluetooth is ready. Waiting for connection...");
}

void loop() {
  // Check if data is coming from the Bluetooth module (from the app)
  if (BTSerial.available()) {
    char data = BTSerial.read();  // Read the incoming data from Flutter

    if (data == '1') {
      // If '1' is received from Flutter (connection successful)
      digitalWrite(LED_BUILTIN, HIGH);  // Turn on LED to indicate connection
      BTSerial.println("Connected");
    } else if (data == '0') {
      // If '0' is received from Flutter (disconnect)
      digitalWrite(LED_BUILTIN, LOW);   // Turn off the LED to indicate disconnection
      BTSerial.println("Disconnected");
    }
  }

  // Optionally, forward data from the serial monitor to the Bluetooth module
  if (Serial.available()) {
    BTSerial.write(Serial.read());  // Send data from Serial Monitor to Bluetooth
  }
}
