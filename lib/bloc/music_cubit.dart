import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class MusicCubit extends Cubit<PlayerController> {
  MusicCubit() : super(PlayerController());

  Stream<List<double>> get waveStream => state.onCurrentExtractedWaveformData;
  Stream<int> get currentDurationStream => state.onCurrentDurationChanged;

  Future<void> playMusic(String url) async {
    if (state.playerState == PlayerState.playing) return;
    if (state.playerState == PlayerState.paused) {
      state.startPlayer(forceRefresh: false);
    }
    print("Playing music from URL: $url");
    try {
      // Step 1: Download the audio file
      final tempFile = await _downloadAudio(url);

      // Step 2: Load the player with the downloaded file path
      await state.preparePlayer(
          path: tempFile.path, shouldExtractWaveform: true);

      await state.startPlayer();
      emit(state);
    } catch (e) {
      print("Error: $e");
    }
  }

  // Download the audio file to a local temporary path
  Future<File> _downloadAudio(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final appDirectory = await getApplicationDocumentsDirectory();
      final file = File('${appDirectory.path}/temp_audio.mp3');
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      throw Exception("Failed to download audio.");
    }
  }

  Future<void> pauseMusic() async {
    await state.pausePlayer();
    emit(state);
  }

  Future<void> stopMusic() async {
    await state.stopPlayer();
    emit(state);
  }
}
