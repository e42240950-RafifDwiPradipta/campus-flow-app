import 'package:flutter/material.dart';
import '../main.dart'; // Akses keranjangGlobal & formatRupiah
import 'keranjang_page.dart';

class JastipMakananPage extends StatefulWidget {
  const JastipMakananPage({super.key});

  @override
  State<JastipMakananPage> createState() => _JastipMakananPageState();
}

class _JastipMakananPageState extends State<JastipMakananPage> {
  final Color primaryTeal = const Color(0xFF1B4D5C);

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tempatCtrl = TextEditingController();
  final TextEditingController _menuCtrl = TextEditingController();
  final TextEditingController _hargaCtrl = TextEditingController();
  final TextEditingController _catatanCtrl = TextEditingController();

  final List<String> _rekomendasiTempat = [
    "Kantin Pusat Polije",
    "Warmindo Depan",
    "Indomaret Terdekat",
    "Fotokopian Koperasi",
  ];

  void _tambahKeKeranjang() {
    if (_formKey.currentState!.validate()) {
      int hargaBarang =
          int.tryParse(_hargaCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

      int biayaJastip = 2000;

      setState(() {
        keranjangGlobal.add({
          'jenis': 'Jastip',
          'nama': "Titip: ${_tempatCtrl.text}",
          'harga': hargaBarang + biayaJastip,
          'detail': "${_menuCtrl.text} (+ Jastip ${formatRupiah(biayaJastip)})",
          'catatan': _catatanCtrl.text.isEmpty ? '-' : _catatanCtrl.text,
        });
      });

      _tempatCtrl.clear();
      _menuCtrl.clear();
      _hargaCtrl.clear();
      _catatanCtrl.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pesanan Jastip berhasil masuk keranjang!"),
          backgroundColor: Color(0xFF2D7D8E),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text(
          "Jastip Bebas",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [_buildCartBadge()],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(25, 10, 25, 40),
              decoration: BoxDecoration(
                color: primaryTeal,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mau nitip apa hari ini?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Tulis aja warungnya dan menunya. Biar kami yang jalan!",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("1. Lokasi Pembelian"),
                    _buildSaranTempat(),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _tempatCtrl,
                      hint: "Contoh: Warung Bu Siti",
                      icon: Icons.storefront_outlined,
                      validatorMsg: "Lokasi kosong",
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle("2. Detail Pesanan"),
                    _buildTextField(
                      controller: _menuCtrl,
                      hint: "Contoh: Nasi Goreng 1",
                      icon: Icons.restaurant_menu,
                      maxLines: 2,
                      validatorMsg: "Detail kosong",
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle("3. Perkiraan Harga Total Barang"),
                    _buildTextField(
                      controller: _hargaCtrl,
                      hint: "15000",
                      icon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                      validatorMsg: "Masukkan harga",
                      isPrice: true, // AKTIFKAN RP
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle("4. Catatan Tambahan"),
                    _buildTextField(
                      controller: _catatanCtrl,
                      hint: "Contoh: Jangan pakai bawang",
                      icon: Icons.note_alt_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _tambahKeKeranjang,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        "TAMBAH KE KERANJANG",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET PENDUKUNG ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 5),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: primaryTeal,
        ),
      ),
    );
  }

  Widget _buildSaranTempat() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _rekomendasiTempat.map((tempat) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(tempat, style: const TextStyle(fontSize: 12)),
              onPressed: () => setState(() => _tempatCtrl.text = tempat),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? validatorMsg,
    bool isPrice = false, // Tambahkan parameter ini
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        // Ini kuncinya:
        prefixText: isPrice ? 'Rp ' : null,
        prefixStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        prefixIcon: Icon(icon, color: primaryTeal),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validatorMsg != null
          ? (val) => (val!.isEmpty) ? validatorMsg : null
          : null,
    );
  }

  Widget _buildCartBadge() {
    return IconButton(
      icon: Badge(
        label: Text("${keranjangGlobal.length}"),
        isLabelVisible: keranjangGlobal.isNotEmpty,
        child: const Icon(Icons.shopping_bag_outlined),
      ),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const KeranjangPage()),
      ).then((_) => setState(() {})),
    );
  }
}
