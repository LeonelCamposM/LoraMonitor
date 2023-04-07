import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lora_monitor/domain/measure.dart';
import 'package:lora_monitor/presentation/core/loading.dart';
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
  bool oneDay = true;
  bool oneWeek = false;
  bool oneMonth = false;
  bool loading = true;
  List<ChartData> chartData = [];

  void loadData(DateTime fromDate, DateTime toDate) async {
    ChartRepo repo = ChartRepo();
    List<Measure> measures =
        await repo.getChartData(widget.sensorName, fromDate, toDate);
    setState(() {
      sensorMeasures = measures;
      loading = false;
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
        loadData(
            DateTime.now().subtract(const Duration(days: 1)), DateTime.now());
        break;

      default:
    }
    setState(() {
      loading = true;
    });
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
      for (var element in sensorMeasures) {
        DateTime date = element.date.toDate();
        chartData.add(ChartData(date, element.humidity.toDouble()));
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
    loadData(DateTime.now().subtract(const Duration(days: 1)), DateTime.now());
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
                                name: "Día Humedad del suelo",
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
                                    name: "Semana Humedad del suelo ",
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
                                    name: "Mes Humedad del suelo",
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
