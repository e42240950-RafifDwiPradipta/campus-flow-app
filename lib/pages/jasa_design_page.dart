import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart'; // Akses formatRupiah
import 'keranjang_page.dart';

class JasaDesignPage extends StatefulWidget {
  const JasaDesignPage({super.key});

  @override
  State<JasaDesignPage> createState() => _JasaDesignPageState();
}

class _JasaDesignPageState extends State<JasaDesignPage> {
  final Color primaryTeal = const Color(0xFF1B4D5C);

  // 1. DATA REMOVE BG SUDAH DIHAPUS
  final List<Map<String, dynamic>> paketDesign = [
    {
      "nama": "Desain Poster / Flyer",
      "harga": 25000,
      "deskripsi": "Revisi 2x, File HD (JPG/PNG/PDF)",
      "ikon": Icons.palette_outlined,
      "warna": const Color(0xFFE3F2FD),
    },
    {
      "nama": "Desain PPT (Per Slide)",
      "harga": 5000,
      "deskripsi": "Modern & Clean, Animasi standar",
      "ikon": Icons.slideshow_rounded,
      "warna": const Color(0xFFFFF3E0),
    },
    {
      "nama": "Desain Logo Minimalis",
      "harga": 50000,
      "deskripsi": "Konsep unik, Master file (SVG/AI)",
      "ikon": Icons.category_outlined,
      "warna": const Color(0xFFF3E5F5),
    },
  ];

  // =========================================================
  // FIREBASE: FUNGSI TAMBAH PESANAN DESAIN KE KERANJANG
  // =========================================================
  Future<void> _submitOrderToFirebase(
    Map<String, dynamic> paket,
    String brief,
    String wa,
    String? namaFile,
    int jumlahPesanan, // <--- TAMBAHAN PARAMETER JUMLAH
  ) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan login terlebih dahulu!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Tampilkan Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF1B4D5C)),
      ),
    );

    try {
      int totalHargaAkhir =
          paket['harga'] * jumlahPesanan; // Hitung total harga

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .add({
            'jenis': 'Design',
            'nama': paket['nama'],
            'harga': totalHargaAkhir, // Masukkan harga hasil perkalian
            'detail': "File: ${namaFile ?? 'Tidak ada'}",
            'catatan': "WA: $wa | Detail: $brief",
            'jumlah': jumlahPesanan, // Simpan jumlah ke database
            'timestamp': FieldValue.serverTimestamp(),
          });

      if (mounted) Navigator.pop(context); // Tutup Loading
      if (mounted) Navigator.pop(context); // Tutup Bottom Sheet Form

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pesanan desain masuk keranjang!"),
            backgroundColor: Color(0xFF1B4D5C),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Tutup Loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menambah pesanan: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showFormOrder(Map<String, dynamic> paket) {
    final TextEditingController briefCtrl = TextEditingController();
    final TextEditingController waCtrl = TextEditingController();
    String? namaFileLampiran;

    // 2. VARIABEL PENYIMPAN JUMLAH (Khusus PPT)
    int jumlahItem = 1;
    bool isPPT = paket['nama'].toString().contains('PPT');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // Hitung harga total secara real-time di UI
            int totalHargaTampil = paket['harga'] * jumlahItem;

            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 25,
                left: 25,
                right: 25,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: paket['warna'],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          paket['ikon'],
                          color: primaryTeal,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              paket['nama'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            // TAMPILKAN HARGA TOTAL DINAMIS
                            Text(
                              formatRupiah(totalHargaTampil),
                              style: TextStyle(
                                color: primaryTeal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),

                  // ==========================================
                  // 3. FITUR KUSTOMISASI JUMLAH SLIDE PPT
                  // ==========================================
                  if (isPPT) ...[
                    const Text(
                      "Jumlah Slide Dibutuhkan",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            color: jumlahItem > 1 ? primaryTeal : Colors.grey,
                            onPressed: () {
                              if (jumlahItem > 1) {
                                setModalState(() => jumlahItem--);
                              }
                            },
                          ),
                          const SizedBox(width: 15),
                          Text(
                            "$jumlahItem",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 15),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            color: primaryTeal,
                            onPressed: () {
                              setModalState(() => jumlahItem++);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],

                  // ==========================================
                  const Text(
                    "Deskripsi Kebutuhan",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: briefCtrl,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "Contoh: Tolong buatkan desain minimalis...",
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Nomor WhatsApp",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: waCtrl,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: "0812xxxx...",
                      prefixIcon: const Icon(Icons.phone_android, size: 20),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Upload Bahan / Foto",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      FilePickerResult? result = await FilePicker.pickFiles(
                        type: FileType.image,
                      );
                      if (result != null) {
                        setModalState(() {
                          namaFileLampiran = result.files.first.name;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            color: primaryTeal,
                            size: 30,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            namaFileLampiran ?? "Ketuk untuk upload foto/bahan",
                            style: TextStyle(
                              fontSize: 12,
                              color: namaFileLampiran != null
                                  ? primaryTeal
                                  : Colors.grey,
                              fontWeight: namaFileLampiran != null
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () {
                      if (briefCtrl.text.isEmpty || waCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Mohon isi deskripsi dan No. WA!"),
                          ),
                        );
                        return;
                      }

                      // Panggil fungsi Firebase & KASIH DATA JUMLAH
                      _submitOrderToFirebase(
                        paket,
                        briefCtrl.text,
                        waCtrl.text,
                        namaFileLampiran,
                        jumlahItem, // <--- Lempar angka jumlahnya kesini
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      "TAMBAH KE KERANJANG",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text(
          "Jasa Design",
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
            _buildHeaderBanner(),
            const SizedBox(height: 25),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25),
              child: Text(
                "Pilih Layanan Desain",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 15),
            _buildPackageList(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 10, 25, 40),
      decoration: BoxDecoration(
        color: primaryTeal,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Visualkan Ide Kreatifmu!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Hasil akhir akan dikirimkan melalui WhatsApp.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      itemCount: paketDesign.length,
      itemBuilder: (context, index) {
        final paket = paketDesign[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(15),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: paket['warna'],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(paket['ikon'], color: primaryTeal, size: 28),
            ),
            title: Text(
              paket['nama'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Text(
                  paket['deskripsi'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 5),
                Text(
                  formatRupiah(paket['harga']),
                  style: const TextStyle(
                    color: Color(0xFF1B4D5C),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.add_circle, color: primaryTeal, size: 35),
              onPressed: () => _showFormOrder(paket),
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // FIREBASE: BADGE KERANJANG REAL-TIME
  // =========================================================
  Widget _buildCartBadge() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return IconButton(
        icon: const Icon(Icons.shopping_bag_outlined),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const KeranjangPage()),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .snapshots(),
      builder: (context, snapshot) {
        int cartCount = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KeranjangPage(),
                  ),
                ),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 8,
                  top: 10,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text(
                      "$cartCount",
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
      },
    );
  }
}
