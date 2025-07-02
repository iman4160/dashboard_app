// speaker_screen.dart
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart'; // For playing audio from various sources
import 'package:audio_session/audio_session.dart'; // For managing audio session
import 'dart:io'; // For checking device file existence
import 'package:get_storage/get_storage.dart'; // IMPORTANT: Added for GetStorage
import 'package:dashboard/microphone_screen.dart'; // Import to use RecordedAudio model

class AudioSourceItem {
  String title; // Made mutable (removed final)
  String url; // Made mutable (removed final)
  final AudioSourceType type;
  AudioPlayer? player; // Each item will have its own player
  ProcessingState _processingState = ProcessingState.idle;

  AudioSourceItem({
    required this.title,
    required this.url,
    required this.type,
  });

  // Get the current playback status
  bool get isPlaying => player?.playerState.playing == true;
  ProcessingState get processingState => _processingState;

  void updateProcessingState(ProcessingState state) {
    _processingState = state;
  }
}

enum AudioSourceType { asset, network, deviceFile }

class SpeakerScreen extends StatefulWidget {
  const SpeakerScreen({super.key});

  @override
  State<SpeakerScreen> createState() => _SpeakerScreenState();
}

class _SpeakerScreenState extends State<SpeakerScreen> {
  // Define your audio sources
  late List<AudioSourceItem> _audioSources;

  @override
  void initState() {
    super.initState();
    _initializeAudioSources();
    _initAudioSession();
  }

  // Initialize audio session for proper audio behavior
  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  void _initializeAudioSources() {
    _audioSources = [
      AudioSourceItem(
        title: 'Sample Asset Audio (App Bundle)',
        url: 'audios/sample_audio.mp3', // You need to add this asset
        type: AudioSourceType.asset,
      ),
      AudioSourceItem(
        title: 'Network Audio (Bensound - Happy Rock)',
        url: 'https://www.bensound.com/bensound-music/bensound-happyrock.mp3',
        type: AudioSourceType.network,
      ),
      AudioSourceItem(
        title: 'Device File Audio (First Recorded Audio)',
        url: '', // This will be populated dynamically from recorded audios
        type: AudioSourceType.deviceFile,
      ),
    ];
  }

  @override
  void dispose() {
    // Dispose all players when the screen is removed
    for (var item in _audioSources) {
      item.player?.dispose();
    }
    super.dispose();
  }

  Future<void> _togglePlayPause(AudioSourceItem item) async {
    // Stop any other currently playing audio
    for (var otherItem in _audioSources) {
      if (otherItem != item && otherItem.player?.playerState.playing == true) {
        await otherItem.player?.stop();
        setState(() {
          otherItem.updateProcessingState(ProcessingState.idle);
        });
      }
    }

    if (item.player == null) {
      item.player = AudioPlayer();
      item.player?.playerStateStream.listen((playerState) {
        setState(() {
          item.updateProcessingState(playerState.processingState);
        });
        if (playerState.processingState == ProcessingState.completed) {
          item.player?.stop(); // Stop explicitly when completed
        }
      });
    }

    if (item.isPlaying) {
      await item.player?.pause();
    } else {
      try {
        if (item.processingState == ProcessingState.completed) {
          // If completed, seek to start before playing again
          await item.player?.seek(Duration.zero);
        }
        if (item.type == AudioSourceType.asset) {
          await item.player?.setAsset(item.url);
        } else if (item.type == AudioSourceType.network) {
          await item.player?.setUrl(item.url);
        } else if (item.type == AudioSourceType.deviceFile) {
          // For device file, ensure the path exists and is set
          if (item.url.isEmpty || !await File(item.url).exists()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Device file not found or not recorded yet.')),
            );
            setState(() {
              item.updateProcessingState(ProcessingState.idle);
            });
            return;
          }
          await item.player?.setFilePath(item.url);
        }
        await item.player?.play();
      } catch (e) {
        print('Error playing audio from ${item.type}: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing audio: $e')),
        );
        setState(() {
          item.updateProcessingState(ProcessingState.idle); // Reset state on error
        });
      }
    }
  }

  // Helper to get the path of the first recorded audio for the device file example
  Future<String> _getFirstRecordedAudioPath() async {
    final GetStorage box = GetStorage();
    final List<dynamic>? storedAudiosJson = box.read('recorded_audios');
    if (storedAudiosJson != null && storedAudiosJson.isNotEmpty) {
      final RecordedAudio firstAudio = RecordedAudio.fromJson(storedAudiosJson.first);
      return firstAudio.path;
    }
    return ''; // Return empty string if no recorded audios
  }


  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Theme.of(context).primaryColor;
    final Color accentBlue = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Speaker',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryGreen,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.volume_up, size: 80, color: accentBlue.withOpacity(0.7)),
            const SizedBox(height: 20),
            Text(
              'Play audio from various sources:',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            FutureBuilder<String>(
              future: _getFirstRecordedAudioPath(),
              builder: (context, snapshot) {
                // Update the device file audio source URL and title
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  final deviceFileItem = _audioSources.firstWhere((item) => item.type == AudioSourceType.deviceFile);
                  deviceFileItem.url = snapshot.data!;
                  deviceFileItem.title = snapshot.data!.isNotEmpty
                      ? 'Device File Audio: ${snapshot.data!.split('/').last}'
                      : 'Device File Audio (No recording found)';
                }
                return Column(
                  children: _audioSources.map((item) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 2,
                      child: ListTile(
                        leading: _buildLeadingIcon(item.type, primaryGreen, accentBlue),
                        title: Text(item.title),
                        subtitle: StreamBuilder<PlayerState>(
                          stream: item.player?.playerStateStream,
                          builder: (context, playerSnapshot) {
                            final playerState = playerSnapshot.data;
                            final playing = playerState?.playing;
                            final processingState = playerState?.processingState;

                            String statusText = 'Tap to play';
                            if (playing == true) {
                              statusText = 'Playing...';
                            } else if (processingState == ProcessingState.buffering) {
                              statusText = 'Buffering...';
                            } else if (processingState == ProcessingState.loading) {
                              statusText = 'Loading...';
                            } else if (processingState == ProcessingState.completed) {
                              statusText = 'Finished';
                            }
                            return Text(statusText);
                          },
                        ),
                        trailing: StreamBuilder<PlayerState>(
                          stream: item.player?.playerStateStream,
                          builder: (context, playerSnapshot) {
                            final playerState = playerSnapshot.data;
                            final playing = playerState?.playing;
                            final processingState = playerState?.processingState;

                            if (processingState == ProcessingState.loading ||
                                processingState == ProcessingState.buffering) {
                              return const CircularProgressIndicator();
                            }
                            return IconButton(
                              icon: Icon(
                                playing == true ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                color: playing == true ? Colors.grey : primaryGreen,
                                size: 30,
                              ),
                              onPressed: () => _togglePlayPause(item),
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(AudioSourceType type, Color primaryGreen, Color accentBlue) {
    switch (type) {
      case AudioSourceType.asset:
        return Icon(Icons.folder, color: accentBlue);
      case AudioSourceType.network:
        return Icon(Icons.cloud, color: primaryGreen);
      case AudioSourceType.deviceFile:
        return Icon(Icons.smartphone, color: accentBlue);
    }
  }
}

// Re-using the RecordedAudio model from microphone_screen.dart for consistency
// You might put this in a shared models file if you prefer
class RecordedAudio {
  String name;
  String path;
  Duration duration;

  RecordedAudio({
    required this.name,
    required this.path,
    this.duration = Duration.zero,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'path': path,
    'durationMicroseconds': duration.inMicroseconds,
  };

  factory RecordedAudio.fromJson(Map<String, dynamic> json) => RecordedAudio(
    name: json['name'] as String,
    path: json['path'] as String,
    duration: Duration(microseconds: json['durationMicroseconds'] as int? ?? 0),
  );
}
