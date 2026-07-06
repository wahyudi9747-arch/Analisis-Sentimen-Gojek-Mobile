import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prediction_result.dart';
import '../services/sentiment_service.dart';
import '../widgets/probability_bar.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final SentimentService _service = SentimentService();
  late Future<List<HistoryItem>> _futureHistory;

  @override
  void initState() {
    super.initState();
    _futureHistory = _service.getHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Analisis')),
      body: FutureBuilder<List<HistoryItem>>(
        future: _futureHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat riwayat: ${snapshot.error}'));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada riwayat analisis.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final item = items[index];
              final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(item.createdAt);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: colorForLabel(item.predictedLabel),
                  child: Text(
                    item.predictedLabel.isNotEmpty
                        ? item.predictedLabel[0].toUpperCase()
                        : '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(item.originalText, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  '${item.predictedLabel} • ${(item.confidence * 100).toStringAsFixed(1)}% • $dateStr',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
