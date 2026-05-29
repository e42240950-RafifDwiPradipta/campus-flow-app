import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart'; // Akses formatRupiah
import 'keranjang_page.dart';

class AtkPage extends StatefulWidget {
  const AtkPage({super.key});

  @override
  State<AtkPage> createState() => _AtkPageState();
}

class _AtkPageState extends State<AtkPage> {
  final Color primaryTeal = const Color(0xFF1B4D5C);
  final Map<String, int> _jumlahBeli = {};

  // =========================================================
  // PERBAIKAN: Variabel penahan Stream agar tidak loading ulang
  // =========================================================
  late Stream<QuerySnapshot> _atkStream;

  @override
  void initState() {
    super.initState();
    _syncCartFromFirebase(); // Panggil fungsi sinkronisasi saat halaman dibuka

    // PERBAIKAN: Simpan Stream ke memori 1x saja saat halaman dibuka
    _atkStream = FirebaseFirestore.instance.collection('stok_atk').snapshots();
  }

  // =========================================================
  // FIREBASE: AMBIL DATA KERANJANG SAAT INI (Biar Counter Sinkron)
  // =========================================================
  Future<void> _syncCartFromFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .where('jenis', isEqualTo: 'ATK')
          .get();

      setState(() {
        _jumlahBeli.clear();
        for (var doc in snapshot.docs) {
          var data = doc.data();
          _jumlahBeli[data['nama']] = data['jumlah'] ?? 0;
        }
      });
    } catch (e) {
      debugPrint("Gagal load keranjang: $e");
    }
  }

  // =========================================================
  // FIREBASE: UPDATE / HAPUS BARANG SAAT TOMBOL +/- DIKLIK
  // =========================================================
  Future<void> _updateCartToFirebase(Map<String, dynamic> item, int qty) async {
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

    // Jadikan nama barang sebagai ID Dokumen
    String docId = item['nama'].toString().replaceAll(RegExp(r'[/\\?]'), '-');
    var docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(docId);

    try {
      if (qty <= 0) {
        await docRef.delete();
      } else {
        await docRef.set({
          'jenis': 'ATK',
          'nama': item['nama'],
          'harga': (item['harga'] ?? 0) * qty,
          'harga_satuan': item['harga'],
          'detail': 'Produk ATK ($qty pcs)',
          'jumlah': qty,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal update keranjang: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: const Text(
          "Toko ATK",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: Column(
        children: [
          // Banner Promo Kecil
          _buildPromoBanner(),

          // =========================================================
          // FIREBASE: STREAM BUILDER UNTUK DAFTAR PRODUK ATK
          // =========================================================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _atkStream, // PERBAIKAN: Gunakan variabel yang sudah diamankan
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                var docs = snapshot.data!.docs;

                return GridView.builder(
                  padding: const EdgeInsets.all(15),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final item = docs[index].data() as Map<String, dynamic>;
                    return _buildProductCard(item);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      color: const Color(0xFFE8F4F1),
      child: Row(
        children: [
          Icon(Icons.local_offer_outlined, size: 16, color: primaryTeal),
          const SizedBox(width: 8),
          const Text(
            "Gratis Ongkir untuk pengambilan di Kampus 2!",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("Stok barang sedang kosong."));
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    final String nama = item['nama'] ?? 'Produk';
    final int qty = _jumlahBeli[nama] ?? 0;
    final int stokTersedia = item['stok'] ?? 0;
    String? urlGambar = item['gambar'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: primaryTeal.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              width: double.infinity,
              alignment: Alignment.center,
              child: Hero(
                tag: nama,
                child: urlGambar != null && urlGambar.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: Image.network(
                          urlGambar,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.inventory_2, // Fallback aman
                            size: 60,
                            color: primaryTeal,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.inventory_2, // Fallback aman
                        size: 60,
                        color: primaryTeal,
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tersisa: $stokTersedia",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  formatRupiah(item['harga'] ?? 0),
                  style: TextStyle(
                    color: primaryTeal,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),

                // Cek UI berdasarkan jumlah (Jika stok 0, tampilkan tombol habis)
                if (stokTersedia <= 0)
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Habis",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                else if (qty > 0)
                  _buildCounter(item, nama, qty, stokTersedia)
                else
                  _buildBuyButton(item, nama, stokTersedia),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounter(
    Map<String, dynamic> item,
    String nama,
    int qty,
    int stokTersedia,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _circleBtn(Icons.remove, () {
          setState(() {
            int newQty = qty - 1;
            _jumlahBeli[nama] = newQty;
            _updateCartToFirebase(item, newQty);
          });
        }),
        Text(
          "$qty",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        _circleBtn(Icons.add, () {
          if (qty < stokTersedia) {
            setState(() {
              int newQty = qty + 1;
              _jumlahBeli[nama] = newQty;
              _updateCartToFirebase(item, newQty);
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Maksimal stok tercapai!")),
            );
          }
        }),
      ],
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: primaryTeal.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 18, color: primaryTeal),
      ),
    );
  }

  Widget _buildBuyButton(
    Map<String, dynamic> item,
    String nama,
    int stokTersedia,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: ElevatedButton(
        onPressed: () {
          if (stokTersedia > 0) {
            setState(() {
              _jumlahBeli[nama] = 1;
              _updateCartToFirebase(item, 1);
            });
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          "Beli",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget? _buildFAB() {
    int cartCount = _jumlahBeli.values.where((qty) => qty > 0).length;

    if (cartCount == 0) return null;
    return FloatingActionButton.extended(
      backgroundColor: const Color(0xFF2D7D8E),
      onPressed: () =>
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const KeranjangPage()),
          ).then((_) {
            _syncCartFromFirebase();
          }),
      label: Text("$cartCount Item di Keranjang"),
      icon: const Icon(Icons.shopping_bag, color: Colors.white),
    );
  }
}
