// device_io_page.dart
import 'package:flutter/material.dart';
import 'package:dashboard/camera_screen.dart';
import 'package:dashboard/gallery_screen.dart';
import 'package:dashboard/microphone_screen.dart';
import 'package:dashboard/speaker_screen.dart';
import 'package:dashboard/location_screen.dart';
import 'package:dashboard/video_player_screen.dart';
import 'package:dashboard/biometric_auth_screen.dart';
import 'package:dashboard/video_screen.dart'; // NEW: Import VideoScreen
import 'package:dashboard/video_gallery_screen.dart'; // NEW: Import VideoGalleryScreen


class DeviceIOPage extends StatelessWidget {
  const DeviceIOPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = Theme.of(context).primaryColor;
    final Color accentBlue = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Device I/O Features',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryGreen,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Camera Button (Green)
              _buildDeviceIOButton(
                context,
                text: 'Camera',
                icon: Icons.camera_alt,
                color: primaryGreen, // Green
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const CameraScreen()));
                },
              ),
              const SizedBox(height: 15.0),

              // Gallery/File Picker Button (Blue)
              _buildDeviceIOButton(
                context,
                text: 'Gallery/File Picker',
                icon: Icons.photo_library,
                color: accentBlue, // Blue
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const GalleryScreen()));
                },
              ),
              const SizedBox(height: 15.0),

              // Microphone Button (Green)
              _buildDeviceIOButton(
                context,
                text: 'Microphone',
                icon: Icons.mic,
                color: primaryGreen, // Green
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MicrophoneScreen()));
                },
              ),
              const SizedBox(height: 15.0),

              // Speaker Button (Blue)
              _buildDeviceIOButton(
                context,
                text: 'Speaker',
                icon: Icons.volume_up,
                color: accentBlue, // Blue
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SpeakerScreen()));
                },
              ),
              const SizedBox(height: 15.0),

              // Location Button (Green)
              _buildDeviceIOButton(
                context,
                text: 'Location',
                icon: Icons.location_on,
                color: primaryGreen, // Green
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LocationScreen()));
                },
              ),
              const SizedBox(height: 15.0),

              // Video Playing Button (Blue)
              _buildDeviceIOButton(
                context,
                text: 'Video Playing',
                icon: Icons.play_circle_fill,
                color: accentBlue, // Blue
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const VideoPlayerScreen()));
                },
              ),
              const SizedBox(height: 15.0),

              // NEW: Video Recorder Button (Green)
              _buildDeviceIOButton(
                context,
                text: 'Video Recorder',
                icon: Icons.videocam,
                color: primaryGreen, // Green
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const VideoScreen()));
                },
              ),
              const SizedBox(height: 15.0),

              // NEW: Video Gallery Button (Blue)
              _buildDeviceIOButton(
                context,
                text: 'Video Gallery',
                icon: Icons.video_library,
                color: accentBlue, // Blue
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const VideoGalleryScreen()));
                },
              ),
              const SizedBox(height: 15.0),

              // Biometric Auth Button (Green)
              _buildDeviceIOButton(
                context,
                text: 'Biometric Auth',
                icon: Icons.fingerprint,
                color: primaryGreen, // Green
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const BiometricAuthScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build consistent elevated button styles
  Widget _buildDeviceIOButton(
      BuildContext context, {
        required String text,
        required IconData icon,
        required Color color, // This will be the background color
        required VoidCallback onPressed,
      }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color, // Use the passed color for background
        foregroundColor: Colors.white, // White text and icon color
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Consistent rounded corners
        ),
        elevation: 4.0, // Consistent subtle shadow
        textStyle: const TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold, // Consistent bold text
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 28.0),
          const SizedBox(width: 15.0),
          Text(text),
        ],
      ),
    );
  }
}
