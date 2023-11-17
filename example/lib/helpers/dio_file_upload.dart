import 'dart:io';

import 'package:dio/dio.dart';
import 'package:example/helpers/progress_loader.dart';
import 'package:flutter/material.dart';

Future<bool> uploadFile({
  required String url,
  required File file,
  required BuildContext context,
  required String mimeType,
  CancelToken? cancelToken,
}) async {
  final pl = ProgressLoader(context, isDismissible: false, title: 'Uploading...');
  await pl.show();
  final baseOptions = BaseOptions(
    connectTimeout: const Duration(minutes: 10),
    sendTimeout: const Duration(minutes: 10),
    receiveTimeout: const Duration(minutes: 10),
    contentType: mimeType,
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
    // Define your headers
    Map<String, dynamic> headers = {
      'api-key': 'ffc794383684a6051bb31656d07bc446db869a5903dc8cd455fb12179d5de6ea',
      'accept-language': 'en',
      'app-type': 'ZIZ_MOBILE',
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMTMiLCJpYXQiOjE2OTg2Njk2MTcsImV4cCI6MTcyOTQyODAxN30.xff8Yqec4OHROxEvbVf0d0GZzTrGqHnf5xxqF6ZpR7M' // Example content type header
    };
    final data = await Dio().post(
      'https://devapi.zizle.com/api/v1/medias/aws/get_signed_url',
      data: {"main_folder": "communities", "sub_folder": "videos", "file_extension": "mp4", "mime_type": "video/mp4"},
      options: Options(headers: headers),
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

Future<Map<String, dynamic>?> getUrlsThumbnails(BuildContext context) async {
  final pl = ProgressLoader(context, isDismissible: false, title: 'fetching...');
  await pl.show();
  try {
    // Define your headers
    Map<String, dynamic> headers = {
      'api-key': 'ffc794383684a6051bb31656d07bc446db869a5903dc8cd455fb12179d5de6ea',
      'accept-language': 'en',
      'app-type': 'ZIZ_MOBILE',
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMTMiLCJpYXQiOjE2OTg2Njk2MTcsImV4cCI6MTcyOTQyODAxN30.xff8Yqec4OHROxEvbVf0d0GZzTrGqHnf5xxqF6ZpR7M' // Example content type header
    };
    final data = await Dio().post(
      'https://devapi.zizle.com/api/v1/medias/aws/get_signed_url',
      data: {"main_folder": "communities", "sub_folder": "thumbs", "file_extension": "png", "mime_type": "image/png"},
      options: Options(headers: headers),
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

Future<Map<String, dynamic>?> uploadUrls(
    {required BuildContext context, required String url, required String thumbUrl}) async {
  final pl = ProgressLoader(context, isDismissible: false, title: 'uploading...');
  debugPrint("Thumb url : $thumbUrl :::: $url");
  await pl.show();
  try {
    // Define your headers

    // String thumbUrl = getThumbUrl(url: url);
    Map<String, dynamic> headers = {
      'api-key': 'ffc794383684a6051bb31656d07bc446db869a5903dc8cd455fb12179d5de6ea',
      'accept-language': 'en',
      'app-type': 'ZIZ_MOBILE',
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxMywiaWF0IjoxNjk5MzU4MTIzLCJleHAiOjE3MzAxMTY1MjN9.UyQ_70JG4emIMHzG8ShjNC68VFrO46iGTlKtVWBWX10' // Example content type header
    };
    final data = await Dio().post(
      'https://devapi.zizle.com/api/v1/spotlight/create_post',
      data: {"video_url": url, "thumb_image": thumbUrl},
      options: Options(headers: headers),
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

String getThumbUrl({required String url}) {
  String thumb = '';
  thumb = url.replaceFirst("videos", "thumbs");
  debugPrint("Thumb Url : $thumb");
  return thumb;
}
