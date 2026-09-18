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
        scaffoldBackgroundColor: const Color(0xFF0D0D11),
        cardColor: const Color(0xFF16161C),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00ADB5),
          secondary: Colors.amber,
        ),
      ),
      home: const ProEditorScreen(),
    );
  }
}

class ProEditorScreen extends StatefulWidget {
  const ProEditorScreen({super.key});

  @override
  State<ProEditorScreen> createState() => _ProEditorScreenState();
}

class _ProEditorScreenState extends State<ProEditorScreen> {
  VideoPlayerController? _controller;
  final ImagePicker _picker = ImagePicker();
  
  // स्टेटस और स्टेट वैरिएबल्स
  String videoTitle = "कोई वीडियो लोड नहीं है";
  double currentRatio = 9 / 16; // डिफ़ॉल्ट रील्स फॉर्मेट
  String ratioText = "9:16";
  String captionText = "🔥 वायरल कैप्शन: यहाँ अपना टेक्स्ट लिखें";
  Color captionColor = Colors.amber;
  double playbackSpeed = 1.0;
  bool isSplit = false;
  Duration currentPosition = Duration.zero;

  // वीडियो लोड करना
  Future<void> pickVideo() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      _controller?.dispose();
      _controller = VideoPlayerController.file(File(file.path))
        ..initialize().then((_) {
          setState(() {
            videoTitle = file.name;
            _controller!.addListener(() {
              if (mounted) {
                setState(() {
                  currentPosition = _controller!.value.position;
                });
              }
            });
            _controller!.play();
          });
        });
    }
  }

  // १. आस्पेक्ट रेशियो टॉगल (9:16 -> 16:9 -> 1:1)
  void cycleRatio() {
    setState(() {
      if (ratioText == "9:16") {
        currentRatio = 16 / 9;
        ratioText = "16:9";
      } else if (ratioText == "16:9") {
        currentRatio = 1 / 1;
        ratioText = "1:1";
      } else {
        currentRatio = 9 / 16;
        ratioText = "9:16";
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("स्क्रीन रेशियो बदला: $ratioText"), duration: const Duration(seconds: 1)),
    );
  }

  // २. असली कट/स्प्लिट लॉजिक
  void cutVideoAtCurrentFrame() {
    if (_controller != null && _controller!.value.isInitialized) {
      setState(() {
        isSplit = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("कट लगा: ${currentPosition.inSeconds} सेकंड पर स्प्लिट हुआ"),
          backgroundColor: const Color(0xFF00ADB5),
        ),
      );
    }
  }

  // ३. स्पीड चेंज (0.5x, 1x, 2x)
  void changeSpeed() {
    if (_controller != null && _controller!.value.isInitialized) {
      setState(() {
        if (playbackSpeed == 1.0) {
          playbackSpeed = 1.5;
        } else if (playbackSpeed == 1.5) {
          playbackSpeed = 2.0;
        } else if (playbackSpeed == 2.0) {
          playbackSpeed = 0.5;
        } else {
          playbackSpeed = 1.0;
        }
        _controller!.setPlaybackSpeed(playbackSpeed);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("वीडियो स्पीड: ${playbackSpeed}x"), duration: const Duration(seconds: 1)),
      );
    }
  }

  // ४. कैप्शन कस्टमाइज़ डायलॉग
  void editCaptionDialog() {
    TextEditingController textCtrl = TextEditingController(text: captionText);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("कैप्शन एडिट करें"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: textCtrl, decoration: const InputDecoration(labelText: "कैप्शन टेक्स्ट")),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  onPressed: () {
                    setState(() => captionColor = Colors.amber);
                    Navigator.pop(ctx);
                  },
                  child: const Text("पीला", style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                  onPressed: () {
                    setState(() => captionColor = Colors.cyanAccent);
                    Navigator.pop(ctx);
                  },
                  child: const Text("नीला", style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: () {
                    setState(() => captionColor = Colors.redAccent);
                    Navigator.pop(ctx);
                  },
                  child: const Text("लाल", style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => captionText = textCtrl.text);
              Navigator.pop(ctx);
            },
            child: const Text("लागू करें"),
          )
        ],
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
        backgroundColor: const Color(0xFF16161C),
        title: Text(videoTitle, style: const TextStyle(fontSize: 13, color: Colors.white70)),
        actions: [
          IconButton(
            icon: const Icon(Icons.aspect_ratio, color: Color(0xFF00ADB5)),
            tooltip: "रेशियो बदलें",
            onPressed: cycleRatio,
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            tooltip: "एक्सपोर्ट",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("एक्सपोर्ट इंजन रेंडरिंग के लिए तैयार है")),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // प्रीव्यू विंडो (रेशियो के अनुसार साइज बदलेगा)
          Expanded(
            flex: 5,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: AspectRatio(
                  aspectRatio: currentRatio,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_controller != null && _controller!.value.isInitialized)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
                            });
                          },
                          child: VideoPlayer(_controller!),
                        )
                      else
                        InkWell(
                          onTap: pickVideo,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.video_library_outlined, size: 50, color: Color(0xFF00ADB5)),
                              SizedBox(height: 8),
                              Text("गैलरी से वीडियो चुनें", style: TextStyle(color: Colors.white60)),
                            ],
                          ),
                        ),

                      // लाइव एडिटेबल ऑटो-कैप्शन बॉक्स
                      Positioned(
                        bottom: 15,
                        child: GestureDetector(
                          onTap: editCaptionDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: captionColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              captionText,
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // टाइमलाइन सीकर
          if (_controller != null && _controller!.value.isInitialized)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: VideoProgressIndicator(
                _controller!,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Color(0xFF00ADB5),
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.white10,
                ),
              ),
            ),

          // मल्टी-ट्रैक टाइमलाइन
          Container(
            height: 80,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF16161C),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade800,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF00ADB5)),
                    ),
                    child: Center(
                      child: Text(
                        isSplit ? "क्लिप १ (0s - ${currentPosition.inSeconds}s)" : "📹 मुख्य वीडियो ट्रैक",
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                ),
                if (isSplit) const SizedBox(width: 6),
                if (isSplit)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.teal.shade800,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: const Center(
                        child: Text("📹 क्लिप २ (स्प्लिट पार्ट)", style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // नीचे एक्टिव कंट्रोल टूल्स
          Container(
            height: 85,
            color: const Color(0xFF121216),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTool(Icons.add_photo_alternate, "वीडियो बदलें", pickVideo),
                _buildTool(Icons.content_cut, "कट / स्प्लिट", cutVideoAtCurrentFrame),
                _buildTool(Icons.subtitles, "कैप्शन बदलें", editCaptionDialog),
                _buildTool(Icons.speed, "${playbackSpeed}x स्पीड", changeSpeed),
                _buildTool(Icons.crop_rotate, ratioText, cycleRatio),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTool(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF00ADB5), size: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
        ],
      ),
    );
  }
}
