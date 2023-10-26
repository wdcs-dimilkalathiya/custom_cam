import 'dart:math';

import 'package:example/text_editor/child_size_notifier.dart';
import 'package:flutter/material.dart';

class DraggableTextWidget extends StatelessWidget {
  final int index;
  final DraggableText text;
  final GlobalKey globalKey;
  final Function(Size)? onSizeGet;
  final Function(DragUpdateDetails) onDragUpdate;

  const DraggableTextWidget(
      {super.key,
      required this.index,
      required this.text,
      required this.onDragUpdate,
      required this.globalKey,
      this.onSizeGet});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: text.dx,
      top: text.dy,
      child: Draggable(
        feedback: Container(),
        onDragUpdate: onDragUpdate,
        child: ChildSizeNotifier(
          builder: (context, size, child) {
            onSizeGet?.call(size);
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
              style: const TextStyle(fontSize: 28, color: Colors.black),
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
      required this.screenSize});
  final String text;
  final Size videoSize;
  final Size widgetSize;
  final Size screenSize;
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
          style: TextStyle(fontSize: 28 * scale, color: Colors.black),
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
