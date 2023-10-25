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
      {super.key, required this.text, required this.gkey, required this.widgetSize, required this.videoSize});
  final String text;
  final Size videoSize;
  final Size widgetSize;
  final GlobalKey gkey;

  double calculateImageScale(Size widgetSize, BuildContext context) {
    // final imageWidth = widgetSize.width;
    // final imageHeight = widgetSize.height;
    // const videoWidth = 1280;
    // const videoHeight = 720;

    final scaleX = (MediaQuery.sizeOf(context).width * MediaQuery.of(context).devicePixelRatio) / videoSize.width;
    final scaleY = (MediaQuery.sizeOf(context).height * MediaQuery.of(context).devicePixelRatio) / videoSize.height;

    return 1 / (scaleX > scaleY ? scaleX : scaleY);
  }

  @override
  Widget build(BuildContext context) {
    // final scaleValue = calculateImageScale(widgetSize, context);
    return RepaintBoundary(
      key: gkey,
      child: Transform(
        transform: Matrix4.identity()..scale(1.1),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width - 32,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),
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
