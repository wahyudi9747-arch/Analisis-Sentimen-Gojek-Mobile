import 'package:flutter/material.dart';

Color colorForLabel(String label) {
  switch (label.toLowerCase()) {
    case 'positif':
      return Colors.green;
    case 'netral':
      return Colors.amber;
    case 'negatif':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

class ProbabilityBar extends StatelessWidget {
  final String label;
  final double value; // 0.0 - 1.0

  const ProbabilityBar({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label[0].toUpperCase() + label.substring(1)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: value.clamp(0.0, 1.0),
                minHeight: 14,
                backgroundColor: Colors.grey.shade200,
                color: colorForLabel(label),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(width: 48, child: Text('$percent%')),
        ],
      ),
    );
  }
}
