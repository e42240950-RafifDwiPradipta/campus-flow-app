import 'package:flutter/material.dart';
import '../main.dart'; // Wajib import ini untuk akses daftarAlamatGlobal

class AlamatPage extends StatefulWidget {
  const AlamatPage({super.key});

  @override
  State<AlamatPage> createState() => _AlamatPageState();
}

class _AlamatPageState extends State<AlamatPage> {
  final Color primaryTeal = const Color(0xFF1B4D5C);

  final TextEditingController _labelCtrl = TextEditingController();
  final TextEditingController _detailCtrl = TextEditingController();

  // Fungsi Tambah Alamat via Bottom Sheet
  void _tampilkanInputAlamat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 25,
          left: 25,
          right: 25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tambah Alamat Baru",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _labelCtrl,
              decoration: InputDecoration(
                labelText: "Label Alamat",
                hintText: "Contoh: Kos, Kantor, Rumah",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _detailCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Alamat Lengkap",
                hintText: "Tuliskan jalan, nomor rumah, atau detail gedung...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                if (_labelCtrl.text.isNotEmpty && _detailCtrl.text.isNotEmpty) {
                  setState(() {
                    // SIMPAN KE GUDANG GLOBAL
                    daftarAlamatGlobal.add({
                      "label": _labelCtrl.text,
                      "detail": _detailCtrl.text,
                      "isUtama": false,
                    });
                  });
                  _labelCtrl.clear();
                  _detailCtrl.clear();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "SIMPAN ALAMAT",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _hapusAlamat(int index) {
    setState(() {
      // HAPUS DARI GUDANG GLOBAL
      daftarAlamatGlobal.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Alamat berhasil dihapus"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text(
          "Alamat Saya",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header Info
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
              "Atur alamat pengirimanmu agar proses Jastip & antar dokumen makin cepat.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),

          Expanded(
            // BACA DARI GUDANG GLOBAL
            child: daftarAlamatGlobal.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: daftarAlamatGlobal.length,
                    itemBuilder: (context, index) {
                      final item = daftarAlamatGlobal[index];
                      return _buildAlamatCard(item, index);
                    },
                  ),
          ),

          // Tombol Tambah di Bawah
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              onPressed: _tampilkanInputAlamat,
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text(
                "TAMBAH ALAMAT BARU",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 5,
                shadowColor: primaryTeal.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 15),
          const Text(
            "Belum ada alamat tersimpan.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAlamatCard(Map<String, dynamic> item, int index) {
    bool isUtama = item['isUtama'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUtama ? primaryTeal : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () {
            setState(() {
              for (var alamat in daftarAlamatGlobal) {
                alamat['isUtama'] = false;
              }
              daftarAlamatGlobal[index]['isUtama'] = true;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: isUtama ? primaryTeal : Colors.grey[100],
                  child: Icon(
                    Icons.location_on,
                    color: isUtama ? Colors.white : Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item['label'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (isUtama)
                            Container(
                              margin: const EdgeInsets.only(left: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: primaryTeal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                "Utama",
                                style: TextStyle(
                                  color: primaryTeal,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item['detail'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => _showKonfirmasiHapus(index),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showKonfirmasiHapus(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hapus Alamat?"),
        content: const Text(
          "Apakah kamu yakin ingin menghapus alamat ini dari daftar?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("BATAL"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _hapusAlamat(index);
            },
            child: const Text("HAPUS", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
