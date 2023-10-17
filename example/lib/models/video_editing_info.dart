class VideoEditingInfo {
  Duration editedVideoDuration;
  Duration totalVideoDuration;
  String path;
  Duration startTrim;
  Duration endTrim;

  VideoEditingInfo(
      {required this.editedVideoDuration,
      required this.totalVideoDuration,
      required this.path,
      required this.startTrim,
      required this.endTrim});
}
