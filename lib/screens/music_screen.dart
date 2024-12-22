import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_assignment/bloc/music_cubit.dart';

class MusicScreen extends StatelessWidget {
  const MusicScreen({super.key});

  String _formatDuration(Duration? duration) {
    if (duration == null) return "00:00";
    String minutes = duration.inMinutes.toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final musicCubit = BlocProvider.of<MusicCubit>(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/background.jpg',
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          ),

          // Positioned container at the bottom with gradient
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 368,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: const [
                    Color(0xFF2A2A2A),
                    Color(0xFF646464),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(40),
                  topRight: const Radius.circular(40),
                ),
              ),
              child: BlocBuilder<MusicCubit, PlayerController>(
                  builder: (context, playerController) {
                final bool isPlaying =
                    playerController.playerState == PlayerState.playing;
                final bool isPaused =
                    playerController.playerState == PlayerState.paused;
                final bool isStopped =
                    playerController.playerState == PlayerState.stopped;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 0, 4),
                      child: const Text(
                        'Instant Crush',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: const Text(
                        'feat. Julian Casablancas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Audio waveform above the play button
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            StreamBuilder<List<double>>(
                                stream: playerController
                                    .onCurrentExtractedWaveformData,
                                builder: (context, snapshot) {
                                  return AudioFileWaveforms(
                                    waveformData: snapshot.data ?? [],
                                    playerController: playerController,
                                    size: Size(
                                        MediaQuery.of(context).size.width - 48,
                                        100),
                                  );
                                }),
                            SizedBox(height: 16),

                            // Display position and duration
                            StreamBuilder<int>(
                                stream:
                                    playerController.onCurrentDurationChanged,
                                builder: (context, snapshot) {
                                  return Text(
                                    _formatDuration(Duration(
                                        milliseconds: snapshot.data ?? 0)),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  );
                                }),
                            SizedBox(height: 16),

                            // Play/Pause Button
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 185, 184, 184),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: IconButton(
                                iconSize: 30,
                                onPressed: () {
                                  if (isPlaying) {
                                    musicCubit.pauseMusic();
                                  } else if (isPaused || isStopped) {
                                    musicCubit.playMusic(
                                        "https://codeskulptor-demos.commondatastorage.googleapis.com/descent/background%20music.mp3");
                                  }
                                },
                                color: Color(0xFF2A2A2A),
                                icon: Icon(
                                  isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
