import 'dart:async';
import 'dart:io';

import 'package:example/helpers/progress_loader.dart';
import 'package:example/models/editing_info.dart';
import 'package:ffmpeg_kit_flutter_https_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_https_gpl/log.dart';
import 'package:ffmpeg_kit_flutter_https_gpl/return_code.dart';
import 'package:ffmpeg_kit_flutter_https_gpl/session.dart';
import 'package:ffmpeg_kit_flutter_https_gpl/statistics.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FFMPEGHandler {
  static Future<String?> compressVideo(
    String inputPath,
    String outputPath,
    BuildContext context,
  ) async {
    final stream = StreamController<String?>();
    final VideoPlayerController controller = VideoPlayerController.file(File(inputPath));
    final pl = ProgressLoader(context, isDismissible: false, title: 'Compressing...');
    await pl.show();
    await controller.initialize();
    int videoInMiliseconds = controller.value.duration.inMilliseconds;
    controller.dispose();

    final argument = '-i $inputPath'
        // ' -hwaccel opencl'
        ' -vf "scale=720:-1"'
        ' -c:v libx264'
        ' -c:a aac'
        ' -ac 2'
        ' -pix_fmt yuv420p'
        ' -r 30'
        ' -g 6'
        ' -b:v 1M'
        ' -maxrate 1M'
        ' -tune fastdecode'
        ' -preset ultrafast'
        ' -vsync -1'
        ' -crf 23 $outputPath';

    await FFmpegKit.executeAsync(argument, (Session session) async {
      debugPrint('Logs:${await session.getLogsAsString()}');

      // CALLED WHEN SESSION IS EXECUTED
      final returnCode = await session.getReturnCode();
      await pl.hide();
      pl.updateTile('Uplading...');
      if (ReturnCode.isSuccess(returnCode)) {
        // SUCCESS
        // pl.updateLoaderValue(1);
        // await pl.show();
        debugPrint('api call');
        debugPrint(inputPath);
        debugPrint(outputPath);
        await pl.hide();
        stream.sink.add(outputPath);
      } else if (ReturnCode.isCancel(returnCode)) {
        // CANCEL
        stream.sink.add(null);
        await pl.hide();
      } else {
        // ERROR
        stream.sink.add(null);
        await pl.hide();
      }
    }, (Log log) {
      // CALLED WHEN SESSION PRINTS LOGS
    }, (Statistics statistics) {
      if (statistics.getTime() > 0) {
        pl.updateLoaderValue((statistics.getTime() / 10) ~/ (videoInMiliseconds / 1000));
      }
    });
    final result = await stream.stream.first;
    stream.close();
    return result;
  }

  static Future<String?> generateThumbnail(String videoPath, String thumbSavePath, BuildContext context) async {
    final ffmpegCommand = '-i $videoPath -vf "select=eq(n\\,0)" -vframes 1 $thumbSavePath';
    final streamController = StreamController<String?>();
    final pl = ProgressLoader(context, isDismissible: false, title: 'Generating thumbnail');
    await pl.show();
    await FFmpegKit.executeAsync(
      ffmpegCommand,
      (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          debugPrint('Thumbnail generated successfully: ${await session.getOutput()}');
          await pl.hide();
          streamController.sink.add(thumbSavePath);
        } else {
          await pl.hide();
          streamController.sink.add(null);
          debugPrint('Error generating thumbnail');
        }
      },
      (log) {},
      (statistics) {},
    );
    debugPrint('====videoPath');
    debugPrint(videoPath);
    debugPrint('=====thumbSavePath');
    debugPrint(thumbSavePath);
    final result = await streamController.stream.first;
    streamController.close();
    return result;
  }

  static Future<List<String>?> processVideoWithTrimming({
    required String outputVideoPath,
    required String thumbnailPath,
    required BuildContext context,
    required EditingInfo info,
  }) async {
    final streamController = StreamController<List<String>?>();
    final pl = ProgressLoader(context, isDismissible: false, title: 'Processing....');
    await pl.show();
    final ffmpegCommand = ''
        ' -ss ${info.videoEditingInfo.startTrim}'
        ' -i ${info.videoEditingInfo.path}'
        ' -t ${((info.videoEditingInfo.editedVideoDuration.inMilliseconds / 1000)).toStringAsFixed(2)}'
        ' -ss ${info.audioEditingInfo!.startTrim}'
        ' -i ${info.audioEditingInfo?.path}'
        ' -t ${((info.videoEditingInfo.editedVideoDuration.inMilliseconds) / 1000).toStringAsFixed(2)}'
        ' -vf "scale=720:-1"'
        ' -c:v libx264'
        ' -c:a aac'
        ' -ac 2'
        ' -pix_fmt yuv420p'
        ' -r 30'
        ' -g 6'
        ' -b:v 1M'
        ' -maxrate 1M'
        ' -tune fastdecode'
        ' -preset medium'
        ' -vsync -1'
        ' -crf 23'
        ' -y $outputVideoPath';
    debugPrint('=========== error logs ========');
    debugPrint(ffmpegCommand);
    await FFmpegKit.executeAsync(ffmpegCommand, (Session session) async {
      debugPrint('Logs:${await session.getLogsAsString()}');

      // CALLED WHEN SESSION IS EXECUTED
      final returnCode = await session.getReturnCode();
      await pl.hide();
      if (ReturnCode.isSuccess(returnCode)) {
        await pl.hide();
        streamController.sink.add([outputVideoPath, thumbnailPath]);
      } else if (ReturnCode.isCancel(returnCode)) {
        // CANCEL
        streamController.sink.add(null);
        await pl.hide();
      } else {
        // ERROR
        debugPrint('=========== error logs ========');
        debugPrint(ffmpegCommand);
        debugPrint(await session.getLogsAsString());
        streamController.sink.add(null);
        await pl.hide();
      }
    }, (Log log) {
      // CALLED WHEN SESSION PRINTS LOGS
    }, (Statistics statistics) {
      if (statistics.getTime() > 0) {
        pl.updateLoaderValue(
            (statistics.getTime() / 10) ~/ ((info.videoEditingInfo.editedVideoDuration).inMilliseconds / 1000));
      }
    });
    final result = await streamController.stream.first;
    streamController.close();
    return result;
  }
}
