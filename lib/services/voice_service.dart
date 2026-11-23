import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceService {
  final FlutterTts tts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();

  Future<void> speak(String text) async {
    await tts.setLanguage("ur-PK");
    await tts.setPitch(1.3);
    await tts.setSpeechRate(0.9);
    await tts.speak(text);
  }

  Future<bool> startListening(Function(String) onResult) async {
    bool avail = await speech.initialize();
    if (avail) {
      speech.listen(onResult: (r) {
        if (r.finalResult) {
          onResult(r.recognizedWords);
        }
      });
      return true;
    }
    return false;
  }

  void stopListening() {
    speech.stop();
  }
}
