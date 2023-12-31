import 'dart:async';
import 'dart:io';

import 'package:example/helpers/progress_loader.dart';
import 'package:example/models/editing_info.dart';
import 'package:example/models/text_editing_info.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/log.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/media_information.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/return_code.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/session.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/statistics.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

mixin FFMPEGHandler {
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

  Future<List<String>?> processVideoWithTrimming(
      {required String outputVideoPath,
      required String thumbnailPath,
      required BuildContext context,
      required EditingInfo info,
      void Function(Session)? completeCallback,
      void Function(Log)? logCallback,
      void Function(Statistics)? statisticsCallback}) async {
    final streamController = StreamController<List<String>?>();
    final pl = ProgressLoader(context, isDismissible: false, title: 'Processing....');
    await pl.show();
    // final xPos = (info.textEditingInfo!.xPos / 100) * 720;
    // final yPos = (info.textEditingInfo!.yPos / 100) * 1280;

    // final containerX = xPos;
    // final containerY = yPos;

    // Calculate normalized X and Y coordinates
    // const textPlace =
    //     'System fonts on Android are stored under the /system/fonts folder. You can use those fonts in your ffmpeg commands by registering /system/fonts as a font directory via the FFmpegKitConfig.setFontDirectory methods';
    /// Add below line if you like to generate text overlay without passing image.
    /// ' -vf "scale=720:-1,drawtext=text=\'$textPlace\':x=100:y=100:fontsize=24:fontcolor=white:box=1:boxcolor=white@0.5:boxborderw=5"'
    final ffmpegCommand = ''
        ' -ss ${info.videoEditingInfo.startTrim}'
        ' -i ${info.videoEditingInfo.path}'
        ' -t ${((info.videoEditingInfo.editedVideoDuration.inMilliseconds / 1000)).toStringAsFixed(2)}'
        '${info.audioEditingInfo == null ? '' : ' -ss ${info.audioEditingInfo!.startTrim}'}'
        '${info.audioEditingInfo == null ? '' : ' -i ${info.audioEditingInfo?.path}'}'
        '${info.audioEditingInfo == null ? '' : ' -t ${((info.videoEditingInfo.editedVideoDuration.inMilliseconds) / 1000).toStringAsFixed(2)}'}'
        '${info.textEditingInfo == null ? '' : info.textEditingInfo!.fold('', (previousValue, element) => '$previousValue -i ${element.imagePath}')}'
        '${info.textEditingInfo == null ? ' -vf "scale=${info.isVideoHorizontal ? 1280 : 720}:-1"' : buildFilterComplex(info.textEditingInfo!,info, hasAudio: info.audioEditingInfo != null)}'
        '${info.textEditingInfo == null ? '' : ' -map "[v${info.textEditingInfo!.length + 1}]"'}'
        '${info.audioEditingInfo == null && info.textEditingInfo == null ? ' -map 0' : (info.audioEditingInfo == null) ? ' -map 0:a?' : ' -map 1:a'}'
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
    await FFmpegKit.executeAsync(
        ffmpegCommand,
        (Session session) async {
          completeCallback?.call(session);
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
            debugPrint('=========== error2 ========');
            streamController.sink.add(null);
            await pl.hide();
          }
        },
        logCallback,
        (Statistics statistics) {
          statisticsCallback?.call(statistics);
          if (statistics.getTime() > 0) {
            pl.updateLoaderValue(
                (statistics.getTime() / 10) ~/ ((info.videoEditingInfo.editedVideoDuration).inMilliseconds / 1000));
          }
        });
    final result = await streamController.stream.first;
    streamController.close();
    return result;
  }

  static String buildFilterComplex(List<TextEditingInfo> overlayInfos, EditingInfo info, {bool hasAudio = true}) {
    if (overlayInfos.isEmpty) {
      return ''; // Return an empty string if there are no images or overlay information.
    }

    // Initialize the filterComplex string with the first video scaling operation.
    String filterComplex = ' -filter_complex "[0:v]scale=${info.isVideoHorizontal ? 1280 : 720}:-1[v1];';

    for (int i = 1; i <= overlayInfos.length; i++) {
      // Get the current image path and overlay information.
      TextEditingInfo overlayInfo = overlayInfos[i - 1];

      // Build the overlay filter part for the current image and append it to the filterComplex string.
      filterComplex +=
          '[${'v$i'}][${(!hasAudio) ? i : i + 1}:v]overlay=x=${overlayInfo.xPos}:y=${overlayInfo.yPos}[v${i + 1}];';
    }
    filterComplex = filterComplex.substring(0, filterComplex.length - 1);
    filterComplex += '"';

    return filterComplex;
  }

  Future<MediaInformation?> getMediaInfo(String path) async {
    final mediaInfo = await FFprobeKit.getMediaInformation(path);
    final info = mediaInfo.getMediaInformation();
    return info;
  }

  Future<bool> hasAudioInVideo(String path) async {
    final mediaInfo = await FFprobeKit.getMediaInformation(path);
    final info = mediaInfo.getMediaInformation();
    if (info == null) {
      return false;
    } else {
      for (var stream in info.getStreams()) {
        if (stream.getCodec() == 'audio') {
          return true;
        }
      }
    }
    return false;
  }
}
