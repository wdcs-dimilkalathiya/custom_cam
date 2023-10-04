import 'package:camera/camera.dart';

class CamSettings {
  ResolutionPreset resolution;
  int videoTimeoutSeconds = 30;

  CamSettings({required this.resolution, required this.videoTimeoutSeconds});
}
