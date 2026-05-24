import 'package:flutter/material.dart';
import '../main.dart';
import 'keranjang_page.dart';

class AtkPage extends StatefulWidget {
  const AtkPage({super.key});

  @override
  State<AtkPage> createState() => _AtkPageState();
}

class _AtkPageState extends State<AtkPage> {
  final Color primaryTeal = const Color(0xFF1B4D5C);
  final Map<String, int> _jumlahBeli = {};

  // Inisialisasi jumlah beli berdasarkan isi keranjang saat ini agar sinkron
  @override
  void initState() {
    super.initState();
    for (var item in keranjangGlobal) {
      if (item['jenis'] == 'ATK') {
        // Ekstrak angka dari string "Produk ATK (X pcs)"
        RegExp regExp = RegExp(r'\((.*?) ');
        var match = regExp.firstMatch(item['detail'] ?? "");
        if (match != null) {
          _jumlahBeli[item['nama']] = int.tryParse(match.group(1)!) ?? 0;
        }
      }
    }
  }

  void updateKeranjang(Map<String, dynamic> item) {
    final qty = _jumlahBeli[item['nama']] ?? 0;

    setState(() {
      keranjangGlobal.removeWhere((e) => e['nama'] == item['nama']);
      if (qty > 0) {
        keranjangGlobal.add({
          'jenis': 'ATK',
          'nama': item['nama'],
          'harga': item['harga'] * qty,
          'detail': 'Produk ATK ($qty pcs)',
        });
      }
    });
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
          // Banner Promo Kecil ala Shopee
          _buildPromoBanner(),

          Expanded(
            child: stokAtkGlobal.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(15),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.65,
                        ),
                    itemCount: stokAtkGlobal.length,
                    itemBuilder: (context, index) {
                      final item = stokAtkGlobal[index];
                      return _buildProductCard(item);
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
    final String nama = item['nama'];
    final int qty = _jumlahBeli[nama] ?? 0;
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
          // =========================================================
          // MODIFIKASI UTAMA: MENAMPILKAN FOTO PRODUK SUNGUHAN
          // =========================================================
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
                // Logika: Cek apakah ada link gambar internet
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
                          // Trik Pengaman: Kalau link mati atau internet off, otomatis tampilin Icon
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              item['ikon'] ?? Icons.inventory_2,
                              size: 60,
                              color: primaryTeal,
                            );
                          },
                        ),
                      )
                    : Icon(
                        item['ikon'] ?? Icons.inventory_2,
                        size: 60,
                        color: primaryTeal,
                      ),
              ),
            ),
          ),

          // Detail Produk
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
                  "Tersisa: ${item['stok']}",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  formatRupiah(item['harga']),
                  style: TextStyle(
                    color: primaryTeal,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),

                // Tombol Beli / Counter (UI Shopee Style)
                qty > 0
                    ? _buildCounter(item, nama, qty)
                    : _buildBuyButton(item, nama),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounter(Map<String, dynamic> item, String nama, int qty) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _circleBtn(Icons.remove, () {
          setState(() {
            _jumlahBeli[nama] = qty - 1;
            updateKeranjang(item);
          });
        }),
        Text(
          "$qty",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        _circleBtn(Icons.add, () {
          if (qty < item['stok']) {
            setState(() {
              _jumlahBeli[nama] = qty + 1;
              updateKeranjang(item);
            });
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

  Widget _buildBuyButton(Map<String, dynamic> item, String nama) {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: ElevatedButton(
        onPressed: () {
          if (item['stok'] > 0) {
            setState(() {
              _jumlahBeli[nama] = 1;
              updateKeranjang(item);
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
    if (keranjangGlobal.isEmpty) return null;
    return FloatingActionButton.extended(
      backgroundColor: const Color(0xFF2D7D8E),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const KeranjangPage()),
      ).then((_) => setState(() {})),
      label: Text("${keranjangGlobal.length} Item di Keranjang"),
      icon: const Icon(Icons.shopping_bag, color: Colors.white),
    );
  }
}
