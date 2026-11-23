import 'dart:convert';
import 'package:http/http.dart' as http;
class GroqService {
  final String apiKey;
  GroqService(this.apiKey);
  Future<String> ask(String text, List<Map<String,String>> history) async {
    final res = await http.post(Uri.parse("https://api.groq.com/openai/v1/chat/completions"),
      headers: {"Authorization": "Bearer $apiKey", "Content-Type": "application/json"},
      body: jsonEncode({"model": "llama-3.3-70b-versatile","messages": [{"role": "system", "content": "Tum ek pyari AI Girl ho. Roman Urdu + English mix me baat karo."}, ...history.map((m) => {"role": m["role"], "content": m["text"]}), {"role": "user", "content": text}],"temperature": 0.8, "max_tokens": 200}));
    if (res.statusCode == 200) { return jsonDecode(res.body)["choices"][0]["message"]["content"]; }
    return "Jaan, thoda issue hai! 🥺";
  }
}
