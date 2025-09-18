import 'package:flutter/material.dart';

class AIReportScreen extends StatelessWidget {
  final String qrCode;

  const AIReportScreen({super.key, required this.qrCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Analysis Report'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics, size: 80, color: Colors.purple),
            const SizedBox(height: 20),
            Text('Generating AI report for QR Code: $qrCode'),
            const SizedBox(height: 20),
            const Text('AI analysis screen coming soon...'),
          ],
        ),
      ),
    );
  }
}