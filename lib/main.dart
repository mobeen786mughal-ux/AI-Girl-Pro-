import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() => runApp(const AIGirlPro());
class AIGirlPro extends StatelessWidget {
  const AIGirlPro({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, title: 'AI Girl Pro', theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black), home: const HomeScreen());
  }
}
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  String _msg = "Hi Jaan! Main Tumhari AI Girl Hun! ❤️";
  String _emotion = "happy";
  bool _isListening = false;
  bool _isThinking = false;
  List<Map<String, String>> _history = [];
  final String groqKey = "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";
  String getEmoji() {
    if (_emotion == "love") return "😍";
    if (_emotion == "sad") return "😔";
    if (_emotion == "angry") return "😡";
    if (_emotion == "laugh") return "😂";
    if (_emotion == "shy") return "🙈";
    return "😊";
  }
  String detectEmotion(String text) {
    String t = text.toLowerCase();
    if (t.contains("love") || t.contains("pyar") || t.contains("jaan")) return "love";
    if (t.contains("sad") || t.contains("udas")) return "sad";
    if (t.contains("gussa") || t.contains("angry")) return "angry";
    if (t.contains("haha") || t.contains("funny")) return "laugh";
    if (t.contains("sharm")) return "shy";
    return "happy";
  }
  Future<void> speak(String text) async {
    await _tts.setLanguage("ur-PK");
    await _tts.setPitch(1.3);
    await _tts.setSpeechRate(0.9);
    await _tts.speak(text);
  }
  Future<void> askGroq(String userText) async {
    setState(() { _isThinking = true; _msg = "Soch rahi hun Jaan... 🤔"; });
    try {
      final res = await http.post(Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
        headers: {"Authorization": "Bearer $groqKey", "Content-Type": "application/json"},
        body: jsonEncode({"model": "llama-3.3-70b-versatile","messages": [{"role": "system", "content": "Tum ek pyari AI Girl ho. Roman Urdu + English mix me baat karo. Short, pyare, emotional jawab do."}, ..._history.map((m) => {"role": m["role"], "content": m["text"]}), {"role": "user", "content": userText}],"temperature": 0.8, "max_tokens": 200}));
      if (res.statusCode == 200) {
        String reply = jsonDecode(res.body)["choices"][0]["message"]["content"];
        _history.add({"role": "user", "text": userText});
        _history.add({"role": "assistant", "text": reply});
        setState(() { _msg = reply; _emotion = detectEmotion(reply); _isThinking = false; });
        speak(reply);
      } else { setState(() { _msg = "Jaan, thoda issue hai, phir se bolo na! 🥺"; _isThinking = false; }); }
    } catch (e) { setState(() { _msg = "Internet check karo Jaan! 📶"; _isThinking = false; }); }
  }
  Future<void> listen() async {
    bool avail = await _speech.initialize();
    if (avail) { setState(() => _isListening = true); _speech.listen(onResult: (r) { if (r.finalResult) { setState(() => _isListening = false); askGroq(r.recognizedWords); } }); }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.pink, title: Row(children: [CircleAvatar(backgroundImage: AssetImage("assets/icons/app-icon.jpg")), SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("AI Girl Pro", style: TextStyle(fontWeight: FontWeight.bold)), Text("Online • ${getEmoji()} ${_emotion}", style: TextStyle(fontSize: 12))])])),
      body: Column(children: [
        Expanded(flex: 3, child: Stack(children: [ModelViewer(src: "assets/models/Anime-Girl.glb", alt: "AI Girl", autoRotate: true, cameraControls: true, autoPlay: true), Positioned(top: 10, left: 10, right: 10, child: Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(15)), child: Text(_msg, style: TextStyle(color: Colors.white, fontSize: 16)))), if (_isThinking) Positioned(bottom: 10, right: 10, child: CircularProgressIndicator(color: Colors.pink))])),
        Container(padding: EdgeInsets.all(8), child: Wrap(spacing: 8, children: [for (var b in ["Hi Jaan! ❤️", "Baat Karo", "Dance Karo 💃", "I Love You", "Sad Hun"]) ElevatedButton(onPressed: () => askGroq(b), style: ElevatedButton.styleFrom(backgroundColor: Colors.pink), child: Text(b, style: TextStyle(color: Colors.white)))])),
        Padding(padding: EdgeInsets.all(10), child: Row(children: [IconButton(onPressed: listen, icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: Colors.pink, size: 30)), Expanded(child: TextField(controller: _ctrl, decoration: InputDecoration(hintText: "Kuch likho Jaan...", filled: true, fillColor: Colors.white12, border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none)))), IconButton(onPressed: () { if (_ctrl.text.isNotEmpty) { askGroq(_ctrl.text); _ctrl.clear(); } }, icon: Icon(Icons.send, color: Colors.pink, size: 30))])),
      ]),
    );
  }
}
