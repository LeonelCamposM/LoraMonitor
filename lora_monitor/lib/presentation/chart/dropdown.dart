import 'package:flutter/material.dart';

class DropdownCustomButton extends StatefulWidget {
  const DropdownCustomButton(
      {Key? key,
      required this.options,
      required this.onChanged,
      required this.selectedValue})
      : super(key: key);
  final List<String> options;
  final Function onChanged;
  final String selectedValue;

  @override
  DropdownCustomButtonState createState() => DropdownCustomButtonState();
}

class DropdownCustomButtonState extends State<DropdownCustomButton> {
  // Initial Selected Value
  String dropdownvalue = '';

  @override
  void initState() {
    dropdownvalue = widget.selectedValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownButton(
          // Initial Value
          value: dropdownvalue,

          // Down Arrow Icon
          icon: const Icon(Icons.keyboard_arrow_down),

          // Array list of items
          items: widget.options.map((String items) {
            return DropdownMenuItem(
              value: items,
              child: Text(items),
            );
          }).toList(),
          // After selecting the desired option,it will
          // change button value to selected value
          onChanged: (String? newValue) {
            setState(() {
              dropdownvalue = newValue!;
              widget.onChanged(newValue);
            });
          },
        ),
      ],
    );
  }
}
