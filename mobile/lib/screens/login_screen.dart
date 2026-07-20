import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int step = 1;
  bool isLoading = false;

  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController answerCtrl = TextEditingController();

  Map<String, dynamic> mathChallenge = {};

  Future<void> handleLogin() async {
    if (emailCtrl.text.isEmpty || passCtrl.text.isEmpty) {
      _showError("Email dan Kata Sandi tidak boleh kosong!");
      return;
    }

    setState(() => isLoading = true);
    try {
      final res = await http.post(
        Uri.parse('$apiUrl/api/auth/login-step1'),
        headers: apiHeaders,
        body: jsonEncode({"email": emailCtrl.text, "password": passCtrl.text}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          mathChallenge = data['math'];
          step = 2; 
        });
      } else {
        _showError("Email atau Password salah!");
      }
    } catch (e) {
      _showError("Gagal terhubung ke Server API.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> verifyMath() async {
    if (answerCtrl.text.isEmpty) {
      _showError("Jawaban matematika harus diisi!");
      return;
    }

    setState(() => isLoading = true);
    try {
      final res = await http.post(
        Uri.parse('$apiUrl/api/auth/verify-math'),
        headers: apiHeaders,
        body: jsonEncode({
          "email": emailCtrl.text,
          "password": passCtrl.text,
          "answer": answerCtrl.text, 
          "challenge_token": mathChallenge['token']
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token'] ?? 'TOKEN_VALID');
        await prefs.setInt('user_role', data['role_id']);
        await prefs.setString('user_nama', data['nama_lengkap'] ?? emailCtrl.text); 

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        _showError("Jawaban matematika salah!");
        setState(() { step = 1; answerCtrl.clear(); }); 
      }
    } catch (e) {
      _showError("Gagal memverifikasi jawaban.");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)), 
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      )
    );
  }

  // Desain Input Field
  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF95D5B2)), 
      prefixIcon: Icon(icon, color: const Color(0xFF74C69D)),
      filled: true,
      fillColor: const Color(0xFF081C15), 
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.transparent)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF95D5B2), width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B4332), 
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: const Color(0xFF2D6A4F), 
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo & Judul
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFFD8F3DC).withOpacity(0.1), shape: BoxShape.circle),
                  child: Image.asset('assets/logo.png', height: 70, errorBuilder: (c,e,s) => const Icon(Icons.security, size: 60, color: Color(0xFFD8F3DC))),
                ),
                const SizedBox(height: 15),
                const Text("DCFMIS Mobile", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFD8F3DC), letterSpacing: 1.2)),
                const SizedBox(height: 5),
                const Text("Data Center Facility Management", style: TextStyle(fontSize: 12, color: Color(0xFF95D5B2))),
                const SizedBox(height: 35),

                // ==========================================
                // TAMPILAN STEP 1 (LOGIN EMAIL & PASS)
                // ==========================================
                if (step == 1) ...[
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: _inputStyle("Email Pengguna", Icons.email_outlined),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: _inputStyle("Kata Sandi", Icons.lock_outline),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF74C69D), 
                        foregroundColor: const Color(0xFF081C15), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                      ),
                      onPressed: isLoading ? null : handleLogin,
                      child: isLoading 
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Color(0xFF081C15), strokeWidth: 2.5))
                        : const Text("MASUK KE SISTEM", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  )
                ] 
                
                // ==========================================
                // TAMPILAN STEP 2 (CAPTCHA MATEMATIKA)
                // ==========================================
                else ...[
                  const Icon(Icons.verified_user, color: Color(0xFF95D5B2), size: 40),
                  const SizedBox(height: 10),
                  const Text("Verifikasi Keamanan", style: TextStyle(color: Color(0xFFD8F3DC), fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  const Text("Jawab pertanyaan berikut untuk melanjutkan", style: TextStyle(color: Color(0xFF95D5B2), fontSize: 12)),
                  const SizedBox(height: 20),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                    decoration: BoxDecoration(color: const Color(0xFF081C15), borderRadius: BorderRadius.circular(15)),
                    child: Text(
                      "${mathChallenge['num1']} ${mathChallenge['operator']} ${mathChallenge['num2']}",
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFFD8F3DC), letterSpacing: 2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  TextField(
                    controller: answerCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF081C15),
                      hintText: "Jawaban Anda",
                      hintStyle: const TextStyle(color: Color(0xFF52796F), fontSize: 16),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.transparent)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF95D5B2), width: 2)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16), 
                            side: const BorderSide(color: Color(0xFF74C69D), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                          onPressed: () => setState(() => step = 1),
                          child: const Text("BATAL", style: TextStyle(color: Color(0xFFD8F3DC), fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF74C69D), 
                            foregroundColor: const Color(0xFF081C15), 
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                          onPressed: isLoading ? null : verifyMath,
                          child: isLoading 
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Color(0xFF081C15), strokeWidth: 2))
                            : const Text("VERIFIKASI", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ),
                      ),
                    ],
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// === MOBILE DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) ===