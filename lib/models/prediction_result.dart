// Model ini merefleksikan skema `PredictionResponse` di backend
// (backend/app/models/schemas.py) supaya field-nya selalu sinkron.
class PredictionResult {
  final String originalText;
  final String cleanText;
  final String predictedLabel;
  final double confidence;
  final Map<String, double> probabilities;

  PredictionResult({
    required this.originalText,
    required this.cleanText,
    required this.predictedLabel,
    required this.confidence,
    required this.probabilities,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    final rawProbs = Map<String, dynamic>.from(json['probabilities'] ?? {});
    return PredictionResult(
      originalText: json['original_text'] ?? '',
      cleanText: json['clean_text'] ?? '',
      predictedLabel: json['predicted_label'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      probabilities: rawProbs.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );
  }
}

// Model ini sesuai PERSIS dengan hasil `get_history()` di backend/app/core/database.py
// (tabel `prediction_history`: id, original_text, predicted_label, confidence, created_at).
class HistoryItem {
  final int id;
  final String originalText;
  final String predictedLabel;
  final double confidence;
  final DateTime createdAt;

  HistoryItem({
    required this.id,
    required this.originalText,
    required this.predictedLabel,
    required this.confidence,
    required this.createdAt,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] ?? 0,
      originalText: json['original_text'] ?? '',
      predictedLabel: json['predicted_label'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '')?.toLocal() ?? DateTime.now(),
    );
  }
}
