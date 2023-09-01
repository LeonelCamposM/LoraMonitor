#include <WebServer.h>
#include <ArduinoJson.h>

#include <WiFi.h>
#include "ESPAsyncWebServer.h"

#define MEASURE_PATH "/measure_data.txt"
const char* PARAM_MESSAGE = "limits";

String sensorNames[5] = { "sensorOne", "sensorTwo", "sensorThree", "sensorFour", "sensorFive" };

AsyncWebServer server(80);

void startHttpServer() {

  server.on("/deleteAllData", HTTP_GET, [](AsyncWebServerRequest* request) {
    remove_file("/" + sensorNames[0]);
    remove_file("/" + sensorNames[1]);
    remove_file("/" + sensorNames[2]);
    remove_file("/" + sensorNames[3]);
    remove_file("/" + sensorNames[4]);
    if (true) {
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
    String response = "";
    String data = getAllData("/" + sensorNames[0]);
    response = data == "" ? "" : data + "/\n";
    data = getAllData("/" + sensorNames[1]);
    response += data == "" ? "" : data + "/\n";
    data = getAllData("/" + sensorNames[2]);
    response += data == "" ? "" : data + "/\n";
    data = getAllData("/" + sensorNames[3]);
    response += data == "" ? "" : data + "/\n";
    data = getAllData("/" + sensorNames[4]);
    response += data == "" ? "" : data + "/\n";
    if (response == "") {
      request->send(404, "text/plain", "error");
    } else {
      request->send(200, "text/plain", response);
    }
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
