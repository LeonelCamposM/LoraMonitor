#include <Wire.h>
#include <SPI.h>
#include <Adafruit_BME280.h>
#include <Adafruit_Sensor.h>
#include "Adafruit_TSL2591.h"

Adafruit_BME280 bme;
Adafruit_TSL2591 tsl = Adafruit_TSL2591(2591);

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

bool startTSL() {
  bool success = true;
  if (!tsl.begin()) {
    success = false;
  }
  return success;
}

float getLuminosity() {
  uint32_t lum = tsl.getFullLuminosity();
  uint16_t ir, full;
  ir = lum >> 16;
  full = lum & 0xFFFF;
  return tsl.calculateLux(full, ir);
}

float getBMPAltitude() {
  return bme.readAltitude(1013.25);
}

float getBMPTemperature() {
  return bme.readTemperature();
}

float getBMPPressure() {
  return bme.readPressure() / 100.0F;
}

float getBMPHumidity() {
  return bme.readHumidity();
}

const int moisturePin = 36;
double getMoisturePercentage() {
  double sensorValue = analogRead(moisturePin);
#ifdef DEBUG
  Serial.println(sensorValue);
#endif
  return sensorValue;
}

const int raindropsPin = 4;
int getRaindropPercentage() {
  int sensorValue = analogRead(raindropsPin);
#ifdef DEBUG
  Serial.println(sensorValue);
#endif
  return sensorValue;
}