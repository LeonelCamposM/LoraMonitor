#include <SPI.h>
#include <SD.h>
#include <RHSoftwareSPI.h>
#include <ArduinoJson.h>
#include <ESP32Time.h>

#define SD_CS 13
#define SD_SCK 14
#define SD_MOSI 15
#define SD_MISO 2
#define MEASURE_PATH "/measure_data.txt"

SPIClass sd_spi(HSPI);

bool remove_file(String path) {
  bool response = false;
  sd_spi.begin(SD_SCK, SD_MISO, SD_MOSI, SD_CS);
  if (!SD.begin(SD_CS, sd_spi)) {
    Serial.println("SD Card: mounting failed.");
  } else {
    bool exist = SD.exists(path);
    if (exist) {
      response = SD.remove(path);
    }
    sd_spi.end();
    SD.end();
  }
  return response;
}

void saveData(String path, String data, String time) {
  sd_spi.begin(SD_SCK, SD_MISO, SD_MOSI, SD_CS);
  if (!SD.begin(SD_CS, sd_spi)) {
    Serial.println("SD Card: mounting failed.");
  } else {
    if (time != "") {
      data.replace("today", time);
    }
    data += ";";
    File dataFile;
    if (SD.exists(path) && time != "") {
      dataFile = SD.open(path, "a");
    } else {
      dataFile = SD.open(path, FILE_WRITE);
    }

    if (dataFile) {
      dataFile.println(data);
      dataFile.close();
      Serial.println("Saving data: ");
      Serial.println(data);
    }

    SD.end();
    sd_spi.end();
  }
}

String getAllData(String path) {
  String response = "";
  sd_spi.begin(SD_SCK, SD_MISO, SD_MOSI, SD_CS);
  if (!SD.begin(SD_CS, sd_spi)) {
    Serial.println("SD Card: mounting failed.");
  } else {
    File dataFile = SD.open(path);
    if (dataFile) {
      while (dataFile.available()) {
        response += dataFile.readStringUntil('\n');
      }
      dataFile.close();
    } else {
      Serial.println("error opening file");
    }
    SD.end();
    sd_spi.end();
  }
  return response;
}
