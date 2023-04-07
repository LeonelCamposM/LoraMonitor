import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lora_monitor/domain/measure.dart';
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
  bool oneDay = false;
  bool oneWeek = false;
  bool oneMonth = false;
  List<ChartData> chartData = [];

  void loadData() async {
    ChartRepo repo = ChartRepo();
    List<Measure> measures = await repo.getChartData(widget.sensorName);
    setState(() {
      sensorMeasures = measures;
    });
    initialFormat();
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

  void initialFormat() {
    List<DateTime> days = [];
    for (var element in sensorMeasures) {
      DateTime date = element.date.toDate();
      chartData.add(ChartData(date, element.humidity.toDouble()));
      days.add(date);
    }
    chartData.sort((a, b) {
      return a.x.compareTo(b.x);
    });
    oneDay = sameDay(days);
    oneMonth = isSameMonth(days);
  }

  @override
  void initState() {
    loadData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        labelFormat: '{value}%', borderColor: Colors.blue),
                    series: <ChartSeries<ChartData, DateTime>>[
                      LineSeries<ChartData, DateTime>(
                          name: "Humedad del suelo",
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
                            labelFormat: '{value}%', borderColor: Colors.blue),
                        series: <ChartSeries<ChartData, DateTime>>[
                          LineSeries<ChartData, DateTime>(
                              name: "Humedad del suelo ",
                              dataSource: chartData,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y),
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
                            labelFormat: '{value}%', borderColor: Colors.blue),
                        series: <ChartSeries<ChartData, DateTime>>[
                          LineSeries<ChartData, DateTime>(
                              name: "a",
                              dataSource: chartData,
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y),
                        ],
                      )),
      ],
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final DateTime x;
  final double y;
}
