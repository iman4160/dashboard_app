// lib/video_gallery_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart'; // Ensure this import is correct
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:dashboard/models/video_item.dart'; // Import the VideoItem model

class VideoGalleryScreen extends StatefulWidget {
  const VideoGalleryScreen({super.key});

  @override
  State<VideoGalleryScreen> createState() => _VideoGalleryScreenState();
}

class _VideoGalleryScreenState extends State<VideoGalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  final GetStorage _box = GetStorage();
  List<VideoItem> _pickedVideos = [];
  VideoPlayerController? _currentPlayingController;

  @override
  void initState() {
    super.initState();
    _loadPickedVideos();
  }

  @override
  void dispose() {
    _currentPlayingController?.dispose();
    super.dispose();
  }

  void _loadPickedVideos() {
    final List<dynamic>? storedVideosJson = _box.read('picked_videos');
    if (storedVideosJson != null) {
      setState(() {
        _pickedVideos = storedVideosJson.map((json) => VideoItem.fromJson(json)).toList();
      });
    }
  }

  void _savePickedVideos() {
    _box.write('picked_videos', _pickedVideos.map((video) => video.toJson()).toList());
  }

  Future<bool> _requestPhotosPermission() async {
    final photosStatus = await Permission.photos.request(); // For iOS 14+
    if (photosStatus.isGranted || await Permission.storage.request().isGranted) { // Fallback for Android/older iOS
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photo Library/Storage permission denied.')),
      );
      return false;
    }
  }

  Future<void> _pickVideoFromGallery() async {
    if (await _requestPhotosPermission()) {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);

      if (video != null) {
        // For gallery videos, we directly use the picked path.
        // No need to copy as they are already persistent on the device.
        setState(() {
          _pickedVideos.add(VideoItem(
            name: 'Picked Video ${DateFormat('HH:mm:ss').format(DateTime.now())}',
            path: video.path,
          ));
        });
        _savePickedVideos();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video picked and saved!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video picking cancelled.')),
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

                // Note: For gallery videos, we usually don't delete the original file
                // from the user's gallery. We just remove it from our app's list.
                // If the video was recorded by our app and copied to app-specific storage,
                // then deleting the file is appropriate. For picked videos,
                // we usually only delete the reference in our app.
                // For simplicity, this example only deletes from the app's list.
                // If you copied gallery videos to app storage, you'd delete them here.

                setState(() {
                  _pickedVideos.removeWhere((item) => item.path == videoItem.path);
                });
                _savePickedVideos();
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
          'Video Gallery',
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
              onPressed: _pickVideoFromGallery,
              icon: const Icon(Icons.image),
              label: const Text('Pick Video from Gallery'),
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
                'Picked Videos:',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ),
          ),
          Expanded(
            child: _pickedVideos.isEmpty
                ? Center(
              child: Text(
                'No videos picked yet.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            )
                : ListView.builder(
              itemCount: _pickedVideos.length,
              itemBuilder: (context, index) {
                final video = _pickedVideos[index];
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
