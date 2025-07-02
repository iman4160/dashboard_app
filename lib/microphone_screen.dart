// microphone_screen.dart
import 'package:flutter/material.dart';
import 'package:record/record.dart'; // For recording audio
import 'package:path_provider/path_provider.dart'; // For getting app document directory
import 'package:just_audio/just_audio.dart'; // For playing recorded audio
import 'package:get_storage/get_storage.dart'; // To save and load recorded file paths
import 'dart:io'; // For File operations
import 'package:permission_handler/permission_handler.dart'; // For microphone permissions
import 'package:intl/intl.dart'; // IMPORTANT: Added for DateFormat

class MicrophoneScreen extends StatefulWidget {
  const MicrophoneScreen({super.key});

  @override
  State<MicrophoneScreen> createState() => _MicrophoneScreenState();
}

class _MicrophoneScreenState extends State<MicrophoneScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final GetStorage _box = GetStorage();
  List<RecordedAudio> _recordedAudios = [];
  bool _isRecording = false;
  String? _currentRecordingPath;
  TextEditingController _audioNameController = TextEditingController();
  AudioPlayer? _currentPlayingPlayer; // Keep track of the currently playing player

  @override
  void initState() {
    super.initState();
    _loadRecordedAudios();
    // Corrected: Call onStateChanged() to get the Stream before listening
    _audioRecorder.onStateChanged().listen((state) {
      setState(() {
        _isRecording = state == RecordState.record;
      });
    });
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _currentPlayingPlayer?.dispose(); // Dispose the player if it's still active
    _audioNameController.dispose();
    super.dispose();
  }

  // Load recorded audio paths from GetStorage
  void _loadRecordedAudios() {
    final List<dynamic>? storedAudiosJson = _box.read('recorded_audios');
    if (storedAudiosJson != null) {
      setState(() {
        _recordedAudios = storedAudiosJson.map((json) => RecordedAudio.fromJson(json)).toList();
      });
    }
  }

  // Save recorded audio paths to GetStorage
  void _saveRecordedAudios() {
    _box.write('recorded_audios', _recordedAudios.map((audio) => audio.toJson()).toList());
  }

  // Request microphone permission
  Future<bool> _requestMicrophonePermission() async {
    var status = await Permission.microphone.request();
    if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied. Please enable it in settings.')),
      );
      return false;
    }
    return true;
  }

  // Start recording audio
  Future<void> _startRecording() async {
    if (await _requestMicrophonePermission()) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        _currentRecordingPath = '${appDir.path}/$fileName';

        await _audioRecorder.start(
          RecordConfig(encoder: AudioEncoder.aacLc), // encoder is now part of RecordConfig
          path: _currentRecordingPath!,
        );
        setState(() {
          _isRecording = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording started!')),
        );
      } catch (e) {
        print('Error starting recording: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting recording: $e')),
        );
      }
    }
  }

  // Stop recording audio
  Future<void> _stopRecording() async {
    final path = await _audioRecorder.stop();
    if (path != null) {
      setState(() {
        _isRecording = false;
      });
      _showSaveAudioDialog(path);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No audio was recorded.')),
      );
    }
  }

  // Show dialog to save recorded audio
  void _showSaveAudioDialog(String audioPath) {
    _audioNameController.text = 'Recording ${DateFormat('HH:mm:ss').format(DateTime.now())}'; // Default name
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Recording'),
          content: TextField(
            controller: _audioNameController,
            decoration: const InputDecoration(hintText: 'Enter a name for the audio'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Delete the file if cancelled
                File(audioPath).delete().catchError((e) => print('Error deleting file: $e'));
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_audioNameController.text.isNotEmpty) {
                  setState(() {
                    _recordedAudios.add(RecordedAudio(
                      name: _audioNameController.text,
                      path: audioPath,
                      duration: Duration.zero, // Duration will be fetched on play
                    ));
                  });
                  _saveRecordedAudios();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Audio saved successfully!')),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a name for the audio.')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Play/Pause recorded audio
  Future<void> _togglePlayPause(RecordedAudio audio) async {
    // If the same audio is playing, pause it.
    if (_currentPlayingPlayer?.playerState.playing == true &&
        _currentPlayingPlayer?.audioSource is UriAudioSource &&
        (_currentPlayingPlayer?.audioSource as UriAudioSource).uri.toFilePath() == audio.path) {
      await _currentPlayingPlayer?.pause();
      return;
    }

    // If another audio is playing, stop it first.
    if (_currentPlayingPlayer != null && _currentPlayingPlayer!.playerState.playing) {
      await _currentPlayingPlayer?.stop();
    }

    _currentPlayingPlayer = AudioPlayer(); // Create a new player for the new audio
    try {
      await _currentPlayingPlayer?.setFilePath(audio.path);
      // Update duration after setting source
      if (_currentPlayingPlayer?.duration != null) {
        setState(() {
          audio.duration = _currentPlayingPlayer!.duration!;
        });
      }
      await _currentPlayingPlayer?.play();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Playing: ${audio.name}')),
      );
      // Listen for playback completion
      _currentPlayingPlayer?.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          _currentPlayingPlayer?.stop(); // Stop explicitly when completed
        }
      });
    } catch (e) {
      print('Error playing audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing audio: $e')),
      );
    }
  }

  // Delete recorded audio
  void _deleteAudio(RecordedAudio audio) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${audio.name}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Stop if currently playing
                if (_currentPlayingPlayer?.playerState.playing == true &&
                    _currentPlayingPlayer?.audioSource is UriAudioSource &&
                    (_currentPlayingPlayer?.audioSource as UriAudioSource).uri.toFilePath() == audio.path) {
                  await _currentPlayingPlayer?.stop();
                }

                // Delete the file from device storage
                try {
                  final file = File(audio.path);
                  if (await file.exists()) {
                    await file.delete();
                  }
                } catch (e) {
                  print('Error deleting file from storage: $e');
                }

                setState(() {
                  _recordedAudios.removeWhere((item) => item.path == audio.path);
                });
                _saveRecordedAudios();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Audio deleted successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Microphone',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryGreen,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  label: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? Colors.red : primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                if (_isRecording)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Recording...',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recorded Audios:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ),
          ),
          Expanded(
            child: _recordedAudios.isEmpty
                ? Center(
              child: Text(
                'No audios recorded yet.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
                : ListView.builder(
              itemCount: _recordedAudios.length,
              itemBuilder: (context, index) {
                final audio = _recordedAudios[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    leading: Icon(Icons.audiotrack, color: primaryGreen),
                    title: Text(audio.name),
                    subtitle: StreamBuilder<PlayerState>(
                      stream: _currentPlayingPlayer?.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final playing = playerState?.playing;
                        final processingState = playerState?.processingState;

                        bool isThisAudioPlaying = playing == true &&
                            _currentPlayingPlayer?.audioSource is UriAudioSource &&
                            (_currentPlayingPlayer?.audioSource as UriAudioSource).uri.toFilePath() == audio.path;

                        String subtitleText = 'Tap to play';
                        if (isThisAudioPlaying) {
                          if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
                            subtitleText = 'Loading...';
                          } else {
                            subtitleText = 'Playing';
                          }
                        } else if (audio.duration != Duration.zero) {
                          subtitleText = 'Duration: ${_formatDuration(audio.duration)}';
                        }
                        return Text(subtitleText);
                      },
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        StreamBuilder<PlayerState>(
                          stream: _currentPlayingPlayer?.playerStateStream,
                          builder: (context, snapshot) {
                            final playerState = snapshot.data;
                            final playing = playerState?.playing;
                            bool isThisAudioPlaying = playing == true &&
                                _currentPlayingPlayer?.audioSource is UriAudioSource &&
                                (_currentPlayingPlayer?.audioSource as UriAudioSource).uri.toFilePath() == audio.path;

                            return IconButton(
                              icon: Icon(
                                isThisAudioPlaying ? Icons.pause : Icons.play_arrow,
                                color: primaryGreen,
                              ),
                              onPressed: () => _togglePlayPause(audio),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteAudio(audio),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}

// Data model for Recorded Audio
class RecordedAudio {
  String name;
  String path;
  Duration duration; // Store duration to display it

  RecordedAudio({
    required this.name,
    required this.path,
    this.duration = Duration.zero,
  });

  // Convert RecordedAudio object to JSON for GetStorage
  Map<String, dynamic> toJson() => {
    'name': name,
    'path': path,
    'durationMicroseconds': duration.inMicroseconds, // Store duration as microseconds
  };

  // Create RecordedAudio object from JSON
  factory RecordedAudio.fromJson(Map<String, dynamic> json) => RecordedAudio(
    name: json['name'] as String,
    path: json['path'] as String,
    duration: Duration(microseconds: json['durationMicroseconds'] as int? ?? 0),
  );
}
