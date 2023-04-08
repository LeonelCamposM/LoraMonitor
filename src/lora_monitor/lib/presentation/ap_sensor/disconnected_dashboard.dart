import 'package:flutter/material.dart';
import 'package:lora_monitor/presentation/core/size_config.dart';
import 'package:lora_monitor/presentation/core/text.dart';

class DisconnectedDashboard extends StatelessWidget {
  const DisconnectedDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: SizeConfig.blockSizeVertical * 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    getTitleText("Sensor desconectado", false),
                  ],
                )
              ],
            ),
            SizeConfig.blockSizeVertical <= 8.1
                ? SizedBox(
                    height: SizeConfig.blockSizeVertical * 65,
                  )
                : SizedBox(
                    height: SizeConfig.blockSizeVertical * 70,
                  ),
          ],
        ),
      ],
    );
  }
}