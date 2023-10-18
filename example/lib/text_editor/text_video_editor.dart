import 'package:example/text_editor/dragable_text.dart';
import 'package:flutter/material.dart';
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
  List<double> xPos = [30.0, 120.0];
  List<double> yPos = [30.0, 120.0];

  @override
  void initState() {
    super.initState();
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
          for (int i = 0; i < 2; i++) ...[
            ValueListenableBuilder(
                valueListenable: dragText,
                builder: (context, bool value, Widget? child) {
                  if (value == false) {
                    return Container();
                  } else {
                    return positionedText(i);
                  }
                })
          ],
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
    debugPrint('======index $i');
    return DraggableTextWidget(
      index: i,
      onDragUpdate: (details) {
        setState(() {
          xPos[i] += details.delta.dx;
          yPos[i] += details.delta.dy;
        });
      },
      text: DraggableText((i == 0) ? "dhjdhswu" : textCotroller.text, xPos[i], yPos[i]),
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
