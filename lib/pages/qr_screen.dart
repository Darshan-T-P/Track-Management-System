// // qr_scanner_screen.dart
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import './qr_details.dart';

// // Mock QR Scanner - Replace with actual qr_code_scanner package
// class QRScannerScreen extends StatefulWidget {
//   const QRScannerScreen({super.key});

//   @override
//   State<QRScannerScreen> createState() => _QRScannerScreenState();
// }

// class _QRScannerScreenState extends State<QRScannerScreen> {
//   bool _isScanning = false;
//   bool _flashOn = false;
//   String? _scannedData;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Scan QR Code',
//           style: TextStyle(color: Colors.white),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(
//               _flashOn ? Icons.flash_on : Icons.flash_off,
//               color: Colors.white,
//             ),
//             onPressed: _toggleFlash,
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           // Camera Preview Area (Mock)
//           Container(
//             width: double.infinity,
//             height: double.infinity,
//             color: Colors.black,
//             child: Center(
//               child: Container(
//                 width: 250,
//                 height: 250,
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: Colors.white,
//                     width: 2,
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Center(
//                   child: Text(
//                     'Point camera at QR Code',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // Scanning overlay
//           if (_isScanning)
//             Container(
//               width: double.infinity,
//               height: double.infinity,
//               color: Colors.black.withOpacity(0.5),
//               child: const Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               ),
//             ),

//           // Bottom controls
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.all(20),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                 ),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       ElevatedButton.icon(
//                         onPressed: _simulateScan,
//                         icon: const Icon(Icons.qr_code_scanner),
//                         label: const Text('Simulate Scan'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF1565C0),
//                           foregroundColor: Colors.white,
//                         ),
//                       ),
//                       ElevatedButton.icon(
//                         onPressed: _scanFromGallery,
//                         icon: const Icon(Icons.photo),
//                         label: const Text('From Gallery'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.grey[600],
//                           foregroundColor: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     'Align QR code within the frame to scan',
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _toggleFlash() {
//     setState(() {
//       _flashOn = !_flashOn;
//     });
//   }

//   void _simulateScan() {
//     setState(() {
//       _isScanning = true;
//     });

//     // Simulate scanning delay
//     Future.delayed(const Duration(seconds: 2), () {
//       final mockQRData = {
//         'qr_code': 'QR-RC-2024-001234',
//         'fitting_type': 'elastic_rail_clip',
//         'batch_number': 'BATCH-2024-0001',
//         'manufacturer': 'ABC Rail Fittings Ltd',
//         'manufacturing_date': '2024-01-15',
//         'installation_location': 'Zone: CR, Division: Mumbai, Station: CST'
//       };

//       setState(() {
//         _isScanning = false;
//         _scannedData = json.encode(mockQRData);
//       });

//       _showQRDetails(mockQRData);
//     });
//   }

//   void _scanFromGallery() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Gallery scanning feature coming soon')),
//     );
//   }

//   void _showQRDetails(Map<String, dynamic> qrData) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => QRDetailsScreen(qrData: qrData),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../core/services/api_services.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
  if (isProcessing) return;
  if (capture.barcodes.isEmpty) return;

  final qrCode = capture.barcodes.first.rawValue;
  if (qrCode == null || qrCode.isEmpty) return;

  setState(() => isProcessing = true);

  // --- Step 1: Extract UUID from QR code ---
  String? uuid;
  try {
    final uri = Uri.parse(qrCode);
    // If QR contains full URL, get last path segment as UUID
    uuid = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : qrCode;
  } catch (e) {
    // If QR is just a raw UUID
    uuid = qrCode;
  }

  if (uuid == null || uuid.isEmpty) {
    debugPrint('UUID not found in QR code');
    setState(() => isProcessing = false);
    return;
  }

  // --- Step 2: Fetch product from FastAPI ---
  Map<String, dynamic>? productData;
  try {
    productData = await ApiService.getProductByUuid(uuid);
  } catch (e) {
    debugPrint('Error fetching product: $e');
  }

  if (!mounted) return;

  // --- Step 3: Show product details or error ---
  if (productData == null || productData['success'] != true) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: const Text('Product not found or invalid QR code'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  } else {
    final product = productData['product'];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Product: ${product['uuid']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('QR Code URL: ${product['qr_code_url']}'),
              Text('Details Entered: ${product['details_entered']}'),
              const SizedBox(height: 8),
              if (product['details'] != null)
                Text('Details:\n${jsonEncode(product['details'])}'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  // --- Step 4: Reset scanning state ---
  Future.delayed(const Duration(seconds: 2), () {
    if (mounted) setState(() => isProcessing = false);
  });
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Asset QR")),
      body: MobileScanner(onDetect: _onDetect),
    );
  }
}
