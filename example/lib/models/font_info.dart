
import 'package:flutter/material.dart';

class FontInfo {
  String name;
  TextStyle Function() style;

  FontInfo({required this.name, required this.style});

  factory FontInfo.fromJson(Map<String, dynamic> json) {
    return FontInfo(name: json['name'], style: json['style']);
  }
}
