import 'package:flutter/material.dart';

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
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
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
  String currentStatus = "तैयार (Ready)";
  String selectedVideo = "सैंपल_वीडियो.mp4";

  void showMessage(String title, String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("ठीक है"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("शिव एआई प्रो एडिटर (FOSS)", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF00ADB5)),
            onPressed: () => showMessage("एक्सपोर्ट", "वीडियो एक्सपोर्ट इंजन प्रारंभ हो रहा है..."),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // प्रीव्यू विंडो
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.play_circle_fill, size: 64, color: Colors.white70),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Text(selectedVideo, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  ),
                  Positioned(
                    bottom: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade700,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text("🔥 वायरल कैप्शन: ये पहाड़ शानदार हैं!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // टाइमलाइन स्थिति
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.tune, color: Color(0xFF00ADB5)),
                  const SizedBox(width: 10),
                  Expanded(child: Text("स्टेटस: $currentStatus", style: const TextStyle(fontSize: 13))),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // सेक्शन १: ऑडियो टूल्स
            const Text("१. ऑडियो और वोकल टूल्स (स्थानीय)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.music_note, size: 18),
                  label: const Text("ऑडियो अलग करें (MP3)"),
                  onPressed: () => showMessage("ऑडियो", "वीडियो से ऑडियो अलग होकर सेव हो गया है।"),
                ),
                ActionChip(
                  avatar: const Icon(Icons.mic_off, size: 18),
                  label: const Text("बैकग्राउंड शोर हटाएं"),
                  onPressed: () => showMessage("शोर रिमूवर", "ऑडियो नॉइज़ साफ कर दिया गया है।"),
                ),
                ActionChip(
                  avatar: const Icon(Icons.graphic_eq, size: 18),
                  label: const Text("बीट डिटेक्शन और सिंक"),
                  onPressed: () => showMessage("बीट सिंक", "म्यूजिक बीट्स टाइमलाइन पर मार्क हो गए हैं।"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // सेक्शन २: ऑटो कैप्शन और टेक्स्ट टेंप्लेट्स
            const Text("२. ऑटो-कैप्शन और काइनेटिक स्टाइल्स", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.subtitles, size: 18),
                  label: const Text("लोकल व्हिस्पर कैप्शन (हिंदी)"),
                  onPressed: () => showMessage("कैप्शन", "वीडियो की आवाज सुनकर हिंदी सबटाइटल जनरेट हो गए।"),
                ),
                ActionChip(
                  avatar: const Icon(Icons.style, size: 18),
                  label: const Text("होरमोजी बोल्ड येलो"),
                  onPressed: () => showMessage("टेंप्लेट", "येलो बोल्ड कैप्शन स्टाइल लागू किया गया।"),
                ),
                ActionChip(
                  avatar: const Icon(Icons.text_fields, size: 18),
                  label: const Text("काइनेटिक टाइपराइटर"),
                  onPressed: () => showMessage("एनिमेशन", "टाइपराइटर टेक्स्ट मोशन एक्टिवेट हो गया।"),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // सेक्शन ३: वीडियो कटिंग, इफेक्ट्स व यूट्यूब
            const Text("३. इफेक्ट्स, कट्स और यूट्यूब टूल्स", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.flash_on, size: 18),
                  label: const Text("लॉसलैस क्विक-कट"),
                  onPressed: () => showMessage("फास्ट कट", "बिना री-एन्कोडिंग के वीडियो कट तैयार है।"),
                ),
                ActionChip(
                  avatar: const Icon(Icons.crop_portrait, size: 18),
                  label: const Text("रील्स क्रॉप (9:16)"),
                  onPressed: () => showMessage("रील्स", "वर्टिकल शॉर्ट्स लेआउट सेट हो गया।"),
                ),
                ActionChip(
                  avatar: const Icon(Icons.speed, size: 18),
                  label: const Text("स्पीड कर्व (स्लो-फास्ट)"),
                  onPressed: () => showMessage("स्पीड", "कर्व स्पीड रैंपिंग लागू कर दी गई है।"),
                ),
                ActionChip(
                  avatar: const Icon(Icons.auto_awesome, size: 18),
                  label: const Text("लोकल बैकग्राउंड रिमूवल"),
                  onPressed: () => showMessage("एआई रिमूवल", "मीडियापाइप से बैकग्राउंड हटा दिया गया।"),
                ),
                ActionChip(
                  avatar: const Icon(Icons.list_alt, size: 18),
                  label: const Text("यूट्यूब चैप्टर्स टाइमस्टैम्प्स"),
                  onPressed: () => showMessage("टाइमस्टैम्प्स", "यूट्यूब डिस्क्रिप्शन के लिए टाइमस्टैम्प कॉपी हो गए!"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
