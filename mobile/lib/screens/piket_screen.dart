import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'piket_detail_screen.dart';

class PiketScreen extends StatefulWidget {
  const PiketScreen({super.key});

  @override
  State<PiketScreen> createState() => _PiketScreenState();
}

class _PiketScreenState extends State<PiketScreen> {
  List laporan = [];
  bool isLoading = false;
  
  // Paging & Search Vars
  int currentPage = 1;
  bool hasMoreData = true;
  String searchDate = "";
  
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPiket();
    _scrollController.addListener(() {
      // Jika scroll mentok bawah, ambil halaman selanjutnya
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
        if (!isLoading && hasMoreData) fetchPiket();
      }
    });
  }

  // Fungsi memuat data (Paging + Filter Tanggal)
  Future<void> fetchPiket({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage = 1;
      hasMoreData = true;
      laporan.clear();
    }

    if (!hasMoreData) return;

    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('auth_token');
      Map<String, String> headers = { ...apiHeaders };
      if (authToken != null) headers['Authorization'] = 'Bearer $authToken';

      // Parameter URL Paging dan Pencarian
      String url = '$apiUrl/api/piket/summary?page=$currentPage';
      if (searchDate.isNotEmpty) {
        url += '&tanggal=$searchDate';
      }

      final res = await http.get(Uri.parse(url), headers: headers);
      
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        setState(() {
          if (data is List) {
            if (data.isEmpty) {
              hasMoreData = false;
            } else {
              laporan.addAll(data);
              currentPage++;
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error Fetch: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Dialog Pilih Tanggal
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(primary: Color(0xFFCDEDF6), onPrimary: Color(0xFF031D44), surface: Color(0xFF103B3E)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        searchDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        _searchController.text = searchDate;
      });
      fetchPiket(isRefresh: true);
    }
  }

  // WIDGET DASHBOARD: Menampilkan 7 Data
  Widget _buildDashboardHighlight() {
    if (laporan.isEmpty) return const SizedBox.shrink();

    // Data Paling Atas (Terbaru / Sesuai Pencarian)
    final latest = laporan.first;

    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B8793), Color(0xFF36D1DC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)) ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("DATA PIKET TERAKHIR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                child: Text("${latest['tanggal_pemeriksaan']} ${latest['jam_pemeriksaan']}", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildInfoBox(Icons.thermostat, "Suhu", latest['suhu_ruangan_server']),
              const SizedBox(width: 10),
              _buildInfoBox(Icons.computer, "PC NOC", latest['status_pc_noc']),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildInfoBox(Icons.cleaning_services, "R. Server", latest['kebersihan_ruangan']),
              const SizedBox(width: 10),
              _buildInfoBox(Icons.delete_outline, "Sampah", latest['kebersihan_sampah']),
            ],
          ),
          const SizedBox(height: 15),
          // Field ke-7: Catatan Kejadian
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.3))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Catatan Kejadian:", style: TextStyle(color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 5),
                Text(latest['catatan_kejadian'] ?? '-', style: const TextStyle(color: Colors.white, fontSize: 13, fontStyle: FontStyle.italic)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoBox(IconData icon, String title, String? value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.3))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: Colors.white, size: 16), const SizedBox(width: 5), Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11))]),
            const SizedBox(height: 5),
            Text(value ?? '-', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Piket'),
        backgroundColor: const Color(0xFF103B3E),
      ),
      body: Column(
        children: [
          // PENCARIAN BERDASARKAN TANGGAL
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Cari Berdasarkan Tanggal...",
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.date_range, color: Colors.cyanAccent),
                      filled: true,
                      fillColor: const Color(0xFF1B4C50),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                if (searchDate.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.redAccent),
                    onPressed: () {
                      setState(() { searchDate = ""; _searchController.clear(); });
                      fetchPiket(isRefresh: true);
                    },
                  ),
              ],
            ),
          ),

          // DASHBOARD (7 DATA)
          if (!isLoading || laporan.isNotEmpty) _buildDashboardHighlight(),

          // LIST DATA (5 DATA) dengan Paging
          Expanded(
            child: laporan.isEmpty && isLoading
                ? const Center(child: CircularProgressIndicator())
                : laporan.isEmpty
                    ? const Center(child: Text("Data tidak ditemukan.", style: TextStyle(color: Colors.white70)))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemCount: laporan.length + (hasMoreData ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == laporan.length) return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
                          
                          final p = laporan[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            color: const Color(0xFF1A5A63),
                            elevation: 4,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => PiketDetailScreen(piketId: p['id'])));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Baris 1: Tanggal & Jam
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, color: Colors.cyanAccent, size: 16),
                                        const SizedBox(width: 5),
                                        Text("${p['tanggal_pemeriksaan']} | ${p['jam_pemeriksaan']}", style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                                        const Spacer(),
                                        const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14),
                                      ],
                                    ),
                                    const Divider(color: Colors.white24, height: 20),
                                    
                                    // Baris 2: Suhu & PC Status
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Suhu: ${p['suhu_ruangan_server']}", style: const TextStyle(color: Colors.white, fontSize: 13)),
                                        Text("PC: ${p['status_pc_noc']}", style: const TextStyle(color: Colors.white, fontSize: 13)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Baris 3: Catatan Kejadian
                                    Text("Catatan: ${p['catatan_kejadian'] ?? '-'}", style: const TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFCDEDF6),
        child: const Icon(Icons.add, color: Color(0xFF031D44), size: 30),
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/piket_input');
          if (result == true) fetchPiket(isRefresh: true);
        },
      ),
    );
  }
}
// === MOBILE DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) ===