import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/prediction_result.dart';

class SentimentService {
  // -----------------------------------------------------------------
  // Backend FastAPI sudah jalan dan model (Model2_CNN_BiLSTM_Hybrid)
  // sudah terpasang. UI tidak berubah sama sekali.
  // -----------------------------------------------------------------
  static const bool useDummyData = false;

  // PENTING: sesuaikan alamat ini dengan cara kamu jalankan backend:
  // - Emulator Android            -> http://10.0.2.2:8000
  // - HP fisik satu WiFi dgn laptop -> http://<IP_LOKAL_LAPTOP>:8000 (cek `ipconfig`/`ifconfig`)
  // - Sudah deploy (Railway/Render) -> https://nama-app.up.railway.app
  static const String baseUrl = 'https://gojek-sentiment-backend-production.up.railway.app';

  Future<PredictionResult> predict(String text) async {
    if (useDummyData) {
      return _dummyPredict(text);
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/sentiment/predict'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal memproses prediksi (${response.statusCode})');
    }
    return PredictionResult.fromJson(jsonDecode(response.body));
  }

  Future<List<HistoryItem>> getHistory({int limit = 20}) async {
    if (useDummyData) {
      return _dummyHistory();
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/sentiment/history?limit=$limit'),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil riwayat (${response.statusCode})');
    }
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => HistoryItem.fromJson(e)).toList();
  }

  // ---------------- DUMMY DATA (dipakai sebelum backend siap) ----------------

  Future<PredictionResult> _dummyPredict(String text) async {
    await Future.delayed(const Duration(milliseconds: 900)); // simulasi loading

    final labels = ['positif', 'netral', 'negatif'];
    final rnd = Random();
    final chosen = labels[rnd.nextInt(labels.length)];

    final probs = <String, double>{'positif': 0.1, 'netral': 0.1, 'negatif': 0.1};
    probs[chosen] = 0.7 + rnd.nextDouble() * 0.25;
    final total = probs.values.reduce((a, b) => a + b);
    probs.updateAll((key, value) => value / total);

    return PredictionResult(
      originalText: text,
      cleanText: text.toLowerCase().replaceAll(RegExp(r'[^a-z\s]'), '').trim(),
      predictedLabel: chosen,
      confidence: probs[chosen]!,
      probabilities: probs,
    );
  }

  Future<List<HistoryItem>> _dummyHistory() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final now = DateTime.now();
    return [
      HistoryItem(
        id: 3,
        originalText: 'aplikasinya bagus banget cepat responnya',
        predictedLabel: 'positif',
        confidence: 0.93,
        createdAt: now,
      ),
      HistoryItem(
        id: 2,
        originalText: 'kadang error pas jam sibuk',
        predictedLabel: 'netral',
        confidence: 0.61,
        createdAt: now.subtract(const Duration(minutes: 5)),
      ),
      HistoryItem(
        id: 1,
        originalText: 'lemot dan sering force close',
        predictedLabel: 'negatif',
        confidence: 0.88,
        createdAt: now.subtract(const Duration(minutes: 12)),
      ),
    ];
  }
}
