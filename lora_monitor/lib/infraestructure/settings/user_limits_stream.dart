import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lora_monitor/domain/user_limit.dart';
import 'package:lora_monitor/presentation/core/loading.dart';
import 'package:lora_monitor/presentation/settings/user_limits_view.dart';

// ignore: must_be_immutable
class UserLimitsStream extends StatefulWidget {
  late Stream<QuerySnapshot> _limitStream;
  UserLimitsStream({Key? key}) : super(key: key) {
    _limitStream = FirebaseFirestore.instance
        .collection("users/yuY2SQJgcOYgPUKvUdRx/userLimits")
        .snapshots();
  }

  @override
  State<UserLimitsStream> createState() => _UserLimitsStreamState();
}

class _UserLimitsStreamState extends State<UserLimitsStream> {
  List<UserLimit> getUserLimits(
      AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    List<UserLimit> userLimits = [];
    ListView(
      children: snapshot.data!.docs
          .map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            userLimits.add(UserLimit.fromJson(data));
          })
          .toList()
          .cast(),
    );

    return userLimits;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget._limitStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return getLoading();
        }

        List<UserLimit> userLimitsList = getUserLimits(snapshot);
        UserLimit humidityLimit = UserLimit(0, 0, "soilMoisture");

        for (var element in userLimitsList) {
          if (element.measure == "soilMoisture") humidityLimit = element;
        }

        return UserLimitsView(
          limit: humidityLimit,
        );
      },
    );
  }
}
