import 'dart:io';

import 'package:dio/dio.dart';
import 'package:example/progress_loader.dart';
import 'package:flutter/material.dart';

Future<bool> uploadFile({
  required String url,
  required File file,
  required BuildContext context,
  CancelToken? cancelToken,
}) async {
  final pl = ProgressLoader(context, isDismissible: false, title: 'Uploading...');
  await pl.show();
  final baseOptions = BaseOptions(
    connectTimeout: const Duration(minutes: 10),
    sendTimeout: const Duration(minutes: 10),
    receiveTimeout: const Duration(minutes: 10),
    contentType: 'video/mp4',
    headers: {
      'Content-Length': file.lengthSync(),
    },
  );

  final dio = Dio(baseOptions);

  final data = await dio.put<Map<String, dynamic>>(
    url,
    data: file.openRead(),
    cancelToken: cancelToken,
    onSendProgress: (count, total) {
      pl.updateLoaderValue(((count / total) * 100).toInt());
    },
  ).then(
    (value) => true,
    onError: (Object error) async {
      await pl.hide();
      return false;
    },
  ).onError((error, stackTrace) async {
    await pl.hide();
    return false;
  });
  await pl.hide();
  return data;
}

Future<Map<String, dynamic>?> getUrls(BuildContext context) async {
  final pl = ProgressLoader(context, isDismissible: false, title: 'fetching...');
  await pl.show();
  try {
    final data = await Dio().post(
      'https://dev-api-tk.soundit.com/api/v5/aws/get_signed_demo_url',
      onReceiveProgress: (count, total) {
        pl.updateLoaderValue(((count / total) * 100).toInt());
      },
    );
    debugPrint(data.data.toString());
     await pl.hide();
    return data.data;
  } catch (e) {
    debugPrint(e.toString());
  }
  await pl.hide();
  return null;
}
