import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lora_monitor/domain/user_limit.dart';

void updateUserLimits(min, max) {
  var ref = FirebaseFirestore.instance
      .collection("/users/yuY2SQJgcOYgPUKvUdRx/userLimits/")
      .doc("soilMoisture");
  ref.set(UserLimit(max, min, "soilMoisture").toJson());
}
