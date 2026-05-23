import 'package:flutter/material.dart';
import '../main.dart';
import 'home_page.dart';

class NotaSuksesPage extends StatelessWidget {
  final Map<String, dynamic> dataNota;

  const NotaSuksesPage({super.key, required this.dataNota});

  // Fungsi jaga-jaga kalau data subtotal tidak terbawa
  int hitungManual(List items) {
    int total = 0;
    for (var item in items) {
      total += (item['harga'] as int);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF1B4D5C);

    return Scaffold(
      backgroundColor: primaryTeal, // Background Teal penuh agar elegan
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            children: [
              // Ikon Sukses Beranimasi Sederhana
              const Icon(Icons.check_circle, color: Colors.white, size: 80),
              const SizedBox(height: 15),
              const Text(
                "Pesanan Berhasil!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Terima kasih telah menggunakan Campus Flow",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 40),

              // AREA NOTA (Efek Kertas Putih)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Nota
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "NO. PESANAN",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          dataNota['noPesanan'] ?? dataNota['id'] ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryTeal,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),

                    // Detail Item (DIREVISI AGAR LENGKAP)
                    const Text(
                      "ITEM DIPESAN",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...(dataNota['items'] as List).map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['nama'],
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // Munculkan spesifikasi (A4, Jilid, dll)
                                  if (item['spesifikasi'] != null &&
                                      item['spesifikasi'] != '-')
                                    Text(
                                      item['spesifikasi'],
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  // Munculkan catatan (Nasi Pecel, No WA, dll)
                                  if (item['catatan'] != null &&
                                      item['catatan'] != '-')
                                    Text(
                                      "Note: ${item['catatan']}",
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.orange,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              "Rp ${item['harga']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Divider(height: 30),

                    // --- RINCIAN BIAYA & DISKON ---
                    const Text(
                      "RINCIAN BIAYA",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildSummaryRow(
                      "Subtotal Produk",
                      "Rp ${dataNota['subtotal'] ?? hitungManual(dataNota['items'])}",
                    ),
                    _buildSummaryRow(
                      "Ongkos Kirim",
                      "Rp ${dataNota['ongkir'] ?? 0}",
                    ),

                    // Logika memunculkan baris diskon jika ada
                    if ((dataNota['diskon'] ?? 0) > 0)
                      _buildSummaryRow(
                        "Diskon Promo Print",
                        "- Rp ${dataNota['diskon']}",
                        isDiscount: true,
                      ),

                    const Divider(height: 30),

                    // Info Pengiriman & Bayar
                    _buildNotaRow("Tanggal", dataNota['tanggal'] ?? "-"),
                    _buildNotaRow(
                      "Metode Ambil",
                      dataNota['metodeAmbil'] ?? "-",
                    ),
                    _buildNotaRow("Pembayaran", dataNota['metodeBayar'] ?? "-"),
                    _buildNotaRow("Alamat", dataNota['alamat'] ?? "-"),

                    const Divider(height: 30),

                    // TOTAL AKHIR
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "TOTAL BAYAR",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Rp ${dataNota['total']}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Tombol Kembali ke Beranda
              ElevatedButton(
                onPressed: () {
                  // Keranjang sudah dikosongkan di CheckoutPage,
                  // di sini kita hanya navigasi balik.
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primaryTeal,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "KEMBALI KE BERANDA",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET PENDUKUNG ---
  Widget _buildNotaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(width: 20),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // Widget khusus untuk rincian biaya (ongkir & diskon)
  Widget _buildSummaryRow(
    String title,
    String value, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDiscount ? Colors.green : Colors.grey,
              fontSize: 13,
              fontWeight: isDiscount ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDiscount ? Colors.green : Colors.black87,
              fontSize: 13,
              fontWeight: isDiscount ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
