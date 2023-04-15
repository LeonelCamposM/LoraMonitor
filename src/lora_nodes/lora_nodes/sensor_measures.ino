#include <Wire.h>
#include <SPI.h>
#include <Adafruit_BME280.h>

Adafruit_BME280 bme;

bool startBMP() {
  bool success = true;
  unsigned status;
  status = bme.begin();
  if (!status) {
    success = false;
#ifdef DEBUG
    Serial.println("Could not find a valid BME280 sensor, check wiring, address, sensor ID!");
    Serial.print("SensorID was: 0x");
    Serial.println(bme.sensorID(), 16);
    Serial.print("        ID of 0xFF probably means a bad address, a BMP 180 or BMP 085\n");
    Serial.print("   ID of 0x56-0x58 represents a BMP 280,\n");
    Serial.print("        ID of 0x60 represents a BME 280.\n");
    Serial.print("        ID of 0x61 represents a BME 680.\n");
#endif
  }

  return success;
}

float getBMPAltitude() {
  return bme.readAltitude(1013.25);
}

float getBMPTemperature() {
  return bme.readTemperature();
}

float getBMPPressure() {
  return bme.readPressure();
}

float getBMPHumidity() {
  return bme.readHumidity();
}

const int moisturePin = 36;
int maxMoisture = 2670;  // dry
int minMoisture = 1050;  // wet

double getMoisturePercentage() {
  double sensorValue = analogRead(moisturePin);
#ifdef DEBUG
  Serial.println(sensorValue);
#endif
  double percentageHumidity = map(sensorValue, minMoisture, maxMoisture, 100, 0);
  if (percentageHumidity < 0 || sensorValue == 0) {
    percentageHumidity = 0;
  }
  if (percentageHumidity > 100) {
    percentageHumidity = 100;
  }
  return percentageHumidity;
}

const int raindropsPin = 2;
int maxRaindrops = 4095;  // dry
int minRaindrops = 1263;  // wet

int getRaindropPercentage() {
  int sensorValue = analogRead(raindropsPin);
  int percentageRaindrops = map(sensorValue, minRaindrops, maxRaindrops, 100, 0);
  if (percentageRaindrops < 0 || sensorValue == 0) {
    percentageRaindrops = 0;
  }
  if (percentageRaindrops > 100) {
    percentageRaindrops = 100;
  }
  return percentageRaindrops;
}