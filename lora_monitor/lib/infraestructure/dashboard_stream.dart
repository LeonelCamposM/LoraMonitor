import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lora_monitor/domain/measure.dart';
import 'package:lora_monitor/domain/user_limit.dart';
import 'package:lora_monitor/presentation/core/loading.dart';
import 'package:lora_monitor/presentation/dashboard/dashboard_view.dart';

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
          return getLoading();
        }
        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection("users/yuY2SQJgcOYgPUKvUdRx/lastMeasures")
              .get(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> lastMeasuressnapshot) {
            if (!lastMeasuressnapshot.hasData) {
              return getLoading();
            }

            // String data = "";
            // for (var doc in lastMeasuressnapshot.data!.docs) {
            //   data += (doc.id);
            //   data += (doc.data().toString());
            //   data += "\n+++++++++++++++++++++\n";
            // }
            // for (var doc in userLimitssnapshot.data!.docs) {
            //   data += (doc.id);
            //   data += (doc.data().toString());
            //   data += "\n----------------------\n";
            // }

            return DashboardView(
                measure: Measure.fromJson(lastMeasuressnapshot.data!.docs[1]
                    .data() as Map<dynamic, dynamic>),
                limit: UserLimit.fromJson(userLimitssnapshot.data!.docs[1]
                    .data() as Map<dynamic, dynamic>));
          },
        );
      },
    );
  }
}
