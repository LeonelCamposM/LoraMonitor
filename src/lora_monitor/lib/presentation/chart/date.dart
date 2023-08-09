import 'dart:async';
import 'package:flutter/material.dart';

class DatePicker extends StatefulWidget {
  DatePicker(
      {Key? key,
      required this.title,
      onSelectedDate,
      required this.callback,
      required this.selectedDate})
      : super(key: key);

  final String title;
  final Function callback;
  DateTime selectedDate;

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: widget.selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != widget.selectedDate) {
      setState(() {
        widget.selectedDate = picked;
      });
      widget.callback(widget.selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text("${widget.selectedDate.toLocal()}".split(' ')[0]),
        const SizedBox(
          height: 20.0,
        ),
        ElevatedButton(
          onPressed: () => _selectDate(context),
          child: Text(widget.title),
        ),
      ],
    ));
  }
}
