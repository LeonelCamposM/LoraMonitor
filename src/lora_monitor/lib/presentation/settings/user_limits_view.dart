import 'package:flutter/material.dart';
import 'package:lora_monitor/domain/user_limit.dart';
import 'package:lora_monitor/infraestructure/settings/user_limits_repo.dart';
import 'package:lora_monitor/presentation/core/size_config.dart';
import 'package:lora_monitor/presentation/core/text.dart';

class UserLimitsView extends StatefulWidget {
  const UserLimitsView({super.key, required this.limit});
  final UserLimit limit;

  @override
  State<UserLimitsView> createState() => _UserLimitsViewState();
}

class _UserLimitsViewState extends State<UserLimitsView> {
  double min = 0;
  double max = 0;

  void setValues(double humidityMin, double humiditymax) {
    setState(() {
      min = humidityMin;
      max = humiditymax;
    });
  }

  @override
  void initState() {
    super.initState();
    min = widget.limit.min.toDouble();
    max = widget.limit.max.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: TitledSlider(
            setValues: setValues,
            title: "Húmedad del suelo",
            max: 3000,
            limit: widget.limit,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: SizeConfig.blockSizeHorizontal * 14,
                height: SizeConfig.blockSizeHorizontal * 14,
                child: FloatingActionButton(
                  onPressed: () => {
                    updateUserLimits(min, max),
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Límite de humedad actualizado '),
                    ))
                  },
                  child: Icon(
                    size: SizeConfig.blockSizeHorizontal * 6,
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ignore: must_be_immutable
class TitledSlider extends StatefulWidget {
  String title = "";
  double max = 0;
  TitledSlider(
      {super.key,
      required this.title,
      required this.max,
      required this.setValues,
      required this.limit});

  Function setValues;
  UserLimit limit;

  @override
  State<TitledSlider> createState() => _TitledSliderState();
}

class _TitledSliderState extends State<TitledSlider> {
  double max = 0;
  double min = 1100;

  String getValueTag(int value, String title) {
    String tag = "";
    tag = "$value%";
    return tag;
  }

  @override
  void initState() {
    super.initState();
    max = widget.limit.max.toDouble();
    min = widget.limit.min.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: SizeConfig.blockSizeHorizontal * 90,
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                getTitleText(widget.title, false),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 3,
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: SizedBox(child: getBodyText("Máximo: ", false)),
                      ),
                    ],
                  ),
                ),
                Slider(
                  value: max,
                  max: widget.max,
                  divisions: 10,
                  label: getValueTag(max.round(), widget.title),
                  onChanged: (double value) {
                    setState(() {
                      max = value;
                      widget.setValues(min, max);
                    });
                  },
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical * 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: SizedBox(child: getBodyText("Mínimo: ", false)),
                      ),
                    ],
                  ),
                ),
                Slider(
                  value: min,
                  max: widget.max,
                  divisions: 10,
                  label: getValueTag(min.round(), widget.title),
                  onChanged: (double value) {
                    setState(() {
                      min = value;
                      widget.setValues(min, max);
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
