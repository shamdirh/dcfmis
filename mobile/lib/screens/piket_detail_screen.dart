import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class PiketDetailScreen extends StatefulWidget {
  final int piketId;
  const PiketDetailScreen({super.key, required this.piketId});

  @override
  State<PiketDetailScreen> createState() => _PiketDetailScreenState();
}

class _PiketDetailScreenState extends State<PiketDetailScreen> {
  Map<String, dynamic>? dataLengkap;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetailPiket();
  }

  Future<void> fetchDetailPiket() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('auth_token');
      Map<String, String> headers = { ...apiHeaders };
      if (authToken != null) headers['Authorization'] = 'Bearer $authToken';

      final res = await http.get(Uri.parse('$apiUrl/api/piket/detail?id=${widget.piketId}'), headers: headers);
      
      if (res.statusCode == 200) {
        setState(() => dataLengkap = jsonDecode(res.body));
      }
    } catch (e) {
      debugPrint("Error Fetch Detail Piket: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ==========================================
  // WIDGET UI HELPER UNTUK READ-ONLY
  // ==========================================
  Widget _buildAccordionHeader(String title, IconData icon) {
    return Row(children: [
      Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFFCDEDF6).withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: Colors.cyanAccent, size: 20)),
      const SizedBox(width: 12),
      Text(title, style: const TextStyle(color: Color(0xFFCDEDF6), fontSize: 16, fontWeight: FontWeight.bold)),
    ]);
  }

  // Tampilan Kotak Data (Sama dengan Input tapi tidak bisa diketik)
  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: const Color(0xFF1B4C50), borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallReadOnly(String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(color: const Color(0xFF103B3E), borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10), textAlign: TextAlign.center),
              const SizedBox(height: 5),
              Text(value.isEmpty ? "-" : value, style: const TextStyle(color: Colors.cyanAccent, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCardReadOnly({required String title, required IconData icon, required Color titleColor, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(color: const Color(0xFF1A5A63), borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: titleColor, size: 22), const SizedBox(width: 8), Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.bold, fontSize: 16))]),
            const Divider(color: Colors.white24, height: 25, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Scaffold(backgroundColor: const Color(0xFF031D44), appBar: AppBar(backgroundColor: const Color(0xFF103B3E)), body: const Center(child: CircularProgressIndicator()));
    if (dataLengkap == null) return Scaffold(backgroundColor: const Color(0xFF031D44), appBar: AppBar(backgroundColor: const Color(0xFF103B3E)), body: const Center(child: Text("Data Gagal Dimuat", style: TextStyle(color: Colors.white))));

    final d = dataLengkap!;
    List panelList = d['panels'] ?? [];
    List upsList = d['ups'] ?? [];
    Map fasilitas = d['fasilitas'] ?? {};
    Map acData = fasilitas['ac'] ?? {};
    Map cctvData = fasilitas['cctv'] ?? {};
    Map rakData = fasilitas['rak'] ?? {};

    // Helper mencegah error jika data DB tidak lengkap
    Map<String, dynamic> getPanel(int index) => panelList.length > index ? panelList[index] : {'nama_panel': 'Panel Data Kosong'};
    Map<String, dynamic> getUps(int index) => upsList.length > index ? upsList[index] : {'nama_ups': 'UPS Data Kosong'};

    return Scaffold(
      backgroundColor: const Color(0xFF031D44),
      appBar: AppBar(title: const Text('Detail Laporan Piket', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFF103B3E), centerTitle: true, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // PROFIL OPERATOR ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0B8793), Color(0xFF36D1DC)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
                const CircleAvatar(radius: 25, backgroundColor: Colors.white24, child: Icon(Icons.assignment_ind, color: Colors.white, size: 30)),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d['nama_lengkap'] ?? '-', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      Text(d['jabatan'] ?? '-', style: const TextStyle(color: Color(0xFF031D44), fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // LAPORAN UTAMA ---
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: true,
              tilePadding: EdgeInsets.zero,
              title: _buildAccordionHeader("1. Informasi Laporan", Icons.info_outline),
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildReadOnlyField("Tanggal", d['tanggal_pemeriksaan'] ?? '-')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildReadOnlyField("Jam", d['jam_pemeriksaan'] ?? '-')),
                  ],
                ),
                _buildReadOnlyField("Suhu Ruangan Server (C)", d['suhu_ruangan_server'] ?? '-'),
                _buildReadOnlyField("Kondisi PC 1 (NOC)", d['status_pc_noc'] ?? '-'),
                _buildReadOnlyField("Kebersihan Ruangan", d['kebersihan_ruangan'] ?? '-'),
                _buildReadOnlyField("Kebersihan Sampah", d['kebersihan_sampah'] ?? '-'),
                _buildReadOnlyField("Catatan Kejadian", d['catatan_kejadian'] ?? '-'),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 30),

          // --- KONDISI AC & CCTV ---
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: _buildAccordionHeader("2. Fasilitas (AC & CCTV)", Icons.videocam_outlined),
              children: [
                const SizedBox(height: 10),
                ...acData.entries.map((e) => _buildReadOnlyField(e.key, e.value.toString())),
                const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Status CCTV", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold))),
                ...cctvData.entries.map((e) => _buildReadOnlyField(e.key, e.value.toString())),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 30),

          // --- PANEL LISTRIK & UPS ---
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: _buildAccordionHeader("3. Kelistrikan & UPS", Icons.electrical_services),
              children: [
                const SizedBox(height: 15),
                // SDP 1
                _buildModuleCardReadOnly(title: getPanel(0)['nama_panel'], icon: Icons.flash_on, titleColor: Colors.greenAccent, children: [
                  _buildReadOnlyField("Kondisi Dalam Panel", getPanel(0)['kondisi'] ?? '-'),
                  Row(children: [_buildSmallReadOnly("Amp R", getPanel(0)['amp_r'] ?? '-'), _buildSmallReadOnly("Amp S", getPanel(0)['amp_s'] ?? '-'), _buildSmallReadOnly("Amp T", getPanel(0)['amp_t'] ?? '-')]),
                  Row(children: [_buildSmallReadOnly("Volt R", getPanel(0)['volt_r'] ?? '-'), _buildSmallReadOnly("Volt S", getPanel(0)['volt_s'] ?? '-'), _buildSmallReadOnly("Volt T", getPanel(0)['volt_t'] ?? '-')]),
                ]),
                // SDP 2
                _buildModuleCardReadOnly(title: getPanel(1)['nama_panel'], icon: Icons.flash_on, titleColor: Colors.greenAccent, children: [
                  _buildReadOnlyField("Kondisi Dalam Panel", getPanel(1)['kondisi'] ?? '-'),
                  Row(children: [_buildSmallReadOnly("Amp R", getPanel(1)['amp_r'] ?? '-'), _buildSmallReadOnly("Amp S", getPanel(1)['amp_s'] ?? '-'), _buildSmallReadOnly("Amp T", getPanel(1)['amp_t'] ?? '-')]),
                  Row(children: [_buildSmallReadOnly("Volt R", getPanel(1)['volt_r'] ?? '-'), _buildSmallReadOnly("Volt S", getPanel(1)['volt_s'] ?? '-'), _buildSmallReadOnly("Volt T", getPanel(1)['volt_t'] ?? '-')]),
                  Row(children: [_buildSmallReadOnly("Hz", getPanel(1)['hz'] ?? '-'), const Spacer(), const Spacer()]),
                ]),
                // UPS 1
                _buildModuleCardReadOnly(title: getUps(0)['nama_ups'], icon: Icons.battery_charging_full, titleColor: Colors.orangeAccent, children: [
                  _buildReadOnlyField("Kondisi UPS & Battery", getUps(0)['kondisi_fisik'] ?? '-'),
                  Row(children: [_buildSmallReadOnly("Temp In", getUps(0)['temp_in'] ?? '-'), _buildSmallReadOnly("Temp Out", getUps(0)['temp_out'] ?? '-')]),
                  _buildReadOnlyField("Indikator LED", getUps(0)['led_indicator'] ?? '-'),
                  Row(children: [_buildSmallReadOnly("In A", getUps(0)['in_a'] ?? '-'), _buildSmallReadOnly("In B", getUps(0)['in_b'] ?? '-'), _buildSmallReadOnly("In C", getUps(0)['in_c'] ?? '-')]),
                  _buildReadOnlyField("Indikator Baterai", getUps(0)['indikator_baterai'] ?? '-'),
                  Row(children: [_buildSmallReadOnly("Out A", getUps(0)['out_a'] ?? '-'), _buildSmallReadOnly("Out B", getUps(0)['out_b'] ?? '-'), _buildSmallReadOnly("Out C", getUps(0)['out_c'] ?? '-')]),
                ]),
                // DIST 1
                _buildModuleCardReadOnly(title: getPanel(2)['nama_panel'], icon: Icons.electrical_services, titleColor: Colors.lightBlueAccent, children: [
                  _buildReadOnlyField("Kondisi Dalam Panel", getPanel(2)['kondisi'] ?? '-'),
                  Row(children: [_buildSmallReadOnly("Amp R", getPanel(2)['amp_r'] ?? '-'), _buildSmallReadOnly("Amp S", getPanel(2)['amp_s'] ?? '-'), _buildSmallReadOnly("Amp T", getPanel(2)['amp_t'] ?? '-')]),
                  Row(children: [_buildSmallReadOnly("Volt R", getPanel(2)['volt_r'] ?? '-'), _buildSmallReadOnly("Volt S", getPanel(2)['volt_s'] ?? '-'), _buildSmallReadOnly("Volt T", getPanel(2)['volt_t'] ?? '-')]),
                  Row(children: [_buildSmallReadOnly("Hz", getPanel(2)['hz'] ?? '-'), const Spacer(), const Spacer()]),
                ]),
                // UPS 2
                _buildModuleCardReadOnly(title: getUps(1)['nama_ups'], icon: Icons.battery_charging_full, titleColor: Colors.orangeAccent, children: [
                  _buildReadOnlyField("Kondisi UPS & Battery", getUps(1)['kondisi_fisik'] ?? '-'),
                  Row(children: [_buildSmallReadOnly("Temp In", getUps(1)['temp_in'] ?? '-'), _buildSmallReadOnly("Temp Out", getUps(1)['temp_out'] ?? '-')]),
                  _buildReadOnlyField("Indikator LED", getUps(1)['led_indicator'] ?? '-'),
                  Row(children: [_buildSmallReadOnly("In A", getUps(1)['in_a'] ?? '-'), _buildSmallReadOnly("In B", getUps(1)['in_b'] ?? '-'), _buildSmallReadOnly("In C", getUps(1)['in_c'] ?? '-')]),
                  _buildReadOnlyField("Indikator Baterai", getUps(1)['indikator_baterai'] ?? '-'),
                  Row(children: [_buildSmallReadOnly("Out A", getUps(1)['out_a'] ?? '-'), _buildSmallReadOnly("Out B", getUps(1)['out_b'] ?? '-'), _buildSmallReadOnly("Out C", getUps(1)['out_c'] ?? '-')]),
                ]),
                // DIST 2
                _buildModuleCardReadOnly(title: getPanel(3)['nama_panel'], icon: Icons.electrical_services, titleColor: Colors.lightBlueAccent, children: [
                  _buildReadOnlyField("Kondisi Dalam Panel", getPanel(3)['kondisi'] ?? '-'),
                  Row(children: [_buildSmallReadOnly("Amp R", getPanel(3)['amp_r'] ?? '-'), _buildSmallReadOnly("Amp S", getPanel(3)['amp_s'] ?? '-'), _buildSmallReadOnly("Amp T", getPanel(3)['amp_t'] ?? '-')]),
                  Row(children: [_buildSmallReadOnly("Volt R", getPanel(3)['volt_r'] ?? '-'), _buildSmallReadOnly("Volt S", getPanel(3)['volt_s'] ?? '-'), _buildSmallReadOnly("Volt T", getPanel(3)['volt_t'] ?? '-')]),
                  Row(children: [_buildSmallReadOnly("Hz", getPanel(3)['hz'] ?? '-'), const Spacer(), const Spacer()]),
                ]),
                // UPS 3
                _buildModuleCardReadOnly(title: getUps(2)['nama_ups'], icon: Icons.battery_charging_full, titleColor: Colors.orangeAccent, children: [
                  _buildReadOnlyField("Kondisi UPS & Battery", getUps(2)['kondisi_fisik'] ?? '-'),
                  Row(children: [_buildSmallReadOnly("Temp In", getUps(2)['temp_in'] ?? '-'), _buildSmallReadOnly("Temp Out", getUps(2)['temp_out'] ?? '-')]),
                  _buildReadOnlyField("Indikator LED", getUps(2)['led_indicator'] ?? '-'),
                  Row(children: [_buildSmallReadOnly("In A", getUps(2)['in_a'] ?? '-'), _buildSmallReadOnly("In B", getUps(2)['in_b'] ?? '-'), _buildSmallReadOnly("In C", getUps(2)['in_c'] ?? '-')]),
                  _buildReadOnlyField("Indikator Baterai", getUps(2)['indikator_baterai'] ?? '-'),
                  Row(children: [_buildSmallReadOnly("Out A", getUps(2)['out_a'] ?? '-'), _buildSmallReadOnly("Out B", getUps(2)['out_b'] ?? '-'), _buildSmallReadOnly("Out C", getUps(2)['out_c'] ?? '-')]),
                ]),
                // DIST 3
                _buildModuleCardReadOnly(title: getPanel(4)['nama_panel'], icon: Icons.electrical_services, titleColor: Colors.lightBlueAccent, children: [
                  _buildReadOnlyField("Kondisi Dalam Panel", getPanel(4)['kondisi'] ?? '-'),
                  Row(children: [_buildSmallReadOnly("Amp R", getPanel(4)['amp_r'] ?? '-'), _buildSmallReadOnly("Amp S", getPanel(4)['amp_s'] ?? '-'), _buildSmallReadOnly("Amp T", getPanel(4)['amp_t'] ?? '-')]),
                  Row(children: [_buildSmallReadOnly("Volt R", getPanel(4)['volt_r'] ?? '-'), _buildSmallReadOnly("Volt S", getPanel(4)['volt_s'] ?? '-'), _buildSmallReadOnly("Volt T", getPanel(4)['volt_t'] ?? '-')]),
                  Row(children: [_buildSmallReadOnly("Hz", getPanel(4)['hz'] ?? '-'), const Spacer(), const Spacer()]),
                ]),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 30),

          // --- RAK SERVER ---
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: _buildAccordionHeader("4. Kondisi Rak Server", Icons.dns_outlined),
              children: [
                const SizedBox(height: 10),
                ...rakData.entries.map((e) => _buildReadOnlyField(e.key, e.value.toString())),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
// === MOBILE DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) ===