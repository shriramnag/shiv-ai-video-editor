import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const ShivAIApp());
}

class ShivAIApp extends StatelessWidget {
  const ShivAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'शिव एआई वीडियो एडिटर',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F12),
        cardColor: const Color(0xFF18181D),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00ADB5),
          secondary: Color(0xFFFF5722),
        ),
      ),
      home: const MainEditorScreen(),
    );
  }
}

class MainEditorScreen extends StatefulWidget {
  const MainEditorScreen({super.key});

  @override
  State<MainEditorScreen> createState() => _MainEditorScreenState();
}

class _MainEditorScreenState extends State<MainEditorScreen> {
  VideoPlayerController? _controller;
  final ImagePicker _picker = ImagePicker();
  String videoName = "कोई वीडियो लोड नहीं है";
  String activeCaption = "वायरल कैप्शन यहाँ दिखेगा";
  bool isPlaying = false;

  // फोन गैलरी से असली वीडियो चुनना
  Future<void> pickVideo() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      _controller?.dispose();
      _controller = VideoPlayerController.file(File(file.path))
        ..initialize().then((_) {
          setState(() {
            videoName = file.name;
            _controller!.play();
            isPlaying = true;
          });
        });
    }
  }

  void togglePlayPause() {
    if (_controller != null && _controller!.value.isInitialized) {
      setState(() {
        if (_controller!.value.isPlaying) {
          _controller!.pause();
          isPlaying = false;
        } else {
          _controller!.play();
          isPlaying = true;
        }
      });
    } else {
      pickVideo();
    }
  }

  void showActionAlert(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$title: $message"),
        backgroundColor: const Color(0xFF00ADB5),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF18181D),
        elevation: 0,
        title: Text(videoName, style: const TextStyle(fontSize: 14, color: Colors.white70)),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_library, color: Color(0xFF00ADB5)),
            tooltip: "वीडियो चुनें",
            onPressed: pickVideo,
          ),
          IconButton(
            icon: const Icon(Icons.file_upload_outlined, color: Colors.white),
            tooltip: "एक्सपोर्ट",
            onPressed: () => showActionAlert("एक्सपोर्ट", "फास्ट रेंडरिंग प्रारंभ हो गई"),
          ),
        ],
      ),
      body: Column(
        children: [
          // १. वीडियो प्रीव्यू प्लेयर विंडो (इमेज जैसा)
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_controller != null && _controller!.value.isInitialized)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: _controller!.value.aspectRatio,
                        child: VideoPlayer(_controller!),
                      ),
                    )
                  else
                    InkWell(
                      onTap: pickVideo,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline, size: 55, color: Color(0xFF00ADB5)),
                          SizedBox(height: 8),
                          Text("गैलरी से वीडियो चुनें", style: TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                    ),

                  // वीडियो के ऊपर प्ले/पॉज बटन
                  if (_controller != null && _controller!.value.isInitialized)
                    IconButton(
                      iconSize: 50,
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      onPressed: togglePlayPause,
                    ),

                  // इमेज जैसा वायरल कैप्शन बॉक्स
                  Positioned(
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        activeCaption,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // २. टाइमलाइन और वेवफॉर्म एरिया (केपकट / इनशॉट स्टाइल)
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF141418),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // वीडियो प्रोग्रेस बार
                  if (_controller != null && _controller!.value.isInitialized)
                    VideoProgressIndicator(
                      _controller!,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Color(0xFF00ADB5),
                        bufferedColor: Colors.white24,
                        backgroundColor: Colors.black,
                      ),
                    ),
                  const SizedBox(height: 8),

                  // टाइमलाइन लेयर्स (वीडियो, ऑडियो, टेक्स्ट)
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // वीडियो क्लिप बार
                        Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade800,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF00ADB5), width: 1.5),
                          ),
                          child: const Center(
                            child: Text("📹 वीडियो क्लिप", style: TextStyle(fontSize: 12, color: Colors.white)),
                          ),
                        ),
                        // ऑडियो ट्रैक बार
                        Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade900,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text("🎵 ऑडियो वेव", style: TextStyle(fontSize: 12, color: Colors.white70)),
                          ),
                        ),
                        // टेक्स्ट लेयर बार
                        Container(
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.amber.shade900,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text("📝 कैप्शन", style: TextStyle(fontSize: 12, color: Colors.white70)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ३. नीचे मुख्य टूल्स बार
          Container(
            height: 95,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: const Color(0xFF18181D),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _buildToolButton(Icons.movie_creation_outlined, "वीडियो चुनें", pickVideo),
                _buildToolButton(Icons.content_cut, "लॉसलैस कट", () => showActionAlert("कट", "क्लिप स्प्लिट हो गई")),
                _buildToolButton(Icons.audiotrack, "ऑडियो अलग", () => showActionAlert("ऑडियो", "MP3 अलग निकाल लिया गया")),
                _buildToolButton(Icons.subtitles, "ऑटो कैप्शन", () {
                  setState(() => activeCaption = "🔥 लोकल व्हिस्पर: ऑडियो से कैप्शन तैयार!");
                  showActionAlert("कैप्शन", "हिंदी कैप्शन टाइमलाइन पर जुड़ गया");
                }),
                _buildToolButton(Icons.speed, "स्पीड कर्व", () => showActionAlert("स्पीड", "कर्व स्मूथ मोशन लागू")),
                _buildToolButton(Icons.auto_fix_high, "शोर हटाएं", () => showActionAlert("नॉइज़", "बैकग्राउंड आवाज़ साफ")),
                _buildToolButton(Icons.crop_rotate, "9:16 रील्स", () => showActionAlert("फॉर्मेट", "शॉर्ट्स रेशियो सेट")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 75,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF00ADB5), size: 24),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

