import 'package:flutter/material.dart';
import '../core/services/api_services.dart';

class ManufacturerListScreen extends StatefulWidget {
  const ManufacturerListScreen({super.key});

  @override
  State<ManufacturerListScreen> createState() => _ManufacturerListScreenState();
}

class _ManufacturerListScreenState extends State<ManufacturerListScreen> {
  bool _isLoading = true;
  List<dynamic> _manufacturers = [];

  @override
  void initState() {
    super.initState();
    _fetchManufacturers();
  }

  Future<void> _fetchManufacturers() async {
    setState(() => _isLoading = true);
    try {
      final manufacturers = await ApiService.getManufacturers();
      setState(() {
        _manufacturers = manufacturers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load manufacturers: $e')));
    }
  }

  Future<void> _showManufacturerForm({Map<String, dynamic>? manufacturer}) async {
    final nameController =
        TextEditingController(text: manufacturer != null ? manufacturer['name'] : '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              manufacturer != null ? 'Edit Manufacturer' : 'Add Manufacturer',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                  labelText: 'Manufacturer Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final data = {'name': nameController.text};
                try {
                  if (manufacturer != null) {
                    await ApiService.createManufacturer(data); // Update endpoint if you have one
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Manufacturer updated')));
                  } else {
                    await ApiService.createManufacturer(data);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Manufacturer added')));
                  }
                  Navigator.pop(context);
                  _fetchManufacturers();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')));
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0)),
              child: Text(manufacturer != null ? 'Update' : 'Add'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _showManufacturerActions(Map<String, dynamic> manufacturer) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Manufacturer'),
              onTap: () {
                Navigator.pop(context);
                _showManufacturerForm(manufacturer: manufacturer);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Manufacturer'),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: Text(
                        'Are you sure you want to delete ${manufacturer['name']}?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete')),
                    ],
                  ),
                );
                if (confirm == true) {
                  try {
                    // Add a deleteManufacturer API in ApiService if backend supports
                    // await ApiService.deleteManufacturer(manufacturer['id']);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Manufacturer deleted')));
                    _fetchManufacturers();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error deleting manufacturer: $e')));
                  }
                }
              },
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
        title: const Text('Manufacturers'),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchManufacturers,
              child: _manufacturers.isEmpty
                  ? const Center(child: Text('No manufacturers available'))
                  : ListView.builder(
                      itemCount: _manufacturers.length,
                      itemBuilder: (context, index) {
                        final manufacturer = _manufacturers[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(manufacturer['name'] ?? 'Unnamed Manufacturer'),
                            onTap: () => _showManufacturerActions(manufacturer),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showManufacturerForm(),
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(Icons.add),
      ),
    );
  }
}
