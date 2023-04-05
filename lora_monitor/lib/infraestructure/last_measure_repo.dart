import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lora_monitor/domain/measure.dart';

// ignore: must_be_immutable
class LastMeasure extends StatelessWidget {
  late Stream<QuerySnapshot> _usersStream;
  LastMeasure({Key? key}) : super(key: key) {
    _usersStream = FirebaseFirestore.instance
        .collection("/Users/yuY2SQJgcOYgPUKvUdRx/lastMeasure")
        .snapshots();
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(color: Colors.green);
        }

        List<Measure> lastMeasuresList = getLastMeasures(snapshot);
        return Text(lastMeasuresList.toString());
        //return getScoreboardList(scoreboardList);
      },
    );
  }
}

List<Measure> getLastMeasures(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
  // Get all the scores from players
  List<Measure> lastMeasures = [];
  ListView(
    children: snapshot.data!.docs
        .map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          lastMeasures.add(Measure.fromJson(data));
        })
        .toList()
        .cast(),
  );

  // Sort scoreboard by score of the players
  lastMeasures.sort((a, b) => a.date.compareTo(b.date));
  List<Measure> sorted = [];
  for (var element in lastMeasures.reversed) {
    sorted.add(element);
  }
  return sorted;
}
