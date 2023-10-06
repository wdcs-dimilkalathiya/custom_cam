import 'package:custom_cam/custom_cam.dart';
import 'package:example/viewer_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
                      settings: CamSettings(resolution: selectedRes, videoTimeoutSeconds: 180),
                      onSuccess: (videoPath) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewerScreen(videoPath: videoPath),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                );
              },
              child: const Text('Start'),
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
          ],
        ),
      ),
    );
  }
}
