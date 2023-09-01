const char* ssid = "LORAMONITOR";
const char* password = "12345lora";
IPAddress local_IP(192, 168, 1, 22);
IPAddress gateway(192, 168, 1, 5);
IPAddress subnet(255, 255, 255, 0);

void startAccesPoint() {
  WiFi.disconnect(false);
  WiFi.mode(WIFI_AP);
#ifdef DEBUG
  Serial.print("Setting up Access Point ... ");
  Serial.println(WiFi.softAPConfig(local_IP, gateway, subnet) ? "Ready" : "Failed!");
  Serial.print("Starting Access Point ... ");
  Serial.println(WiFi.softAP(ssid, password) ? "Ready" : "Failed!");
  Serial.print("IP address = ");
  Serial.println(WiFi.softAPIP());
#else
  WiFi.softAPConfig(local_IP, gateway, subnet);
  WiFi.softAP(ssid, password);
#endif
}

void stopAccesPoint() {
  WiFi.softAPdisconnect(true);
}

void setupAPMode() {
  startAccesPoint();
  startHttpServer();
}
