import 'dart:io';

import 'package:example/models/editing_info.dart';
import 'package:example/models/text_editing_info.dart';
import 'package:example/video_editor/bloc/video_edior_bloc.dart/video_editor_bloc.dart';
import 'package:example/video_editor/bloc/video_edior_bloc.dart/video_editor_state.dart';
import 'package:example/video_editor/widgets/audio_selector.dart';
import 'package:example/video_editor/widgets/crop/crop_grid.dart';
import 'package:example/video_editor/widgets/trim/trim_slider.dart';
import 'package:example/video_editor/widgets/trim/trim_timeline.dart';
import 'package:example/viewer_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoEditor extends StatefulWidget {
  const VideoEditor({super.key, this.onFinish, this.textEditingInfo, required this.file});

  final File file;
  final TextEditingInfo? textEditingInfo;
  final Function(EditingInfo editingInfo)? onFinish;

  @override
  State<VideoEditor> createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> with SingleTickerProviderStateMixin {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  @override
  void dispose() async {
    _exportingProgress.dispose();
    _isExporting.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext _) {
    return BlocProvider(
      create: (_) => VideoEditorBloc(videoFile: widget.file, vsync: this, textEditingInfo: widget.textEditingInfo),
      child: BlocBuilder<VideoEditorBloc, VideoEditorState>(
        builder: (context, state) {
          final videoEditorBloc = context.read<VideoEditorBloc>();
          return WillPopScope(
            onWillPop: () async => false,
            child: Scaffold(
              backgroundColor: Colors.black,
              body: videoEditorBloc.controller.initialized
                  ? SafeArea(
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Stack(
                                        alignment: Alignment.center,
                                        fit: StackFit.loose,
                                        children: [
                                          CropGridViewer.preview(controller: videoEditorBloc.controller),
                                          AnimatedBuilder(
                                            animation: videoEditorBloc.controller.video,
                                            builder: (_, __) => AnimatedOpacity(
                                              opacity: videoEditorBloc.controller.isPlaying ? 0 : 1,
                                              duration: kThemeAnimationDuration,
                                              child: IgnorePointer(
                                                child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.play_arrow,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SafeArea(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                ..._trimSlider(context),
                                                videoEditorBloc.audioFile == null
                                                    ? Center(
                                                        child: ElevatedButton(
                                                          onPressed: () async {
                                                            FilePickerResult? result = await FilePicker.platform
                                                                .pickFiles(type: FileType.audio);
                                                            if (result != null) {
                                                              videoEditorBloc.savePickedFile(
                                                                File(result.files.first.path!),
                                                              );
                                                            }
                                                          },
                                                          child: const Text('pick audio'),
                                                        ),
                                                      )
                                                    : AudioSelector(videoEditorBloc.audioFile!),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.yellow[700],
                onPressed: () {
                  // widget.onFinish?.call(getEditingInfo());
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewerScreen(
                          editingInfo: videoEditorBloc.getEditingInfo(),
                        ),
                      ));
                },
                child: const Icon(
                  Icons.send,
                  color: Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  List<Widget> _trimSlider(BuildContext context) {
    final videoEditorBloc = context.read<VideoEditorBloc>();
    return [
      AnimatedBuilder(
        animation: Listenable.merge([
          videoEditorBloc.controller,
          videoEditorBloc.controller.video,
        ]),
        builder: (_, __) {
          final int duration = videoEditorBloc.controller.videoDuration.inSeconds;
          final double pos = videoEditorBloc.controller.trimPosition * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt()))),
              const Expanded(child: SizedBox()),
              AnimatedOpacity(
                opacity: videoEditorBloc.controller.isTrimming ? 1 : 0,
                duration: kThemeAnimationDuration,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(formatter(videoEditorBloc.controller.startTrim)),
                  const SizedBox(width: 10),
                  Text(formatter(videoEditorBloc.controller.endTrim)),
                ]),
              ),
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
          controller: videoEditorBloc.controller,
          height: height,
          horizontalMargin: height / 4,
          child: TrimTimeline(
            controller: videoEditorBloc.controller,
            padding: const EdgeInsets.only(top: 10),
          ),
        ),
      )
    ];
  }
}
