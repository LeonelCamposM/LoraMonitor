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
String sensorName = "sensorThree";
bool done = false;
const int sendMinute = 50;

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

void goToSleep(unsigned long sleepMicroseconds) {
  esp_sleep_enable_timer_wakeup(sleepMicroseconds);
  Serial.println("Going to sleep...");
  esp_sleep_pd_config(ESP_PD_DOMAIN_RTC_PERIPH, ESP_PD_OPTION_OFF);
  esp_sleep_pd_config(ESP_PD_DOMAIN_RTC_SLOW_MEM, ESP_PD_OPTION_OFF);
  esp_sleep_pd_config(ESP_PD_DOMAIN_RTC_FAST_MEM, ESP_PD_OPTION_OFF);
  delay(2000);
  esp_deep_sleep_start();
}

void sendSensorMeasure() {
  Serial.println("Sending sensor data...");
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
  message["rain"] = -1.01;
  message["soilMoisture"] = getMoisturePercentage();
  message["sensorName"] = sensorName;
  String jsonString;
  serializeJson(message, jsonString);
  sendAckLora(String(jsonString));
  Serial.println("send " + jsonString);
  sleepLora();
}

void startAccessPoint() {
  start_lora = startLora();
  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println(F("SSD1306 allocation failed"));
  } else {
    display.ssd1306_command(SSD1306_DISPLAYON);
  }
  display.clearDisplay();
  Serial.println(analogRead(36));
  welcomeMessage();
  Serial.println("apMode");
  apModeStartTime = millis();  // record the start time of AP mode
  setupAPMode();
}

void recieveSensorMeasure() {
  unsigned long loopStartTime = millis();

  while (millis() - loopStartTime < 180000) {
    receiveLora();
  }
}

void setup() {
#ifdef DEBUG
  Serial.begin(115200);
  while (!Serial)
    ;
#endif

  setupRTC();
  Serial.println(getTime());
  if (getNowMinute() == sendMinute) {
    Serial.println("Time to send or recieve data...");
    if (startLora()) {
#ifdef SENSOR_NODE
      sendSensorMeasure();
#else
      recieveSensorMeasure();
#endif
      unsigned long sleepMicros = calculateSleepMicrosUntilNextSend();
      Serial.print("Sleeping for ");
      Serial.print(sleepMicros / 1000000UL);
      Serial.println(" seconds until next send...");
      goToSleep(sleepMicros);
    }
  } else {

#ifdef SENSOR_NODE
    unsigned long sleepMicros = calculateSleepMicrosUntilNextSend();
    Serial.print("Sleeping for ");
    Serial.print(sleepMicros / 1000000UL);
    Serial.println(" seconds until next send...");
    goToSleep(sleepMicros);
#else
    esp_sleep_wakeup_cause_t wakeup_reason = esp_sleep_get_wakeup_cause();
    if (wakeup_reason == ESP_SLEEP_WAKEUP_TIMER) {
      unsigned long sleepMicros = calculateSleepMicrosUntilNextSend();
      Serial.print("Sleeping for ");
      Serial.print(sleepMicros / 1000000UL);
      Serial.println(" seconds until next send...");
      goToSleep(sleepMicros);
    } else {
      Serial.println("App mode for a mins");
      startAccessPoint();
    }
#endif
  }
}

void loop() {
#ifdef SENSOR_NODE
#else
  if (!done) {
    if (apModeStartTime > 0 && millis() - apModeStartTime >= 120000) {
      // 5 minutes have passed since AP mode was activated
      display.ssd1306_command(SSD1306_DISPLAYOFF);
      Serial.println("loraMode");
      stopAccesPoint();
      done = true;
      unsigned long sleepMicros = calculateSleepMicrosUntilNextSend();
      Serial.print("Sleeping for ");
      Serial.print(sleepMicros / 1000000UL);
      Serial.println(" seconds until next send...");
      goToSleep(sleepMicros);
    }
  }

  if (start_lora) {
    receiveLora();
  }
#endif
}
