#include "RTClib.h"
#include <ArduinoJson.h>

RTC_PCF8523 rtc;
char daysOfTheWeek[7][12] = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" };

void setupRTC() {
  if (!rtc.begin()) {
#ifdef DEBUG
    Serial.println("Couldn't find RTC");
    Serial.flush();
#endif
    while (1) delay(10);
  }

  if (!rtc.initialized() || rtc.lostPower()) {
#ifdef DEBUG
    Serial.println("RTC is NOT initialized, let's set the time!");
#endif
    // This line sets the RTC with an explicit date & time, for example to set
    // January 21, 2014 at 3am you would call:
    rtc.adjust(DateTime(2023, 3, 25, 3, 8, 0));
  }
  rtc.start();
}

String getTime() {
  DateTime now = rtc.now();
  String result = "";
#ifdef DEBUG
  Serial.print(now.year(), DEC);
  Serial.print('/');
  Serial.print(now.month(), DEC);
  Serial.print('/');
  Serial.print(now.day(), DEC);
  Serial.print(now.hour(), DEC);
  Serial.print(':');
  Serial.print(now.minute(), DEC);
  Serial.print(':');
  Serial.print(now.second(), DEC);
  Serial.println();
  Serial.println();
#endif
  char buffer[20];
  sprintf(buffer, "%04d-%02d-%02d %02d:%02d:%02d", now.year(), now.month(), now.day(), now.hour(), now.minute(), now.second());
  result = String(buffer);
  return result;
}
