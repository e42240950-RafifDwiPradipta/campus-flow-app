import 'package:flutter/material.dart';
import '../main.dart';
import 'package:intl/intl.dart';
import 'nota_sukses_page.dart';

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

  @override
  void initState() {
    super.initState();
    _alamatCtrl.addListener(_hitungOngkir);
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
    if (alamat.contains("kampus") || alamat.contains("polije")) {
      _estimasiJarak = 2.5;
    } else if (alamat.contains("mastrip")) {
      _estimasiJarak = 6.0;
    } else {
      _estimasiJarak = 4.0 + (alamat.length % 5);
    }

    int baseOngkir = 3000;
    if (_estimasiJarak <= 5.0) {
      _biayaOngkir = baseOngkir;
    } else {
      int extraKm = (_estimasiJarak - 5.0).ceil();
      _biayaOngkir = baseOngkir + (extraKm * 1000);
    }

    setState(() {});
  }

  int hitungSubtotal() {
    int subtotal = 0;
    for (var item in keranjangGlobal) {
      subtotal += (item['harga'] as int);
    }
    return subtotal;
  }

  int hitungDiskon() {
    int totalDiskon = 0;
    for (var item in keranjangGlobal) {
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
    return Column(
      children: keranjangGlobal.map((item) {
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
                      item['nama'],
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
                formatRupiah(item['harga']),
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
              hintText: "Contoh: Gedung B, Lantai 2...",
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
        prefixIcon: Icon(Icons.qr_code_scanner, color: primaryTeal),
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
                if (_metodeAmbil == "Diantar (COD)" &&
                    _alamatCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Mohon isi alamat pengantaran!"),
                    ),
                  );
                  return;
                }
                if (_metodeBayar == "QRIS") {
                  _tampilkanDialogQRIS();
                } else {
                  _jalankanLoadingDanSimpan();
                }
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

  void _tampilkanDialogQRIS() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        contentPadding: const EdgeInsets.all(25),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Scan QRIS",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "Campus Flow / PT Mahasiswa Maju",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[300]!, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(Icons.qr_code_2, size: 200, color: primaryTeal),
            ),
            const SizedBox(height: 20),
            const Text(
              "Total Tagihan",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            Text(
              formatRupiah(hitungTotal()),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange[800],
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _jalankanLoadingDanSimpan();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "SAYA SUDAH BAYAR",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Batalkan",
                style: TextStyle(color: Colors.grey),
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

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      _prosesSimpanData();
    });
  }

  void _prosesSimpanData() {
    List<Map<String, dynamic>> itemsFinal = keranjangGlobal.map((item) {
      int qty = 1;
      if (item['jumlah'] != null) {
        qty = item['jumlah'] is int
            ? item['jumlah']
            : int.tryParse(item['jumlah'].toString()) ?? 1;
      } else if (item['detail'] != null &&
          item['detail'].toString().contains('pcs')) {
        final match = RegExp(
          r'\((\d+)\s*pcs\)',
        ).firstMatch(item['detail'].toString());
        if (match != null) {
          qty = int.tryParse(match.group(1) ?? '1') ?? 1;
        }
      }

      return {
        'nama': item['nama'],
        'harga': item['harga'],
        'jumlah': qty,
        'spesifikasi': item['spesifikasi'] ?? item['detail'] ?? '-',
        'catatan': item['catatan'] ?? item['note'] ?? '-',
        'file': item['file'],
        'referensi': item['referensi'] ?? item['foto'],
      };
    }).toList();

    for (var itemFinal in itemsFinal) {
      for (var stokItem in stokAtkGlobal) {
        if (stokItem['nama'] == itemFinal['nama']) {
          int stokAwal = stokItem['stok'] as int;
          int stokDipotong = itemFinal['jumlah'] as int;

          stokItem['stok'] = stokAwal - stokDipotong;
          if ((stokItem['stok'] as int) < 0) stokItem['stok'] = 0;
        }
      }
    }

    String generatedId =
        "CAMPUS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
    String orderDate = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now());

    Map<String, dynamic> notaBaru = {
      'id': generatedId,
      'noPesanan': generatedId,
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
      'status': _metodeBayar == "QRIS"
          ? 'Diproses'
          : 'Diproses (pembayaran tunai)',
      'warnaStatus': _metodeBayar == "QRIS" ? Colors.blue : Colors.orange,
    };

    setState(() {
      // 1. Simpan pesanan ke daftar pesanan global
      daftarPesananGlobal.insert(0, notaBaru);

      // 2. Tambah data ke Notifikasi Global
      notifikasiGlobal.insert(0, {
        'judul': 'Pesanan Baru Masuk: $generatedId',
        'waktu': orderDate,
      });

      // 3. Kosongkan keranjang
      keranjangGlobal.clear();
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => NotaSuksesPage(dataNota: notaBaru),
      ),
    );
  }
}
