import 'package:flutter/material.dart';

AppBar appBar(
  String title, {
  List<Widget>? actions,
}) =>
    AppBar(
      title: Text(title),
      automaticallyImplyLeading: false,
      actions: actions,
    );

const optionText = Text(
  'Or',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  ),
  textAlign: TextAlign.center,
);

const spacer = SizedBox(
  height: 12,
);
