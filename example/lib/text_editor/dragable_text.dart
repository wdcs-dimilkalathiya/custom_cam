import 'dart:math';

import 'package:example/text_editor/cubit/text_editor_cubit.dart';
import 'package:example/text_editor/child_size_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DraggableTextWidget extends StatelessWidget {
  final int index;

  const DraggableTextWidget({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TextEditorCubit>();
    final text = DraggableText(
      cubit.textInfo[index].text,
      cubit.textInfo[index].xPos,
      cubit.textInfo[index].yPos,
    );
    return Positioned(
      left: text.dx,
      top: text.dy,
      child: Draggable(
        feedback: Container(),
        onDragUpdate: (details) {
          cubit.onDragUpdate(details, index);
        },
        child: ChildSizeNotifier(
          builder: (context, size, child) {
            cubit.textInfo[index].widgetSize = size;
            return child!;
          },
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width - 32,
            ),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Text(
              text.text,
              textAlign: TextAlign.center,
              style: cubit.textInfo[index].textStyle,
            ),
          ),
        ),
      ),
    );
  }
}

class CaptureImageWidget extends StatelessWidget {
  const CaptureImageWidget(
      {super.key,
      required this.text,
      required this.gkey,
      required this.widgetSize,
      required this.videoSize,
      required this.screenSize,
      required this.style});
  final String text;
  final Size videoSize;
  final Size widgetSize;
  final Size screenSize;
  final TextStyle style;
  final GlobalKey gkey;

  double calculateImageScaleVertical() {
    final videoWidth = videoSize.width;
    final videoHeight = videoSize.height;

    final scaleX = (videoWidth / screenSize.width);
    final scaleY = (videoHeight / screenSize.height);

    return max(scaleX, scaleY);
  }

  @override
  Widget build(BuildContext context) {
    final scale = calculateImageScaleVertical();
    return RepaintBoundary(
      key: gkey,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: (MediaQuery.sizeOf(context).width - 32) * scale,
        ),
        padding: EdgeInsets.symmetric(vertical: 6 * scale, horizontal: 10 * scale),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12 * scale),
          color: Colors.white,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: style.copyWith(fontSize: 28 * scale, color: Colors.black),
        ),
      ),
    );
  }
}

class DraggableText {
  String text;
  double dx;
  double dy;

  DraggableText(this.text, this.dx, this.dy);
}
