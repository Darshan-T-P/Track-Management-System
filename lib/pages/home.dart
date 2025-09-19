import 'package:flutter/material.dart';
import 'package:tms/core/services/api_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final profile = await ApiService.getProfile();
    setState(() {
      user = profile;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? const Center(child: Text("No user info found"))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Name: ${user!['name']}", style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 8),
                      Text("Email: ${user!['email']}", style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text("Role: ${user!['role']}", style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
    );
  }
}
