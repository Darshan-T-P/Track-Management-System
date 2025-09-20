import 'package:flutter/material.dart';
import 'package:tms/core/services/api_services.dart';
import 'package:tms/pages/qr_screen.dart';

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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Track Management System"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? const Center(child: Text("No user info found"))
              : Column(
                  children: [
                    // Stack for Welcome + Overlapping QR Button
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Welcome Gradient Header
                        Container(
                          height: 180,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color.fromARGB(255, 144, 46, 193), Color(0xFF2575FC)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(170),
                              bottomRight: Radius.circular(170),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Welcome !!",
                                style: TextStyle(
                                  fontSize: 22,
                                  // fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              // const SizedBox(width: 80),
                              Text(
                                user!['name'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ), // spacing for QR button
                            ],
                          ),
                        ),

                        // Overlapping QR Scan Button
                        Positioned(
                          bottom: -100, // half outside
                          left: 0,
                          right: 0,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const QRScannerScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF2575FC), Color(0xFF6A11CB)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.qr_code_scanner,
                                          color: Colors.white, size: 52),
                                      SizedBox(height: 8),
                                      Text(
                                        "Scan QR",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 100),

                    // Reports Section Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Reports",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Glassmorphic Reports Card
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListView(
                            padding: const EdgeInsets.all(12),
                            children: const [
                              ListTile(
                                leading: Icon(Icons.description, color: Colors.blue),
                                title: Text("Inspection Report #1"),
                                subtitle: Text("2 days ago"),
                                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              ),
                              Divider(),
                              ListTile(
                                leading: Icon(Icons.build, color: Colors.green),
                                title: Text("Maintenance Report #2"),
                                subtitle: Text("5 days ago"),
                                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              ),
                              Divider(),
                              ListTile(
                                leading: Icon(Icons.warning, color: Colors.red),
                                title: Text("Alert Report #3"),
                                subtitle: Text("1 week ago"),
                                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
