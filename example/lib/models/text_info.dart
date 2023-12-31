import 'package:flutter/material.dart';

class TextInfo {
  String text = '';
  Size widgetSize = const Size(0, 0);
  double xPos = 30.0;
  double yPos = 30.0;
  double xPercent = 0;
  double yPercent = 0;
  TextAlign textAlign;
  bool hasBg;
  TextStyle textStyle;

  TextInfo(
      {required this.widgetSize,
      required this.xPos,
      required this.xPercent,
      required this.yPercent,
      required this.yPos,
      required this.text,
      required this.textAlign,
      required this.hasBg,
      required this.textStyle});
}
