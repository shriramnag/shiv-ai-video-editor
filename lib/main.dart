import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shiv AI Editor',
      theme: ThemeData.dark(),
      home: const EditorHomeScreen(),
    );
  }
}

class EditorHomeScreen extends StatelessWidget {
  const EditorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('शिव एआई वीडियो एडिटर'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.video_collection, size: 80, color: Colors.blueAccent),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.video_file),
              label: const Text('वीडियो चुनें'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.audiotrack),
              label: const Text('ऑडियो अलग करें (Extract MP3)'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.cut),
              label: const Text('लॉसलैस कट'),
            ),
          ],
        ),
      ),
    );
  }
}

