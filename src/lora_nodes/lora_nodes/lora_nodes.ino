#include "WiFi.h"
#include <ArduinoJson.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#define DEBUG
// #define SENSOR_NODE
#define uS_TO_S_FACTOR 1000000
#define TIME_TO_SLEEP 2000

bool start_lora = false;
String sensorName = "sensorTwo";

#define SCREEN_WIDTH 128  // OLED display width, in pixels
#define SCREEN_HEIGHT 64  // OLED display height, in pixels

// Declaration for an SSD1306 display connected to I2C (SDA, SCL pins)
#define OLED_RESET -1  // Reset pin # (or -1 if sharing Arduino reset pin)
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);
unsigned long apModeStartTime = 0;

void welcomeMessage() {
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(WHITE);
  int16_t x1, y1;
  uint16_t w, h;
  display.getTextBounds(getTime(), 0, 0, &x1, &y1, &w, &h);
  display.setCursor((SCREEN_WIDTH - w) / 2, (SCREEN_HEIGHT - h) / 2);
  display.println(getTime());
  display.println(analogRead(36));
  display.display();
}

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
    if (startBMP()) {
      message["temperature"] = getBMPTemperature();
      message["pressure"] = getBMPPressure();
      message["altitude"] = getBMPAltitude();
      message["humidity"] = getBMPHumidity();
    } else {
      message["temperature"] = -1.01;
      message["pressure"] = -1.01;
      message["altitude"] = -1.01;
      message["humidity"] = -1.01;
    }

    if (startTSL()) {
      message["light"] = getLuminosity();
    } else {
      message["light"] = -1.01;
    }

    message["battery"] = -1.01;
    message["date"] = "today";
    message["rain"] = analogRead(36);
    message["soilMoisture"] = analogRead(4);
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
  Serial.println(getTime());
  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println(F("SSD1306 allocation failed"));
  } else {
    display.ssd1306_command(SSD1306_DISPLAYON);
  }
  display.clearDisplay();
  if (toggleMode()) {
    Serial.println(analogRead(36));
    welcomeMessage();
    Serial.println("apMode");
    apModeStartTime = millis();  // record the start time of AP mode
    setupAPMode();
  } else {
    display.ssd1306_command(SSD1306_DISPLAYOFF);
    Serial.println("loraMode");
  }
#endif
}

void loop() {
  if (apModeStartTime > 0 && millis() - apModeStartTime >= 300000) {
    // 5 minutes have passed since AP mode was activated
    ESP.restart();  // restart the ESP
  }

  if (start_lora) {
    receiveLora();
  }
}
