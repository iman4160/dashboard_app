// lib/video_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:dashboard/models/video_item.dart'; // Import the VideoItem model

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final ImagePicker _picker = ImagePicker();
  final GetStorage _box = GetStorage();
  List<VideoItem> _recordedVideos = [];
  VideoPlayerController? _currentPlayingController;

  @override
  void initState() {
    super.initState();
    _loadRecordedVideos();
  }

  @override
  void dispose() {
    _currentPlayingController?.dispose();
    super.dispose();
  }

  void _loadRecordedVideos() {
    final List<dynamic>? storedVideosJson = _box.read('recorded_videos');
    if (storedVideosJson != null) {
      setState(() {
        _recordedVideos = storedVideosJson.map((json) => VideoItem.fromJson(json)).toList();
      });
    }
  }

  void _saveRecordedVideos() {
    _box.write('recorded_videos', _recordedVideos.map((video) => video.toJson()).toList());
  }

  Future<bool> _requestCameraPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();
    final storageStatus = await Permission.storage.request(); // For Android saving

    if (cameraStatus.isGranted && microphoneStatus.isGranted && storageStatus.isGranted) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera, Microphone, or Storage permission denied.')),
      );
      return false;
    }
  }

  Future<void> _recordVideo() async {
    if (await _requestCameraPermissions()) {
      final XFile? video = await _picker.pickVideo(source: ImageSource.camera);

      if (video != null) {
        // You can save the video to app documents directory if needed for persistence
        final appDir = await getApplicationDocumentsDirectory();
        final newFileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
        final newPath = '${appDir.path}/$newFileName';

        try {
          // Copy the picked video to a persistent location
          final File newFile = await File(video.path).copy(newPath);

          setState(() {
            _recordedVideos.add(VideoItem(
              name: 'Recorded Video ${DateFormat('HH:mm:ss').format(DateTime.now())}',
              path: newFile.path,
            ));
          });
          _saveRecordedVideos();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video recorded and saved!')),
          );
        } catch (e) {
          print('Error saving video: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving video: $e')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video recording cancelled.')),
        );
      }
    }
  }

  Future<void> _togglePlayPause(VideoItem videoItem) async {
    // If the same video is playing, pause it.
    if (_currentPlayingController != null &&
        _currentPlayingController!.value.isPlaying &&
        _currentPlayingController!.dataSource == videoItem.path) {
      await _currentPlayingController!.pause();
      return;
    }

    // Dispose previous controller if any
    if (_currentPlayingController != null) {
      await _currentPlayingController!.dispose();
    }

    _currentPlayingController = VideoPlayerController.file(File(videoItem.path));

    try {
      await _currentPlayingController!.initialize();
      setState(() {
        videoItem.duration = _currentPlayingController!.value.duration;
      });
      await _currentPlayingController!.play();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Playing: ${videoItem.name}')),
      );
    } catch (e) {
      print('Error playing video: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error playing video: $e')),
      );
      _currentPlayingController = null; // Clear controller on error
    }
  }

  void _deleteVideo(VideoItem videoItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete "${videoItem.name}"?'),
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
                if (_currentPlayingController != null && _currentPlayingController!.dataSource == videoItem.path) {
                  await _currentPlayingController!.pause();
                  await _currentPlayingController!.dispose();
                  _currentPlayingController = null;
                }

                // Delete the file from device storage
                try {
                  final file = File(videoItem.path);
                  if (await file.exists()) {
                    await file.delete();
                  }
                } catch (e) {
                  print('Error deleting video file: $e');
                }

                setState(() {
                  _recordedVideos.removeWhere((item) => item.path == videoItem.path);
                });
                _saveRecordedVideos();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Video deleted successfully!')),
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

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    return "${twoDigits(d.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Video Recorder',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryGreen,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _recordVideo,
              icon: const Icon(Icons.videocam),
              label: const Text('Record Video'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recorded Videos:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ),
          ),
          Expanded(
            child: _recordedVideos.isEmpty
                ? Center(
              child: Text(
                'No videos recorded yet.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
                : ListView.builder(
              itemCount: _recordedVideos.length,
              itemBuilder: (context, index) {
                final video = _recordedVideos[index];
                final bool isCurrentPlaying = _currentPlayingController != null &&
                    _currentPlayingController!.dataSource == video.path &&
                    _currentPlayingController!.value.isPlaying;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.video_library, color: primaryGreen),
                        title: Text(video.name),
                        subtitle: Text(
                          video.duration == Duration.zero
                              ? 'Tap to load duration'
                              : 'Duration: ${_formatDuration(video.duration)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isCurrentPlaying ? Icons.pause : Icons.play_arrow,
                                color: primaryGreen,
                              ),
                              onPressed: () => _togglePlayPause(video),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteVideo(video),
                            ),
                          ],
                        ),
                      ),
                      if (_currentPlayingController != null && _currentPlayingController!.dataSource == video.path)
                        AspectRatio(
                          aspectRatio: _currentPlayingController!.value.isInitialized
                              ? _currentPlayingController!.value.aspectRatio
                              : 16 / 9, // Default aspect ratio
                          child: VideoPlayer(_currentPlayingController!),
                        )
                      else if (_currentPlayingController == null || _currentPlayingController!.dataSource != video.path)
                        Container(
                          height: 150, // Placeholder height
                          color: Colors.black,
                          child: Center(
                            child: Icon(Icons.play_circle_fill, size: 60, color: Colors.white.withOpacity(0.7)),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}