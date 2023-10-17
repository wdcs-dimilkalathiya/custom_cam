class AudioEditingInfo {
  Duration audioEditedDuration;
  Duration totalAudioDuration;
  String path;
  Duration startTrim;
  Duration endTrim;

  AudioEditingInfo(
      {required this.audioEditedDuration,
      required this.totalAudioDuration,
      required this.path,
      required this.startTrim,
      required this.endTrim});
}
