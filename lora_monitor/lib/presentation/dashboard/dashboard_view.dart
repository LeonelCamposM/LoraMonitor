import 'package:flutter/material.dart';
import 'package:lora_monitor/domain/measure.dart';
import 'package:lora_monitor/domain/user_limit.dart';
import 'package:lora_monitor/presentation/core/size_config.dart';
import 'package:lora_monitor/presentation/core/text.dart';
import 'package:intl/intl.dart';
import 'package:lora_monitor/presentation/home.dart';

class DashboardView extends StatelessWidget {
  const DashboardView(
      {super.key,
      required this.measure,
      required this.limits,
      required this.changePage});
  final List<Measure> measure;
  final List<UserLimit> limits;
  final Function changePage;

  @override
  Widget build(BuildContext context) {
    return getVerticalList(measure, limits, changePage);
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
        child: getVerticalIcon(sensorMeasure, limitsMap));
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
            child: getTitleIcon(title),
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

Widget getVerticalList(
    List<Measure> lastMeasures, List<UserLimit> limits, Function changePage) {
  return SizedBox(
    height: SizeConfig.blockSizeVertical * 85,
    child: ListView(
        reverse: true,
        scrollDirection: Axis.vertical,
        children: List.generate(
          lastMeasures.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              height: SizeConfig.blockSizeVertical * 40,
              width: SizeConfig.blockSizeHorizontal * 100,
              child: GestureDetector(
                onTap: () => {
                  changePage(HomeState.chart, lastMeasures[index].sensorName)
                },
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 10,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    getBodyText(
                                        " ${DateFormat('dd MMMM', 'es').format(lastMeasures[index].date.toDate()).replaceAll(" ", " de ")}"
                                        " ${DateFormat(DateFormat.jm().pattern).format(lastMeasures[index].date.toDate())}",
                                        false),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        CircularChartCard(
                                          sensorMeasure: lastMeasures[index],
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
            ),
          ),
        )),
  );
}

Icon getTitleIcon(String title) {
  Icon icon = const Icon(color: Colors.white, Icons.battery_5_bar);
  switch (title) {
    case "Humedad":
      icon = const Icon(color: Colors.white, Icons.water_drop);
      break;
    case "Luz":
      icon = const Icon(color: Colors.white, Icons.sunny);
      break;
    case "Presión":
      icon = const Icon(color: Colors.white, Icons.vertical_align_center);
      break;
    case "H. Suelo":
      icon = const Icon(color: Colors.white, Icons.grid_on);
      break;
    case "Lluvia":
      icon = const Icon(color: Colors.white, Icons.cloud);
      break;
    case "Altitud":
      icon = const Icon(color: Colors.white, Icons.landscape);
      break;
    case "Temperatura":
      icon = const Icon(color: Colors.white, Icons.device_thermostat);
      break;
    default:
  }
  return icon;
}

String translateTitle(String title) {
  String translatedTitle = "";
  switch (title) {
    case "humidity":
      translatedTitle = "Humedad";
      break;
    case "light":
      translatedTitle = "Luz";
      break;
    case "pressure":
      translatedTitle = "Presión";
      break;
    case "soilMoisture":
      translatedTitle = "H. Suelo";
      break;
    case "rain":
      translatedTitle = "Lluvia";
      break;
    case "battery":
      translatedTitle = "Batería";
      break;
    case "altitude":
      translatedTitle = "Altitud";
      break;
    case "temperature":
      translatedTitle = "Temperatura";
      break;
    default:
  }
  return translatedTitle;
}

Widget getVerticalIcon(Measure lastMeasure, Map<String, UserLimit> limitsMap) {
  Map<dynamic, dynamic> measureMap = lastMeasure.toJson();
  measureMap.removeWhere(
      (key, value) => value == -1.01 || (key == "sensorName" || key == "date"));
  List<String> mapKeys = [];
  for (var keys in measureMap.keys) {
    mapKeys.add(keys);
  }
  mapKeys.sort(((a, b) => translateTitle(a).compareTo(translateTitle(b))));
  return SizedBox(
    height: SizeConfig.blockSizeVertical * 30,
    width: SizeConfig.blockSizeHorizontal * 79,
    child: ListView(
        reverse: false,
        scrollDirection: Axis.vertical,
        children: List.generate(
          (measureMap.length / 2).ceil(),
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: SizeConfig.blockSizeHorizontal * 41,
                  height: SizeConfig.blockSizeVertical * 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      DashboardIcon(
                          measure: measureMap[mapKeys[index * 2]] as double,
                          limit: limitsMap[mapKeys[index * 2]]!,
                          title: translateTitle(mapKeys[index * 2]),
                          goodColor: const Color(0xFF0798A5),
                          badColor: Colors.red),
                    ],
                  ),
                ),
                (index * 2 + 1) < measureMap.length
                    ? SizedBox(
                        width: SizeConfig.blockSizeHorizontal * 38,
                        height: SizeConfig.blockSizeVertical * 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            DashboardIcon(
                                measure: measureMap[mapKeys[index * 2 + 1]]
                                    as double,
                                limit: limitsMap[mapKeys[index * 2 + 1]]!,
                                title: translateTitle(mapKeys[index * 2 + 1]),
                                goodColor: const Color(0xFF0798A5),
                                badColor: Colors.red),
                          ],
                        ),
                      )
                    : const Text("")
              ],
            ),
          ),
        )),
  );
}
