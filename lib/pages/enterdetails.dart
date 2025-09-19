import 'package:flutter/material.dart';
import '../core/services/api_services.dart' show ApiService;

class EnterProductDetailsScreen extends StatefulWidget {
  final String uuid;
  const EnterProductDetailsScreen({super.key, required this.uuid});

  @override
  State<EnterProductDetailsScreen> createState() =>
      _EnterProductDetailsScreenState();
}

class _EnterProductDetailsScreenState extends State<EnterProductDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _productNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _lotNumberController = TextEditingController();
  final _batchController = TextEditingController();
  final _vendorController = TextEditingController();
  final _warrantyController = TextEditingController();
  final _installedByController = TextEditingController();
  final _installationLocationController = TextEditingController();
  final _serialNumberController = TextEditingController();

  DateTime? _manufactureDate;
  DateTime? _installationDate;
  DateTime? _supplyDate;

  bool _isSubmitting = false;

  Future<void> _pickDate(BuildContext context, Function(DateTime) onPicked) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      onPicked(date);
      setState(() {}); // refresh UI
    }
  }

  Future<void> _submitDetails() async {
    if (!_formKey.currentState!.validate()) return;

    if (_manufactureDate == null || _installationDate == null || _supplyDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all dates')),
      );
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
    };

    try {
      final result = await ApiService.addProductDetails(widget.uuid, details);

      setState(() => _isSubmitting = false);

      if (result["success"] == true) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(result["message"] ?? "Details saved")),
  );
  Navigator.pop(context);
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(result["message"] ?? "Failed to add product details")),
  );
}
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Widget _buildDateField(String label, DateTime? date, Function(DateTime) onPicked) {
    return InkWell(
      onTap: () => _pickDate(context, onPicked),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(date == null ? "Select date" : date.toLocal().toString().split(' ')[0]),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool required = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (v) => required && v!.isEmpty ? "Required" : null,
    );
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
              const Text("Product Info", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildTextField("Product Name", _productNameController, required: true),
              const SizedBox(height: 12),
              _buildTextField("Description", _descriptionController, required: true),
              const SizedBox(height: 12),
              _buildTextField("Category", _categoryController),

              const SizedBox(height: 20),
              const Text("Manufacturing", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildTextField("Manufacturer", _manufacturerController, required: true),
              const SizedBox(height: 12),
              _buildTextField("Lot Number", _lotNumberController, required: true),
              const SizedBox(height: 12),
              _buildTextField("Batch ID", _batchController),
              const SizedBox(height: 12),
              _buildDateField("Date of Manufacture", _manufactureDate, (d) => _manufactureDate = d),

              const SizedBox(height: 20),
              const Text("Supply", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildTextField("Vendor", _vendorController),
              const SizedBox(height: 12),
              _buildDateField("Date of Supply", _supplyDate, (d) => _supplyDate = d),
              const SizedBox(height: 12),
              _buildTextField("Warranty Period", _warrantyController),

              const SizedBox(height: 20),
              const Text("Installation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildDateField("Installation Date", _installationDate, (d) => _installationDate = d),
              const SizedBox(height: 12),
              _buildTextField("Installation Location", _installationLocationController),
              const SizedBox(height: 12),
              _buildTextField("Installed By", _installedByController),
              const SizedBox(height: 12),
              _buildTextField("Serial Number", _serialNumberController),

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
