import 'dart:io';

import 'package:example/audio/audio_trimmer/audio_trimmer.dart';
import 'package:example/audio/audio_trimmer/trim_area_properties.dart';
import 'package:example/audio/audio_trimmer/trim_editor_properties.dart';
import 'package:example/audio/utils/duration_style.dart';
import 'package:example/video_editor/bloc/video_edior_bloc.dart/video_editor_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AudioSelector extends StatefulWidget {
  final File file;

  const AudioSelector(this.file, {Key? key}) : super(key: key);
  @override
  State<AudioSelector> createState() => _AudioSelectorState();
}

class _AudioSelectorState extends State<AudioSelector> {
  final _progressVisibility = false;
  bool isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAudio();
  }

  void _loadAudio() async {
    final cubit = context.read<VideoEditorBloc>();
    if (cubit.isAudioInitialized) return;
    setState(() {
      isLoading = true;
    });
    await cubit.loadAudio(widget.file);
    setState(() {
      isLoading = false;
      cubit.isAudioInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final videoEdiorBloc = context.read<VideoEditorBloc>();
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: LinearProgressIndicator(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: AudioTrimmer(
                      trimmer: context.read<VideoEditorBloc>().trimmer!,
                      viewerHeight: 50,
                      maxAudioLength: videoEdiorBloc.maxAudioLength,
                      viewerWidth: MediaQuery.of(context).size.width,
                      durationStyle: DurationStyle.FORMAT_MM_SS,
                      backgroundColor: Theme.of(context).primaryColor,
                      barColor: Colors.white,
                      durationTextStyle: const TextStyle(
                        color: Colors.white,
                      ),
                      allowAudioSelection: false,
                      editorProperties: TrimEditorProperties(
                        circleSize: 0,
                        borderPaintColor: Colors.yellow[700]!,
                        borderWidth: 2,
                        borderRadius: 5,
                        circlePaintColor: Colors.pink.shade400,
                        sideTapSize: 0,
                        circleSizeOnDrag: 0,
                      ),
                      areaProperties: TrimAreaProperties.edgeBlur(blurEdges: true),
                      onChangeStart: (value) {
                        videoEdiorBloc.startValue = value;
                      },
                      onChangeEnd: (value) {
                        videoEdiorBloc.endValue = value;
                      },
                      onDragEnd: () async {
                       await videoEdiorBloc.stopAndResetBothPlayer(isFromAudio: true);
                      },
                      onChangePlaybackState: (value) {
                        // if (mounted) {
                        //   setState(() => _isPlaying = value);
                        // }
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
