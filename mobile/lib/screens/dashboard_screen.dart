import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = "Admin";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_nama') ?? "Admin";
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  // ==========================================
  // WIDGET TENTANG APLIKASI 
  // ==========================================
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF0F9FF), // Latar Biru Pastel Terang (Sky 50)
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF0284C7), size: 28), // Ikon Biru Langit Gelap
              SizedBox(width: 10),
              Text("Tentang Aplikasi", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18)), // Teks Navy Gelap
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Aplikasi Data Center Facility Management Information System (DCFMIS) versi Mobile ini dibangun untuk memudahkan petugas piket Pusat Data untuk melakukan pendataan rutin harian fasilitas Pusat Data: Suhu Ruangan Server, PC operator, CCTV Pusat Data, Kondisi AC Ruangan, Panel Listrik Utama, Indikator UPS dan Baterai, Indikator Panel Distribusi Listrik, Kondisi Rack Server, serta Catatan Kejadian Harian. Aplikasi juga dilengkapi dengan Data Server dan Data Alokasi IP.",
                  style: TextStyle(color: Color(0xFF334155), fontSize: 13, height: 1.5), // Teks abu-abu gelap
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 20),
                Divider(color: Color(0xFFCBD5E1), thickness: 1), // Garis batas abu-abu terang
                SizedBox(height: 15),
                Text("Dikembangkan Oleh:", style: TextStyle(color: Color(0xFF0284C7), fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text("Saeful Hamdi, A.Md", style: TextStyle(color: Color(0xFF0F172A), fontSize: 15, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.email, color: Color(0xFF64748B), size: 14), // Ikon email abu-abu
                    SizedBox(width: 5),
                    Text("saefulhamdi@kotabogor.go.id", style: TextStyle(color: Color(0xFF475569), fontSize: 12)),
                  ],
                ),
                SizedBox(height: 10),
                Text("Pranata Komputer Mahir", style: TextStyle(color: Color(0xFF475569), fontSize: 13)),
                Text("Dinas Komunikasi dan Informatika\nKota Bogor", style: TextStyle(color: Color(0xFF475569), fontSize: 13, height: 1.4)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("TUTUP", style: TextStyle(color: Color(0xFF0369A1), fontWeight: FontWeight.bold)), // Tombol Biru Gelap
            )
          ],
        );
      },
    );
  }

  // ==========================================
  // WIDGET MENU 
  // ==========================================
  Widget _buildMenuCard(String title, IconData icon, List<Color> gradientColors, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: gradientColors.last.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))
          ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2), // Latar belakang ikon transparan cerah
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 15),
            Text(
              title, 
              textAlign: TextAlign.center, 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031D44), // Backgound Navy konsisten
      appBar: AppBar(
        title: const Text('Dashboard DCFMIS', style: TextStyle(color: Color(0xFFCDEDF6), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF103B3E),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.logout, color: Colors.redAccent), onPressed: _logout)
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Selamat Datang,", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16)),
            Text(userName, style: const TextStyle(color: Color(0xFFCDEDF6), fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  // Menu Modul Piket 
                  _buildMenuCard(
                    "Laporan Piket", 
                    Icons.assignment_turned_in, 
                    [const Color(0xFF0B8793), const Color(0xFF36D1DC)], 
                    () => Navigator.pushNamed(context, '/piket')
                  ),
                  
                  // Menu Modul IP 
                  _buildMenuCard(
                    "Manajemen IP", 
                    Icons.network_check, 
                    [const Color(0xFF2F80ED), const Color(0xFF56CCF2)], 
                    () => Navigator.pushNamed(context, '/ip_screen')
                  ),
                  
                  // Menu Modul Server 
                  _buildMenuCard(
                    "Manajemen Server", 
                    Icons.dns, 
                    [const Color(0xFFF2994A), const Color(0xFFF2C94C)], 
                    () => Navigator.pushNamed(context, '/server_screen')
                  ),

                  // Menu Modul Tentang Aplikasi 
                  _buildMenuCard(
                    "Tentang Aplikasi", 
                    Icons.info_outline, 
                    [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)], 
                    _showAboutDialog
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// === MOBILE DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) ===