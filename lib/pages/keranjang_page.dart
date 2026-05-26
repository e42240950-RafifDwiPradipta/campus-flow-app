import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart'; // Tetap biarkan untuk formatRupiah atau data statis lainnya jika ada
import 'checkout_page.dart';

class KeranjangPage extends StatefulWidget {
  const KeranjangPage({super.key});

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  final Color primaryTeal = const Color(0xFF1B4D5C);

  // Ambil referensi user yang sedang login
  User? user = FirebaseAuth.instance.currentUser;

  // Fungsi untuk menghitung total langsung dari daftar dokumen Firestore
  int _hitungSubtotal(List<QueryDocumentSnapshot> docs) {
    int total = 0;
    for (var doc in docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      total += (data['harga'] as int? ?? 0);
    }
    return total;
  }

  // Fungsi menghapus satu item dari Firestore
  Future<void> _hapusItemKeranjang(String docId) async {
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('cart')
            .doc(docId)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Item dihapus dari keranjang"),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal menghapus: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Fungsi mengosongkan keranjang dari Firestore
  Future<void> _kosongkanKeranjang(List<QueryDocumentSnapshot> docs) async {
    if (user != null) {
      try {
        // Karena Firestore tidak punya fitur 'delete collection', kita harus looping
        WriteBatch batch = FirebaseFirestore.instance.batch();
        for (var doc in docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();

        if (mounted) Navigator.pop(context); // Tutup dialog
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal mengosongkan keranjang: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Jika belum login, jangan coba akses Firestore
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Keranjang Belanja"),
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text("Silakan login terlebih dahulu.")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text(
          "Keranjang Belanja",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        // Tombol delete all akan dirender di dalam StreamBuilder jika ada datanya
      ),
      // MENGGUNAKAN STREAM BUILDER UNTUK DATA REAL-TIME
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .collection('cart')
            .orderBy(
              'timestamp',
              descending: true,
            ) // Urutkan dari yang terbaru dimasukkan
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          }

          final cartDocs = snapshot.data?.docs ?? [];

          // Tampilkan AppBar Actions (Hapus Semua) HANYA jika keranjang ada isinya
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Opsional: Cara aman update UI di luar build cycle jika perlu
          });

          return Column(
            children: [
              // AREA DAFTAR BARANG
              Expanded(
                child: cartDocs.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: cartDocs.length,
                        itemBuilder: (context, index) {
                          var doc = cartDocs[index];
                          Map<String, dynamic> itemData =
                              doc.data() as Map<String, dynamic>;
                          return _buildCartItem(doc.id, itemData);
                        },
                      ),
              ),

              // AREA CHECKOUT BUTTON (Hanya muncul jika ada barang)
              if (cartDocs.isNotEmpty) _buildCheckoutSection(cartDocs),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.remove_shopping_cart_rounded,
                size: 100,
                color: Colors.red[300],
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Wah, keranjangmu masih kosong!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.blueGrey[800],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Yuk, cari kebutuhan kampusmu sekarang. Jangan sampai ada yang terlewat ya!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5, fontSize: 14),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
              ),
              label: const Text(
                "Mulai Belanja",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(String docId, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_getIcon(item['jenis']), color: primaryTeal),
        ),
        title: Text(
          item['nama'] ?? "Item",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              item['detail'] ?? "",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              formatRupiah(item['harga'] ?? 0),
              style: TextStyle(
                color: primaryTeal,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () =>
              _hapusItemKeranjang(docId), // Panggil fungsi hapus ke Firebase
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(List<QueryDocumentSnapshot> docs) {
    int totalHarga = _hitungSubtotal(docs);

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Baris Tombol Hapus Semua (Dipindah ke bawah sini karena AppBar ribet baca state StreamBuilder)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showConfirmDeleteAll(docs),
                  icon: const Icon(
                    Icons.delete_sweep,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  label: const Text(
                    "Kosongkan Keranjang",
                    style: TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Pembayaran",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  formatRupiah(totalHarga),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigasi ke Checkout (Nanti halaman checkout juga harus pakai data Firebase ini)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CheckoutPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              child: const Text(
                "KONFIRMASI PESANAN",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String? jenis) {
    switch (jenis) {
      case 'Print':
        return Icons.print_outlined;
      case 'ATK':
        return Icons.shopping_bag_outlined;
      case 'Jastip':
        return Icons.fastfood_outlined;
      default:
        return Icons.shopping_cart_outlined;
    }
  }

  void _showConfirmDeleteAll(List<QueryDocumentSnapshot> docs) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Kosongkan Keranjang?"),
        content: const Text(
          "Semua item akan dihapus dari daftar belanja Anda.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => _kosongkanKeranjang(docs),
            child: const Text(
              "Hapus Semua",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
