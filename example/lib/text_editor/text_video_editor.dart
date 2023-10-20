import 'dart:io';

import 'package:example/helpers/progress_loader.dart';
import 'package:example/models/text_editing_info.dart';
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
  Size widgetSize = const Size(0, 0);
  List<double> xPos = [30.0];
  List<double> yPos = [30.0];
  double xPercent = 0;
  double yPercent = 0;

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
          ValueListenableBuilder(
              valueListenable: dragText,
              builder: (context, bool value, Widget? child) {
                if (value == false) {
                  return Container();
                } else {
                  return positionedText(0);
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
          if (mounted) {
            imageData = await captureFromWidget(
                CaptureImageWidget(
                  text: textCotroller.text,
                  gkey: globalKey,
                  widgetSize: widgetSize,
                ),
                context: context,
                delay: const Duration(milliseconds: 200));
          }
          final directory = await getTemporaryDirectory();
          final pathOfImage = await File('${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png').create();
          if (imageData != null) {
            await pathOfImage.writeAsBytes(imageData);
          }
          await pl.hide();
          if (mounted && imageData != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoEditor(
                      file: File(widget.path),
                      textEditingInfo: TextEditingInfo(imagePath: pathOfImage.path, xPos: xPercent, yPos: yPercent)),
                ));
          }
        },
        child: const Icon(Icons.send),
      ),
    );
  }

  Widget textField(context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 10, right: 10),
      child: Container(
        height: 55,
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
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
                  if (textCotroller.text.isNotEmpty) {
                    dragText.value = true;
                    Navigator.pop(context);
                  }
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
          xPos[i] += details.delta.dx;
          yPos[i] += details.delta.dy;
        });
        xPercent = (xPos[i] / width) * 100;
        yPercent = (yPos[i] / height) * 100;
      },
      onSizeGet: (size) {
        widgetSize = size;
      },
      text: DraggableText(textCotroller.text, xPos[i], yPos[i]),
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
