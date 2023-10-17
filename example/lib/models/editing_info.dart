import 'package:example/models/audio_editing_info.dart';
import 'package:example/models/video_editing_info.dart';

class EditingInfo {
  VideoEditingInfo videoEditingInfo;
  AudioEditingInfo? audioEditingInfo;

  EditingInfo({required this.videoEditingInfo, required this.audioEditingInfo});
}