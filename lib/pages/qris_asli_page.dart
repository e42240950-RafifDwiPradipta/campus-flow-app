import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../main.dart';
import 'nota_sukses_page.dart';
import 'pesanan_page.dart';

class QrisAsliPage extends StatefulWidget {
  final String orderId;
  final int totalTagihan;
  final Map<String, dynamic> dataPesananLengkap;
  final String serverKey;

  const QrisAsliPage({
    super.key,
    required this.orderId,
    required this.totalTagihan,
    required this.dataPesananLengkap,
    required this.serverKey,
  });

  @override
  State<QrisAsliPage> createState() => _QrisAsliPageState();
}

class _QrisAsliPageState extends State<QrisAsliPage> {
  final Color primaryTeal = const Color(0xFF1B4D5C);
  String? qrImageUrl;
  bool isError = false;
  String errorMessage = "";
  Timer? _statusTimer;

  late String _midtransOrderId;
  late DateTime _waktuMulai;

  @override
  void initState() {
    super.initState();
    _midtransOrderId =
        "${widget.orderId}-${DateTime.now().millisecondsSinceEpoch}";
    _generateQrisMidtrans();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  // 1. Fungsi Tembak API Midtrans (YANG SUDAH DIPERBAIKI)
  Future<void> _generateQrisMidtrans() async {
    String authHeader =
        'Basic ${base64Encode(utf8.encode('${widget.serverKey}:'))}';

    try {
      var response = await http.post(
        Uri.parse('https://api.sandbox.midtrans.com/v2/charge'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': authHeader,
        },
        body: jsonEncode({
          "payment_type": "qris", // UBAH KE qris AGAR LEBIH STABIL
          "transaction_details": {
            "order_id": _midtransOrderId,
            "gross_amount": widget.totalTagihan,
          },
        }),
      );

      // Print hasil mentah dari Midtrans biar kelihatan di Debug Console
      print("==== RESPONSE MIDTRANS ====");
      print(response.statusCode);
      print(response.body);

      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Pengecekan aman (safe check) agar aplikasi tidak crash kalau actions null
        if (jsonResponse['actions'] != null) {
          var actions = jsonResponse['actions'] as List;

          // Cari URL QR Code secara aman
          var qrAction = actions.firstWhere(
            (action) => action['name'] == 'generate-qr-code',
            orElse: () => null,
          );

          if (qrAction != null && qrAction['url'] != null) {
            String urlQris = qrAction['url'];

            print("==== URL QRIS BERHASIL DIDAPATKAN ====");
            print(urlQris);

            setState(() {
              qrImageUrl = urlQris;
              _waktuMulai = DateTime.now(); // Catat waktu mulai
            });

            _mulaiCekStatusOtomatis();
          } else {
            setState(() {
              isError = true;
              errorMessage = "URL QRIS tidak ditemukan di dalam data Midtrans.";
            });
          }
        } else {
          setState(() {
            isError = true;
            errorMessage = "Midtrans tidak mengirimkan gambar QRIS.";
          });
        }
      } else {
        setState(() {
          isError = true;
          errorMessage =
              jsonResponse['status_message'] ?? "Gagal mendapatkan QRIS";
        });
      }
    } catch (e) {
      // Tampilkan error di console jika gagal parsing
      print("==== ERROR KONEKSI / PARSING ====");
      print(e.toString());

      setState(() {
        isError = true;
        errorMessage = "Koneksi terputus: $e";
      });
    }
  }

  // 2. Fungsi Pengecekan Otomatis (Polling) tiap 3 Detik + Cek Expired
  void _mulaiCekStatusOtomatis() {
    String authHeader =
        'Basic ${base64Encode(utf8.encode('${widget.serverKey}:'))}';

    _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final waktuSekarang = DateTime.now();
        final selisihWaktu = waktuSekarang.difference(_waktuMulai).inMinutes;

        // Jika sudah lebih dari 15 menit tampil di layar...
        if (selisihWaktu >= 15) {
          timer.cancel(); // Hentikan timer
          _prosesKadaluarsaOtomatis(); // Panggil fungsi batal paksa
          return; // Stop eksekusi kode di bawahnya
        }

        // Jika belum 15 menit, lanjut cek status ke Midtrans
        var response = await http.get(
          Uri.parse(
            'https://api.sandbox.midtrans.com/v2/$_midtransOrderId/status',
          ),
          headers: {'Accept': 'application/json', 'Authorization': authHeader},
        );

        var jsonResponse = jsonDecode(response.body);
        String status = jsonResponse['transaction_status'] ?? "";

        if (status == 'settlement' || status == 'capture') {
          timer.cancel();
          _prosesKeNotaSukses();
        }
        // Jika Midtrans duluan yang bilang expired/cancel
        else if (status == 'expire' || status == 'cancel') {
          timer.cancel();
          _prosesKadaluarsaOtomatis();
        }
      } catch (e) {
        // Biarkan saja berputar kalau ada delay koneksi
      }
    });
  }

  // Tutup paksa jika sudah 15 menit
  Future<void> _prosesKadaluarsaOtomatis() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Update status di Firebase jadi Dibatalkan
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .update({
          'status': 'Dibatalkan',
          'keterangan': 'Waktu pembayaran QRIS habis (15 Menit)',
        });

    if (mounted) {
      Navigator.pop(context); // Tutup loading

      // Tampilkan pesan error singkat
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Waktu pembayaran habis. Pesanan dibatalkan."),
          backgroundColor: Colors.red,
        ),
      );

      // Lempar user kembali ke halaman beranda atau riwayat pesanan
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const PesananPage()),
        (route) => route.isFirst,
      );
    }
  }

  // 3. Otomatis Lanjut ke Nota Sukses
  Future<void> _prosesKeNotaSukses() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.orderId)
        .update({'status': 'Diproses', 'metodeBayar': 'QRIS'});

    if (mounted) {
      Navigator.pop(context);

      Map<String, dynamic> dataUntukNota = Map.from(widget.dataPesananLengkap);
      dataUntukNota['status'] = 'Diproses';
      dataUntukNota['metodeBayar'] = 'QRIS';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NotaSuksesPage(dataNota: dataUntukNota),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Pembayaran QRIS",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Total Tagihan",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 5),
              Text(
                "Rp ${widget.totalTagihan}", // Pastikan kamu membuat format rupiahnnya dengan benar ya!
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: primaryTeal,
                ),
              ),
              const SizedBox(height: 30),

              if (isError)
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                )
              else if (qrImageUrl == null)
                Column(
                  children: [
                    CircularProgressIndicator(color: primaryTeal),
                    const SizedBox(height: 15),
                    const Text(
                      "Membuat QRIS...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Image.network(
                            qrImageUrl!,
                            height: 250,
                            width: 250,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "SCAN UNTUK MEMBAYAR",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Text(
                            "Bisa di-screenshot untuk disimpan",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Text(
                          "Menunggu pembayaran masuk...",
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
