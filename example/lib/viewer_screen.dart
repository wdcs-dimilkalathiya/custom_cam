import 'dart:io';
import 'dart:math';

import 'package:example/dio_file_upload.dart';
import 'package:example/ffmpeg_handler.dart';
import 'package:example/main.dart';
import 'package:example/video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';

class ViewerScreen extends StatefulWidget {
  const ViewerScreen({
    super.key,
    required this.thumbnail,
    required this.videoPath,
  });
  final String thumbnail;
  final String videoPath;

  @override
  State<ViewerScreen> createState() => _ViewerScreenState();
}

class _ViewerScreenState extends State<ViewerScreen> {
  String? compressedVideoPath;
  String? compressedVideoSize;
  String? ogVideoSize;
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      final fileName = widget.videoPath.split('/').last.split('.').first;
      final format = widget.videoPath.split('/').last.split('.').last;
      final path = await getTemporaryDirectory();
      if (mounted) {
        compressedVideoPath = await FFMPEGHandler.compressVideo(
          widget.videoPath,
          '${path.path}/${fileName}01.$format',
          context,
        );
        debugPrint('compressedVideoPath');
        debugPrint(compressedVideoPath);
        ogVideoSize = await getFileSize(widget.videoPath, 1);
        if (compressedVideoPath != null) {
          compressedVideoSize = await getFileSize(compressedVideoPath!, 1);
          print(await File(compressedVideoPath!).exists());
        }
        setState(() {});
      }
    });
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
                    await OpenFile.open(widget.videoPath);
                  },
                  child: VideoPlayerWidget(filePath: widget.videoPath)),
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
      ),
    );
  }
}
