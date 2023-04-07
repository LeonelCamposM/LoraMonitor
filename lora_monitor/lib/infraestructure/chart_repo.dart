import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/measure.dart';

class ChartRepo {
  late final CollectionReference<Measure> _chartCollection;

  ChartRepo() {
    _chartCollection = FirebaseFirestore.instance
        .collection('users/yuY2SQJgcOYgPUKvUdRx/measures')
        .withConverter<Measure>(
          fromFirestore: (doc, options) => Measure.fromJson(doc.data()!),
          toFirestore: (object, options) => object.toJson(),
        );
  }

  Future<List<Measure>> getChartData(
      String sensorName, DateTime fromDate, DateTime toDate) async {
    final collection = await _chartCollection
        .where("sensorName", isEqualTo: sensorName)
        .where("date", isGreaterThanOrEqualTo: fromDate)
        .where("date", isLessThanOrEqualTo: toDate)
        .orderBy("date", descending: true)
        .get();
    var data = collection.docs.map((snapshot) => snapshot.data());
    List<Measure>? chartData = [];
    if (data.isNotEmpty) {
      for (var measure in data) {
        chartData.add(measure);
      }
    }

    return chartData;
  }
}
