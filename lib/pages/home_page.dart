import 'package:flutter/material.dart';
import '../models/prediction_result.dart';
import '../services/sentiment_service.dart';
import '../widgets/probability_bar.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final SentimentService _service = SentimentService();

  bool _loading = false;
  String? _error;
  PredictionResult? _result;

  Future<void> _analyze() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Masukkan teks ulasan terlebih dahulu');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await _service.predict(text);
      setState(() => _result = result);
    } catch (e) {
      setState(() => _error = 'Gagal terhubung ke server: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analisis Sentimen Gojek'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryPage()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (SentimentService.useDummyData)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Text(
                  'Mode DUMMY DATA aktif — hasil masih acak, belum dari model asli. '
                  'Set useDummyData = false di sentiment_service.dart setelah backend siap.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            const Text(
              'Tulis ulasan tentang aplikasi Gojek:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Contoh: aplikasinya sering error pas jam sibuk...',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loading ? null : _analyze,
              icon: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(_loading ? 'Menganalisis...' : 'Analisis Sentimen'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            if (_result != null) ...[
              const SizedBox(height: 20),
              _buildResultCard(_result!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(PredictionResult result) {
    final color = colorForLabel(result.predictedLabel);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.label, color: color),
                const SizedBox(width: 8),
                Text(
                  'Sentimen: ${result.predictedLabel.toUpperCase()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%'),
            const Divider(height: 24),
            const Text('Distribusi probabilitas per kelas:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...result.probabilities.entries
                .map((e) => ProbabilityBar(label: e.key, value: e.value)),
            const Divider(height: 24),
            const Text('Teks setelah preprocessing:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              result.cleanText,
              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
