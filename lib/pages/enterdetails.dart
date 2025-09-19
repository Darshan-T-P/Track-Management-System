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
  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _lotNumberController = TextEditingController();
  final TextEditingController _installationLocationController = TextEditingController();
  // Add other controllers as needed...

  bool _isSubmitting = false;

  void _submitDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final details = {
      "manufacturer": _manufacturerController.text,
      "lot_number": _lotNumberController.text,
      "installation_location": _installationLocationController.text,
      // Add other fields following your ProductDetails model
    };

    final success = await ApiService.addProductDetails(widget.uuid, details);

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product details added successfully")),
      );
      Navigator.pop(context); // Go back to scanner or details screen
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
                controller: _manufacturerController,
                decoration: const InputDecoration(labelText: "Manufacturer"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _lotNumberController,
                decoration: const InputDecoration(labelText: "Lot Number"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _installationLocationController,
                decoration: const InputDecoration(labelText: "Installation Location"),
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              // Add more fields as needed
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
