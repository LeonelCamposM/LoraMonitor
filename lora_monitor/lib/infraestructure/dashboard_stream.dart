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

            List<UserLimit> userLimits = [];
            for (var doc in userLimitssnapshot.data!.docs) {
              userLimits
                  .add(UserLimit.fromJson(doc.data() as Map<dynamic, dynamic>));
            }
            List<Measure> measureList = [];
            for (var doc in lastMeasuressnapshot.data!.docs) {
              measureList
                  .add(Measure.fromJson(doc.data() as Map<dynamic, dynamic>));
            }
            return DashboardView(measure: measureList, limits: userLimits);
          },
        );
      },
    );
  }
}
