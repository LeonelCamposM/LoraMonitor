import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lora_monitor/domain/user_limit.dart';

// ignore: must_be_immutable
class UserLimitsRepo extends StatelessWidget {
  late Stream<QuerySnapshot> _limitStream;
  UserLimitsRepo({Key? key}) : super(key: key) {
    _limitStream = FirebaseFirestore.instance
        .collection("users/yuY2SQJgcOYgPUKvUdRx/userLimits")
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _limitStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(color: Colors.green);
        }
        List<UserLimit> userLimitsList = getUserLimits(snapshot);
        return Text(userLimitsList.toString());
      },
    );
  }
}

List<UserLimit> getUserLimits(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
  List<UserLimit> userLimits = [];
  ListView(
    children: snapshot.data!.docs
        .map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          userLimits.add(UserLimit.fromJson(data));
        })
        .toList()
        .cast(),
  );
  print(userLimits);
  return userLimits;
}
