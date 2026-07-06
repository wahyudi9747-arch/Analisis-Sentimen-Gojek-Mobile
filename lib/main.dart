import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const GojekSentimentApp());
}

class GojekSentimentApp extends StatelessWidget {
  const GojekSentimentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gojek Sentiment Analysis',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
