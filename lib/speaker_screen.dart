// speaker_screen.dart
import 'package:flutter/material.dart';

class SpeakerScreen extends StatelessWidget {
  const SpeakerScreen({super.key});

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.volume_up, size: 80, color: accentBlue.withOpacity(0.7)),
            const SizedBox(height: 20),
            Text(
              'Speaker control features will be implemented here!',
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement speaker volume/playback logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Speaker functionality placeholder.')),
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Test Speaker'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentBlue,
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
