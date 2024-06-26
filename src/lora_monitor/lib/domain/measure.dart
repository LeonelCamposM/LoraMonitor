import 'package:cloud_firestore/cloud_firestore.dart';

class Measure {
  double temperature;
  double pressure;
  double altitude;
  double battery;
  double humidity;
  double rain;
  double light;
  double soilMoisture;
  String sensorName;
  Timestamp date;

  Measure(
      this.temperature,
      this.pressure,
      this.altitude,
      this.battery,
      this.humidity,
      this.rain,
      this.light,
      this.soilMoisture,
      this.sensorName,
      this.date);

  factory Measure.fromServer(Map<dynamic, dynamic> json) => Measure(
      (json['temperature'] as num).toDouble(),
      (json['pressure'] as num).toDouble(),
      (json['altitude'] as num).toDouble(),
      (json['battery'] as num).toDouble(),
      (json['humidity'] as num).toDouble(),
      (json['rain'] as num).toDouble(),
      (json['light'] as num).toDouble(),
      (json['soilMoisture'] as num).toDouble(),
      json['sensorName'] as String,
      Timestamp.fromDate(DateTime.parse(json['date'])));

  factory Measure.fromJson(Map<dynamic, dynamic> json) {
    return Measure(
        json['temperature'] as double,
        json['pressure'] as double,
        json['altitude'] as double,
        json['battery'] as double,
        json['humidity'] as double,
        json['rain'] as double,
        json['light'] as double,
        json['soilMoisture'] as double,
        json['sensorName'] as String,
        json['date'] as Timestamp);
  }

  Map<String, dynamic> toJson() => {
        'temperature': temperature,
        'pressure': pressure,
        'altitude': altitude,
        'battery': battery,
        'humidity': humidity,
        'rain': rain,
        'light': light,
        'soilMoisture': soilMoisture,
        'sensorName': sensorName,
        'date': date
      };
}
