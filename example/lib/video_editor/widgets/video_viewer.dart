import 'package:example/video_editor/bloc/video_edior_bloc.dart/video_editor_bloc.dart';
import 'package:example/video_editor/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

class VideoViewer extends StatelessWidget {
  const VideoViewer({super.key, required this.controller, this.child});

  final VideoEditorController controller;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<VideoEditorBloc>();
    return GestureDetector(
      onTap: cubit.onPlayPauseTapped,
      child: Center(
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: controller.video.value.aspectRatio,
              child: VideoPlayer(controller.video),
            ),
            if (child != null)
              AspectRatio(
                aspectRatio: controller.video.value.aspectRatio,
                child: child,
              ),
          ],
        ),
      ),
    );
  }
}
