import 'package:example/models/audio_editing_info.dart';
import 'package:example/models/text_editing_info.dart';
import 'package:example/models/video_editing_info.dart';

class EditingInfo {
  VideoEditingInfo videoEditingInfo;
  AudioEditingInfo? audioEditingInfo;
  TextEditingInfo? textEditingInfo;

  EditingInfo({required this.videoEditingInfo, this.audioEditingInfo, this.textEditingInfo});
}