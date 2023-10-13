import 'dart:io';

import 'package:example/video_editor/bloc/video_edior_bloc.dart/video_editor_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FixedBarViewerRandom extends StatelessWidget {
  final File audioFile;
  final int audioDuration;
  final double barHeight;
  final double barWeight;
  final BoxFit fit;

  final Color? barColor;
  final Color? backgroundColor;

  /// For showing the bars generated from the audio,
  /// like a frame by frame preview
  const FixedBarViewerRandom(
      {Key? key,
      required this.audioFile,
      required this.audioDuration,
      required this.barHeight,
      required this.barWeight,
      required this.fit,
      this.backgroundColor,
      this.barColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<int?>>(
      stream: context.read<VideoEditorBloc>().generateBars(barHeight, barWeight),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<int?> bars = snapshot.data!;
          return Container(
            color: backgroundColor ?? Colors.white,
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: bars.map((int? height) {
                return Container(
                  color: barColor ?? Colors.black,
                  height: height?.toDouble(),
                  width: 5.0,
                );
              }).toList(),
            ),
          );
        } else {
          return Container(
            color: Colors.grey[900],
            height: barHeight,
            width: double.maxFinite,
          );
        }
      },
    );
  }
}
