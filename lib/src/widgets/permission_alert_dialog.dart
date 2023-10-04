import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> showPermissionDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Permission required'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('To record video app requires camera and microphone permisson'),
              Text('please provide permission to access this feature'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () async {
              Map<Permission, PermissionStatus> statuses = await [
                Permission.camera,
                Permission.microphone,
              ].request();

              if (statuses[Permission.camera] == PermissionStatus.permanentlyDenied ||
                  statuses[Permission.microphone] == PermissionStatus.permanentlyDenied) {
                await Permission.camera.status;
                await openAppSettings();
              }
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}
