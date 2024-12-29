#include <SoftwareSerial.h>

SoftwareSerial BTSerial(2, 3); // RX, TX (Change these pins if needed)

String removeSpaces(String str) {
  str.trim(); // Remove leading or trailing spaces
  String cleaned = "";
  for (int i = 0; i < str.length(); i++) {
    if (str[i] != ' ') {
      cleaned += str[i];
    }
  }
  return cleaned;
}

void setup() {
  Serial.begin(9600);         // Start hardware serial communication for debugging
  BTSerial.begin(9600);       // Start Bluetooth serial communication
  Serial.println("Bluetooth serial started. Type a number and press Enter.");
}

void loop() {
  if (BTSerial.available()) {           // Check if Bluetooth has data
    String data = BTSerial.readStringUntil('\n'); // Read until newline
    Serial.print("Selected Sensor: ");   // Display received sensor selection
    Serial.println(data);                // Show the received sensor index
  }

  if (Serial.available()) {             // Check if there's data from the Serial Monitor
    String data = Serial.readStringUntil('\n'); // Read until newline
    data = removeSpaces(data);          // Remove spaces
    BTSerial.println(data);             // Send to Bluetooth
  }
}
