import 'package:flutter/material.dart';

class TextInfo {
  String text = '';
  Size widgetSize = const Size(0, 0);
  double xPos = 30.0;
  double yPos = 30.0;
  double xPercent = 0;
  double yPercent = 0;

  TextInfo(
      {required this.widgetSize,
      required this.xPos,
      required this.xPercent,
      required this.yPercent,
      required this.yPos,
      required this.text});
}
