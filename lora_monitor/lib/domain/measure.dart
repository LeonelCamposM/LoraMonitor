import 'package:cloud_firestore/cloud_firestore.dart';

class Measure {
  double temperature;
  double pressure;
  double altitude;
  double battery;
  double humidity;
  String sensorName;
  Timestamp date;

  Measure(this.temperature, this.pressure, this.altitude, this.battery,
      this.humidity, this.sensorName, this.date);

  factory Measure.fromJson(Map<dynamic, dynamic> json) => Measure(
      json['temperature'] as double,
      json['pressure'] as double,
      json['altitude'] as double,
      json['battery'] as double,
      json['humidity'] as double,
      json['sensorName'] as String,
      json['date'] as Timestamp);

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
