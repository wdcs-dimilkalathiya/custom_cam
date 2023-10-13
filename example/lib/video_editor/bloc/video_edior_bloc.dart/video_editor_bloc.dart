import 'dart:io';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:example/video_editor/bloc/video_edior_bloc.dart/video_editor_state.dart';
import 'package:example/video_editor/controller.dart';
import 'package:flutter/material.dart';

const kMaxAudioVideoDuration = 30;

class VideoEditorBloc extends Cubit<VideoEditorState> {
  VideoEditorBloc({required this.videoFile, required this.vsync}) : super(InitialVideoEditoState()) {
    controller = VideoEditorController.file(
      videoFile,
      minDuration: const Duration(seconds: 10),
      maxDuration: const Duration(seconds: kMaxAudioVideoDuration),
    );
    tabController = TabController(length: 2, vsync: vsync);
    controller.initialize(aspectRatio: 9 / 16).then((_) => emit(InitialVideoEditoState())).catchError((error) {
      // handle minumum duration bigger than video duration error
    }, test: (e) => e is VideoMinDurationError);
    tabController.addListener(() {
      print('object controller');
      print((controller.endTrim.inSeconds - controller.startTrim.inSeconds));
      maxAudioLength =
          Duration(milliseconds: (controller.endTrim.inMilliseconds - controller.startTrim.inMilliseconds).toInt());
    });
  }
  final TickerProvider vsync;
  late TabController tabController;
  Duration maxAudioLength = const Duration(seconds: kMaxAudioVideoDuration);
  late final VideoEditorController controller;
  final File videoFile;
  File? audioFile;
  double startValue = 0.0;
  double endValue = 0.0;
  List<int> bars = [];

  void savePickedFile(File file) {
    audioFile = file;
    emit(InitialVideoEditoState());
  }

  Stream<List<int?>> generateBars(double barHeight, double barWeight) async* {
    if (bars.isEmpty) {
      Random r = Random();
      for (int i = 1; i <= barWeight / 5.0; i++) {
        int number = 1 + r.nextInt(barHeight.toInt() - 1);
        bars.add(r.nextInt(number));
        yield bars;
      }
    } else {
      yield bars;
    }
  }

  @override
  Future<void> close() {
    controller.dispose();
    return super.close();
  }
}
