import 'dart:io';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:example/audio/trimmer.dart';
import 'package:example/models/audio_editing_info.dart';
import 'package:example/models/editing_info.dart';
import 'package:example/models/text_editing_info.dart';
import 'package:example/models/video_editing_info.dart';
import 'package:example/video_editor/bloc/video_edior_bloc.dart/video_editor_state.dart';
import 'package:example/video_editor/controller.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

const kMaxAudioVideoDuration = 30;

class VideoEditorBloc extends Cubit<VideoEditorState> {
  VideoEditorBloc({required this.videoFile, required this.vsync, this.textEditingInfo})
      : super(InitialVideoEditoState()) {
    controller = VideoEditorController.file(videoFile,
        minDuration: const Duration(seconds: 10),
        maxDuration: const Duration(seconds: kMaxAudioVideoDuration),
        onTrimChange: stopAndResetBothPlayer);
    tabController = TabController(length: 2, vsync: vsync);
    controller.initialize(aspectRatio: 9 / 16, handleListener: false).then((_) {
      tabHandler();
      emit(InitialVideoEditoState());
      controller.video.addListener(_videoListener);
    }).catchError((error) {
      // handle minumum duration bigger than video duration error
    }, test: (e) => e is VideoMinDurationError);
  }
  Duration tabHandler() {
    maxAudioLength =
        Duration(milliseconds: (controller.endTrim.inMilliseconds - controller.startTrim.inMilliseconds).toInt());
    return maxAudioLength;
  }

  final TickerProvider vsync;
  final List<TextEditingInfo>? textEditingInfo;
  late TabController tabController;
  Duration maxAudioLength = const Duration(seconds: kMaxAudioVideoDuration);
  late final VideoEditorController controller;
  final File videoFile;
  Trimmer? trimmer;
  bool isAudioInitialized = false;
  File? audioFile;
  double startValue = 0.0;
  double endValue = 0.0;
  List<int> bars = [];

  void savePickedFile(File file) async {
    audioFile = file;
    await controller.video.setVolume(0);
    await controller.video.setLooping(false);
    await controller.video.pause();
    await controller.video.seekTo(const Duration(milliseconds: 0));
    emit(InitialVideoEditoState());
  }

  void _videoListener() async {
    final position = controller.videoPosition;
    if (position.inMilliseconds < controller.startTrim.inMilliseconds ||
        position.inMilliseconds >= controller.endTrim.inMilliseconds) {
      await trimmer?.audioPlayer?.pause().then((value) {
        trimmer?.audioPlayer?.seek(Duration(milliseconds: startValue.toInt()));
      });
      await controller.video.pause().then((value) {
        controller.video.seekTo(controller.startTrim);
      });
    }
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

  Future<void> stopAndResetBothPlayer({bool isFromAudio = false}) async {
    if (!controller.initialized || !isAudioInitialized) return;
    tabHandler();
    if (!isFromAudio) {
      trimmer?.callUpdateEvent();
    }
    // if(controller.video.value.isPlaying) {
    controller.video.pause();
    // }
    // if(trimmer.audioPlayer?.playing ?? true) {
    trimmer?.audioPlayer?.pause();
    // }
    controller.video.seekTo(controller.startTrim);
    if (isAudioInitialized) {
      trimmer?.audioPlayer?.seek(Duration(milliseconds: startValue.toInt()));
    }
    emit(InitialVideoEditoState());
  }

  loadAudio(File file) async {
    trimmer = Trimmer();
    await trimmer?.loadAudio(audioFile: file);
    trimmer?.audioPlayer?.setLoopMode(LoopMode.one);
    // controller.video.play();
    // trimmer?.audioPlayer?.play();
  }

  Future<void> onPlayPauseTapped() async {
    if (!isAudioInitialized) {
      if (controller.video.value.isPlaying) {
        controller.video.pause();
      } else {
        controller.video.play();
      }
    } else {
      if (controller.video.value.isPlaying || (trimmer?.audioPlayer?.playing ?? true)) {
        await Future.wait([
          controller.video.pause(),
          trimmer!.audioPlayer!.pause(),
        ]);
      } else {
        await Future.wait([
          controller.video.play(),
          trimmer!.audioPlayer!.play(),
        ]);
      }
    }
  }

  EditingInfo getEditingInfo() {
    return EditingInfo(
        videoEditingInfo: VideoEditingInfo(
            editedVideoDuration: controller.trimmedDuration,
            totalVideoDuration: controller.video.value.duration,
            path: videoFile.path,
            startTrim: controller.startTrim,
            endTrim: controller.endTrim),
        audioEditingInfo: isAudioInitialized
            ? AudioEditingInfo(
                audioEditedDuration: Duration(milliseconds: (endValue - startValue).toInt()),
                totalAudioDuration: trimmer?.audioPlayer?.duration ?? const Duration(seconds: 0),
                path: audioFile?.path ?? '',
                startTrim: Duration(milliseconds: startValue.toInt()),
                endTrim: Duration(milliseconds: endValue.toInt()))
            : null,
        textEditingInfo: textEditingInfo);
  }

  @override
  Future<void> close() {
    tabController.removeListener(tabHandler);
    controller.video.removeListener(_videoListener);
    controller.dispose();
    trimmer?.dispose();
    return super.close();
  }
}
