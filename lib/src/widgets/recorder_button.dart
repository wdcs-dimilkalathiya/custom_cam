import 'package:custom_cam/custom_cam.dart';
import 'package:flutter/material.dart';

class RecorderButton extends StatefulWidget {
  const RecorderButton({super.key, required this.controller, required this.isRecording, required this.onTap});
  final CameraController controller;
  final bool isRecording;
  final VoidCallback onTap;

  @override
  State<RecorderButton> createState() => _RecorderButtonState();
}

class _RecorderButtonState extends State<RecorderButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 80,
        width: 80,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Center(
          child: AnimatedContainer(
            height: widget.isRecording ? 24 : 70,
            width: widget.isRecording ? 24 : 70,
            duration: const Duration(milliseconds: 200),
            decoration: ShapeDecoration(
              shape: widget.isRecording
                  ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
                  : const CircleBorder(),
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}
