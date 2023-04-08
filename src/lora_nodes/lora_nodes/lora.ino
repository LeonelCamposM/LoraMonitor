#include <SPI.h>
#include <LoRa.h>
#include <Wire.h>

#define SCLK 5   // GPIO5  -- SX1278's SCLK
#define MISO 19  // GPIO19 -- SX1278's MISO
#define MOSI 27  // GPIO27 -- SX1278's MOSI
#define CS 18    // GPIO18 -- SX1278's CS
#define RST 14   // GPIO14 -- SX1278's RESET
#define DI0 26   // GPIO26 -- SX1278's IRQ(Interrupt Request)
#define BAND 903E6

#define MEASURE_PATH "/measure_data.txt"

String rssi = "RSSI --";
String messageSize = "--";
String packet;
String globalPacket;

bool startLora() {
  bool error = false;
  SPI.begin(SCLK, MISO, MOSI, CS);
  LoRa.setPins(CS, RST, DI0);
  if (!LoRa.begin(BAND)) {
#ifdef DEBUG
    Serial.println("Starting LoRa failed!");
#endif
    error = true;
  }
  LoRa.setSyncWord(0x12);
  LoRa.receive();
  return !error;
}

bool validatePacket(String packet) {
  // Parse the packet to extract the values
  DynamicJsonDocument doc(1024);
  deserializeJson(doc, packet);

  // Extract the values
  float temperature = doc["temperature"];
  float pressure = doc["pressure"];
  float altitude = doc["altitude"];
  float humidity = doc["humidity"];
  float battery = doc["battery"];
  String date = doc["date"];
  float light = doc["light"];
  float rain = doc["rain"];
  float soilMoisture = doc["soilMoisture"];
  String sensorName = doc["sensorName"];

  // Validate the values
  bool validateTemperature = temperature >= -50 && temperature <= 50;
  bool validatePressure = pressure >= 800 && pressure <= 1200;
  bool validateAltitude = altitude >= -100 && altitude <= 10000;
  bool validateHumidity = humidity >= 0 && humidity <= 100;
  bool validateBattery = battery >= 0 && battery <= 100;

  // Validate date and sensorName
  bool validateDate = date.length() > 0;
  bool validateSensorName = sensorName.length() > 0;

  // Validate light, rain and soilMoisture
  bool validateLight = light >= 0 && light <= 100;
  bool validateRain = rain >= 0 && rain <= 100;
  bool validateSoilMoisture = soilMoisture >= 0 && soilMoisture <= 100;
#ifdef DEBUG
  if (!validateTemperature) {
    Serial.println("Temperature validation failed");
  }
  if (!validatePressure) {
    Serial.println("Pressure validation failed");
  }
  if (!validateAltitude) {
    Serial.println("Altitude validation failed");
  }
  if (!validateHumidity) {
    Serial.println("Humidity validation failed");
  }
  if (!validateBattery) {
    Serial.println("Battery validation failed");
  }
  if (!validateDate) {
    Serial.println("Date validation failed");
  }
  if (!validateSensorName) {
    Serial.println("Sensor name validation failed");
  }
  if (!validateLight) {
    Serial.println("Light validation failed");
  }
  if (!validateRain) {
    Serial.println("Rain validation failed");
  }
  if (!validateSoilMoisture) {
    Serial.println("Soil moisture validation failed");
  }
#endif
  return validateTemperature && validatePressure && validateAltitude && validateHumidity && validateBattery && validateDate && validateSensorName && validateLight && validateRain && validateSoilMoisture;
}

void handleRequest(int packetSize, String date) {
  packet = "";
  messageSize = String(packetSize, DEC);
  for (int i = 0; i < packetSize; i++) { packet += (char)LoRa.read(); }
  rssi = "RSSI " + String(LoRa.packetRssi(), DEC);

  bool validPacket = validatePacket(packet);
  if (validPacket) {
    //saveData(MEASURE_PATH, packet, date);
    sendLora("ACK");
#ifdef DEBUG
    Serial.println("Recieved " + messageSize + " bytes");
    Serial.println(packet);
    Serial.println(rssi);
#endif
  }
}

String receiveLora() {
  while (true) {
    packet = "";
    int packetSize = LoRa.parsePacket();
    if (packetSize) {
      // String date = getTime();
      String date = "today";
      handleRequest(packetSize, date);
      break;
    }
  }
  return packet;
}

void sendLora(String message) {
  LoRa.beginPacket();
  LoRa.print(message);
  LoRa.endPacket();
}

void sendAckLora(String message) {
  int retries = 0;
  bool ackReceived = false;

  while (retries < 5 && !ackReceived) {
    LoRa.beginPacket();
    LoRa.print(message);
    LoRa.endPacket();

    // Wait for a response
    unsigned long start = millis();
    while (millis() - start < 1000) {
      int packetSize = LoRa.parsePacket();
      if (packetSize) {
        String response = "";
        while (LoRa.available()) {
          response += (char)LoRa.read();
        }
        if (response == "ACK") {
#ifdef DEBUG
          Serial.println("Message received correctly");
#endif
          ackReceived = true;
          break;
        }
      }
    }

    if (!ackReceived) {
      retries++;
#ifdef DEBUG
      Serial.println("Retrying to send the message...");
#endif
    }
  }

  if (!ackReceived) {
#ifdef DEBUG
    Serial.println("Could not send the message after 5 attempts");
#endif
  }
}

void sleepLora() {
  LoRa.sleep();
}