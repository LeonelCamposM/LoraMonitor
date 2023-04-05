class Measure {
  double temperature;
  double pressure;
  double altitude;
  int battery;
  int humidity;
  String sensorName;
  DateTime date;

  Measure(this.temperature, this.pressure, this.altitude, this.battery,
      this.humidity, this.sensorName, this.date);

  factory Measure.fromJson(Map<dynamic, dynamic> json) => Measure(
      json['temperature'] as double,
      json['pressure'] as double,
      json['altitude'] as double,
      json['battery'] as int,
      json['humidity'] as int,
      json['sensorName'] as String,
      DateTime.parse(json['date'] as String));

  Map<dynamic, dynamic> toJson() => {
        'temperature': temperature,
        'pressure': pressure,
        'altitude': altitude,
        'battery': battery,
        'humidity': humidity,
        'sensorName': sensorName,
        'date': date.toString()
      };
}
