import 'package:flutter/material.dart';
import '../main.dart';
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

  // Rekomendasi tempat cepat (Biar ngetiknya makin SatSet)
  final List<String> _rekomendasiTempat = [
    "Kantin Pusat Polije",
    "Warmindo Depan",
    "Indomaret Terdekat",
    "Fotokopian Koperasi",
  ];

  void _tambahKeKeranjang() {
    if (_formKey.currentState!.validate()) {
      // Ambil angka harga saja (kalau user iseng ketik 'Rp' atau titik)
      int hargaBarang =
          int.tryParse(_hargaCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

      // Biaya Jastip Flat (Misal Rp 2.000 per titipan)
      int biayaJastip = 2000;

      setState(() {
        keranjangGlobal.add({
          'jenis': 'Jastip',
          'nama': "Titip: ${_tempatCtrl.text}",
          'harga': hargaBarang + biayaJastip,
          'detail': "${_menuCtrl.text} (+ Jastip 2k)",
          'catatan': _catatanCtrl.text.isEmpty ? '-' : _catatanCtrl.text,
        });
      });

      // Bersihkan form setelah ditambahkan
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
            // --- HEADER BANNER ---
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
                    "Tulis aja warungnya dan menunya. Biar kami yang jalan, kamu tinggal nunggu di kelas!",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- FORM INPUT ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                      hint: "Contoh: Warung Bu Siti / Indomaret",
                      icon: Icons.storefront_outlined,
                      validatorMsg: "Lokasi tidak boleh kosong",
                    ),

                    const SizedBox(height: 20),
                    _buildSectionTitle("2. Detail Pesanan"),
                    _buildTextField(
                      controller: _menuCtrl,
                      hint: "Contoh: Nasi Goreng Pedas 1, Es Teh 1",
                      icon: Icons.restaurant_menu,
                      maxLines: 2,
                      validatorMsg: "Detail pesanan harus diisi",
                    ),

                    const SizedBox(height: 20),
                    _buildSectionTitle("3. Perkiraan Harga Total Barang"),
                    _buildTextField(
                      controller: _hargaCtrl,
                      hint: "Contoh: 15000",
                      icon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                      validatorMsg: "Masukkan perkiraan harga",
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 5, top: 5),
                      child: Text(
                        "*Jika harga aslinya berbeda, kurir akan konfirmasi via WA.",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    _buildSectionTitle("4. Catatan Tambahan (Opsional)"),
                    _buildTextField(
                      controller: _catatanCtrl,
                      hint: "Contoh: Jangan pakai bawang, kuahnya pisah ya.",
                      icon: Icons.note_alt_outlined,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 30),

                    // --- TOMBOL SUBMIT ---
                    ElevatedButton(
                      onPressed: _tambahKeKeranjang,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 5,
                        shadowColor: primaryTeal.withOpacity(0.3),
                      ),
                      child: const Text(
                        "TAMBAH KE KERANJANG",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey[300]!),
              onPressed: () {
                setState(() {
                  _tempatCtrl.text = tempat;
                });
              },
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
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 0), // Adjust if maxLines > 1
          child: Icon(icon, color: primaryTeal),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryTeal, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
      validator: validatorMsg != null
          ? (value) => (value == null || value.isEmpty) ? validatorMsg : null
          : null,
    );
  }

  Widget _buildCartBadge() {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KeranjangPage()),
            ).then((value) => setState(() {})),
          ),
          if (keranjangGlobal.isNotEmpty)
            Positioned(
              right: 8,
              top: 10,
              child: CircleAvatar(
                radius: 8,
                backgroundColor: Colors.red,
                child: Text(
                  "${keranjangGlobal.length}",
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
