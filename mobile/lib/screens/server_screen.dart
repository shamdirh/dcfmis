import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class ServerScreen extends StatefulWidget {
  const ServerScreen({super.key});

  @override
  State<ServerScreen> createState() => _ServerScreenState();
}

class _ServerScreenState extends State<ServerScreen> {
  bool isLoading = true;
  
  // Penampung data per kategori
  List<dynamic> fisikBalaikota = [];
  List<dynamic> virtualBalaikota = [];
  List<dynamic> fisikAsnet = [];
  List<dynamic> virtualAsnet = [];

  // Variabel Pencarian
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchServers();
  }

  Future<void> _fetchServers() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('auth_token');
      Map<String, String> headers = { ...apiHeaders };
      if (authToken != null) headers['Authorization'] = 'Bearer $authToken';

      final res = await http.get(Uri.parse('$apiUrl/api/server/manage'), headers: headers);

      if (res.statusCode == 200) {
        var decodedData = jsonDecode(res.body);
        List<dynamic> allServers = [];

        if (decodedData is List) {
          allServers = decodedData;
        } else if (decodedData is Map && decodedData.containsKey('data')) {
          allServers = decodedData['data'];
        }

        setState(() {
          fisikBalaikota = allServers.where((s) {
            String p = (s['pusat_data'] ?? '').toString().toLowerCase().replaceAll(' ', '');
            String k = (s['kategori_server'] ?? '').toString().toLowerCase().replaceAll(' ', '');
            return p.contains('balaikota') && k.contains('fisik');
          }).toList();
          
          virtualBalaikota = allServers.where((s) {
            String p = (s['pusat_data'] ?? '').toString().toLowerCase().replaceAll(' ', '');
            String k = (s['kategori_server'] ?? '').toString().toLowerCase().replaceAll(' ', '');
            return p.contains('balaikota') && (k.contains('virtual') || k.contains('vm'));
          }).toList();
          
          fisikAsnet = allServers.where((s) {
            String p = (s['pusat_data'] ?? '').toString().toLowerCase().replaceAll(' ', '');
            String k = (s['kategori_server'] ?? '').toString().toLowerCase().replaceAll(' ', '');
            return p.contains('asnet') && k.contains('fisik');
          }).toList();
          
          virtualAsnet = allServers.where((s) {
            String p = (s['pusat_data'] ?? '').toString().toLowerCase().replaceAll(' ', '');
            String k = (s['kategori_server'] ?? '').toString().toLowerCase().replaceAll(' ', '');
            return p.contains('asnet') && (k.contains('virtual') || k.contains('vm'));
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("Gagal memuat data server: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ========================
  // UNIVERSAL JSON PARSER
  // ========================
  List<Widget> _buildJsonListUI(dynamic rawData, Widget Function(String category, Map item) builder) {
    if (rawData == null || rawData.toString().trim().isEmpty) return [];

    dynamic decoded;
    if (rawData is String) {
      try { decoded = jsonDecode(rawData); } catch(e) { return []; }
    } else {
      decoded = rawData;
    }

    List<Widget> widgets = [];

    if (decoded is List) {
      for (var item in decoded) {
        if (item is Map) widgets.add(builder("", item));
      }
    } else if (decoded is Map) {
      decoded.forEach((key, value) {
        if (value is List && value.isNotEmpty) {
          widgets.add(Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(key.toString().toUpperCase(), style: const TextStyle(color: Color(0xFF0369A1), fontWeight: FontWeight.bold, fontSize: 12)),
          ));
          for (var item in value) {
            if (item is Map) widgets.add(builder(key.toString(), item));
          }
        }
      });
    }
    return widgets;
  }

  // ==========================================
  // POP-UP DETAIL SERVER
  // ==========================================
  void _showServerDetail(Map<String, dynamic> server) {
    showDialog(
      context: context,
      builder: (context) {
        
        List<Widget> softwareWidgets = _buildJsonListUI(server['software_terpasang'], (category, s) {
          String nama = s['nama_software']?.toString() ?? s['nama']?.toString() ?? s['software']?.toString() ?? '-';
          String versi = s['versi']?.toString() ?? '';
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(versi.isNotEmpty ? "$nama (Versi: $versi)" : nama, style: const TextStyle(color: Color(0xFF334155), fontSize: 13))),
              ],
            ),
          );
        });

        List<Widget> kredensialWidgets = _buildJsonListUI(server['kredensial_akun'], (category, k) {
          String user = k['username']?.toString() ?? k['user']?.toString() ?? '-';
          String pass = k['password']?.toString() ?? k['pass']?.toString() ?? '-';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.person, color: Color(0xFF0369A1), size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text("User: $user", style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13))),
                const Text(" | ", style: TextStyle(color: Colors.grey)),
                Expanded(child: Text("Pass: $pass", style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13))),
              ],
            ),
          );
        });

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFFF0F9FF), 
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.dns, color: Color(0xFF0284C7), size: 30),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(server['nama_server'] ?? '-', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ),
                const Divider(color: Color(0xFFCBD5E1), thickness: 1.5),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(Icons.calendar_today, "Dibuat", server['tanggal_pembuatan']),
                        const SizedBox(height: 15),
                        
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBAE6FD))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Spesifikasi Hardware", style: TextStyle(color: Color(0xFF0369A1), fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildHardwareBox("CPU", server['spek_cpu']),
                                  _buildHardwareBox("RAM", server['spek_ram']),
                                  _buildHardwareBox("HDD", server['spek_hdd']),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text("Software Terpasang", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        if (softwareWidgets.isEmpty)
                          const Text("Tidak ada data software terpasang", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                        else
                          ...softwareWidgets,

                        const SizedBox(height: 20),

                        const Text("Kredensial Akun", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 8),
                        if (kredensialWidgets.isEmpty)
                          const Text("Tidak ada data kredensial akun", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                        else
                          ...kredensialWidgets,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildDetailRow(IconData icon, String title, dynamic value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF64748B), size: 18),
        const SizedBox(width: 8),
        Text("$title: ", style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
        Expanded(child: Text(value?.toString() ?? '-', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 14))),
      ],
    );
  }

  Widget _buildHardwareBox(String label, dynamic value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
        const SizedBox(height: 4),
        Text(value?.toString() ?? '-', style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  // ==================================================
  // WIDGET DAFTAR SERVER (List View + Filter Search)
  // ==================================================
  Widget _buildServerList(List<dynamic> originalData) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)));
    }
    
    // filter pencarian pada data yang dikirimkan
    List<dynamic> displayData = originalData;
    if (searchQuery.isNotEmpty) {
      displayData = originalData.where((s) {
        String namaServer = (s['nama_server'] ?? '').toString().toLowerCase();
        return namaServer.contains(searchQuery);
      }).toList();
    }

    if (displayData.isEmpty) {
      return Center(
        child: Text(
          searchQuery.isNotEmpty ? "Server tidak ditemukan." : "Tidak ada data server di kategori ini.", 
          style: const TextStyle(color: Colors.white70)
        )
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: displayData.length,
      itemBuilder: (context, index) {
        final server = displayData[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: const Color(0xFF325477), // Biru keabuan
          elevation: 3,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showServerDetail(server),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: const Color(0xFFCDEDF6), borderRadius: BorderRadius.circular(10)),
                    child: Center(child: Text("${index + 1}", style: const TextStyle(color: Color(0xFF031D44), fontWeight: FontWeight.bold, fontSize: 16))),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(server['nama_server'] ?? 'Unknown Server', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 6),
                        Text("CPU: ${server['spek_cpu'] ?? '-'} | RAM: ${server['spek_ram'] ?? '-'} | HDD: ${server['spek_hdd'] ?? '-'}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text("Dibuat: ${server['tanggal_pembuatan'] ?? '-'}", style: const TextStyle(color: Colors.cyanAccent, fontSize: 11, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                  const Icon(Icons.read_more, color: Colors.white54, size: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFF23395B), // Biru cerah
        appBar: AppBar(
          title: const Text('Dashboard Manajemen Server', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          backgroundColor: const Color(0xFF103B3E),
          elevation: 4,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.cyanAccent,
            unselectedLabelColor: Colors.white54,
            indicatorColor: Colors.cyanAccent,
            indicatorWeight: 3,
            tabs: [
              Tab(text: "Fisik Balaikota", icon: Icon(Icons.computer)),
              Tab(text: "Virtual Balaikota", icon: Icon(Icons.cloud)),
              Tab(text: "Fisik ASNET", icon: Icon(Icons.computer)),
              Tab(text: "Virtual ASNET", icon: Icon(Icons.cloud)),
            ],
          ),
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: () {
              _searchController.clear();
              setState(() => searchQuery = "");
              _fetchServers();
            })
          ],
        ),
        body: Column(
          children: [
            // KOTAK PENCARIAN (SEARCH BAR)
            Container(
              padding: const EdgeInsets.all(15),
              color: const Color(0xFF103B3E), 
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.toLowerCase();
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Cari Nama Server...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.cyanAccent),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.redAccent),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              searchQuery = "";
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF1B4C50),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
            ),

            // KONTEN TAB
            Expanded(
              child: TabBarView(
                children: [
                  _buildServerList(fisikBalaikota),
                  _buildServerList(virtualBalaikota),
                  _buildServerList(fisikAsnet),
                  _buildServerList(virtualAsnet),
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