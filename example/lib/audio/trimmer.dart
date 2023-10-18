import 'dart:async';
import 'dart:io';
import 'package:just_audio/just_audio.dart';

enum TrimmerEvent { initialized, update }

/// Helps in loading audio from file, saving trimmed audio to a file
/// and gives audio playback controls. Some of the helpful methods
/// are:
/// * [loadAudio()]
/// * [saveTrimmedAudio)]
/// * [audioPlaybackControl()]
class Trimmer {
  // final FlutterFFmpeg _flutterFFmpeg = FFmpegKit();

  final StreamController<TrimmerEvent> _controller =
      StreamController<TrimmerEvent>.broadcast();

  AudioPlayer? _audioPlayer;

  AudioPlayer? get audioPlayer => _audioPlayer;

  File? currentAudioFile;

  /// Listen to this stream to catch the events
  Stream<TrimmerEvent> get eventStream => _controller.stream;

  /// Loads a audio using the path provided.
  ///
  /// Returns the loaded audio file.
  Future<void> loadAudio({required File audioFile}) async {
    currentAudioFile = audioFile;
    if (audioFile.existsSync()) {
      _audioPlayer = AudioPlayer();
      await _audioPlayer?.setFilePath(audioFile.path);
      _controller.add(TrimmerEvent.initialized);
    }
  }

  void callUpdateEvent() {
    _controller.sink.add(TrimmerEvent.update);
  }

  /// For getting the audio controller state, to know whether the
  /// audio is playing or paused currently.
  ///
  /// The two required parameters are [startValue] & [endValue]
  ///
  /// * [startValue] is the current starting point of the audio.
  /// * [endValue] is the current ending point of the audio.
  ///
  /// Returns a `Future<bool>`, if `true` then audio is playing
  /// otherwise paused.
  Future<bool> audioPlaybackControl({
    required double startValue,
    required double endValue,
  }) async {
    if (audioPlayer?.playing ?? false) {
      await audioPlayer?.pause();
      return false;
    } else {
      var duration = audioPlayer!.position;
      if ((duration.inMilliseconds) >= endValue.toInt()) {
        await audioPlayer!.seek(Duration(milliseconds: startValue.toInt()));
        await audioPlayer!.play();
        return true;
      } else {
        await audioPlayer!.play();
        return true;
      }
    }
  }

  /// Clean up
  void dispose() {
    _controller.close();
  }
}
