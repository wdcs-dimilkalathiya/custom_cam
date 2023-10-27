import 'package:bloc/bloc.dart';
import 'package:example/models/font_info.dart';
import 'package:example/models/text_info.dart';
import 'package:example/text_editor/cubit/text_editor_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class TextEditorCubit extends Cubit<TextEditorState> {
  TextEditorCubit({required this.path, required this.screenHeight, required this.screenWidth})
      : super(InitialTextEditorState()) {
    // GoogleFonts.asMap().forEach((key, value) {
    // fontList.add(FontInfo(name: 'Grifter', style: fontsTextStyle('grifter')));
    fontList.add(FontInfo(name: 'Inter', style: GoogleFonts.inter));
    fontList.add(FontInfo(name: 'Black Mamba Trial', style: fontsTextStyle('black_mamba_trial')));
    fontList.add(FontInfo(name: 'Covered By Your Grace', style: GoogleFonts.coveredByYourGrace));
    fontList.add(FontInfo(name: 'Salome', style: fontsTextStyle('Salome')));
    // fontList.add(FontInfo(name: 'Bulevar', style: GoogleFonts.bulevar));
    fontList.add(FontInfo(name: 'Zen Dots', style: GoogleFonts.zenDots));
    // });
    globalKey = GlobalKey();
    dragText = ValueNotifier(false);
    textCotroller = TextEditingController();
    controller = VideoPlayerController.networkUrl(Uri.parse(path))
      ..initialize().then((_) {
        calculateValues();
        emit(InitialTextEditorState());
        controller.setLooping(true);
        controller.play();
      });
  }

  final String path;
  final double screenWidth;
  final double screenHeight;

  late VideoPlayerController controller;
  late TextEditingController textCotroller;
  late ValueNotifier<bool> dragText;
  late GlobalKey globalKey;
  late double videoWidth;
  late double videoHeight;
  late double xMin;
  late double xMax;
  late double yMin;
  late double yMax;
  late double videoAspectRatio;
  late double reverseVideoAspectRatio;
  late double screenAspectRatio;
  ValueNotifier<int> selectedIndex = ValueNotifier(0);
  bool get isHorizontal => controller.value.aspectRatio > 1;

  List<TextInfo> textInfo = [];
  List<FontInfo> fontList = [];

  void calculateValues() {
    // screenWidth = MediaQuery.sizeOf(context).width;
    // screenHeight = MediaQuery.sizeOf(context).height;

    reverseVideoAspectRatio = controller.value.size.height / controller.value.size.width;

    videoWidth = isHorizontal ? 1280 : 720;
    videoHeight = videoWidth * reverseVideoAspectRatio;

    videoAspectRatio = videoWidth / videoHeight;
    screenAspectRatio = screenWidth / screenHeight;

    if (videoAspectRatio > screenAspectRatio) {
      // Video is wider than the screen
      final scaledHeight = screenWidth / videoAspectRatio;
      xMin = 0.0;
      xMax = screenWidth;
      yMin = (screenHeight - scaledHeight) / 2;
      yMax = yMin + scaledHeight;
    } else {
      // Video is taller or equal in height to the screen
      final scaledWidth = screenHeight * videoAspectRatio;
      yMin = 0.0;
      yMax = screenHeight;
      xMin = (screenWidth - scaledWidth) / 2;
      xMax = xMin + scaledWidth;
    }
  }

  void onDragUpdate(DragUpdateDetails details, int i) {
    textInfo[i].xPos += details.delta.dx;
    textInfo[i].yPos += details.delta.dy;
    textInfo[i].xPos = textInfo[i].xPos.clamp(xMin, xMax - textInfo[i].widgetSize.width);
    textInfo[i].yPos = textInfo[i].yPos.clamp(yMin, yMax - textInfo[i].widgetSize.height);
    emit(InitialTextEditorState());

    double videoXNew = (textInfo[i].xPos - xMin) / (xMax - xMin) * videoWidth;
    double videoYNew = (textInfo[i].yPos - yMin) / (yMax - yMin) * videoHeight;

    textInfo[i].xPercent = videoXNew;
    textInfo[i].yPercent = videoYNew;
  }

  void onTextSend() {
    dragText.value = true;
    textInfo.add(
      TextInfo(
        text: textCotroller.text,
        widgetSize: const Size(0, 0),
        xPos: 0,
        yPos: (screenHeight / 2),
        xPercent: 0,
        yPercent: 50,
        textStyle: fontList[selectedIndex.value].style().copyWith(fontSize: 28, color: Colors.black),
      ),
    );
    emit(InitialTextEditorState());
  }

  void onIndexChanged(int index) {
    selectedIndex.value = index;
  }

  dynamic fontsTextStyle(String fontFamily) {
    return () => TextStyle(fontFamily: fontFamily);
  }

  @override
  Future<void> close() {
    controller.dispose();
    textCotroller.dispose();
    dragText.dispose();
    return super.close();
  }
}
