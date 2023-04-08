import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:lora_monitor/presentation/ap_sensor/connected_dashboard.dart';
import 'package:lora_monitor/presentation/ap_sensor/disconnected_dashboard.dart';
import 'package:lora_monitor/presentation/core/size_config.dart';

import 'package:lora_monitor/domain/measure.dart';



// ignore: must_be_immutable
class APSensorRepo extends StatefulWidget {
  const APSensorRepo({Key? key}) : super(key: key);

  @override
  State<APSensorRepo> createState() => APSensorMeasureRepoState();
}

class APSensorMeasureRepoState extends State<APSensorRepo> {
  Timer? timer;
  bool conected = false;
  int counter = 0;

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
    if (measures.isNotEmpty) {
      print(measures.last);
      //addLastMeasure(measures.last);
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

  void getUpdatedValue() async {
    try {
      final response = await http
          .get(
        Uri.parse('http://192.168.1.22:80/getName'),
      )
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          // Time has run out, do what you wanted to do.
          return http.Response(
              'Error', 408); // Request Timeout response status code
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          counter = 0;
          conected = true;
        });
      } else {
        counter += 1;
        if (counter > 5) {
          setState(() {
            conected = false;
          });
        }
      }
    } catch (e) {
      counter += 1;
      if (counter > 5) {
        setState(() {
          conected = false;
        });
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    getUpdatedValue();
    //getNewMeasures();
    super.initState();
    timer = Timer.periodic(
        const Duration(seconds: 1), (Timer t) => getUpdatedValue());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(
          height: 10,
        ),
         conected == true
            ? const ConnectedDashboard()
            : const DisconnectedDashboard(),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                children: [
                  SizedBox(
                    height: SizeConfig.blockSizeHorizontal * 3,
                  ),
                  SizedBox(
                    width: SizeConfig.blockSizeHorizontal * 14,
                    height: SizeConfig.blockSizeHorizontal * 14,
                    child: FloatingActionButton(
                      onPressed: (() => {
                            AppSettings.openWIFISettings(callback: () {}),
                          }),
                      child: Icon(
                        size: SizeConfig.blockSizeHorizontal * 8,
                        conected == false ? Icons.power_off : Icons.power,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

