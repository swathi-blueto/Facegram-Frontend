import 'package:flutter/material.dart';
import 'package:project/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await AuthService.getToken();
    final role = await AuthService.getRole();

    await Future.delayed(const Duration(seconds: 2)); // Splash delay

    if (token != null) {
      // User is logged in, navigate based on role
      Navigator.pushReplacementNamed(
        context, 
        role == 'admin' ? '/admin-dashboard' : '/home'
      );
    } else {
      // User is not logged in
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}