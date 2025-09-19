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
      if (data != null && data['success'] == true) {
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
    "feedback": _reviewController.text,
    "rating": _rating,
  };

  try {
    final res = await ApiService.addReview(widget.uuid, reviewData);

    if (res['message'] == 'Review added successfully') {
      setState(() {
        _reviews.add(res['review']); // ✅ now backend sends this
        _reviewController.clear();
        _rating = 5;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review added')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${res['detail'] ?? "Unknown error"}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to add review: $e')),
    );
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
          : RefreshIndicator(
              onRefresh: _fetchProductDetails,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
            ),
    );
  }

  /// --- Basic Product Info ---
  Widget _buildBasicInfo() {
    final details = _product?['details'];
    if (details == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text("No product details available"),
        ),
      );
    }

    return Card(
      elevation: 2,
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
            const Divider(),
            _buildInfoRow('Manufacturer', details['manufacturer']),
            _buildInfoRow('Lot Number', details['lot_number']),
            _buildInfoRow('Manufactured On', details['date_of_manufacture']),
            _buildInfoRow('Supply Date', details['date_of_supply']),
            _buildInfoRow('Installation Date', details['installation_date']),
            _buildInfoRow('Installed By', details['installed_by']),
            _buildInfoRow('Vendor', details['vendor']),
            _buildInfoRow('Warranty', details['warranty_period']),
          ],
        ),
      ),
    );
  }

  /// --- Inspections ---
  Widget _buildInspections() {
    final inspections = _product?['details']?['inspections'] ?? [];
    return Card(
      elevation: 2,
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
            if (inspections.isEmpty)
              const Text("No inspections yet.")
            else
              ...inspections.map<Widget>((inspection) {
                return ListTile(
                  leading: Icon(
                    inspection['status'] == 'pass'
                        ? Icons.check_circle
                        : Icons.error,
                    color: inspection['status'] == 'pass'
                        ? Colors.green
                        : Colors.red,
                  ),
                  title: Text(inspection['inspector']),
                  subtitle: Text(
                      '${inspection['date']} - ${inspection['remarks'] ?? ''}'),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  /// --- Reviews ---
  Widget _buildReviewsSection() {
    return Card(
      elevation: 2,
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
              const Text("No reviews yet.")
            else
              ..._reviews.map<Widget>((review) {
                return ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: Text(review['reviewer']),
                  subtitle: Text(review['feedback']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < (review['rating'] ?? 0)
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 18,
                      ),
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  /// --- Add Review Form ---
  Widget _buildAddReviewSection() {
    return Card(
      elevation: 2,
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
                const Text("Rating: "),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _rating,
                  items: List.generate(
                    5,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('${index + 1}'),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _rating = value);
                    }
                  },
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _addReview,
                  icon: const Icon(Icons.send),
                  label: const Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 130, child: Text(label)),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
