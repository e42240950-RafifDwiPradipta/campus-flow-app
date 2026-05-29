import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import 'package:intl/intl.dart';
import 'nota_sukses_page.dart';
import 'qris_asli_page.dart';
// --- TAMBAHAN IMPORT DOTENV ---
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _metodeAmbil = "Ambil di Tempat";
  String _metodeBayar = "QRIS";
  final TextEditingController _alamatCtrl = TextEditingController();
  final Color primaryTeal = const Color(0xFF1B4D5C);

  double _estimasiJarak = 0.0;
  int _biayaOngkir = 0;

  List<QueryDocumentSnapshot> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _alamatCtrl.addListener(_hitungOngkir);
    _loadCartData();
  }

  Future<void> _loadCartData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        var snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .get();

        setState(() {
          _cartItems = snapshot.docs;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        debugPrint("Gagal load cart di checkout: $e");
      }
    }
  }

  @override
  void dispose() {
    _alamatCtrl.removeListener(_hitungOngkir);
    _alamatCtrl.dispose();
    super.dispose();
  }

  void _hitungOngkir() {
    if (_metodeAmbil != "Diantar (COD)" || _alamatCtrl.text.isEmpty) {
      setState(() {
        _estimasiJarak = 0.0;
        _biayaOngkir = 0;
      });
      return;
    }

    String alamat = _alamatCtrl.text.toLowerCase();
    if (alamat.contains("kampus") ||
        alamat.contains("polije") ||
        alamat.contains("pancoran") ||
        alamat.contains("blindungan") ||
        alamat.contains("situbondo")) {
      _estimasiJarak = 1.5;
    } else if (alamat.contains("alun") || alamat.contains("kota")) {
      _estimasiJarak = 4.0;
    } else if (alamat.contains("tenggarang") || alamat.contains("nangkaan")) {
      _estimasiJarak = 6.0;
    } else {
      _estimasiJarak = 3.0 + (alamat.length % 4);
    }

    int baseOngkir = 3000;
    if (_estimasiJarak <= 3.0) {
      _biayaOngkir = baseOngkir;
    } else {
      int extraKm = (_estimasiJarak - 3.0).ceil();
      _biayaOngkir = baseOngkir + (extraKm * 1500);
    }
    setState(() {});
  }

  int hitungSubtotal() {
    int subtotal = 0;
    for (var doc in _cartItems) {
      var item = doc.data() as Map<String, dynamic>;
      subtotal += (item['harga'] as int? ?? 0);
    }
    return subtotal;
  }

  int hitungDiskon() {
    int totalDiskon = 0;
    for (var doc in _cartItems) {
      var item = doc.data() as Map<String, dynamic>;
      if (item['jenis'] == 'Print' && item.containsKey('jumlahHalaman')) {
        int hal = item['jumlahHalaman'] as int;
        if (hal >= 50) {
          totalDiskon += ((item['harga'] as int) * 0.10).toInt();
        }
      }
    }
    return totalDiskon;
  }

  int hitungTotal() {
    return hitungSubtotal() + _biayaOngkir - hitungDiskon();
  }

  void _pilihAlamatTersimpan() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Pilih Alamat Tersimpan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 15),
              ...daftarAlamatGlobal.map(
                (alamatMap) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: primaryTeal.withOpacity(0.1),
                    child: Icon(
                      Icons.location_on,
                      color: primaryTeal,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    alamatMap['label'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    alamatMap['detail'],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () {
                    _alamatCtrl.text = alamatMap['detail'];
                    _hitungOngkir();
                    Navigator.pop(context);
                  },
                ),
              ),
              const Divider(height: 30),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.edit_note, color: Colors.grey),
                title: const Text(
                  "Tulis Alamat Manual",
                  style: TextStyle(fontSize: 14),
                ),
                onTap: () {
                  _alamatCtrl.clear();
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Konfirmasi Checkout"),
          backgroundColor: primaryTeal,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text(
          "Konfirmasi Checkout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSectionCard("Rincian Pesanan", _buildRincianPesanan()),
                const SizedBox(height: 15),
                _buildSectionCard("Pengiriman", _buildMetodeAmbilSection()),
                const SizedBox(height: 15),
                _buildSectionCard("Pembayaran", _buildMetodeBayarSection()),
                const SizedBox(height: 15),
                _buildRingkasanBiaya(),
              ],
            ),
          ),
          _buildBottomPaySection(),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, Widget content) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: primaryTeal,
            ),
          ),
          const Divider(height: 25),
          content,
        ],
      ),
    );
  }

  Widget _buildRincianPesanan() {
    if (_cartItems.isEmpty) {
      return const Text(
        "Keranjang Kosong",
        style: TextStyle(color: Colors.grey),
      );
    }
    return Column(
      children: _cartItems.map((doc) {
        var item = doc.data() as Map<String, dynamic>;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['nama'] ?? '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      item['spesifikasi'] ?? item['detail'] ?? "",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                formatRupiah(item['harga'] ?? 0),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetodeAmbilSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _metodeAmbil,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.delivery_dining, color: primaryTeal),
          ),
          items: ["Ambil di Tempat", "Diantar (COD)"]
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: (v) {
            setState(() {
              _metodeAmbil = v!;
              _hitungOngkir();
            });
          },
        ),
        if (_metodeAmbil == "Diantar (COD)") ...[
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Alamat Pengantaran",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: _pilihAlamatTersimpan,
                child: Text(
                  "Pilih Alamat",
                  style: TextStyle(
                    fontSize: 12,
                    color: primaryTeal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _alamatCtrl,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: "Contoh: Kost Jl. Raya Situbondo, Blindungan...",
              prefixIcon: const Icon(Icons.map, size: 20),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          if (_estimasiJarak > 0)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Estimasi Jarak: ${_estimasiJarak.toStringAsFixed(1)} km\nOngkos Kirim: ${formatRupiah(_biayaOngkir)}",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildMetodeBayarSection() {
    return DropdownButtonFormField<String>(
      value: _metodeBayar,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Icon(Icons.payment, color: primaryTeal),
      ),
      items: ["QRIS", "Tunai"]
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e, style: const TextStyle(fontSize: 14)),
            ),
          )
          .toList(),
      onChanged: (v) => setState(() => _metodeBayar = v!),
    );
  }

  Widget _buildRingkasanBiaya() {
    int diskon = hitungDiskon();
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
                "Subtotal Produk",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                formatRupiah(hitungSubtotal()),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (diskon > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Diskon Promo Print (10%)",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "- ${formatRupiah(diskon)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Ongkos Kirim",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              Text(
                formatRupiah(_biayaOngkir),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPaySection() {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Akhir",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                Text(
                  formatRupiah(hitungTotal()),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: primaryTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_cartItems.isEmpty) return;
                if (_metodeAmbil == "Diantar (COD)" &&
                    _alamatCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mohon isi alamat pengantaran!"),
                    ),
                  );
                  return;
                }
                _jalankanLoadingDanSimpan();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                "BAYAR SEKARANG",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _jalankanLoadingDanSimpan() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: primaryTeal),
                const SizedBox(height: 25),
                const Text(
                  "Memproses Pesanan...",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Mohon tunggu sebentar ya.",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        );
      },
    );

    _prosesSimpanDataFirebase();
  }

  Future<void> _prosesSimpanDataFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      String generatedId =
          "CAMPUS-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";
      String orderDate = DateFormat(
        'dd MMM yyyy, HH:mm',
      ).format(DateTime.now());

      List<Map<String, dynamic>> itemsFinal = _cartItems.map((doc) {
        var item = doc.data() as Map<String, dynamic>;
        return {
          'nama': item['nama'] ?? '-',
          'harga': item['harga'] ?? 0,
          'jumlah': item['jumlah'] ?? 1,
          'spesifikasi': item['spesifikasi'] ?? item['detail'] ?? '-',
          'catatan': item['catatan'] ?? '-',
          'file': item['file'],
          'jenis': item['jenis'],
        };
      }).toList();

      String statusAwal = _metodeBayar == "QRIS"
          ? "Menunggu Pembayaran"
          : "Diproses";

      Map<String, dynamic> orderData = {
        'id': generatedId,
        'uid': user.uid,
        'email': emailUserGlobal,
        'namaPemesan': namaUserGlobal,
        'items': itemsFinal,
        'subtotal': hitungSubtotal(),
        'diskon': hitungDiskon(),
        'ongkir': _biayaOngkir,
        'total': hitungTotal(),
        'metodeAmbil': _metodeAmbil,
        'metodeBayar': _metodeBayar,
        'alamat': _metodeAmbil == "Diantar (COD)"
            ? _alamatCtrl.text
            : "Ambil di Tempat",
        'tanggal': orderDate,
        'status': statusAwal,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('orders')
          .doc(generatedId)
          .set(orderData);

      for (var doc in _cartItems) {
        var item = doc.data() as Map<String, dynamic>;
        String namaProduk = item['nama'] ?? '';
        int jumlahDibeli = item['jumlah'] ?? 1;

        var cekStok = await FirebaseFirestore.instance
            .collection('stok_atk')
            .where('nama', isEqualTo: namaProduk)
            .limit(1)
            .get();

        if (cekStok.docs.isNotEmpty) {
          String docIdStok = cekStok.docs.first.id;
          await FirebaseFirestore.instance
              .collection('stok_atk')
              .doc(docIdStok)
              .update({'stok': FieldValue.increment(-jumlahDibeli)});
        }
      }

      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var doc in _cartItems) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (mounted) Navigator.pop(context);

      if (mounted) {
        if (_metodeBayar == "QRIS") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => QrisAsliPage(
                orderId: generatedId,
                totalTagihan: hitungTotal(),
                dataPesananLengkap: orderData,
                // --- SEKARANG MENGAMBIL DARI DOTENV ---
                serverKey: dotenv.env['MIDTRANS_SERVER_KEY'] ?? "",
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => NotaSuksesPage(dataNota: orderData),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
}
