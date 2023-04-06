import 'package:flutter/material.dart';
import 'package:lora_monitor/domain/measure.dart';
import 'package:lora_monitor/domain/user_limit.dart';
import 'package:lora_monitor/presentation/core/size_config.dart';
import 'package:lora_monitor/presentation/core/text.dart';
import 'package:intl/intl.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key, required this.measure, required this.limits});
  final Measure measure;
  final List<UserLimit> limits;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig.blockSizeVertical * 20,
      width: SizeConfig.blockSizeHorizontal * 100,
      child: GestureDetector(
        // onTap: () => {changePage("chart")},
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 10,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            getBodyText(
                                " ${DateFormat('dd MMMM', 'es').format(measure.date.toDate()).replaceAll(" ", " de ")}" +
                                    " ${DateFormat(DateFormat.jm().pattern).format(measure.date.toDate())}",
                                false),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircularChartCard(
                                  sensorMeasure: measure,
                                  limits: limits,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class CircularChartCard extends StatelessWidget {
  CircularChartCard(
      {super.key, required this.sensorMeasure, required this.limits});
  Measure sensorMeasure;
  List<UserLimit> limits;
  Map<String, UserLimit> limitsMap = <String, UserLimit>{};

  @override
  Widget build(BuildContext context) {
    limitsMap = {for (var limit in limits) limit.measure: limit};
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          DashboardIcon(
              measure: sensorMeasure.humidity,
              limit: limitsMap["humidity"]!,
              title: "Humedad",
              goodColor: Colors.blue,
              badColor: Colors.red),
          DashboardIcon(
              measure: sensorMeasure.battery,
              limit: limitsMap["battery"]!,
              title: "Batería",
              goodColor: Colors.yellow,
              badColor: Colors.red)
        ],
      ),
    );
  }
}

class DashboardIcon extends StatelessWidget {
  const DashboardIcon(
      {super.key,
      required this.measure,
      required this.limit,
      required this.title,
      required this.goodColor,
      required this.badColor});
  final double measure;
  final UserLimit limit;
  final String title;
  final Color goodColor;
  final Color badColor;

  @override
  Widget build(BuildContext context) {
    final isWithinLimits = limit.max > measure && limit.min < measure;
    final barColor = isWithinLimits ? goodColor : badColor;
    return PercentageWidget(
      percentaje: measure,
      title: title,
      barColor: barColor,
    );
  }
}

// ignore: must_be_immutable
class PercentageWidget extends StatelessWidget {
  double percentaje;
  String text = "";
  String title = "";
  Color barColor;

  PercentageWidget(
      {super.key,
      required this.percentaje,
      required this.title,
      required this.barColor}) {
    text = percentaje.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          color: barColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: title == "Humedad"
                ? const Icon(color: Colors.white, Icons.water_drop)
                : title == "Temperatura"
                    ? const Icon(color: Colors.white, Icons.device_thermostat)
                    : const Icon(color: Colors.white, Icons.battery_5_bar),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getBodyText(title, false),
              Row(
                children: [getBodyText("${percentaje.ceil()} %", false)],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
