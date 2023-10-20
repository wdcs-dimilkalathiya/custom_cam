class TextEditingInfo {
  String imagePath;
  double xPos;
  double yPos;

  double get xScaled => (xPos / 100) * 720;
  double get yScaled => (yPos / 100) * 1280;

  TextEditingInfo({required this.imagePath, required this.xPos, required this.yPos});
}