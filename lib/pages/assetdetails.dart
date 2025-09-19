import 'package:flutter/material.dart';

class AssetDetailScreen extends StatelessWidget {
  final Map<String, dynamic> asset;

  const AssetDetailScreen({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Asset Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("UUID: ${asset['uuid']}"),
            Text("Manufacturer: ${asset['details']['manufacturer'] ?? 'N/A'}"),
            Text("Batch Number: ${asset['details']['lot_number'] ?? 'N/A'}"),
            Text("Installation Date: ${asset['details']['installation_date'] ?? 'N/A'}"),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }
}
