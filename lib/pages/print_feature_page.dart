import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../main.dart'; // Akses keranjangGlobal
import 'keranjang_page.dart';

class PrintFeaturePage extends StatefulWidget {
  const PrintFeaturePage({super.key});

  @override
  State<PrintFeaturePage> createState() => _PrintFeaturePageState();
}

class _PrintFeaturePageState extends State<PrintFeaturePage> {
  String? _namaFile;
  int _jumlahHalaman = 1;
  String _warna = "Hitam Putih";
  String _ukuranKertas = "A4";
  bool _pakaiJilid = false;

  final TextEditingController _catatanController = TextEditingController();
  final TextEditingController _halamanController = TextEditingController(
    text: "1",
  );
  final Color primaryTeal = const Color(0xFF1B4D5C);

  int _estimasiTotal = 0;

  @override
  void dispose() {
    _catatanController.dispose();
    _halamanController.dispose();
    super.dispose();
  }

  void _hitungHarga() {
    if (_namaFile == null) return;

    int hargaPerHal = (_warna == "Warna") ? 1000 : 500;
    int subtotal = _jumlahHalaman * hargaPerHal;

    if (_ukuranKertas == "A3") subtotal += 2000;
    if (_pakaiJilid) subtotal += 5000;

    setState(() {
      _estimasiTotal = subtotal; // HANYA HARGA NORMAL
    });
  }

  // Logika update halaman dari tombol + dan -
  void _updateHalaman(int val) {
    if (val < 1) val = 1;
    setState(() {
      _jumlahHalaman = val;
      _halamanController.text = val.toString();
      // Pindahkan kursor ke ujung teks
      _halamanController.selection = TextSelection.fromPosition(
        TextPosition(offset: _halamanController.text.length),
      );
    });
    _hitungHarga();
  }

  // Fungsi untuk mengembalikan form ke kondisi awal
  void _resetForm() {
    setState(() {
      _namaFile = null;
      _jumlahHalaman = 1;
      _halamanController.text = "1";
      _warna = "Hitam Putih";
      _ukuranKertas = "A4";
      _pakaiJilid = false;
      _catatanController.clear();
      _estimasiTotal = 0;
    });
  }

  Future<void> _pilihFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'jpg', 'png'],
    );
    if (result != null) {
      setState(() => _namaFile = result.files.first.name);
      _hitungHarga();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text(
          "Layanan Print",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [_buildCartBadge()],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(25, 10, 25, 30),
              decoration: BoxDecoration(
                color: primaryTeal,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Text(
                "Upload dokumenmu dan tentukan spesifikasi cetaknya secara instan.",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("1. Dokumen Anda"),
                  _buildUploadArea(),
                  if (_namaFile != null) ...[
                    const SizedBox(height: 25),
                    _buildSectionTitle("2. Konfigurasi Cetak"),
                    _buildPrintSettings(),
                    const SizedBox(height: 25),
                    _buildSectionTitle("3. Catatan Khusus"),
                    _buildCatatanField(),
                    const SizedBox(height: 30),
                    _buildPriceSummary(),
                    const SizedBox(height: 20),
                    _buildAddToCartButton(),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartBadge() {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined, size: 28),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KeranjangPage()),
            ).then((_) => setState(() {})),
          ),
          if (keranjangGlobal.isNotEmpty)
            Positioned(
              right: 8,
              top: 10,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  "${keranjangGlobal.length}",
                  textAlign: TextAlign.center,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 5),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: primaryTeal.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return InkWell(
      onTap: _pilihFile,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryTeal.withOpacity(0.1), width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.cloud_upload_outlined, size: 50, color: primaryTeal),
            const SizedBox(height: 15),
            Text(
              _namaFile ?? "Ketuk untuk memilih file (PDF/DOCX/IMG)",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _namaFile == null ? Colors.grey : Colors.black87,
              ),
            ),
            if (_namaFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "Ganti file",
                  style: TextStyle(
                    color: primaryTeal,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrintSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          _buildCounterField(),
          const Divider(height: 30),
          _buildDropdown(
            "Tipe Warna",
            Icons.palette_outlined,
            _warna,
            ["Hitam Putih", "Warna"],
            (v) {
              setState(() => _warna = v!);
              _hitungHarga();
            },
          ),
          const SizedBox(height: 15),
          _buildDropdown(
            "Ukuran Kertas",
            Icons.straighten_outlined,
            _ukuranKertas,
            ["A4", "F4 / Folio", "A3"],
            (v) {
              setState(() => _ukuranKertas = v!);
              _hitungHarga();
            },
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              "Jilid Dokumen (+5rb)",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            secondary: Icon(Icons.auto_stories_outlined, color: primaryTeal),
            activeColor: primaryTeal,
            value: _pakaiJilid,
            onChanged: (v) {
              setState(() => _pakaiJilid = v);
              _hitungHarga();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCounterField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Jumlah Halaman",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        // Desain Counter Modern (Menyatu dalam box)
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              _countBtn(Icons.remove, () => _updateHalaman(_jumlahHalaman - 1)),
              SizedBox(
                width: 50,
                child: TextField(
                  controller: _halamanController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  onChanged: (val) {
                    int? parsed = int.tryParse(val);
                    if (parsed != null && parsed > 0) {
                      setState(() => _jumlahHalaman = parsed);
                      _hitungHarga();
                    }
                  },
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus(); // Tutup keyboard
                    if (int.tryParse(_halamanController.text) == null ||
                        int.parse(_halamanController.text) < 1) {
                      _updateHalaman(1); // Balik ke 1 kalau ngawur
                    }
                  },
                ),
              ),
              _countBtn(Icons.add, () => _updateHalaman(_jumlahHalaman + 1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _countBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Icon(icon, size: 20, color: primaryTeal),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    IconData icon,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryTeal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e, style: const TextStyle(fontSize: 14)),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildCatatanField() {
    return TextField(
      controller: _catatanController,
      maxLines: 2,
      decoration: InputDecoration(
        hintText: "Misal: Jilid mika bening, rangkap 2, dll.",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryTeal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryTeal.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Estimasi Total",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                "Rp $_estimasiTotal",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryTeal,
                ),
              ),
            ],
          ),
          if (_jumlahHalaman >= 50) ...[
            const SizedBox(height: 5),
            const Text(
              "*Diskon Print 10% akan otomatis dipotong di halaman pembayaran.",
              style: TextStyle(
                fontSize: 11,
                color: Colors.orange,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return ElevatedButton(
      onPressed: () {
        if (_namaFile == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Mohon upload file terlebih dahulu!"),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        setState(() {
          keranjangGlobal.add({
            'jenis': 'Print',
            'nama': 'Print: $_namaFile',
            'harga': _estimasiTotal,
            'detail':
                '$_ukuranKertas, $_jumlahHalaman Hal, $_warna${_pakaiJilid ? ", Jilid" : ""}',
            'catatan': _catatanController.text,
            'jumlahHalaman': _jumlahHalaman,
            'file': _namaFile, // Simpan nama file agar bisa dipanggil Admin
          });
        });

        // Panggil fungsi reset form
        _resetForm();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Berhasil masuk keranjang!"),
            backgroundColor: Color(0xFF2D7D8E),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: const Text(
        "TAMBAH KE KERANJANG",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
