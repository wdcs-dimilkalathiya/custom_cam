import 'package:flutter/material.dart';

class ChildSizeNotifier extends StatefulWidget {
  const ChildSizeNotifier({
    Key? key,
    required this.builder,
    required this.child,
  }) : super(key: key);
  final Widget Function(BuildContext context, Size size, Widget? child) builder;
  final Widget child;

  @override
  State<ChildSizeNotifier> createState() => _ChildSizeNotifierState();
}

class _ChildSizeNotifierState extends State<ChildSizeNotifier> {
  final ValueNotifier<Size> notifier = ValueNotifier(const Size(0, 0));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        notifier.value = (context.findRenderObject() as RenderBox).size;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: widget.builder,
      child: widget.child,
    );
  }
}
