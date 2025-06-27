// microphone_screen.dart
import 'package:flutter/material.dart';

class MicrophoneScreen extends StatelessWidget {
  const MicrophoneScreen({super.key});

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.mic, size: 80, color: primaryGreen.withOpacity(0.7)),
            const SizedBox(height: 20),
            Text(
              'Microphone features will be implemented here!',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement microphone recording/playback logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Microphone functionality placeholder.')),
                );
              },
              icon: const Icon(Icons.record_voice_over),
              label: const Text('Start Recording'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
