import 'package:flutter/material.dart';

class DraggableTextWidget extends StatelessWidget {
  final int index;
  final DraggableText text;
  final GlobalKey globalKey;
  final Function(DragUpdateDetails) onDragUpdate;

  const DraggableTextWidget(
      {super.key, required this.index, required this.text, required this.onDragUpdate, required this.globalKey});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: text.dx,
      top: text.dy,
      child: Draggable(
        feedback: Container(),
        onDragUpdate: onDragUpdate,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Text(
            text.text,
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class CaptureImageWidget extends StatelessWidget {
  const CaptureImageWidget({super.key, required this.text, required this.gkey});
  final String text;
  final GlobalKey gkey;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: gkey,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 20, color: Colors.black),
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
