import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class FlashToggler extends StatefulWidget {
  const FlashToggler({
    super.key,
    required this.flashMode,
    required this.onChange,
  });
  final FlashMode flashMode;
  final Function(FlashMode flashMode) onChange;

  @override
  State<FlashToggler> createState() => _FlashTogglerState();
}

class _FlashTogglerState extends State<FlashToggler> {
  List<FlashMode> flashModes = [];
  int index = 0;

  @override
  void initState() {
    super.initState();
    flashModes = FlashMode.values;
    index = flashModes.indexWhere((element) => element == widget.flashMode);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (widget.flashMode == FlashMode.torch) {
          widget.onChange(FlashMode.off);
        } else {
          widget.onChange(FlashMode.torch);
        }
      },
      icon: switch (widget.flashMode) {
        FlashMode.off => const Icon(
            Icons.flash_off,
            color: Colors.white,
          ),
        FlashMode.auto => const Icon(
            Icons.flash_auto,
            color: Colors.white,
          ),
        FlashMode.always => const Icon(
            Icons.flash_on,
            color: Colors.white,
          ),
        FlashMode.torch => const Icon(
            Icons.flash_on,
            color: Colors.white,
          ),
      },
    );
  }
}
