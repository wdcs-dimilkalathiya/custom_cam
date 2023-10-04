import 'dart:async';

import 'package:flutter/material.dart';

extension VideoTimer on Duration {
  String format() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final twoDigitMinutes = twoDigits(inMinutes.remainder(60));
    final twoDigitSeconds = twoDigits(inSeconds.remainder(60));
    final hour = twoDigits(inHours);
    return '$hour:$twoDigitMinutes:$twoDigitSeconds';
  }
}

class TimerTag extends StatefulWidget {
  const TimerTag({super.key});

  @override
  State<TimerTag> createState() => _TimerTagState();
}

class _TimerTagState extends State<TimerTag> {
  late Timer _timer;
  late DateTime startTime;
  late ValueNotifier<String> timeTag;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    timeTag = ValueNotifier('00:00:00');
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final streamEndTime = DateTime.now();
      timeTag.value = streamEndTime.difference(startTime).format();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: timeTag,
      builder: (context, value, child) {
        return Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}
