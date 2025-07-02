// lib/models/video_item.dart
import 'package:flutter/material.dart'; // Often useful for Duration and other types, though not strictly needed for this model

class VideoItem {
  String name;
  String path;
  Duration duration; // Ensure this is correctly typed and initialized

  VideoItem({
    required this.name,
    required this.path,
    this.duration = Duration.zero, // Default value for duration
  });

  // Convert VideoItem object to JSON for GetStorage
  Map<String, dynamic> toJson() => {
    'name': name,
    'path': path,
    'durationMicroseconds': duration.inMicroseconds, // Store duration as microseconds
  };

  // Create VideoItem object from JSON
  factory VideoItem.fromJson(Map<String, dynamic> json) => VideoItem(
    name: json['name'] as String,
    path: json['path'] as String,
    duration: Duration(microseconds: json['durationMicroseconds'] as int? ?? 0),
  );
}
