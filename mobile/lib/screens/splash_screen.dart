import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 5));
    final prefs = await SharedPreferences.getInstance();
    final roleId = prefs.getInt('user_role');

    if (!mounted) return;
    
    if (roleId != null) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031D44),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 120, errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.business, size: 80, color: Color(0xFFCDEDF6)); // Fallback jika logo tidak terbaca
            }),
            const SizedBox(height: 20),
            const Text(
              "Data Center",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Color(0xFFCDEDF6),
              ),
            ),
            const Text(
              "Facility Information System",
              style: TextStyle(fontSize: 14, color: Colors.white70, letterSpacing: 3),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Color(0xFF1B4C50)),
          ],
        ),
      ),
    );
  }
}
// === MOBILE DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) ===