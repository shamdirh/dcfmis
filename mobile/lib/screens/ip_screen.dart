import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

// =======================================================
// HALAMAN UTAMA: DAFTAR BLOK IP BERDASARKAN LOKASI
// =======================================================
class IpScreen extends StatefulWidget {
  const IpScreen({super.key});

  @override
  State<IpScreen> createState() => _IpScreenState();
}

class _IpScreenState extends State<IpScreen> {
  bool isLoading = true;
  
  // Penampung Data Kategori Blok IP
  List<dynamic> bkPublik = [];
  List<dynamic> bkLokal = [];
  List<dynamic> asPublik = [];
  List<dynamic> asLokal = [];

  @override
  void initState() {
    super.initState();
    _fetchIpBlocks();
  }

  Future<void> _fetchIpBlocks() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('auth_token');
      Map<String, String> headers = { ...apiHeaders };
      if (authToken != null) headers['Authorization'] = 'Bearer $authToken';

      final res = await http.get(Uri.parse('$apiUrl/api/ip/blocks'), headers: headers);

      if (res.statusCode == 200) {
        var decodedData = jsonDecode(res.body);
        List<dynamic> allBlocks = [];

        // Toleransi format JSON
        if (decodedData is List) {
          allBlocks = decodedData;
        } else if (decodedData is Map && decodedData.containsKey('data')) {
          allBlocks = decodedData['data'];
        }

        setState(() {
          // Membaca dari 'nama_blok', 'keterangan', dan 'jenis_ip'
          bkPublik = allBlocks.where((b) {
            String nama = (b['nama_blok'] ?? '').toString().toLowerCase();
            String ket = (b['keterangan'] ?? '').toString().toLowerCase();
            String jenis = (b['jenis_ip'] ?? '').toString().toLowerCase();
            
            bool isBalaikota = nama.contains('balaikota') || ket.contains('balaikota');
            bool isPublik = jenis.contains('publik') || nama.contains('publik');
            return isBalaikota && isPublik;
          }).toList();

          bkLokal = allBlocks.where((b) {
            String nama = (b['nama_blok'] ?? '').toString().toLowerCase();
            String ket = (b['keterangan'] ?? '').toString().toLowerCase();
            String jenis = (b['jenis_ip'] ?? '').toString().toLowerCase();
            
            bool isBalaikota = nama.contains('balaikota') || ket.contains('balaikota');
            bool isLokal = jenis.contains('lokal') || nama.contains('lokal');
            return isBalaikota && isLokal;
          }).toList();

          asPublik = allBlocks.where((b) {
            String nama = (b['nama_blok'] ?? '').toString().toLowerCase();
            String ket = (b['keterangan'] ?? '').toString().toLowerCase();
            String jenis = (b['jenis_ip'] ?? '').toString().toLowerCase();
            
            bool isAsnet = nama.contains('asnet') || ket.contains('asnet');
            bool isPublik = jenis.contains('publik') || nama.contains('publik');
            return isAsnet && isPublik;
          }).toList();

          asLokal = allBlocks.where((b) {
            String nama = (b['nama_blok'] ?? '').toString().toLowerCase();
            String ket = (b['keterangan'] ?? '').toString().toLowerCase();
            String jenis = (b['jenis_ip'] ?? '').toString().toLowerCase();
            
            bool isAsnet = nama.contains('asnet') || ket.contains('asnet');
            bool isLokal = jenis.contains('lokal') || nama.contains('lokal');
            return isAsnet && isLokal;
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("Gagal memuat blok IP: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Desain Card Blok IP
  Widget _buildBlockCard(Map<String, dynamic> block, Color accentColor) {
    String blokIp = block['cidr_block'] ?? block['nama_blok'] ?? 'Unknown Block';
    String keterangan = block['keterangan'] ?? 'Tidak ada keterangan';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: const Color(0xFF1B4C50),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          // BUKA HALAMAN DETAIL ALOKASI IP
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => IpUsageScreen(
              blokId: block['id'], 
              blokIp: blokIp,
              accentColor: accentColor,
            )
          ));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: accentColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.hub, color: accentColor, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(blokIp, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.2)),
                    const SizedBox(height: 5),
                    Text(keterangan, style: const TextStyle(color: Colors.white70, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: accentColor, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // Header Accordion Kategori
  Widget _buildCategoryHeader(String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Text(title, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031D44),
      appBar: AppBar(
        title: const Text('Manajemen IP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF103B3E),
        elevation: 4,
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.cyanAccent), onPressed: _fetchIpBlocks)],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
        : ListView(
            padding: const EdgeInsets.symmetric(vertical: 15),
            children: [
              // KATEGORI IP BALAIKOTA PUBLIK
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  title: _buildCategoryHeader("IP Publik - Balaikota", Icons.public, const Color(0xFF38BDF8)),
                  children: bkPublik.isEmpty 
                    ? [const Padding(padding: EdgeInsets.all(15), child: Text("Belum ada blok IP", style: TextStyle(color: Colors.white54)))]
                    : bkPublik.map((b) => _buildBlockCard(b, const Color(0xFF38BDF8))).toList(),
                ),
              ),
              const Divider(color: Colors.white12, thickness: 1, indent: 20, endIndent: 20),

              // KATEGORI IP BALAIKOTA LOKAL
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: true,
                  title: _buildCategoryHeader("IP Lokal - Balaikota", Icons.lan, const Color(0xFF34D399)),
                  children: bkLokal.isEmpty 
                    ? [const Padding(padding: EdgeInsets.all(15), child: Text("Belum ada blok IP", style: TextStyle(color: Colors.white54)))]
                    : bkLokal.map((b) => _buildBlockCard(b, const Color(0xFF34D399))).toList(),
                ),
              ),
              const Divider(color: Colors.white12, thickness: 1, indent: 20, endIndent: 20),

              // KATEGORI IP ASNET PUBLIK
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: false,
                  title: _buildCategoryHeader("IP Publik - ASNET", Icons.public, const Color(0xFFFBBF24)),
                  children: asPublik.isEmpty 
                    ? [const Padding(padding: EdgeInsets.all(15), child: Text("Belum ada blok IP", style: TextStyle(color: Colors.white54)))]
                    : asPublik.map((b) => _buildBlockCard(b, const Color(0xFFFBBF24))).toList(),
                ),
              ),
              const Divider(color: Colors.white12, thickness: 1, indent: 20, endIndent: 20),

              // KATEGORI IP ASNET LOKAL
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: false,
                  title: _buildCategoryHeader("IP Lokal - ASNET", Icons.lan, const Color(0xFFF472B6)),
                  children: asLokal.isEmpty 
                    ? [const Padding(padding: EdgeInsets.all(15), child: Text("Belum ada blok IP", style: TextStyle(color: Colors.white54)))]
                    : asLokal.map((b) => _buildBlockCard(b, const Color(0xFFF472B6))).toList(),
                ),
              ),
            ],
          ),
    );
  }
}


// =======================================================
// HALAMAN DETAIL: DAFTAR ALOKASI IP (DENGAN PAGING & SEARCH)
// =======================================================
class IpUsageScreen extends StatefulWidget {
  final dynamic blokId;
  final String blokIp;
  final Color accentColor;

  const IpUsageScreen({super.key, required this.blokId, required this.blokIp, required this.accentColor});

  @override
  State<IpUsageScreen> createState() => _IpUsageScreenState();
}

class _IpUsageScreenState extends State<IpUsageScreen> {
  bool isLoading = true;
  List<dynamic> allUsages = []; 
  List<dynamic> filteredUsages = []; 
  List<dynamic> displayedUsages = []; 

  // Variabel Paging
  int itemsPerPage = 15;
  int currentPage = 1;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsages();
  }

  Future<void> _fetchUsages() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('auth_token');
      Map<String, String> headers = { ...apiHeaders };
      if (authToken != null) headers['Authorization'] = 'Bearer $authToken';

      final res = await http.get(Uri.parse('$apiUrl/api/ip/usages'), headers: headers);

      if (res.statusCode == 200) {
        var decodedData = jsonDecode(res.body);
        List<dynamic> rawUsages = [];

        if (decodedData is List) {
          rawUsages = decodedData;
        } else if (decodedData is Map && decodedData.containsKey('data')) {
          rawUsages = decodedData['data'];
        }

        setState(() {
          // Menggunakan 'ip_block_id' sesuai dengan respon JSON Golang
          allUsages = rawUsages.where((u) {
            return u['ip_block_id'].toString() == widget.blokId.toString();
          }).toList();
          
          filteredUsages = List.from(allUsages);
          _applyPaging();
        });
      }
    } catch (e) {
      debugPrint("Gagal memuat alokasi IP: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Fungsi Pencarian
  void _filterData(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredUsages = List.from(allUsages);
      } else {
        filteredUsages = allUsages.where((u) {
          String ip = (u['ip_address'] ?? '').toString().toLowerCase();
          String kegunaan = (u['kegunaan'] ?? '').toString().toLowerCase();
          String server = (u['nama_server'] ?? '').toString().toLowerCase(); // Menambahkan pencarian ke server
          return ip.contains(query.toLowerCase()) || 
                 kegunaan.contains(query.toLowerCase()) || 
                 server.contains(query.toLowerCase());
        }).toList();
      }
      currentPage = 1; 
      _applyPaging();
    });
  }

  // Fungsi Paging Lokal
  void _applyPaging() {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    if (endIndex > filteredUsages.length) endIndex = filteredUsages.length;
    
    setState(() {
      if (startIndex < filteredUsages.length) {
        displayedUsages = filteredUsages.sublist(startIndex, endIndex);
      } else {
        displayedUsages = [];
      }
    });
  }

  void _nextPage() {
    if ((currentPage * itemsPerPage) < filteredUsages.length) {
      setState(() { currentPage++; _applyPaging(); });
    }
  }

  void _prevPage() {
    if (currentPage > 1) {
      setState(() { currentPage--; _applyPaging(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (filteredUsages.length / itemsPerPage).ceil();
    if (totalPages == 0) totalPages = 1;

    return Scaffold(
      backgroundColor: const Color(0xFF031D44),
      appBar: AppBar(
        title: Text('Alokasi ${widget.blokIp}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF103B3E),
        elevation: 4,
      ),
      body: Column(
        children: [
          // KOTAK PENCARIAN (SEARCH BAR)
          Container(
            padding: const EdgeInsets.all(15),
            color: const Color(0xFF103B3E),
            child: TextField(
              controller: _searchController,
              onChanged: _filterData,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari IP atau Nama Server / Kegunaan...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: Icon(Icons.search, color: widget.accentColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.redAccent),
                        onPressed: () {
                          _searchController.clear();
                          _filterData('');
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

          // LIST ALOKASI IP
          Expanded(
            child: isLoading
              ? Center(child: CircularProgressIndicator(color: widget.accentColor))
              : displayedUsages.isEmpty
                ? const Center(child: Text("Tidak ada IP yang ditemukan.", style: TextStyle(color: Colors.white70)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    itemCount: displayedUsages.length,
                    itemBuilder: (context, index) {
                      final u = displayedUsages[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        color: const Color(0xFF1A5A63),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.monitor, color: widget.accentColor, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    u['ip_address'] ?? '-', 
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                                  ),
                                  const Spacer(),
                                  // Menampilkan status aktif/tidak
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (u['status']?.toString().toLowerCase() == 'aktif') ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6)
                                    ),
                                    child: Text(
                                      u['status'] ?? 'Aktif', 
                                      style: TextStyle(
                                        color: (u['status']?.toString().toLowerCase() == 'aktif') ? Colors.greenAccent : Colors.redAccent, 
                                        fontSize: 10, 
                                        fontWeight: FontWeight.bold
                                      )
                                    ),
                                  )
                                ],
                              ),
                              const Divider(color: Colors.white24, thickness: 1, height: 20),
                              
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(width: 80, child: Text("Kegunaan", style: TextStyle(color: Colors.white70, fontSize: 12))),
                                  const Text(": ", style: TextStyle(color: Colors.white70)),
                                  Expanded(child: Text(u['nama_server'] ?? u['kegunaan'] ?? '-', style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 13))),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(width: 80, child: Text("Port Info", style: TextStyle(color: Colors.white70, fontSize: 12))),
                                  const Text(": ", style: TextStyle(color: Colors.white70)),
                                  Expanded(child: Text(u['port_info'] ?? '-', style: const TextStyle(color: Colors.white, fontSize: 13))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // WIDGET PAGING (PREV / NEXT)
          if (!isLoading && filteredUsages.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF103B3E),
                border: Border(top: BorderSide(color: Colors.white12, width: 1))
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentPage > 1 ? const Color(0xFF1B4C50) : Colors.transparent,
                      elevation: 0,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: currentPage > 1 ? _prevPage : null,
                    icon: const Icon(Icons.arrow_back_ios, size: 14),
                    label: const Text("Sebelumnya"),
                  ),
                  Text("Hal $currentPage / $totalPages", style: TextStyle(color: widget.accentColor, fontWeight: FontWeight.bold)),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentPage < totalPages ? const Color(0xFF1B4C50) : Colors.transparent,
                      elevation: 0,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: currentPage < totalPages ? _nextPage : null,
                    icon: const Icon(Icons.arrow_forward_ios, size: 14),
                    label: const Text("Selanjutnya"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
// === MOBILE DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) ===