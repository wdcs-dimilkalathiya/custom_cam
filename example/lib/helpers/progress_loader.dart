// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';

class ProgressLoader {
  BuildContext? _context, _dismissingContext;
  bool _barrierDismissible = true, _showLogs = false, _isShowing = false;

  final double _dialogElevation = 8.0, _borderRadius = 8.0;
  final Color _backgroundColor = Colors.white;
  String? title = 'Loading...';
  final Curve _insetAnimCurve = Curves.easeInOut;
  ValueNotifier<int> progress = ValueNotifier(0);

  ProgressLoader(BuildContext buildContext, {required bool isDismissible, this.title}) {
    _context = buildContext;
    _barrierDismissible = isDismissible;
  }

  void updateLoaderValue(int newValue) {
    progress.value = newValue;
  }

  void updateTile(String newTitle) {
    title = newTitle;
  }

  bool isShowing() {
    return _isShowing;
  }

  Future<bool> hide() async {
    try {
      if (_isShowing) {
        _isShowing = false;
        Navigator.of(_dismissingContext!).pop();
        if (_showLogs) debugPrint('ProgressDialog dismissed');
        return Future.value(true);
      } else {
        if (_showLogs) debugPrint('ProgressDialog already dismissed');
        return Future.value(false);
      }
    } catch (err) {
      debugPrint('Seems there is an issue hiding dialog');
      debugPrint(err.toString());
      return Future.value(false);
    }
  }

  Future<bool> show() async {
    try {
      if (!_isShowing) {
        showDialog<dynamic>(
          context: _context!,
          barrierDismissible: _barrierDismissible,
          builder: (BuildContext context) {
            _dismissingContext = context;
            return WillPopScope(
              onWillPop: () async => _barrierDismissible,
              child: Dialog(
                  backgroundColor: _backgroundColor,
                  insetAnimationCurve: _insetAnimCurve,
                  insetAnimationDuration: const Duration(milliseconds: 100),
                  elevation: _dialogElevation,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(_borderRadius))),
                  child: ValueListenableBuilder(
                      valueListenable: progress,
                      builder: (context, value, child) {
                        return LoaderBody(
                          progress: progress,
                          title: title ?? 'Loading...',
                        );
                      })),
            );
          },
        );
        // Delaying the function for 200 milliseconds
        // [Default transitionDuration of DialogRoute]
        await Future.delayed(const Duration(milliseconds: 200));
        if (_showLogs) debugPrint('ProgressDialog shown');
        _isShowing = true;
        return true;
      } else {
        if (_showLogs) debugPrint("ProgressDialog already shown/showing");
        return false;
      }
    } catch (err) {
      _isShowing = false;
      debugPrint('Exception while showing the dialog');
      debugPrint(err.toString());
      return false;
    }
  }
}

class LoaderBody extends StatelessWidget {
  const LoaderBody({
    Key? key,
    required this.progress,
    required this.title,
  }) : super(key: key);
  final ValueNotifier<int> progress;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ValueListenableBuilder(
              valueListenable: progress,
              builder: (context, value, child) {
                return Row(
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                      value: value.toDouble() / 100,
                    ),
                    const SizedBox(
                      width: 16.0,
                    ),
                    Text(
                      '$title $value%',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              })
        ],
      ),
    );
  }
}
