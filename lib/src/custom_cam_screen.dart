import 'package:camera/camera.dart';
import 'package:custom_cam/src/cam_settings.dart';
import 'package:custom_cam/src/debouncer.dart';
import 'package:custom_cam/src/widgets/cam_change_button.dart';
import 'package:custom_cam/src/widgets/flash_toggler.dart';
import 'package:custom_cam/src/widgets/permission_alert_dialog.dart';
import 'package:custom_cam/src/widgets/recorder_button.dart';
import 'package:custom_cam/src/widgets/timer_tag.dart';
import 'package:flutter/material.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:permission_handler/permission_handler.dart';

class CustomCamScreen extends StatefulWidget {
  const CustomCamScreen({required this.settings, super.key, required this.onSuccess});
  final CamSettings settings;
  final Function(XFile thumbnail, String videoPath) onSuccess;

  @override
  State<CustomCamScreen> createState() => _CustomCamScreenState();
}

class _CustomCamScreenState extends State<CustomCamScreen> with WidgetsBindingObserver {
  ValueNotifier<bool> isLoading = ValueNotifier(false);
  ValueNotifier<bool> isRecording = ValueNotifier(false);
  ValueNotifier<bool> isBackCamSelected = ValueNotifier(true);
  ValueNotifier<bool> isError = ValueNotifier(false);
  ValueNotifier<bool> ignorePointer = ValueNotifier(false);
  bool isFinalWarning = false;
  bool isFunctionLoading = false;
  ValueNotifier<FlashMode> flashMode = ValueNotifier(FlashMode.off);
  CameraController? controller;
  XFile? file;
  List<CameraDescription> cameras = [];
  late Debouncer debouncer;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    debouncer = Debouncer(seconds: widget.settings.videoTimeoutSeconds);
    initCamera();
    super.initState();
  }

  Future<void> _checkPermission() async {
    PermissionStatus camera = await Permission.camera.status;
    PermissionStatus microphone = await Permission.microphone.status;
    if (camera.isPermanentlyDenied || microphone.isPermanentlyDenied) {
      await openAppSettings();
    } else if (camera.isDenied || microphone.isDenied) {
      if (mounted) {
        await showPermissionDialog(context);
      }
    }
    camera = await Permission.camera.status;
    microphone = await Permission.microphone.status;
    if (camera.isPermanentlyDenied || microphone.isPermanentlyDenied) {
      if (!isFinalWarning) {
        isFinalWarning = true;
        await openAppSettings();
      }
    }
  }

  Future<void> initCamera() async {
    isFunctionLoading = true;
    isLoading.value = true;

    if (cameras.isEmpty) {
      cameras = await availableCameras();
    }
    if (cameras.isNotEmpty) {
      controller = CameraController(isBackCamSelected.value ? cameras[0] : cameras[1], widget.settings.resolution);
      controller?.initialize().then((_) {
        isLoading.value = false;
        controller?.setFlashMode(flashMode.value);
      }).catchError((Object e) async {
        isError.value = true;
        if (e is CameraException) {
          switch (e.code) {
            case 'CameraAccessDenied':
              await _checkPermission();
              break;
            default:
              // Handle other errors here.
              break;
          }
        }
      });
    }
    isFunctionLoading = false;
  }

  Future<void> _startRecording() async {
    ignorePointer.value = true;
    file = await controller?.takePicture();
    await controller?.prepareForVideoRecording();
    await controller?.startVideoRecording();
    isRecording.value = true;
    debouncer.run(_stopRecording);
    // Need to wait for some time because if user presses again in short time camera throws error
    await Future.delayed(
      const Duration(seconds: 1),
    );
    ignorePointer.value = false;
  }

  Future<void> _stopRecording() async {
    isRecording.value = false;
    ignorePointer.value = true;
    XFile video = await controller!.stopVideoRecording();
    widget.onSuccess(file!, video.path);
  }

 Future<void> reInitCam() async {
    final camera = await Permission.camera.status;
    final microphone = await Permission.microphone.status;
    if ((camera.isGranted || camera.isLimited) && (microphone.isGranted || microphone.isLimited)) {
      isLoading.value = true;
      final camController =
          CameraController(isBackCamSelected.value ? cameras[0] : cameras[1], widget.settings.resolution);
      camController.initialize().then((_) {
        isLoading.value = false;
        isError.value = false;
        isFinalWarning = false;
        controller = camController;
        controller?.setFlashMode(flashMode.value);
      }).catchError((e) {
        switch (e.code) {
          case 'CameraAccessDenied':
            isError.value = true;
            break;
          default:
            isError.value = true;
            break;
        }
      });
    } else {
      isError.value = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.hidden:
        {}
      case AppLifecycleState.paused:
        {}
      case AppLifecycleState.resumed:
        {
          if (isFunctionLoading) {
            return;
          }
          reInitCam();
        }
      case AppLifecycleState.inactive:
        {
          isLoading.value = true;
          isError.value = false;
          isRecording.value = false;
          ignorePointer.value = false;
          controller?.dispose();
        }
      case AppLifecycleState.detached:
        {}
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    debouncer.dispose();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: MultiValueListenableBuilder(
          valueListenables: [isLoading, isError],
          builder: (context, values, child) {
            return isLoading.value || !controller!.value.isInitialized || isError.value
                ? isError.value
                    ? const Center(
                        child: Text(
                          'provide nessesary permissions to access recording feature',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                : MultiValueListenableBuilder(
                    valueListenables: [ignorePointer],
                    builder: (context, values, child) {
                      return IgnorePointer(
                        ignoring: ignorePointer.value,
                        child: Stack(
                          children: [
                            const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                            Positioned(
                              child: CameraPreview(controller!),
                            ),
                            Positioned(
                              top: 10,
                              right: 3,
                              child: SafeArea(
                                child: ValueListenableBuilder(
                                    valueListenable: flashMode,
                                    builder: (context, value, child) {
                                      return FlashToggler(
                                        flashMode: value,
                                        onChange: (val) {
                                          flashMode.value = val;
                                          controller?.setFlashMode(val);
                                        },
                                      );
                                    }),
                              ),
                            ),
                            MultiValueListenableBuilder(
                                valueListenables: [isRecording],
                                builder: (context, values, child) {
                                  return Positioned(
                                    bottom: 30,
                                    left: 0,
                                    right: 0,
                                    child: Column(
                                      children: [
                                        if (isRecording.value) const TimerTag(),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            RecorderButton(
                                                controller: controller!,
                                                isRecording: isRecording.value,
                                                onTap: () async {
                                                  if (!isRecording.value) {
                                                    _startRecording();
                                                  } else {
                                                    debouncer.dispose();
                                                    _stopRecording();
                                                  }
                                                }),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            MultiValueListenableBuilder(
                                valueListenables: [isRecording],
                                builder: (context, values, child) {
                                  return isRecording.value
                                      ? const SizedBox()
                                      : Positioned(
                                          bottom: 54,
                                          right: 20,
                                          child: CamChangeButton(
                                            onTap: () {
                                              isBackCamSelected.value = !isBackCamSelected.value;
                                              initCamera();
                                            },
                                          ),
                                        );
                                }),
                          ],
                        ),
                      );
                    });
          }),
    );
  }
}
