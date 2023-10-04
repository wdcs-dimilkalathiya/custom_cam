import 'package:flutter/material.dart';

class CamChangeButton extends StatelessWidget {
  const CamChangeButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Icon(
        Icons.cameraswitch_outlined,
        color: Colors.white,
      ),
    );
  }
}
