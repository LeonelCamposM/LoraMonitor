import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lora_monitor/domain/measure.dart';
import 'package:lora_monitor/presentation/chart/dropdown.dart';
import 'package:lora_monitor/presentation/core/loading.dart';
import 'package:lora_monitor/presentation/dashboard/dashboard_view.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../infraestructure/chart_repo.dart';
import '../core/size_config.dart';

class ChartView extends StatefulWidget {
  ChartView({super.key, required this.sensorName});
  final String sensorName;
  final TooltipBehavior tooltipBehavior = TooltipBehavior(enable: true);

  @override
  State<ChartView> createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> {
  List<Measure> sensorMeasures = [];
  List<ChartData> chartData = [];
  List<String> options = [];
  String currentMeasure = "";
  bool oneDay = true;
  bool oneWeek = false;
  bool oneMonth = false;
  bool loading = true;
  bool firstLoad = true;

  void loadData(DateTime fromDate, DateTime toDate) async {
    ChartRepo repo = ChartRepo();
    List<Measure> measures =
        await repo.getChartData(widget.sensorName, fromDate, toDate);
    if (oneDay) {
      List<Measure> todayMeasures = [];
      for (var measure in measures) {
        if (isToday(measure.date.toDate())) {
          todayMeasures.add(measure);
        }
      }
      measures = todayMeasures;
    }

    setState(() {
      sensorMeasures = measures;
      loading = false;
      if (sensorMeasures.isNotEmpty) {
        Map<String, dynamic> measureMap = sensorMeasures.first.toJson();
        measureMap.removeWhere((key, value) =>
            value == -1.01 || (key == "sensorName" || key == "date"));
        options = measureMap.keys.toList();
        for (var i = 0; i < options.length; i++) {
          options[i] = translateTitle(options[i]);
        }
        if (firstLoad) currentMeasure = options.first;
        firstLoad = false;
      }
    });
    initialFormat();
  }

  void updateChartMeasure(String time) {
    oneDay = false;
    oneMonth = false;
    oneWeek = false;
    chartData.clear();
    sensorMeasures.clear();
    switch (time) {
      case "m":
        oneMonth = true;
        DateTime now = DateTime.now();
        DateTime oneMonthAgo = DateTime(now.year, now.month - 1, now.day)
            .subtract(Duration(days: now.day));
        loadData(oneMonthAgo, DateTime.now());
        break;
      case "w":
        oneWeek = true;
        loadData(
            DateTime.now().subtract(const Duration(days: 7)), DateTime.now());
        break;
      case "d":
        oneDay = true;
        DateTime now = DateTime.now();
        DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
        loadData(startOfDay, DateTime.now());
        break;

      default:
    }
    setState(() {
      loading = true;
    });
  }

  bool isToday(DateTime nextReport) {
    DateTime today = DateTime.now();
    bool result = false;
    if (today.month == nextReport.month &&
        today.day == nextReport.day &&
        today.year == nextReport.year) {
      result = true;
    }
    return result;
  }

  bool sameDay(List<DateTime> fechas) {
    DateTime primerDia = fechas[0].toLocal();
    int dia = primerDia.day;

    for (int i = 1; i < fechas.length; i++) {
      DateTime fecha = fechas[i].toLocal();
      if (fecha.day != dia) {
        return false;
      }
    }

    return true;
  }

  bool isSameMonth(List<DateTime> dates) {
    if (dates.isEmpty) {
      return false;
    }

    final firstDate = dates.first;

    for (final date in dates) {
      if (date.month != firstDate.month || date.year != firstDate.year) {
        return false;
      }
    }
    return true;
  }

  bool isSameWeek(List<DateTime> dates) {
    if (dates.isEmpty) {
      return false;
    }

    final firstDate = dates.first;

    for (final date in dates) {
      if (date.weekday != firstDate.weekday ||
          date.difference(firstDate).inDays >= 7) {
        return false;
      }
    }
    return true;
  }

  void initialFormat() {
    List<DateTime> days = [];
    if (sensorMeasures.isNotEmpty) {
      onMeasureSelected(currentMeasure);
      for (var element in sensorMeasures) {
        DateTime date = element.date.toDate();
        days.add(date);
      }
      chartData.sort((a, b) {
        return a.x.compareTo(b.x);
      });
      oneDay = sameDay(days);
      oneWeek = isSameWeek(days);
      oneMonth = isSameMonth(days);
    }
  }

  void onMeasureSelected(String selectedMeasure) {
    chartData.clear();
    switch (selectedMeasure) {
      case "Humedad":
        for (var element in sensorMeasures) {
          DateTime date = element.date.toDate();
          chartData.add(ChartData(date, element.humidity.toDouble()));
        }
        break;
      case "H. Suelo":
        for (var element in sensorMeasures) {
          DateTime date = element.date.toDate();
          chartData.add(ChartData(date, element.soilMoisture.toDouble()));
        }
        break;
      case "Temperatura":
        for (var element in sensorMeasures) {
          DateTime date = element.date.toDate();
          chartData.add(ChartData(date, element.temperature.toDouble()));
        }
        break;
      case "Presión":
        for (var element in sensorMeasures) {
          DateTime date = element.date.toDate();
          chartData.add(ChartData(date, element.pressure.toDouble()));
        }
        break;
      case "Altitud":
        for (var element in sensorMeasures) {
          DateTime date = element.date.toDate();
          chartData.add(ChartData(date, element.altitude.toDouble()));
        }
        break;
      case "Luz":
        for (var element in sensorMeasures) {
          DateTime date = element.date.toDate();
          chartData.add(ChartData(date, element.light.toDouble()));
        }
        break;
      case "Lluvia":
        for (var element in sensorMeasures) {
          DateTime date = element.date.toDate();
          chartData.add(ChartData(date, element.rain.toDouble()));
        }
        break;
      case "Batería":
        for (var element in sensorMeasures) {
          DateTime date = element.date.toDate();
          chartData.add(ChartData(date, element.battery.toDouble()));
        }
        break;
      default:
    }
    setState(() {
      currentMeasure = selectedMeasure;
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    chartData.clear();
    sensorMeasures.clear();
    super.dispose();
  }

  @override
  void initState() {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
    loadData(startOfDay, DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading == true
        ? Center(child: getLoading())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                  child: DropdownCustomButton(
                      options: options,
                      onChanged: onMeasureSelected,
                      selectedValue: currentMeasure)),
              SizedBox(
                  width: SizeConfig.blockSizeHorizontal * 90,
                  height: SizeConfig.blockSizeVertical * 50,
                  child: oneDay == true
                      ? SfCartesianChart(
                          legend: Legend(
                            isVisible: true,
                          ),
                          tooltipBehavior: widget.tooltipBehavior,
                          primaryXAxis: DateTimeAxis(
                              rangePadding: ChartRangePadding.additional,
                              dateFormat: DateFormat.jm()),
                          primaryYAxis: NumericAxis(
                              labelFormat: '{value}%',
                              borderColor: Colors.blue),
                          series: <ChartSeries<ChartData, DateTime>>[
                            LineSeries<ChartData, DateTime>(
                                name: currentMeasure,
                                dataSource: chartData,
                                xValueMapper: (ChartData data, _) => data.x,
                                yValueMapper: (ChartData data, _) => data.y),
                          ],
                        )
                      : oneMonth == false
                          ? SfCartesianChart(
                              legend: Legend(
                                isVisible: true,
                              ),
                              tooltipBehavior: widget.tooltipBehavior,
                              primaryXAxis: DateTimeAxis(
                                  rangePadding: ChartRangePadding.additional,
                                  dateFormat: DateFormat('dd MMMM', 'es')),
                              primaryYAxis: NumericAxis(
                                  labelFormat: '{value}%',
                                  borderColor: Colors.blue),
                              series: <ChartSeries<ChartData, DateTime>>[
                                LineSeries<ChartData, DateTime>(
                                    name: currentMeasure,
                                    dataSource: chartData,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) =>
                                        data.y),
                              ],
                            )
                          : SfCartesianChart(
                              legend: Legend(
                                isVisible: true,
                              ),
                              tooltipBehavior: widget.tooltipBehavior,
                              primaryXAxis: DateTimeAxis(
                                  rangePadding: ChartRangePadding.additional,
                                  dateFormat: DateFormat('dd/MM/yyyy')),
                              primaryYAxis: NumericAxis(
                                  labelFormat: '{value}%',
                                  borderColor: Colors.blue),
                              series: <ChartSeries<ChartData, DateTime>>[
                                LineSeries<ChartData, DateTime>(
                                    name: currentMeasure,
                                    dataSource: chartData,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) =>
                                        data.y),
                              ],
                            )),
              SizedBox(
                width: SizeConfig.blockSizeHorizontal * 50,
                height: SizeConfig.blockSizeVertical * 7,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                ElevatedButton(
                    onPressed: (() => {updateChartMeasure("m")}),
                    child: const Text("Mes")),
                ElevatedButton(
                    onPressed: (() => {updateChartMeasure("w")}),
                    child: const Text("Semana")),
                ElevatedButton(
                    onPressed: (() => {updateChartMeasure("d")}),
                    child: const Text("Día")),
              ])
            ],
          );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final DateTime x;
  final double y;
}
