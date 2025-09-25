import 'package:flutter/material.dart';
import '../core/services/api_services.dart';

class VendorListScreen extends StatefulWidget {
  const VendorListScreen({super.key});

  @override
  State<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends State<VendorListScreen> {
  bool _isLoading = true;
  List<dynamic> _vendors = [];

  @override
  void initState() {
    super.initState();
    _fetchVendors();
  }

  Future<void> _fetchVendors() async {
    setState(() => _isLoading = true);
    try {
      final vendors = await ApiService.getVendors();
      setState(() {
        _vendors = vendors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load vendors: $e')));
    }
  }

  Future<void> _showVendorForm({Map<String, dynamic>? vendor}) async {
    final nameController = TextEditingController(
      text: vendor != null ? vendor['name'] : '',
    );
    String status = vendor != null ? vendor['status'] : 'active';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              vendor != null ? 'Edit Vendor' : 'Add Vendor',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Vendor Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: status,
              items: [
                'active',
                'inactive',
              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (value) {
                if (value != null) status = value;
              },
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final data = {'name': nameController.text, 'status': status};
                try {
                  if (vendor != null) {
                    // await ApiService.updateVendor(vendor['id'], data);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vendor updated')),
                    );
                  } else {
                    await ApiService.createVendor(data);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vendor added')),
                    );
                  }
                  Navigator.pop(context);
                  _fetchVendors();
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
              ),
              child: Text(vendor != null ? 'Update' : 'Add'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _showVendorActions(Map<String, dynamic> vendor) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Vendor'),
              onTap: () {
                Navigator.pop(context);
                _showVendorForm(vendor: vendor);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Vendor'),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: Text(
                      'Are you sure you want to delete ${vendor['name']}?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  try {
                    // await ApiService.deleteVendor(vendor['id']);
                    print('Delete vendor API call commented out for safety.');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vendor deleted')),
                    );
                    _fetchVendors();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error deleting vendor: $e')),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.toggle_on),
              title: const Text('Change Status'),
              onTap: () {}//async {
              //   Navigator.pop(context);
              //   final newStatus = vendor['status'] == 'active' ? 'inactive' : 'active';
              //   try {
              //     await ApiService.changeVendorStatus(vendor['id'], newStatus);
              //     ScaffoldMessenger.of(context).showSnackBar(
              //         const SnackBar(content: Text('Status updated')));
              //     _fetchVendors();
              //   } catch (e) {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //         SnackBar(content: Text('Error updating status: $e')));
              //   }
              // },
            ),
            ListTile(
              leading: const Icon(Icons.verified),
              title: const Text('Verify Vendor'),
              // onTap: () async {
              //   Navigator.pop(context);
              //   try {
              //     await ApiService.verifyVendor(vendor['id']);
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       const SnackBar(content: Text('Vendor verified')),
              //     );
              //     _fetchVendors();
              //   } catch (e) {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(content: Text('Error verifying vendor: $e')),
              //     );
              //   }
              // },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendors'),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchVendors,
              child: _vendors.isEmpty
                  ? const Center(child: Text('No vendors available'))
                  : ListView.builder(
                      itemCount: _vendors.length,
                      itemBuilder: (context, index) {
                        final vendor = _vendors[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(vendor['name'] ?? 'Unnamed Vendor'),
                            subtitle: Text(
                              'Status: ${vendor['status'] ?? "N/A"}',
                            ),
                            onTap: () => _showVendorActions(vendor),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showVendorForm(),
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.add),
      ),
    );
  }
}
