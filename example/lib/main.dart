// import 'dart:io';

import 'dart:io';

import 'package:custom_cam/custom_cam.dart';
import 'package:example/text_editor/text_video_editor.dart';
import 'package:ffmpeg_kit_flutter_min_gpl/ffmpeg_kit_config.dart';
import 'package:file_picker/file_picker.dart';
// import 'package:example/video_editor/video_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

late final RootIsolateToken isolateToken;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FFmpegKitConfig.setFontDirectory(Platform.isAndroid ? '/system/fonts' : '/System/Library/Fonts');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom cam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.grey,
        brightness: Brightness.dark,
        tabBarTheme: const TabBarTheme(
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
        useMaterial3: true,
        dividerColor: Colors.white,
      ),
      home: const MyHomePage(title: 'Custom cam'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ResolutionPreset selectedRes = ResolutionPreset.high;
  List<ResolutionPreset> resolutionOptions = ResolutionPreset.values;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomCamScreen(
                      settings: CamSettings(resolution: selectedRes, videoTimeoutSeconds: 300),
                      onSuccess: (videoPath) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            // builder: (context) => VideoEditor(file: File(videoPath)),
                            builder: (context) => TextVideoEditor(path: videoPath),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              child: const Text('camera'),
            ),
            const SizedBox(
              height: 6,
            ),
            DropdownMenu<ResolutionPreset>(
              initialSelection: selectedRes,
              onSelected: (ResolutionPreset? value) {
                // This is called when the user selects an item.
                setState(() {
                  selectedRes = value!;
                });
              },
              dropdownMenuEntries: resolutionOptions.map<DropdownMenuEntry<ResolutionPreset>>((ResolutionPreset value) {
                return DropdownMenuEntry<ResolutionPreset>(value: value, label: value.name);
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.video,
                  allowCompression: false,
                );
                if (mounted && result != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TextVideoEditor(path: result.files.first.path!),
                    ),
                  );
                }
              },
              child: const Text('video file'),
            ),
          ],
        ),
      ),
    );
  }
}
