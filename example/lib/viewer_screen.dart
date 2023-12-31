import 'dart:io';
import 'dart:math';

import 'package:example/audio_timmer_viewer.dart';
import 'package:example/helpers/dio_file_upload.dart';
import 'package:example/helpers/ffmpeg_handler.dart';
import 'package:example/main.dart';
import 'package:example/models/editing_info.dart';
import 'package:example/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';

class ViewerScreen extends StatefulWidget {
  const ViewerScreen({
    super.key,
    required this.editingInfo,
  });
  final EditingInfo editingInfo;

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> with FFMPEGHandler {
  String? compressedVideoPath;
  String? compressedVideoSize;
  String? ogVideoSize;
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      await runCommand();
      // if (mounted) {
      //   final thumbnail = await FFMPEGHandler.generateThumbnail(
      //       widget.videoPath, '${path.path}/${DateTime.now().millisecondsSinceEpoch}.png', context);
      //   await OpenFile.open(thumbnail);
      // }
    });
  }

  Future<void> runCommand() async {
    final fileName = widget.editingInfo.videoEditingInfo.path.split('/').last.split('.').first;
    final format = widget.editingInfo.videoEditingInfo.path.split('/').last.split('.').last;
    final path = await getTemporaryDirectory();
    if (mounted) {
      // compressedVideoPath = await FFMPEGHandler.compressVideo(
      //   widget.editingInfo.videoEditingInfo.path,
      //   '${path.path}/${fileName}01.$format',
      //   context,
      // );
      List<String>? data = await processVideoWithTrimming(
        outputVideoPath: '${path.path}/${fileName}01.$format',
        thumbnailPath: '${path.path}/${fileName}02.png',
        context: context,
        info: widget.editingInfo,
        completeCallback: (p0) {
          debugPrint('+++++++++++++++++++++++++');
        },
        logCallback: (p0) {},
        statisticsCallback: (p0) {},
      );

      ogVideoSize = await getFileSize(widget.editingInfo.videoEditingInfo.path, 1);
      if (data != null) {
        compressedVideoSize = await getFileSize(data[0], 1);
        debugPrint((await File(data[0]).exists()).toString());
        compressedVideoPath = data[0];
      }
      setState(() {});
    }
  }

  Future<String> getFileSize(String filepath, int decimals) async {
    var file = File(filepath);
    int bytes = await file.length();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(compressedVideoPath);
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () async {
                final urls = await getUrls(context);
                if (urls != null && mounted && compressedVideoPath != null) {
                  await uploadFile(url: urls['data']['uploadUrl'], file: File(compressedVideoPath!), context: context);
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyHomePage(title: 'title'),
                        ),
                        (route) => false);
                  }
                }
              },
              child: const Text('Upload'),
            ),
            const SizedBox(
              height: 6,
            ),
            ElevatedButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.audio,
                  allowCompression: false,
                );
                if (result != null) {
                  File file = File(result.files.single.path!);
                  if (mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return AudioTrimmerView(file);
                      }),
                    );
                  }
                }
              },
              child: const Text('select audio'),
            ),
            // Image.file(
            //   File(widget.thumbnail),
            //   height: 200,
            //   width: 100,
            // ),
            const SizedBox(
              height: 8,
            ),
            Text(ogVideoSize ?? ''),
            Expanded(
              key: UniqueKey(),
              child: GestureDetector(
                  onTap: () async {
                    await OpenFile.open(widget.editingInfo.videoEditingInfo.path);
                  },
                  child: VideoPlayerWidget(filePath: widget.editingInfo.videoEditingInfo.path)),
            ),
            const SizedBox(
              height: 8,
            ),
            if (compressedVideoPath != null) ...[
              Text(compressedVideoSize ?? ''),
              Expanded(
                  child: GestureDetector(
                onTap: () async {
                  await OpenFile.open(compressedVideoPath!);
                },
                key: UniqueKey(),
                child: VideoPlayerWidget(filePath: compressedVideoPath!),
              )),
            ],
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'ss',
          onPressed: () async {
            await runCommand();
          },
        ),
      ),
    );
  }
}
