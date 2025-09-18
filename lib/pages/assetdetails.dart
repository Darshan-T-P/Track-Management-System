import 'package:flutter/material.dart';
import 'package:tms/core/services/api_services.dart';

class AssetDetailScreen extends StatelessWidget {
  final Map<String, dynamic> asset;
  const AssetDetailScreen({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    final assetInfo = asset['asset'];
    final inspections = asset['inspectionHistory'] as List<dynamic>;
    final reports = asset['reports'] as List<dynamic>;

    return Scaffold(
      appBar: AppBar(title: Text(assetInfo['type'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("QR: ${assetInfo['qrCode']}", style: const TextStyle(fontSize: 18)),
            Text("Location: ${assetInfo['location']}"),
            Text("Status: ${assetInfo['status']}"),
            const SizedBox(height: 16),

            const Text("Inspection History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...inspections.map((i) => ListTile(
                  title: Text(i['condition']),
                  subtitle: Text(i['remarks'] ?? ""),
                  trailing: Text(i['date']),
                )),

            const SizedBox(height: 16),
            const Text("Reports", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...reports.map((r) => ListTile(
                  title: Text(r['issue']),
                  trailing: Text(r['status']),
                )),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final success = await ApiService.reportIssue(assetInfo['qrCode'], "Loose fitting found");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? "Issue Reported" : "Failed to report")),
                );
              },
              child: const Text("Report Issue"),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await ApiService.logInspection(assetInfo['qrCode'], "Good", "No issues found");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? "Inspection Logged" : "Failed to log")),
                );
              },
              child: const Text("Log Inspection"),
            ),
          ],
        ),
      ),
    );
  }
}
