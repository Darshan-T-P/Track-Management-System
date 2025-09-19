import 'package:flutter/material.dart';
import '../core/services/api_services.dart' show ApiService;

class EnterProductDetailsScreen extends StatefulWidget {
  final String uuid;
  const EnterProductDetailsScreen({super.key, required this.uuid});

  @override
  State<EnterProductDetailsScreen> createState() => _EnterProductDetailsScreenState();
}

class _EnterProductDetailsScreenState extends State<EnterProductDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for all fields
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _lotNumberController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();
  final TextEditingController _vendorController = TextEditingController();
  final TextEditingController _warrantyController = TextEditingController();
  final TextEditingController _installedByController = TextEditingController();
  final TextEditingController _installationLocationController = TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();

  DateTime? _manufactureDate;
  DateTime? _installationDate;
  DateTime? _supplyDate;

  bool _isSubmitting = false;

  Future<void> _pickDate(BuildContext context, TextEditingController controller, Function(DateTime) onPicked) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) onPicked(date);
  }

  void _submitDetails() async {
    if (!_formKey.currentState!.validate()) return;

    if (_manufactureDate == null || _installationDate == null || _supplyDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select all dates')));
      return;
    }

    setState(() => _isSubmitting = true);

    final details = {
      "product_name": _productNameController.text,
      "description": _descriptionController.text,
      "category": _categoryController.text,
      "manufacturer": _manufacturerController.text,
      "lot_number": _lotNumberController.text,
      "batch_id": _batchController.text,
      "vendor": _vendorController.text,
      "date_of_manufacture": _manufactureDate!.toIso8601String(),
      "date_of_supply": _supplyDate!.toIso8601String(),
      "warranty_period": _warrantyController.text,
      "installation_date": _installationDate!.toIso8601String(),
      "installation_location": _installationLocationController.text,
      "installed_by": _installedByController.text,
      "serial_number": _serialNumberController.text,
      "inspections": [],
      "reviews": [],
    };

    final result = await ApiService.addProductDetails(widget.uuid, details);
    final bool success = result == true;

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product details added successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add product details")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Product Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(labelText: "Product Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: "Category"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _manufacturerController,
                decoration: const InputDecoration(labelText: "Manufacturer"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _lotNumberController,
                decoration: const InputDecoration(labelText: "Lot Number"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _batchController,
                decoration: const InputDecoration(labelText: "Batch ID"),
              ),
              TextFormField(
                controller: _vendorController,
                decoration: const InputDecoration(labelText: "Vendor"),
              ),
              TextFormField(
                controller: _warrantyController,
                decoration: const InputDecoration(labelText: "Warranty Period"),
              ),
              TextFormField(
                controller: _installedByController,
                decoration: const InputDecoration(labelText: "Installed By"),
              ),
              TextFormField(
                controller: _installationLocationController,
                decoration: const InputDecoration(labelText: "Installation Location"),
              ),
              TextFormField(
                controller: _serialNumberController,
                decoration: const InputDecoration(labelText: "Serial Number"),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                  onPressed: () => _pickDate(context, TextEditingController(), (date) => _manufactureDate = date),
                  child: Text(_manufactureDate == null ? "Pick Manufacture Date" : _manufactureDate.toString())),
              ElevatedButton(
                  onPressed: () => _pickDate(context, TextEditingController(), (date) => _installationDate = date),
                  child: Text(_installationDate == null ? "Pick Installation Date" : _installationDate.toString())),
              ElevatedButton(
                  onPressed: () => _pickDate(context, TextEditingController(), (date) => _supplyDate = date),
                  child: Text(_supplyDate == null ? "Pick Supply Date" : _supplyDate.toString())),
              const SizedBox(height: 20),
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitDetails,
                      child: const Text("Submit"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
