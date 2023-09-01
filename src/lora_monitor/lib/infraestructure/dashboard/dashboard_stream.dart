import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lora_monitor/domain/measure.dart';
import 'package:lora_monitor/domain/user_limit.dart';
import 'package:lora_monitor/presentation/core/loading.dart';
import 'package:lora_monitor/presentation/dashboard/dashboard_view.dart';

class DashboardStream extends StatelessWidget {
  DashboardStream({super.key, required this.changePage});
  final Function changePage;

  final Stream<QuerySnapshot> _limitStream = FirebaseFirestore.instance
      .collection("users/yuY2SQJgcOYgPUKvUdRx/userLimits")
      .snapshots();
  final Stream<QuerySnapshot> _lastMeasuresStream = FirebaseFirestore.instance
      .collection("users/yuY2SQJgcOYgPUKvUdRx/lastMeasures")
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _limitStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return getLoading();
        }

        List<UserLimit> userLimits = snapshot.data!.docs
            .map(
                (doc) => UserLimit.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        return StreamBuilder<QuerySnapshot>(
          stream: _lastMeasuresStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return getLoading();
            }

            List<Measure> lastMeasures = snapshot.data!.docs
                .map((doc) =>
                    Measure.fromJson(doc.data() as Map<String, dynamic>))
                .toList();

            return DashboardView(
                measure: lastMeasures,
                limits: userLimits,
                changePage: changePage);
          },
        );
      },
    );
  }
}
