import 'package:flutter/material.dart';

class VideoPlayerScreen extends StatelessWidget {
  final String lessonId;

  const VideoPlayerScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Player')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.play_circle_fill, size: 96),
            const SizedBox(height: 12),
            Text('Playing lesson: $lessonId'),
          ],
        ),
      ),
    );
  }
}
