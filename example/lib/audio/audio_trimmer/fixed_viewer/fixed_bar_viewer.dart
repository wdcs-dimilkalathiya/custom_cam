import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FixedBarViewer extends StatefulWidget {
  final File audioFile;
  final int audioDuration;
  final double barHeight;
  final double barWeight;
  final BoxFit fit;

  final Color? barColor;
  final Color? backgroundColor;

  /// For showing the bars generated from the audio,
  /// like a frame by frame preview
  const FixedBarViewer(
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
  State<FixedBarViewer> createState() => _FixedBarViewerState();
}

class _FixedBarViewerState extends State<FixedBarViewer> {
  late PlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = PlayerController();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      generateBars();
    });
  }

  final playerWaveStyle = const PlayerWaveStyle(
    fixedWaveColor: Colors.white54,
    liveWaveColor: Colors.white,
    spacing: 6,
  );

  Stream<List<double?>> generateBars() async* {
    yield await controller.extractWaveformData(
      path: widget.audioFile.path,
      noOfSamples: playerWaveStyle.getSamplesForWidth(MediaQuery.sizeOf(context).width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<double?>>(
      stream: generateBars(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<double?> bars = snapshot.data!;
          return Container(
            color: widget.backgroundColor ?? Colors.white,
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: bars.map((double? height) {
                return Container(
                  color: widget.barColor ?? Colors.black,
                  height: ((height ?? 0) * (widget.barHeight * 3)),
                  width: 2.0,
                );
              }).toList(),
            ),
          );
        } else {
          return ColoredBox(
            color: widget.backgroundColor ?? Colors.white,
            child: Center(
              child: LinearProgressIndicator(
                minHeight: 5,
                backgroundColor: Colors.transparent,
                color: widget.barColor ?? Colors.white,
              ),
            ),
          );
        }
      },
    );
  }
}
