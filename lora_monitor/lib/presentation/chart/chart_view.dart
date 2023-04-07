import 'package:flutter/cupertino.dart';
import 'package:lora_monitor/domain/measure.dart';

import '../../infraestructure/chart_repo.dart';

class ChartView extends StatefulWidget {
  const ChartView({super.key, required this.sensorName});
  final String sensorName;

  @override
  State<ChartView> createState() => _ChartViewState();
}

class _ChartViewState extends State<ChartView> {
  List<Measure> sensorMeasures = [];

  void loadData() async {
    ChartRepo repo = ChartRepo();
    List<Measure> measures = await repo.getChartData(widget.sensorName);
    setState(() {
      sensorMeasures = measures;
    });
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text(sensorMeasures.toString());
  }
}
