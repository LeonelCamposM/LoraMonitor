#include <WebServer.h>
#include <ArduinoJson.h>

#include <WiFi.h>
#include "ESPAsyncWebServer.h"

#define MEASURE_PATH "/measure_data.txt"
const char* PARAM_MESSAGE = "limits";

AsyncWebServer server(80);

void startHttpServer() {

  server.on("/deleteAllData", HTTP_GET, [](AsyncWebServerRequest* request) {
    bool response = remove_file(MEASURE_PATH);
    if (response) {
      request->send(200, "text/plain", "ok");
#ifdef DEBUG
      Serial.println("[Server] removed all data");
#endif
    } else {
      request->send(404, "text/plain", "error");
#ifdef DEBUG
      Serial.println("[Server] error removing all data");
#endif
    }
  });

  server.on("/getAllData", HTTP_GET, [](AsyncWebServerRequest* request) {
    request->send(200, "text/plain", getAllData(MEASURE_PATH));
#ifdef DEBUG
    Serial.println("[Server] readed all data");
#endif
  });

  server.on("/getName", HTTP_GET, [](AsyncWebServerRequest* request) {
    request->send(200, "text/plain", "loraMonitor");
  });

  server.begin();
#ifdef DEBUG
  Serial.println("Listening on 192.168.1.22:80");
#endif
}
