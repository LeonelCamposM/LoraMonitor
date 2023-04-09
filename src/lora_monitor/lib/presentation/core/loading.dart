import 'package:flutter/material.dart';
import 'package:lora_monitor/presentation/core/size_config.dart';

Widget getLoading() {
  return Center(
      child: SizedBox(
          width: SizeConfig.blockSizeHorizontal * 25,
          height: SizeConfig.blockSizeVertical * 15,
          child: const CircularProgressIndicator(color: Colors.green)));
}
