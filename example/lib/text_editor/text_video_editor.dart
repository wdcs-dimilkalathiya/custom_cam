import 'dart:io';

import 'package:example/helpers/progress_loader.dart';
import 'package:example/models/text_editing_info.dart';
import 'package:example/models/text_info.dart';
import 'package:example/text_editor/capture.dart';
import 'package:example/text_editor/dragable_text.dart';
import 'package:example/video_editor/video_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  List<TextInfo> textInfo = [];

  @override
  void initState() {
    super.initState();
    globalKey = GlobalKey();
    dragText = ValueNotifier(false);
    textCotroller = TextEditingController();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.path))
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
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
                    widgetSize: textInfo[i].widgetSize,
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

  Widget textField(context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
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
                      style: const TextStyle(color: Colors.black, fontSize: 25),
                      decoration: const InputDecoration(border: InputBorder.none))),
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
                        xPos: (size.width / 2),
                        yPos: (size.height / 2),
                        xPercent: 50,
                        yPercent: 50,
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
    );
  }

  Widget positionedText(int i) {
    return DraggableTextWidget(
      index: i,
      globalKey: globalKey,
      onDragUpdate: (details) {
        final width = MediaQuery.sizeOf(context).width;
        final height = MediaQuery.sizeOf(context).height;
        setState(() {
          textInfo[i].xPos += details.delta.dx;
          textInfo[i].yPos += details.delta.dy;
        });
        textInfo[i].xPercent = (textInfo[i].xPos / width) * 100;
        textInfo[i].yPercent = (textInfo[i].yPos / height) * 100;
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
