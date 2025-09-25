import 'package:flutter/material.dart';
import '../core/services/api_services.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  bool _isLoading = false;
  String? _qrUrl; // Node.js QR code URL

  List<dynamic> _vendors = [];
  List<dynamic> _manufacturers = [];
  List<dynamic> _batches = [];
  final List<String> _itemTypes = ["Clip", "Pad", "Liner", "Sleeper"];

  String? _selectedVendor;
  String? _selectedManufacturer;
  String? _selectedBatch;
  String? _selectedItemType;

  final _productNameController = TextEditingController();
  final _lotController = TextEditingController();
  final _installedByController = TextEditingController();
  final _warrantyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDropdownData();
  }

  Future<void> _fetchDropdownData() async {
    try {
      final vendors = await ApiService.getVendors();
      final manufacturers = await ApiService.getManufacturers();
      final batches = await ApiService.getBatches();
      setState(() {
        _vendors = vendors;
        _manufacturers = manufacturers;
        _batches = batches;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch dropdowns: $e')),
      );
    }
  }

  Future<void> _submitProduct() async {
    if (_productNameController.text.isEmpty ||
        _selectedItemType == null ||
        _selectedVendor == null ||
        _selectedManufacturer == null ||
        _selectedBatch == null ||
        _lotController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final productData = {
      "productName": _productNameController.text,
      "itemType": _selectedItemType,
      "vendorId": _selectedVendor,
      "manufacturerId": _selectedManufacturer,
      "batchNumber": _selectedBatch,
      "lotNumber": _lotController.text,
      "installedBy": _installedByController.text,
      "warrantyPeriod": _warrantyController.text,
      "dateOfManufacture": DateTime.now().toIso8601String(),
      "dateOfSupply": DateTime.now().toIso8601String(),
    };

    try {
      final createdProduct = await ApiService.createProduct(productData);

      // Fetch QR code URL from Node.js backend
      final uuid = createdProduct['uuid'];
      _qrUrl = await ApiService.getQrUrl(uuid);

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product created successfully!')),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Product')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _productNameController,
                    decoration:
                        const InputDecoration(labelText: 'Product Name *'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Item Type *'),
                    items: _itemTypes
                        .map((type) =>
                            DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    value: _selectedItemType,
                    onChanged: (val) => setState(() => _selectedItemType = val),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Vendor *'),
                    items: _vendors
                        .map((v) => DropdownMenuItem(
                              value: v['_id']?.toString(),
                              child: Text(v['name'] ?? ''),
                            ))
                        .toList(),
                    value: _selectedVendor,
                    onChanged: (val) => setState(() => _selectedVendor = val),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Manufacturer *'),
                    items: _manufacturers
                        .map((m) => DropdownMenuItem(
                              value: m['_id']?.toString(),
                              child: Text(m['name'] ?? ''),
                            ))
                        .toList(),
                    value: _selectedManufacturer,
                    onChanged: (val) =>
                        setState(() => _selectedManufacturer = val),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Batch *'),
                    items: _batches
                        .map((b) => DropdownMenuItem(
                              value: b['batchNumber']?.toString(),
                              child: Text(b['batchNumber'] ?? ''),
                            ))
                        .toList(),
                    value: _selectedBatch,
                    onChanged: (val) => setState(() => _selectedBatch = val),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _lotController,
                    decoration:
                        const InputDecoration(labelText: 'Lot Number *'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _installedByController,
                    decoration:
                        const InputDecoration(labelText: 'Installed By'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _warrantyController,
                    decoration:
                        const InputDecoration(labelText: 'Warranty Period'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitProduct,
                    child: const Text('Create Product'),
                  ),
                  if (_qrUrl != null) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: Image.network(
                        _qrUrl!,
                        width: 150,
                        height: 150,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text('Failed to load QR code');
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
