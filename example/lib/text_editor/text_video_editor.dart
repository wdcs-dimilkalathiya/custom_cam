import 'dart:io';

import 'package:example/helpers/progress_loader.dart';
import 'package:example/models/font_info.dart';
import 'package:example/models/text_editing_info.dart';
import 'package:example/models/text_info.dart';
import 'package:example/text_editor/capture.dart';
import 'package:example/text_editor/dragable_text.dart';
import 'package:example/text_editor/font_selector.dart';
import 'package:example/video_editor/video_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class TextVideoEditor extends StatefulWidget {
  const TextVideoEditor({super.key, required this.path});
  final String path;

  @override
  State<TextVideoEditor> createState() => _TextVideoEditorState();
}

class _TextVideoEditorState extends State<TextVideoEditor> {
  late VideoPlayerController _controller;
  late TextEditingController textCotroller;
  late ValueNotifier<bool> dragText;
  late GlobalKey globalKey;
  late double screenWidth;
  late double screenHeight;
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
  bool get isHorizontal => _controller.value.aspectRatio > 1;

  List<TextInfo> textInfo = [];
  List<FontInfo> fontList = [];

  @override
  void initState() {
    super.initState();
    GoogleFonts.asMap().forEach((key, value) {
      fontList.add(FontInfo(name: key, style: value));
    });
    globalKey = GlobalKey();
    dragText = ValueNotifier(false);
    textCotroller = TextEditingController();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.path))
      ..initialize().then((_) {
        calculateValues();
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      });
  }

  void calculateValues() {
    screenWidth = MediaQuery.sizeOf(context).width;
    screenHeight = MediaQuery.sizeOf(context).height;

    reverseVideoAspectRatio = _controller.value.size.height / _controller.value.size.width;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
          for (int i = 0; i < textInfo.length; i++)
            ValueListenableBuilder(
                valueListenable: dragText,
                builder: (context, bool value, Widget? child) {
                  if (value == false) {
                    return const SizedBox.shrink();
                  } else {
                    return positionedText(i);
                  }
                }),
          Positioned(
            top: 40,
            right: 10,
            child: IconButton(
                icon: const Icon(
                  Icons.text_format,
                  color: Colors.white,
                ),
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      enableDrag: true,
                      isDismissible: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      barrierColor: Colors.black.withAlpha(1),
                      builder: (builder) {
                        return textField(context);
                      });
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Uint8List? imageData;
          final pl = ProgressLoader(context, isDismissible: false);
          await pl.show();
          final textList = <TextEditingInfo>[];
          for (int i = 0; i < textInfo.length; i++) {
            if (mounted) {
              imageData = await captureFromWidget(
                  CaptureImageWidget(
                    text: textInfo[i].text,
                    gkey: globalKey,
                    style: textInfo[i].textStyle,
                    widgetSize: textInfo[i].widgetSize,
                    screenSize: Size((MediaQuery.sizeOf(context).width * MediaQuery.of(context).devicePixelRatio),
                        (MediaQuery.sizeOf(context).height * MediaQuery.of(context).devicePixelRatio)),
                    videoSize: Size(videoWidth, videoHeight),
                  ),
                  context: context,
                  delay: const Duration(milliseconds: 200));
            }
            final directory = await getTemporaryDirectory();
            final pathOfImage = await File('${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png').create();
            if (imageData != null) {
              await pathOfImage.writeAsBytes(imageData);
              textList.add(
                TextEditingInfo(
                  imagePath: pathOfImage.path,
                  xPos: textInfo[i].xPercent,
                  yPos: textInfo[i].yPercent,
                ),
              );
            }
          }

          await pl.hide();
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => VideoEditor(
                  file: File(widget.path),
                  textEditingInfo: textList.isEmpty ? null : textList,
                ),
              ),
            );
          }
        },
        child: const Icon(Icons.send),
      ),
    );
  }

  Widget textField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ValueListenableBuilder(
          valueListenable: selectedIndex,
          builder: (context, value, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                      height: 70,
                      child: FontSelector(
                        fontList: fontList,
                        selectedIndex: value,
                        onIndexChanged: (index) {
                          setState(() {
                            selectedIndex.value = index;
                          });
                        },
                      )),
                ),
                Container(
                  height: 55,
                  alignment: Alignment.bottomCenter,
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 3),
                          child: TextFormField(
                            cursorColor: Colors.black,
                            autofocus: true,
                            controller: textCotroller,
                            style: fontList[value].style(color: Colors.black, fontSize: 20),
                            decoration: const InputDecoration(border: InputBorder.none),
                          ),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            Size size = MediaQuery.sizeOf(context);
                            if (textCotroller.text.isNotEmpty) {
                              dragText.value = true;
                              textInfo.add(
                                TextInfo(
                                  text: textCotroller.text,
                                  widgetSize: const Size(0, 0),
                                  xPos: 0,
                                  yPos: (size.height / 2),
                                  xPercent: 0,
                                  yPercent: 50,
                                  textStyle: fontList[selectedIndex.value].style(fontSize: 28, color: Colors.black),
                                ),
                              );
                              Navigator.pop(context);
                            }
                            textCotroller.clear();
                          },
                          icon: const Icon(
                            Icons.send,
                            color: Colors.black,
                          ))
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }

  Widget positionedText(int i) {
    return DraggableTextWidget(
      index: i,
      globalKey: globalKey,
      style: textInfo[i].textStyle,
      onDragUpdate: (details) {
        setState(() {
          textInfo[i].xPos += details.delta.dx;
          textInfo[i].yPos += details.delta.dy;
          textInfo[i].xPos = textInfo[i].xPos.clamp(xMin, xMax - textInfo[i].widgetSize.width);
          textInfo[i].yPos = textInfo[i].yPos.clamp(yMin, yMax - textInfo[i].widgetSize.height);
        });

        double videoXNew = (textInfo[i].xPos - xMin) / (xMax - xMin) * videoWidth;
        double videoYNew = (textInfo[i].yPos - yMin) / (yMax - yMin) * videoHeight;

        debugPrint(videoXNew.toString());
        debugPrint(videoYNew.toString());

        textInfo[i].xPercent = videoXNew;
        textInfo[i].yPercent = videoYNew;
      },
      onSizeGet: (size) {
        textInfo[i].widgetSize = size;
      },
      text: DraggableText(textInfo[i].text, textInfo[i].xPos, textInfo[i].yPos),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    textCotroller.dispose();
    dragText.dispose();
  }
}
