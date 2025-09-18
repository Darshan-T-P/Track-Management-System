import 'package:flutter/material.dart';


class InspectionScreen extends StatelessWidget {
  final String qrCode;
  final String inspectionType;

  const InspectionScreen({
    super.key,
    required this.qrCode,
    required this.inspectionType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspection'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment, size: 80, color: Color(0xFF1565C0)),
            const SizedBox(height: 20),
            Text('Starting $inspectionType inspection'),
            Text('for QR Code: $qrCode'),
            const SizedBox(height: 20),
            const Text('Inspection screen coming soon...'),
          ],
        ),
      ),
    );
  }
}

class MaintenanceScreen extends StatelessWidget {
  final String qrCode;

  const MaintenanceScreen({super.key, required this.qrCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.build, size: 80, color: Colors.orange),
            const SizedBox(height: 20),
            Text('Maintenance for QR Code: $qrCode'),
            const SizedBox(height: 20),
            const Text('Maintenance screen coming soon...'),
          ],
        ),
      ),
    );
  }
}
