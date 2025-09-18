import 'package:flutter/material.dart';
import 'pages/home.dart';
import 'pages/dashboard.dart';
import 'pages/main_screen.dart';
import 'pages/qr_screen.dart';
import 'pages/signup_screen.dart';
import 'pages/signin.dart';
import 'splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RailwayQRApp());
}

class RailwayQRApp extends StatelessWidget {
  const RailwayQRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Railway QR Track Fittings',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1565C0), // Railway Blue
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/main': (context) => const MainScreen(),
        '/home': (context) => const HomeScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/qrscanner': (context) => const QRScannerScreen(),
      },
    );
  }
}
