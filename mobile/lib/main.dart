import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/ip_screen.dart'; 
import 'screens/server_screen.dart'; 
import 'screens/piket_screen.dart';
import 'screens/piket_input_screen.dart';

//const String apiUrl = "http://localhost:8080"; 
const String apiUrl = "https://labs-api-dcfmis.net"; 

const Map<String, String> apiHeaders = {
  "Content-Type": "application/json",
  "X-App-Token": "[o0Ht1407!=5437ul=@K8R{*?zQL36;}0o]123"
};

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIMPUSDAT Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF031D44), 
        primaryColor: const Color(0xFF103B3E), 
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF103B3E),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/ip_screen': (context) => const IpScreen(),
        '/server_screen': (context) => const ServerScreen(),
        '/piket': (context) => const PiketScreen(), 
        '/piket_input': (context) => const PiketInputScreen(), 
      },
    );
  }
}
// === MOBILE DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) ===