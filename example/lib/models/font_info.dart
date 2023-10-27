import 'dart:ui';

import 'package:flutter/material.dart';

class FontInfo {
  String name;
  Function(
      {Paint? background,
      Color? backgroundColor,
      Color? color,
      TextDecoration? decoration,
      Color? decorationColor,
      TextDecorationStyle? decorationStyle,
      double? decorationThickness,
      List<FontFeature>? fontFeatures,
      double? fontSize,
      FontStyle? fontStyle,
      FontWeight? fontWeight,
      Paint? foreground,
      double? height,
      double? letterSpacing,
      Locale? locale,
      List<Shadow>? shadows,
      TextBaseline? textBaseline,
      TextStyle? textStyle,
      double? wordSpacing}) style;

  FontInfo({required this.name, required this.style});

  factory FontInfo.fromJson(Map<String, dynamic> json) {
    return FontInfo(name: json['name'], style: json['style']);
  }
}
