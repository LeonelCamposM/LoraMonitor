#include <Wire.h>
#include <SPI.h>
#include <Adafruit_BMP280.h>
Adafruit_BMP280 bmp;

bool startBMP() {
  bool error = false;
  unsigned status;
  status = bmp.begin(0x76);
  if (!status) {
    error = true;
#ifdef DEBUG
    Serial.println(F("Could not find a valid BMP280 sensor, check wiring or "
                     "try a different address!"));
    Serial.print("SensorID was: 0x");
    Serial.println(bmp.sensorID(), 16);
    Serial.print("        ID of 0xFF probably means a bad address, a BMP 180 or BMP 085\n");
    Serial.print("   ID of 0x56-0x58 represents a BMP 280,\n");
    Serial.print("        ID of 0x60 represents a BME 280.\n");
    Serial.print("        ID of 0x61 represents a BME 680.\n");
#endif
  } else {
    bmp.setSampling(Adafruit_BMP280::MODE_NORMAL,  /* Operating Mode. */
                    Adafruit_BMP280::SAMPLING_X2,  /* Temp. oversampling */
                    Adafruit_BMP280::SAMPLING_X16, /* Pressure oversampling */
                    Adafruit_BMP280::FILTER_X16,   /* Filtering. */
                    Adafruit_BMP280::STANDBY_MS_500);
  }
  return error;
}

float getBMPAltitude() {
  return bmp.readAltitude(1013.25);
}

float getBMPTemperature() {
  return bmp.readTemperature();
}

float getBMPPressure() {
  return bmp.readPressure();
}


const int moisturePin = 36;
int maxMoisture = 4095;  // dry
int minMoisture = 0;     // wet

double getMoisturePercentage() {
  double sensorValue = analogRead(moisturePin);
  Serial.println(sensorValue);
  double percentageHumidity = map(sensorValue, maxMoisture, minMoisture, 100, 0);
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