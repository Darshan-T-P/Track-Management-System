// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../core/services/api_services.dart';
// import '../data/models/auth_models.dart';
// import 'signup_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   bool _isPasswordVisible = false;
//   bool _isLoading = false;

  

//   @override
//   Widget build(BuildContext context) {
    
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         systemOverlayStyle: SystemUiOverlayStyle.dark,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header
//               const Center(
//                 child: Column(
//                   children: [
//                     Text(
//                       'Welcome Back',
//                       style: TextStyle(
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF1A1A1A),
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'Sign in to your account',
//                       style: TextStyle(fontSize: 16, color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 32),

//               // Login Form
//               Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     // Email Field
//                     TextFormField(
//                       controller: _emailController,
//                       keyboardType: TextInputType.emailAddress,
//                       decoration: InputDecoration(
//                         labelText: 'Email Address',
//                         prefixIcon: const Icon(Icons.email),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         filled: true,
//                         fillColor: Colors.white,
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your email';
//                         }
//                         if (!value.contains('@')) {
//                           return 'Please enter a valid email address';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 20),

//                     // Password Field
//                     TextFormField(
//                       controller: _passwordController,
//                       obscureText: !_isPasswordVisible,
//                       decoration: InputDecoration(
//                         labelText: 'Password',
//                         prefixIcon: const Icon(Icons.lock),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _isPasswordVisible
//                                 ? Icons.visibility
//                                 : Icons.visibility_off,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _isPasswordVisible = !_isPasswordVisible;
//                             });
//                           },
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         filled: true,
//                         fillColor: Colors.white,
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your password';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),

//                     // Forgot Password Link
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: TextButton(
//                         onPressed: _handleForgotPassword,
//                         child: const Text(
//                           'Forgot Password?',
//                           style: TextStyle(fontWeight: FontWeight.w600),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 32),

//                     // Login Button
//                     SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton(
//                         onPressed: _isLoading ? null : _handleLogin,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF1565C0),
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           elevation: 2,
//                         ),
//                         child: _isLoading
//                             ? const SizedBox(
//                                 width: 24,
//                                 height: 24,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   valueColor: AlwaysStoppedAnimation<Color>(
//                                     Colors.white,
//                                   ),
//                                 ),
//                               )
//                             : const Text(
//                                 'Sign In',
//                                 style: TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Sign Up Link
//               Center(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       "Don't have an account? ",
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const SignUpScreen(),
//                           ),
//                         );
//                       },
//                       child: const Text(
//                         'Sign Up',
//                         style: TextStyle(fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _handleLogin() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//       });

//       try {
//         // Create login request
//         final loginRequest = LoginRequest(
//           email: _emailController.text.trim(),
//           password: _passwordController.text,
//           deviceInfo: DeviceInfoHelper.getDeviceInfo(),
//         );

//         // Call API service
//         final response = await ApiService.login(loginRequest);

//         if (mounted) {
//           if (response.success) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(response.message ?? 'Login successful!'),
//                 backgroundColor: Colors.green,
//               ),
//             );

//             // Navigate to dashboard or main screen
//             // Navigator.pushReplacementNamed(context, '/dashboard');
//             Navigator.pop(context); // For now, just go back
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                   response.message ?? 'Login failed. Please try again.',
//                 ),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Login failed: ${e.toString()}'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       } finally {
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//           });
//         }
//       }
//     }
//   }

//   Future<void> _handleForgotPassword() async {
//     if (_emailController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter your email address first'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }

//     try {
//       final response = await ApiService.forgotPassword(
//         _emailController.text.trim(),
//       );

//       if (mounted) {
//         if (response != null && response.success) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(response.message ?? 'Password reset email sent'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(response?.message ?? 'Failed to send reset email'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
// }
