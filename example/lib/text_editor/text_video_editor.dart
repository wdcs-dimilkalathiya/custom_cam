import 'dart:io';

import 'package:example/helpers/progress_loader.dart';
import 'package:example/models/text_editing_info.dart';
import 'package:example/text_editor/cubit/text_editor_cubit.dart';
import 'package:example/text_editor/cubit/text_editor_state.dart';
import 'package:example/text_editor/capture.dart';
import 'package:example/text_editor/dragable_text.dart';
import 'package:example/text_editor/text_edtior_input_field.dart';
import 'package:example/video_editor/video_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class TextVideoEditor extends StatefulWidget {
  const TextVideoEditor({super.key, required this.path});
  final String path;

  @override
  State<TextVideoEditor> createState() => _TextVideoEditorState();
}

class _TextVideoEditorState extends State<TextVideoEditor> {
  @override
  Widget build(BuildContext _) {
    final size = MediaQuery.sizeOf(_);
    return BlocProvider(
      create: (context) => TextEditorCubit(path: widget.path, screenHeight: size.height, screenWidth: size.width),
      child: BlocBuilder<TextEditorCubit, TextEditorState>(
        builder: (textEdiorCtx, state) {
          final cubit = textEdiorCtx.read<TextEditorCubit>();
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: cubit.controller.value.aspectRatio,
                    child: VideoPlayer(cubit.controller),
                  ),
                ),
                for (int i = 0; i < cubit.textInfo.length; i++)
                  ValueListenableBuilder(
                      valueListenable: cubit.dragText,
                      builder: (_, bool value, Widget? child) {
                        if (value == false) {
                          return const SizedBox.shrink();
                        } else {
                          return DraggableTextWidget(
                            index: i,
                          );
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
                            context: textEdiorCtx,
                            isScrollControlled: true,
                            enableDrag: true,
                            isDismissible: true,
                            backgroundColor: Colors.transparent.withOpacity(0.5),
                            elevation: 0,
                            barrierColor: Colors.black.withAlpha(1),
                            builder: (_) {
                              return BlocProvider.value(value: cubit, child: const TextEditorInputField());
                            });
                      }),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                Uint8List? imageData;
                final pl = ProgressLoader(textEdiorCtx, isDismissible: false);
                await pl.show();
                final textList = <TextEditingInfo>[];
                for (int i = 0; i < cubit.textInfo.length; i++) {
                  pl.updateLoaderValue((((i + 1) / cubit.textInfo.length) * 100).toInt());
                  if (mounted) {
                    imageData = await captureFromWidget(
                        CaptureImageWidget(
                          text: cubit.textInfo[i].text,
                          gkey: cubit.globalKey,
                          style: cubit.textInfo[i].textStyle,
                          widgetSize: cubit.textInfo[i].widgetSize,
                          screenSize: Size((MediaQuery.sizeOf(context).width * MediaQuery.of(context).devicePixelRatio),
                              (MediaQuery.sizeOf(context).height * MediaQuery.of(context).devicePixelRatio)),
                          videoSize: Size(cubit.videoWidth, cubit.videoHeight),
                        ),
                        context: context,
                        delay: const Duration(milliseconds: 200));
                  }
                  final directory = await getTemporaryDirectory();
                  final pathOfImage =
                      await File('${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png').create();
                  if (imageData != null) {
                    await pathOfImage.writeAsBytes(imageData);
                    textList.add(
                      TextEditingInfo(
                        imagePath: pathOfImage.path,
                        xPos: cubit.textInfo[i].xPercent,
                        yPos: cubit.textInfo[i].yPercent,
                      ),
                    );
                  }
                }

                await pl.hide();
                if (mounted) {
                  Navigator.pushReplacement(
                    textEdiorCtx,
                    MaterialPageRoute(
                      builder: (_) => VideoEditor(
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
        },
      ),
    );
  }
}
