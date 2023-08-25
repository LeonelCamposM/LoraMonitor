import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lora_monitor/domain/measure.dart';
import 'package:lora_monitor/presentation/chart/date.dart';
import 'package:lora_monitor/presentation/chart/dropdown.dart';
import 'package:lora_monitor/presentation/core/loading.dart';
import 'package:lora_monitor/presentation/core/text.dart';
import 'package:lora_monitor/presentation/dashboard/dashboard_view.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:connectivity/connectivity.dart';
import '../../infraestructure/chart_repo.dart';
import 'package:http/http.dart' as http;
import '../core/size_config.dart';

enum ChartType {
  days,
  weeks,
  months,
}

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
  String currenUnitMeasure = "";
  bool oneDay = false;

  bool loading = true;
  bool firstLoad = true;
  bool connectedToInternet = false;

  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();

  void loadData() async {
    ChartRepo repo = ChartRepo();

    if (fromDate == toDate) {
      toDate = fromDate.add(const Duration(hours: 23));
    }
    List<Measure> measures =
        await repo.getChartData(widget.sensorName, fromDate, toDate);

    List<DateTime> measuresDates = [];
    for (var element in measures) {
      measuresDates.add(element.date.toDate());
    }

    oneDay = sameDay(measuresDates);

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

  void updatefromDate(DateTime date) {
    chartData.clear();
    sensorMeasures.clear();
    fromDate = date;
    loadData();
    setState(() {
      loading = true;
    });
  }

  void updateToDate(DateTime date) {
    chartData.clear();
    sensorMeasures.clear();

    toDate = date;
    loadData();
    setState(() {
      setState(() {
        loading = true;
      });
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
    if (fechas.isEmpty) {
      return false;
    }

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
      currenUnitMeasure = getUnitMeasure(selectedMeasure);
      currentMeasure = selectedMeasure;
    });
  }

  Future<bool> hasInternetConnection() async {
    try {
      final uri = Uri.parse('https://www.google.com');
      final response =
          await http.head(uri).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void checkInternetAndLoadData() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      bool hasInternet = await hasInternetConnection();

      if (hasInternet) {
        setState(() {
          connectedToInternet = true;
          loadData();
        });
      } else {
        setState(() {
          connectedToInternet = false;
          loading = false;
        });
      }
    } else {
      setState(() {
        connectedToInternet = false;
        loading = false;
      });
    }
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
    fromDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
    toDate = DateTime.now();
    checkInternetAndLoadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading == true
        ? Center(child: getLoading())
        : connectedToInternet == false
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(child: getTitleText("Conectese a internet", false)),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      getBodyText(
                          "Sensor: ${getSensorName(widget.sensorName)}", false),
                      Center(
                          child: DropdownCustomButton(
                              options: options,
                              onChanged: onMeasureSelected,
                              selectedValue: currentMeasure)),
                    ],
                  ),
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
                                  labelFormat: '{value} $currenUnitMeasure',
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
                                  dateFormat: DateFormat('dd MMMM', 'es')),
                              primaryYAxis: NumericAxis(
                                  labelFormat: '{value} $currenUnitMeasure',
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
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        DatePicker(
                          title: 'Desde',
                          callback: updatefromDate,
                          selectedDate: fromDate,
                        ),
                        DatePicker(
                          title: 'Hasta',
                          callback: updateToDate,
                          selectedDate: toDate,
                        )
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
