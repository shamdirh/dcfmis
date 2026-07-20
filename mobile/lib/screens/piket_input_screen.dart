import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../main.dart';

class PiketInputScreen extends StatefulWidget {
  const PiketInputScreen({super.key});

  @override
  State<PiketInputScreen> createState() => _PiketInputScreenState();
}

class _PiketInputScreenState extends State<PiketInputScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String userEmail = '', userNama = '', userJabatan = '';

  // KONTROLER KHUSUS Memperbaiki data tidak tersimpan
  final TextEditingController tglCtrl = TextEditingController();
  final TextEditingController jamCtrl = TextEditingController();
  final TextEditingController suhuCtrl = TextEditingController();
  final TextEditingController catatanCtrl = TextEditingController(text: "-");

  Map<String, String> laporan = {
    'pc_noc': 'Menyala Normal', 'ruangan': 'Bersih', 'sampah': 'Bersih'
  };

  Map<String, String> acData = {
    'Status AC 1 - Ruang NOC': 'Menyala Normal', 'Status AC 2 - Ruang Server': 'Menyala Normal',
    'Status AC 3 - Ruang Server': 'Menyala Normal', 'Status AC 4 - Ruang Server': 'Menyala Normal',
    'Status AC 5 - Ruang Server': 'Menyala Normal', 'Status AC 6 - Ruang Server': 'Menyala Normal',
    'Status AC 7 - Ruang Pusat Data 2': 'Menyala Normal'
  };
  
  Map<String, String> cctvData = {
    'Status CCTV 1 - Ruang NOC': 'Menyala Normal', 'Status CCTV 2 - Ruang Server': 'Menyala Normal',
    'Status CCTV 3 - Ruang Server': 'Menyala Normal', 'Status CCTV 4 - Ruang Pusat Data 2': 'Menyala Normal'
  };

  Map<String, String> rakData = { for (var i=1; i<=9; i++) 'Rak Server $i': 'Aman / Tidak Ada Perubahan' };

  final List<String> panelNames = ['Panel SDP 1', 'Panel SDP 2', 'Panel Distribusi 1', 'Panel Distribusi 2', 'Panel Distribusi 3'];
  late List<Map<String, dynamic>> panelData;

  final List<String> upsNames = ['UPS 1', 'UPS 2', 'UPS 3'];
  late List<Map<String, dynamic>> upsData;

  final List<String> opsiKondisi = ['Baik', 'Kotor', 'Rusak', 'Perbaikan'];
  final List<String> opsiListrik = ['Menyala Normal', 'Mati / Rusak', 'Dalam Perbaikan'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    panelData = List.generate(5, (i) => {
      'nama_panel': panelNames[i], 'kondisi': 'Baik', 'amp_r': '', 'amp_s': '', 'amp_t': '',
      'volt_r': '', 'volt_s': '', 'volt_t': '', 'hz': ''
    });
    
    upsData = List.generate(3, (i) => {
      'nama_ups': upsNames[i], 'kondisi_fisik': 'Baik', 'temp_in': '', 'temp_out': '',
      'led_indicator': 'Online/Inverter LED', 'indikator_baterai': '5 Kotak= 100%', 
      'in_a': '', 'in_b': '', 'in_c': '', 'out_a': '', 'out_b': '', 'out_c': ''
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('user_email') ?? 'admin@kotabogor.go.id';
      userNama = prefs.getString('user_nama') ?? 'Petugas';
      userJabatan = prefs.getString('user_jabatan') ?? 'Pranata Komputer';
    });
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2101));
    if (picked != null) setState(() => tglCtrl.text = DateFormat('yyyy-MM-dd').format(picked));
  }

  Future<void> _selectTime() async {
    TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && mounted) {
      setState(() => jamCtrl.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00");
    }
  }

  Future<void> submitPiket() async {
    if (tglCtrl.text.isEmpty || jamCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tanggal dan Jam wajib diisi!"), backgroundColor: Colors.red));
      return;
    }

    if (!_formKey.currentState!.validate()) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lengkapi semua nilai yang kosong!"), backgroundColor: Colors.redAccent));
       return;
    }
    _formKey.currentState!.save();

    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      Map<String, String> headers = { ...apiHeaders };
      headers['Authorization'] = 'Bearer ${prefs.getString('auth_token') ?? ''}';

      final bodyData = {
        "email": userEmail, "nama_lengkap": userNama, "jabatan": userJabatan,
        "tanggal_pemeriksaan": tglCtrl.text, "jam_pemeriksaan": jamCtrl.text,
        "kebersihan_ruangan": laporan['ruangan'], "kebersihan_sampah": laporan['sampah'],
        "suhu_ruangan_server": suhuCtrl.text, // MENGGUNAKAN CONTROLLER
        "status_pc_noc": laporan['pc_noc'], 
        "catatan_kejadian": catatanCtrl.text, // MENGGUNAKAN CONTROLLER
        "fasilitas": { "ac": acData, "cctv": cctvData, "rak": rakData },
        "panels": panelData, "ups": upsData
      };

      final res = await http.post(Uri.parse('$apiUrl/api/piket/manage'), headers: headers, body: jsonEncode(bodyData));

      if (res.statusCode == 200 || res.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Laporan berhasil disimpan!"), backgroundColor: Colors.green));
        Navigator.pop(context, true); 
      } else {
        throw Exception("API Error: ${res.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menyimpan data!"), backgroundColor: Colors.red));
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ==========================================
  // WIDGET UI HELPER DENGAN WARNA DASHBOARD
  // ==========================================
  InputDecoration _inputStyle(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
      prefixIcon: icon != null ? Icon(icon, color: Colors.cyanAccent, size: 20) : null,
      filled: true,
      fillColor: const Color(0xFF1B4C50), // Teal Gelap
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.transparent)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.redAccent, width: 2)),
    );
  }

  Widget _buildDropdown(String label, Map data, String key, List<String> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        initialValue: data[key],
        decoration: _inputStyle(label),
        dropdownColor: const Color(0xFF103B3E),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.cyanAccent),
        items: options.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
        onChanged: (v) => setState(() => data[key] = v!),
      ),
    );
  }

  Widget _buildControllerInput(String label, TextEditingController controller, {int lines = 1, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller, maxLines: lines,
        decoration: _inputStyle(label, icon: icon),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
      ),
    );
  }

  Widget _buildSmallNumberInput(String label, Map data, String key) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
        child: TextFormField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70, fontSize: 11),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true, fillColor: const Color(0xFF103B3E), // Navy lebih gelap
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.transparent)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.cyanAccent, width: 1.5)),
            errorStyle: const TextStyle(height: 0),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          validator: (v) => v!.isEmpty ? '' : null,
          onSaved: (v) => data[key] = v,
        ),
      ),
    );
  }

  Widget _buildModuleCard({required String title, required IconData icon, required Color titleColor, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A5A63), // Card Teal
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: titleColor, size: 22),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(color: Colors.white24, height: 25, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildAccordionHeader(String title, IconData icon) {
    return Row(children: [
      Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFFCDEDF6).withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: Colors.cyanAccent, size: 20)),
      const SizedBox(width: 12),
      Text(title, style: const TextStyle(color: Color(0xFFCDEDF6), fontSize: 16, fontWeight: FontWeight.bold)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031D44), // Backgound Navy
      appBar: AppBar(
        title: const Text('Formulir Piket', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF103B3E), // Teal Gelap
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- 0. PROFIL PETUGAS ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0B8793), Color(0xFF36D1DC)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 25, backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white, size: 30)),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userNama, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(userJabatan, style: const TextStyle(color: Color(0xFF031D44), fontWeight: FontWeight.w600, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- LAPORAN UTAMA ---
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
                      Expanded(child: TextFormField(controller: tglCtrl, readOnly: true, onTap: _selectDate, decoration: _inputStyle("Tanggal", icon: Icons.calendar_today), style: const TextStyle(color: Colors.white))),
                      const SizedBox(width: 12),
                      Expanded(child: TextFormField(controller: jamCtrl, readOnly: true, onTap: _selectTime, decoration: _inputStyle("Jam", icon: Icons.access_time), style: const TextStyle(color: Colors.white))),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildControllerInput("Suhu Ruangan Server (C)", suhuCtrl, icon: Icons.thermostat),
                  _buildDropdown("Kondisi PC 1 (NOC)", laporan, "pc_noc", opsiListrik),
                  _buildDropdown("Kebersihan Ruangan", laporan, "ruangan", ['Bersih', 'Kotor', 'Sudah Dibersihkan']),
                  _buildDropdown("Kebersihan Sampah", laporan, "sampah", ['Bersih', 'Penuh', 'Sudah Dibuang']),
                  _buildControllerInput("Catatan Kejadian Selama Piket", catatanCtrl, lines: 3),
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
                  ...acData.keys.map((k) => _buildDropdown(k, acData, k, opsiListrik)),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Status CCTV", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold))),
                  ...cctvData.keys.map((k) => _buildDropdown(k, cctvData, k, opsiListrik)),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 30),

            // --- KELISTRIKAN & UPS ---
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: true, 
                tilePadding: EdgeInsets.zero,
                title: _buildAccordionHeader("3. Kelistrikan & UPS", Icons.electrical_services),
                children: [
                  const SizedBox(height: 15),
                  
                  // SDP 1
                  _buildModuleCard(title: panelData[0]['nama_panel'], icon: Icons.flash_on, titleColor: Colors.greenAccent, children: [ 
                    _buildDropdown("Kondisi Dalam Panel", panelData[0], "kondisi", opsiKondisi),
                    Row(children: [_buildSmallNumberInput("Amp R (A)", panelData[0], "amp_r"), _buildSmallNumberInput("Amp S (A)", panelData[0], "amp_s"), _buildSmallNumberInput("Amp T (A)", panelData[0], "amp_t")]),
                    Row(children: [_buildSmallNumberInput("Volt R (V)", panelData[0], "volt_r"), _buildSmallNumberInput("Volt S (V)", panelData[0], "volt_s"), _buildSmallNumberInput("Volt T (V)", panelData[0], "volt_t")]),
                  ]),

                  // SDP 2
                  _buildModuleCard(title: panelData[1]['nama_panel'], icon: Icons.flash_on, titleColor: Colors.greenAccent, children: [
                    _buildDropdown("Kondisi Dalam Panel", panelData[1], "kondisi", opsiKondisi),
                    Row(children: [_buildSmallNumberInput("Amp R (A)", panelData[1], "amp_r"), _buildSmallNumberInput("Amp S (A)", panelData[1], "amp_s"), _buildSmallNumberInput("Amp T (A)", panelData[1], "amp_t")]),
                    Row(children: [_buildSmallNumberInput("Volt R (V)", panelData[1], "volt_r"), _buildSmallNumberInput("Volt S (V)", panelData[1], "volt_s"), _buildSmallNumberInput("Volt T (V)", panelData[1], "volt_t")]),
                    Row(children: [_buildSmallNumberInput("Hz", panelData[1], "hz"), const Spacer(), const Spacer()]),
                  ]),

                  // UPS 1
                  _buildModuleCard(title: upsData[0]['nama_ups'], icon: Icons.battery_charging_full, titleColor: Colors.orangeAccent, children: [ 
                    _buildDropdown("Kondisi UPS & Battery", upsData[0], "kondisi_fisik", opsiKondisi),
                    Row(children: [_buildSmallNumberInput("Temp Internal (C)", upsData[0], "temp_in"), _buildSmallNumberInput("Temp External (C)", upsData[0], "temp_out")]),
                    _buildDropdown("Indikator LED", upsData[0], "led_indicator", ['Online/Inverter LED', 'Bypass', 'Fault/Alarm']),
                    Row(children: [_buildSmallNumberInput("In A (VAC/Hz)", upsData[0], "in_a"), _buildSmallNumberInput("In B", upsData[0], "in_b"), _buildSmallNumberInput("In C", upsData[0], "in_c")]),
                    _buildDropdown("Indikator Baterai", upsData[0], "indikator_baterai", ['5 Kotak= 100%', '4 Kotak= 80%', '3 Kotak= 60%', '2 Kotak= 40%', '1 Kotak= 20%']),
                    Row(children: [_buildSmallNumberInput("Out A (VAC/Hz)", upsData[0], "out_a"), _buildSmallNumberInput("Out B", upsData[0], "out_b"), _buildSmallNumberInput("Out C", upsData[0], "out_c")]),
                  ]),

                  // DIST 1
                  _buildModuleCard(title: panelData[2]['nama_panel'], icon: Icons.electrical_services, titleColor: Colors.lightBlueAccent, children: [ 
                    _buildDropdown("Kondisi Dalam Panel", panelData[2], "kondisi", opsiKondisi),
                    Row(children: [_buildSmallNumberInput("Amp R (A)", panelData[2], "amp_r"), _buildSmallNumberInput("Amp S (A)", panelData[2], "amp_s"), _buildSmallNumberInput("Amp T (A)", panelData[2], "amp_t")]),
                    Row(children: [_buildSmallNumberInput("Volt R (V)", panelData[2], "volt_r"), _buildSmallNumberInput("Volt S (V)", panelData[2], "volt_s"), _buildSmallNumberInput("Volt T (V)", panelData[2], "volt_t")]),
                    Row(children: [_buildSmallNumberInput("Hz", panelData[2], "hz"), const Spacer(), const Spacer()]),
                  ]),

                  // UPS 2
                  _buildModuleCard(title: upsData[1]['nama_ups'], icon: Icons.battery_charging_full, titleColor: Colors.orangeAccent, children: [
                    _buildDropdown("Kondisi UPS & Battery", upsData[1], "kondisi_fisik", opsiKondisi),
                    Row(children: [_buildSmallNumberInput("Temp Internal (C)", upsData[1], "temp_in"), _buildSmallNumberInput("Temp External (C)", upsData[1], "temp_out")]),
                    _buildDropdown("Indikator LED", upsData[1], "led_indicator", ['Online/Inverter LED', 'Bypass', 'Fault/Alarm']),
                    Row(children: [_buildSmallNumberInput("In A (VAC/Hz)", upsData[1], "in_a"), _buildSmallNumberInput("In B", upsData[1], "in_b"), _buildSmallNumberInput("In C", upsData[1], "in_c")]),
                    _buildDropdown("Indikator Baterai", upsData[1], "indikator_baterai", ['5 Kotak= 100%', '4 Kotak= 80%', '3 Kotak= 60%', '2 Kotak= 40%', '1 Kotak= 20%']),
                    Row(children: [_buildSmallNumberInput("Out A (VAC/Hz)", upsData[1], "out_a"), _buildSmallNumberInput("Out B", upsData[1], "out_b"), _buildSmallNumberInput("Out C", upsData[1], "out_c")]),
                  ]),

                  // DIST 2
                  _buildModuleCard(title: panelData[3]['nama_panel'], icon: Icons.electrical_services, titleColor: Colors.lightBlueAccent, children: [
                    _buildDropdown("Kondisi Dalam Panel", panelData[3], "kondisi", opsiKondisi),
                    Row(children: [_buildSmallNumberInput("Amp R (A)", panelData[3], "amp_r"), _buildSmallNumberInput("Amp S (A)", panelData[3], "amp_s"), _buildSmallNumberInput("Amp T (A)", panelData[3], "amp_t")]),
                    Row(children: [_buildSmallNumberInput("Volt R (V)", panelData[3], "volt_r"), _buildSmallNumberInput("Volt S (V)", panelData[3], "volt_s"), _buildSmallNumberInput("Volt T (V)", panelData[3], "volt_t")]),
                    Row(children: [_buildSmallNumberInput("Hz", panelData[3], "hz"), const Spacer(), const Spacer()]),
                  ]),

                  // UPS 3
                  _buildModuleCard(title: upsData[2]['nama_ups'], icon: Icons.battery_charging_full, titleColor: Colors.orangeAccent, children: [
                    _buildDropdown("Kondisi UPS & Battery", upsData[2], "kondisi_fisik", opsiKondisi),
                    Row(children: [_buildSmallNumberInput("Temp Internal (C)", upsData[2], "temp_in"), _buildSmallNumberInput("Temp External (C)", upsData[2], "temp_out")]),
                    _buildDropdown("Indikator LED", upsData[2], "led_indicator", ['Online/Inverter LED', 'Bypass', 'Fault/Alarm']),
                    Row(children: [_buildSmallNumberInput("In A (VAC/Hz)", upsData[2], "in_a"), _buildSmallNumberInput("In B", upsData[2], "in_b"), _buildSmallNumberInput("In C", upsData[2], "in_c")]),
                    _buildDropdown("Indikator Baterai", upsData[2], "indikator_baterai", ['5 Kotak= 100%', '4 Kotak= 80%', '3 Kotak= 60%', '2 Kotak= 40%', '1 Kotak= 20%']),
                    Row(children: [_buildSmallNumberInput("Out A (VAC/Hz)", upsData[2], "out_a"), _buildSmallNumberInput("Out B", upsData[2], "out_b"), _buildSmallNumberInput("Out C", upsData[2], "out_c")]),
                  ]),

                  // DIST 3
                  _buildModuleCard(title: panelData[4]['nama_panel'], icon: Icons.electrical_services, titleColor: Colors.lightBlueAccent, children: [
                    _buildDropdown("Kondisi Dalam Panel", panelData[4], "kondisi", opsiKondisi),
                    Row(children: [_buildSmallNumberInput("Amp R (A)", panelData[4], "amp_r"), _buildSmallNumberInput("Amp S (A)", panelData[4], "amp_s"), _buildSmallNumberInput("Amp T (A)", panelData[4], "amp_t")]),
                    Row(children: [_buildSmallNumberInput("Volt R (V)", panelData[4], "volt_r"), _buildSmallNumberInput("Volt S (V)", panelData[4], "volt_s"), _buildSmallNumberInput("Volt T (V)", panelData[4], "volt_t")]),
                    Row(children: [_buildSmallNumberInput("Hz", panelData[4], "hz"), const Spacer(), const Spacer()]),
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
                  ...rakData.keys.map((k) => _buildDropdown(k, rakData, k, ['Aman / Tidak Ada Perubahan', 'Ada Penambahan Perangkat', 'Ada Pelepasan Perangkat', 'Lainnya (Tulis di Catatan)'])),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // --- TOMBOL SIMPAN ---
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCDEDF6), // Cyan Light
                  foregroundColor: const Color(0xFF031D44), // Navy
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                icon: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Color(0xFF031D44), strokeWidth: 2)) : const Icon(Icons.cloud_upload, size: 24),
                label: Text(isLoading ? "MENYIMPAN DATA..." : "SIMPAN 105 DATA PIKET", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                onPressed: isLoading ? null : submitPiket,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
// === MOBILE DCFMIS - Saeful Hamdi (shamdi.rh@gmail.com) ===