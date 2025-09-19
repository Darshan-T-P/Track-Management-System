// import 'package:flutter/material.dart';

// import 'aireport.dart';
// import 'inspection.dart';

// class QRDetailsScreen extends StatefulWidget {
//   final Map<String, dynamic> qrData;

//   const QRDetailsScreen({super.key, required this.qrData});

//   @override
//   State<QRDetailsScreen> createState() => _QRDetailsScreenState();
// }

// class _QRDetailsScreenState extends State<QRDetailsScreen> {
//   bool _isLoading = true;
//   Map<String, dynamic>? _fittingDetails;
//   List<Map<String, dynamic>> _inspectionHistory = [];
//   String _scanPurpose = 'inspection';

//   @override
//   void initState() {
//     super.initState();
//     _loadFittingDetails();
//   }

//   Future<void> _loadFittingDetails() async {
//     // Simulate API call to fetch detailed information
//     await Future.delayed(const Duration(seconds: 1));
    
//     setState(() {
//       _fittingDetails = {
//         'qr_code': widget.qrData['qr_code'],
//         'fitting_category': 'Elastic Rail Clip',
//         'fitting_type': 'Type A - Heavy Duty',
//         'batch_number': widget.qrData['batch_number'],
//         'manufacturer': widget.qrData['manufacturer'],
//         'manufacturing_date': widget.qrData['manufacturing_date'],
//         'installation_date': '2024-02-01',
//         'warranty_end_date': '2026-02-01',
//         'expected_life_years': 5,
//         'current_status': 'in_service',
//         'installation_location': {
//           'zone': 'Central Railway',
//           'division': 'Mumbai Division',
//           'station': 'CST',
//           'track_section': 'Platform 1-2',
//           'kilometer_post': '0.5 KM'
//         },
//         'specifications': {
//           'material': 'Spring Steel',
//           'dimensions': '150x75x25 mm',
//           'weight': '0.85 kg',
//           'load_capacity': '25 tons'
//         }
//       };

//       _inspectionHistory = [
//         {
//           'date': '2024-03-01',
//           'type': 'routine',
//           'inspector': 'John Doe',
//           'result': 'pass',
//           'notes': 'Good condition, no defects found'
//         },
//         {
//           'date': '2024-02-15',
//           'type': 'installation',
//           'inspector': 'Jane Smith',
//           'result': 'pass',
//           'notes': 'Properly installed as per specifications'
//         },
//       ];

//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text('Fitting Details'),
//         backgroundColor: const Color(0xFF1565C0),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           PopupMenuButton<String>(
//             onSelected: _handleMenuAction,
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                 value: 'share',
//                 child: ListTile(
//                   leading: Icon(Icons.share),
//                   title: Text('Share'),
//                   dense: true,
//                 ),
//               ),
//               const PopupMenuItem(
//                 value: 'report',
//                 child: ListTile(
//                   leading: Icon(Icons.report),
//                   title: Text('Report Issue'),
//                   dense: true,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildQRCodeCard(),
//                   const SizedBox(height: 16),
//                   _buildBasicInfoCard(),
//                   const SizedBox(height: 16),
//                   _buildLocationCard(),
//                   const SizedBox(height: 16),
//                   _buildSpecificationsCard(),
//                   const SizedBox(height: 16),
//                   _buildStatusCard(),
//                   const SizedBox(height: 16),
//                   _buildInspectionHistoryCard(),
//                   const SizedBox(height: 16),
//                   _buildActionButtons(),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildQRCodeCard() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Container(
//               width: 80,
//               height: 80,
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: const Icon(
//                 Icons.qr_code,
//                 size: 40,
//                 color: Color(0xFF1565C0),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _fittingDetails!['qr_code'],
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     _fittingDetails!['fitting_category'],
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: _getStatusColor(_fittingDetails!['current_status']),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       _fittingDetails!['current_status'].toString().replaceAll('_', ' ').toUpperCase(),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBasicInfoCard() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Basic Information',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 12),
//             _buildInfoRow('Fitting Type', _fittingDetails!['fitting_type']),
//             _buildInfoRow('Batch Number', _fittingDetails!['batch_number']),
//             _buildInfoRow('Manufacturer', _fittingDetails!['manufacturer']),
//             _buildInfoRow('Manufacturing Date', _fittingDetails!['manufacturing_date']),
//             _buildInfoRow('Installation Date', _fittingDetails!['installation_date']),
//             _buildInfoRow('Warranty Until', _fittingDetails!['warranty_end_date']),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLocationCard() {
//     final location = _fittingDetails!['installation_location'];
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Installation Location',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 12),
//             _buildInfoRow('Zone', location['zone']),
//             _buildInfoRow('Division', location['division']),
//             _buildInfoRow('Station', location['station']),
//             _buildInfoRow('Track Section', location['track_section']),
//             _buildInfoRow('Kilometer Post', location['kilometer_post']),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSpecificationsCard() {
//     final specs = _fittingDetails!['specifications'];
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Technical Specifications',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 12),
//             _buildInfoRow('Material', specs['material']),
//             _buildInfoRow('Dimensions', specs['dimensions']),
//             _buildInfoRow('Weight', specs['weight']),
//             _buildInfoRow('Load Capacity', specs['load_capacity']),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusCard() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Status & Lifecycle',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildStatusItem(
//                     'Current Status',
//                     _fittingDetails!['current_status'].toString().replaceAll('_', ' ').toUpperCase(),
//                     _getStatusColor(_fittingDetails!['current_status']),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: _buildStatusItem(
//                     'Expected Life',
//                     '${_fittingDetails!['expected_life_years']} years',
//                     Colors.blue,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             LinearProgressIndicator(
//               value: 0.7, // Calculate based on installation date and expected life
//               backgroundColor: Colors.grey[300],
//               valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               '70% of lifecycle completed',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInspectionHistoryCard() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Inspection History',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 12),
//             ..._inspectionHistory.map((inspection) => _buildInspectionItem(inspection)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButtons() {
//     return Column(
//       children: [
//         // Scan Purpose Selection
//         Card(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Scan Purpose',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 DropdownButtonFormField<String>(
//                   initialValue: _scanPurpose,
//                   decoration: const InputDecoration(
//                     border: OutlineInputBorder(),
//                     contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   ),
//                   items: const [
//                     DropdownMenuItem(value: 'inspection', child: Text('Routine Inspection')),
//                     DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
//                     DropdownMenuItem(value: 'inventory', child: Text('Inventory Check')),
//                     DropdownMenuItem(value: 'emergency', child: Text('Emergency Check')),
//                   ],
//                   onChanged: (value) {
//                     setState(() {
//                       _scanPurpose = value!;
//                     });
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(height: 16),
        
//         // Action Buttons
//         Row(
//           children: [
//             Expanded(
//               child: ElevatedButton.icon(
//                 onPressed: () => _startInspection(),
//                 icon: const Icon(Icons.assignment),
//                 label: const Text('Start Inspection'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF1565C0),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: ElevatedButton.icon(
//                 onPressed: () => _recordMaintenance(),
//                 icon: const Icon(Icons.build),
//                 label: const Text('Maintenance'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.orange,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton.icon(
//             onPressed: () => _generateAIReport(),
//             icon: const Icon(Icons.analytics),
//             label: const Text('Generate AI Analysis Report'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.purple,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 12),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: TextStyle(
//                 color: Colors.grey[600],
//                 fontSize: 14,
//               ),
//             ),
//           ),
//           const Text(': '),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w500,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusItem(String label, String value, Color color) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: color.withOpacity(0.3)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontSize: 12,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: TextStyle(
//               color: color,
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInspectionItem(Map<String, dynamic> inspection) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         border: const Border(
//           left: BorderSide(
//             color: Color(0xFF1565C0),
//             width: 3,
//           ),
//         ),
//         color: Colors.grey[50],
//         borderRadius: const BorderRadius.only(
//           topRight: Radius.circular(8),
//           bottomRight: Radius.circular(8),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 inspection['date'],
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: inspection['result'] == 'pass' ? Colors.green : Colors.red,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Text(
//                   inspection['result'].toUpperCase(),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 10,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 4),
//           Text(
//             '${inspection['type'].toString().replaceAll('_', ' ').toUpperCase()} - ${inspection['inspector']}',
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontSize: 12,
//             ),
//           ),
//           if (inspection['notes'] != null) ...[
//             const SizedBox(height: 4),
//             Text(
//               inspection['notes'],
//               style: const TextStyle(fontSize: 12),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'in_service':
//         return Colors.green;
//       case 'maintenance_due':
//         return Colors.orange;
//       case 'failed':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   void _handleMenuAction(String action) {
//     switch (action) {
//       case 'share':
//         // Implement share functionality
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Sharing QR details...')),
//         );
//         break;
//       case 'report':
//         // Implement report issue functionality
//         _showReportDialog();
//         break;
//     }
//   }

//   void _startInspection() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => InspectionScreen(
//           qrCode: _fittingDetails!['qr_code'],
//           inspectionType: _scanPurpose,
//         ),
//       ),
//     );
//   }

//   void _recordMaintenance() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MaintenanceScreen(
//           qrCode: _fittingDetails!['qr_code'],
//         ),
//       ),
//     );
//   }

//   void _generateAIReport() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AIReportScreen(
//           qrCode: _fittingDetails!['qr_code'],
//         ),
//       ),
//     );
//   }

//   void _showReportDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Report Issue'),
//         content: const Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text('What type of issue would you like to report?'),
//             SizedBox(height: 16),
//             // Add issue type selection
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Issue reported successfully')),
//               );
//             },
//             child: const Text('Report'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// qr_details_screen.dart
import 'package:flutter/material.dart';
import '../core/services/api_services.dart';

class QRDetailsScreen extends StatefulWidget {
  final String uuid;

  const QRDetailsScreen({super.key, required this.uuid});

  @override
  State<QRDetailsScreen> createState() => _QRDetailsScreenState();
}

class _QRDetailsScreenState extends State<QRDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _product;
  List<dynamic> _reviews = [];

  final _reviewController = TextEditingController();
  int _rating = 5;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    try {
      final data = await ApiService.getProductByUuid(widget.uuid);
      if (data!['success'] == true) {
        setState(() {
          _product = data['product'];
          _reviews = _product?['details']?['reviews'] ?? [];
          _isLoading = false;
        });
      } else {
        _showError('Product not found');
      }
    } catch (e) {
      _showError('Failed to load product');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
    setState(() => _isLoading = false);
  }

  Future<void> _addReview() async {
    if (_reviewController.text.isEmpty) return;

    final reviewData = {
      "reviewer": "Mobile User",
      "date": DateTime.now().toIso8601String(),
      "feedback": _reviewController.text,
      "rating": _rating
    };

    try {
      final res = await ApiService.addReview(widget.uuid, reviewData);
      if (res['message'] == 'Review added successfully') {
        setState(() {
          _reviews.add(reviewData);
          _reviewController.clear();
          _rating = 5;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Review added')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to add review')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfo(),
                  const SizedBox(height: 16),
                  _buildInspections(),
                  const SizedBox(height: 16),
                  _buildReviewsSection(),
                  const SizedBox(height: 16),
                  _buildAddReviewSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildBasicInfo() {
    final details = _product?['details'];
    if (details == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              details['product_name'] ?? 'Unnamed Product',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Manufacturer: ${details['manufacturer'] ?? 'N/A'}'),
            Text('Lot Number: ${details['lot_number'] ?? 'N/A'}'),
            Text(
                'Manufactured On: ${details['date_of_manufacture'] ?? 'N/A'}'),
            Text('Vendor: ${details['vendor'] ?? 'N/A'}'),
            Text('Warranty: ${details['warranty_period'] ?? 'N/A'}'),
            Text('Installed By: ${details['installed_by'] ?? 'N/A'}'),
            Text('Installation Date: ${details['installation_date'] ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInspections() {
    final inspections = _product?['details']?['inspections'] ?? [];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inspection History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...inspections.map<Widget>((inspection) {
              return ListTile(
                title: Text(inspection['inspector']),
                subtitle: Text(
                    '${inspection['date']} - ${inspection['remarks'] ?? ''}'),
                leading: const Icon(Icons.check_circle_outline),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reviews',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_reviews.isEmpty)
              const Text('No reviews yet.')
            else
              ..._reviews.map<Widget>((review) {
                return ListTile(
                  title: Text(review['reviewer']),
                  subtitle: Text('${review['feedback']}'),
                  trailing: Text('${review['rating']}/5'),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddReviewSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Review',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your feedback',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Rating:'),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _rating,
                  items: List.generate(
                      5,
                      (index) => DropdownMenuItem(
                          value: index + 1, child: Text('${index + 1}'))),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _rating = value);
                    }
                  },
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _addReview,
                  child: const Text('Submit'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}


