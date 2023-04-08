import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:lora_monitor/domain/measure.dart';
import 'package:lora_monitor/infraestructure/chart_repo.dart';
import 'package:lora_monitor/presentation/core/size_config.dart';
import 'package:lora_monitor/presentation/core/text.dart';

class ConnectedDashboard extends StatefulWidget {
  const ConnectedDashboard({super.key});

  @override
  State<ConnectedDashboard> createState() => _ConnectedDashboardState();
}

class _ConnectedDashboardState extends State<ConnectedDashboard> {
  _ConnectedDashboardState() : loading = true;
  List<Measure> measures = [];
  ChartRepo chartRepo = ChartRepo();
  bool loading;

  Future<void> setTime() async {
    DateTime now = DateTime.now();
    int hour = now.hour;
    int minute = now.minute;
    int second = now.second;
    int day = now.day;
    int month = now.month;
    int year = now.year;

    final url = Uri.parse('http://192.168.1.22/setTime');
    Map<String, dynamic> body = {
      'hour': hour,
      'minute': minute,
      'second': second,
      'day': day,
      'month': month,
      'year': year,
    };

    String jsonString = json.encode(body);
    final response = await http.post(url, body: {'date': jsonString});
    if (response.statusCode == 200) {
      print('Hora y fecha actualizadas correctamente');
    } else {
      print('ya estaban bien');
    }
  }

  Future<List<Measure>> getNewMeasures() async {
    List<String> messages = [];
    var httpClient = HttpClient();
    var request =
        await httpClient.getUrl(Uri.parse('http://192.168.1.22:80/getAllData'));
    var response = await request.close();
    await for (var line
        in response.transform(utf8.decoder).transform(const LineSplitter())) {
      messages.add(line);
    }
    httpClient.close();

    List<Measure> measures = [];
    for (var message in messages) {
      message = message.replaceAll(";", "");
      Map map = jsonDecode(message);
      Measure measure = Measure.fromJson(map);
      measures.add(measure);
    }
    measures.sort((measureOne, measureTwo) =>
        measureOne.sensorName.compareTo(measureTwo.sensorName));
    measures.sort(
        (measureOne, measureTwo) => measureOne.date.compareTo(measureTwo.date));
    if (measures.isNotEmpty) {
      for (var measure in measures) {
        print(measure.toString());
        print("\n");
      }
      //chartRepo.addLastMeasure(measures.last);
    }
    return measures;
  }

  void sendDeleteData() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.22:80/deleteAllData'),
      );
      if (response.statusCode == 200) {
        print("data deleted");
      }
    } catch (e) {
      print("catch");
      print(e);
    }
  }

  void uploadNewMeasures(context) async {
    measures = await getNewMeasures();
    //for (var element in measures) {
      // chartRepo.addMeasure(element);
    //}
    //sendDeleteData();
    if (measures.isNotEmpty) {
    } else {}

    setTime();
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
    });
    uploadNewMeasures(context);
  }

  @override
  Widget build(BuildContext context) {
    return loading == true
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: SizeConfig.blockSizeHorizontal * 20,
                height: SizeConfig.blockSizeHorizontal * 20,
                child: const CircularProgressIndicator(
                  color: Colors.green,
                ),
              ),
            ],
          )
        : measures.isEmpty
            ? SizedBox(
                width: SizeConfig.blockSizeHorizontal * 90,
                height: SizeConfig.blockSizeHorizontal * 40,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 10,
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      getBodyText("No hay nuevas mediciones", false),
                      SizedBox(
                          width: SizeConfig.blockSizeHorizontal * 20,
                          height: SizeConfig.blockSizeHorizontal * 20,
                          child: const Icon(
                            Icons.info_outline_rounded,
                            size: 60,
                            color: Colors.green,
                          ))
                    ],
                  )),
                ),
              )
            : SizedBox(
                width: SizeConfig.blockSizeHorizontal * 90,
                height: SizeConfig.blockSizeHorizontal * 40,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 10,
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      getBodyText("Mediciones recolectadas", false),
                      SizedBox(
                          width: SizeConfig.blockSizeHorizontal * 20,
                          height: SizeConfig.blockSizeHorizontal * 20,
                          child: const Icon(
                            Icons.check_circle_outline_outlined,
                            size: 60,
                            color: Colors.green,
                          ))
                    ],
                  )),
                ),
              );
  }
}