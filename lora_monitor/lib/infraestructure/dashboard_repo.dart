import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DashboardStream extends StatelessWidget {
  const DashboardStream({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users/yuY2SQJgcOYgPUKvUdRx/userLimits")
          .snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot> userLimitssnapshot) {
        if (!userLimitssnapshot.hasData) {
          return const CircularProgressIndicator(
            color: Colors.green,
          );
        }
        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection("users/yuY2SQJgcOYgPUKvUdRx/lastMeasures")
              .get(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> lastMeasuressnapshot) {
            if (!lastMeasuressnapshot.hasData) {
              return const CircularProgressIndicator(
                color: Colors.green,
              );
            }

            String data = "";
            for (var doc in lastMeasuressnapshot.data!.docs) {
              data += (doc.id);
              data += (doc.data().toString());
              data += "\n+++++++++++++++++++++\n";
            }
            for (var doc in userLimitssnapshot.data!.docs) {
              data += (doc.id);
              data += (doc.data().toString());
              data += "\n----------------------\n";
            }
            return Text(data);
          },
        );
      },
    );
  }
}
