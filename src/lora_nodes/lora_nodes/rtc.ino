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

  if (!rtc.initialized()) {
#ifdef DEBUG
    Serial.println("RTC is NOT initialized, let's set the time!");
#endif
    // This line sets the RTC with an explicit date & time, for example to set
    // 4 mes , 27 dia , 2023 año  at 9 : 34 you would call:
    rtc.adjust(DateTime(2023, 8, 29, 9, 25, 0));
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
  Serial.print("HOUR");
  Serial.print(now.hour(), DEC);
  Serial.print(':');
  Serial.print(now.minute(), DEC);
  Serial.print(':');
  Serial.print(now.second(), DEC);
  Serial.println();
  Serial.println();
#endif
  char buffer[40];
  sprintf(buffer, "%04d-%02d-%02d %02d:%02d:%02d", now.year(), now.month(), now.day(), now.hour(), now.minute(), now.second());
  result = String(buffer);
  return result;
}


unsigned long calculateSleepMicrosUntilNextSend() {
  DateTime now = rtc.now();

  // Calcula el tiempo restante hasta la próxima hora y el minuto de envío
  int minutesUntilSend = (sendMinute - now.minute() + 60) % 60;
  unsigned long sleepMicros = minutesUntilSend * 60000000UL;

  // Si el tiempo de sueño calculado es mayor que una hora en microsegundos, ajusta a una hora
  if (sleepMicros > 3600000000UL) {
    sleepMicros = 3600000000UL;  // Una hora en microsegundos
  }

  if (sleepMicros == 0) {
    sleepMicros = sleepMicros = 1 * 60000000UL;
  }

  return sleepMicros;
}

int getNowMinute() {
  return rtc.now().minute();
}