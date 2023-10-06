import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:just_waveform/just_waveform.dart';

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
  final progressStream = BehaviorSubject<WaveformProgress>();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final waveFile = File(p.join((await getTemporaryDirectory()).path, 'waveform.wave'));
      JustWaveform.extract(audioInFile: widget.audioFile, waveOutFile: waveFile)
          .listen(progressStream.add, onError: progressStream.addError);
    } catch (e) {
      progressStream.addError(e);
    }
  }

  // Stream<List<double?>> generateBars() async* {
  //   yield await controller.extractWaveformData(
  //     path: widget.audioFile.path,
  //     noOfSamples: playerWaveStyle.getSamplesForWidth(MediaQuery.sizeOf(context).width),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: widget.backgroundColor ?? Colors.white,
      child: StreamBuilder<WaveformProgress>(
        stream: progressStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            );
          }
          final progress = snapshot.data?.progress ?? 0.0;
          final waveform = snapshot.data?.waveform;
          if (waveform == null) {
            return Center(
              child: LinearProgressIndicator(
                backgroundColor: widget.backgroundColor,
                color: widget.barColor ?? Colors.white,
                value: progress,
              ),
            );
          }
          return AudioWaveformWidget(
            waveform: waveform,
            start: Duration.zero,
            duration: waveform.duration,
            waveColor: widget.barColor ?? Colors.white,
          );
        },
      ),
    );
  }
}

class AudioWaveformWidget extends StatefulWidget {
  final Color waveColor;
  final double scale;
  final double strokeWidth;
  final double pixelsPerStep;
  final Waveform waveform;
  final Duration start;
  final Duration duration;

  const AudioWaveformWidget({
    Key? key,
    required this.waveform,
    required this.start,
    required this.duration,
    this.waveColor = Colors.blue,
    this.scale = 1.0,
    this.strokeWidth = 5.0,
    this.pixelsPerStep = 8.0,
  }) : super(key: key);

  @override
  State<AudioWaveformWidget> createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<AudioWaveformWidget> {
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        painter: AudioWaveformPainter(
          waveColor: widget.waveColor,
          waveform: widget.waveform,
          start: widget.start,
          duration: widget.duration,
          scale: widget.scale,
          strokeWidth: widget.strokeWidth,
          pixelsPerStep: widget.pixelsPerStep,
        ),
      ),
    );
  }
}

class AudioWaveformPainter extends CustomPainter {
  final double scale;
  final double strokeWidth;
  final double pixelsPerStep;
  final Paint wavePaint;
  final Waveform waveform;
  final Duration start;
  final Duration duration;

  AudioWaveformPainter({
    required this.waveform,
    required this.start,
    required this.duration,
    Color waveColor = Colors.blue,
    this.scale = 1.0,
    this.strokeWidth = 5.0,
    this.pixelsPerStep = 8.0,
  }) : wavePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = waveColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (duration == Duration.zero) return;

    double width = size.width;
    double height = size.height;

    final waveformPixelsPerWindow = waveform.positionToPixel(duration).toInt();
    final waveformPixelsPerDevicePixel = waveformPixelsPerWindow / width;
    final waveformPixelsPerStep = waveformPixelsPerDevicePixel * pixelsPerStep;
    final sampleOffset = waveform.positionToPixel(start);
    final sampleStart = -sampleOffset % waveformPixelsPerStep;
    for (var i = sampleStart.toDouble(); i <= waveformPixelsPerWindow + 1.0; i += waveformPixelsPerStep) {
      final sampleIdx = (sampleOffset + i).toInt();
      final x = i / waveformPixelsPerDevicePixel;
      final minY = normalise(waveform.getPixelMin(sampleIdx), height);
      final maxY = normalise(waveform.getPixelMax(sampleIdx), height);
      canvas.drawLine(
        Offset(x + strokeWidth / 2, max(strokeWidth * 0.75, minY)),
        Offset(x + strokeWidth / 2, min(height - strokeWidth * 0.75, maxY)),
        wavePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AudioWaveformPainter oldDelegate) {
    return false;
  }

  double normalise(int s, double height) {
    if (waveform.flags == 0) {
      final y = 32768 + (scale * s).clamp(-32768.0, 32767.0).toDouble();
      return height - 1 - y * height / 65536;
    } else {
      final y = 128 + (scale * s).clamp(-128.0, 127.0).toDouble();
      return height - 1 - y * height / 256;
    }
  }
}
