import 'package:example/models/audio_editing_info.dart';
import 'package:example/models/text_editing_info.dart';
import 'package:example/models/video_editing_info.dart';

class EditingInfo {
  VideoEditingInfo videoEditingInfo;
  AudioEditingInfo? audioEditingInfo;
  List<TextEditingInfo>? textEditingInfo;
  bool isVideoHorizontal;

  EditingInfo(
      {required this.videoEditingInfo, required this.isVideoHorizontal, this.audioEditingInfo, this.textEditingInfo});
}
