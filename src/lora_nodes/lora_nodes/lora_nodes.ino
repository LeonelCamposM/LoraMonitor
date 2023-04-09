#include "WiFi.h"
#include <ArduinoJson.h>

#define DEBUG
#define SENSOR_NODE
#define uS_TO_S_FACTOR 1000000
#define TIME_TO_SLEEP 2000

bool start_lora = false;
String sensorName = "sensorOne";

void goToSleep() {
  esp_sleep_pd_config(ESP_PD_DOMAIN_RTC_PERIPH, ESP_PD_OPTION_OFF);
  esp_sleep_pd_config(ESP_PD_DOMAIN_RTC_SLOW_MEM, ESP_PD_OPTION_OFF);
  esp_sleep_pd_config(ESP_PD_DOMAIN_RTC_FAST_MEM, ESP_PD_OPTION_OFF);
  delay(2000);
  esp_deep_sleep_start();
}

void setup() {
#ifdef DEBUG
  Serial.begin(115200);
  while (!Serial)
    ;
#endif

#ifdef SENSOR_NODE
  esp_sleep_enable_timer_wakeup(3600000000);
  if (startLora()) {
    StaticJsonDocument<200> message;
    message["temperature"] = 11.1;
    message["pressure"] = 903.4;
    message["altitude"] = 22.1;
    message["battery"] = 23.1;
    message["humidity"] = 22.1;
    message["date"] = "today";
    message["light"] = 24.8;
    message["rain"] = 1.89;
    message["soilMoisture"] = 80.9;
    message["sensorName"] = sensorName;
    String jsonString;
    serializeJson(message, jsonString);
    sendAckLora(String(jsonString));
    Serial.println("send " + jsonString);
    sleepLora();
  }
  goToSleep();
#else
  start_lora = startLora();
  setupRTC();
  setupAPMode();
#endif
}

void loop() {
  if (start_lora) {
    receiveLora();
  }
}