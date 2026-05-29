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
      total += (item['harga'] as int? ?? 0);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF1B4D5C);

    // Ambil status dan metode bayar dari data nota (Sinkron dengan Checkout)
    String status = dataNota['status'] ?? 'Diproses';
    Color warnaStatus = dataNota['warnaStatus'] ?? Colors.orange;
    String metodeBayar =
        dataNota['metodeBayar'] ?? 'QRIS'; // Default asumsikan sudah bayar QRIS
    String statusLunas = metodeBayar == 'QRIS' ? '(LUNAS)' : '(BAYAR NANTI)';

    // Amankan data list item agar tidak error jika kosong
    List items = dataNota['items'] as List? ?? [];

    return Scaffold(
      backgroundColor: primaryTeal, // Background Teal penuh agar elegan
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            children: [
              // Ikon Sukses Beranimasi Sederhana
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 80,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Pesanan Berhasil!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Terima kasih telah mempercayakan\nkebutuhan kampusmu pada Campus Flow.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // =========================================================
              // AREA NOTA (Efek Kertas Struk Elegan)
              // =========================================================
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Nota Ala Struk Digital
                    Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.storefront,
                            color: primaryTeal,
                            size: 30,
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "CAMPUS FLOW",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: primaryTeal,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            dataNota['tanggal'] ?? "Baru Saja",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Divider(thickness: 1, color: Colors.black12),
                    ),

                    // Nomor Pesanan & Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "NO. PESANAN",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          dataNota['noPesanan'] ?? dataNota['id'] ?? '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryTeal,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "STATUS PESANAN",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: warnaStatus.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: warnaStatus,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Divider(thickness: 1, color: Colors.black12),
                    ),

                    // Detail Item
                    const Text(
                      "ITEM DIPESAN",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...items
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['nama'] ?? 'Item',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (item['spesifikasi'] != null &&
                                          item['spesifikasi'] != '-')
                                        Text(
                                          item['spesifikasi'],
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
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
                                  formatRupiah(item['harga'] ?? 0),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(), // Jangan lupa .toList()

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(thickness: 1, color: Colors.black12),
                    ),

                    // --- RINCIAN BIAYA & PENGIRIMAN ---
                    const Text(
                      "RINCIAN TRANSAKSI",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _buildSummaryRow(
                      "Subtotal Produk",
                      formatRupiah(dataNota['subtotal'] ?? hitungManual(items)),
                    ),
                    _buildSummaryRow(
                      "Ongkos Kirim",
                      formatRupiah(dataNota['ongkir'] ?? 0),
                    ),

                    // Logika memunculkan baris diskon jika ada
                    if ((dataNota['diskon'] ?? 0) > 0)
                      _buildSummaryRow(
                        "Diskon Promo",
                        "- ${formatRupiah(dataNota['diskon'])}",
                        isDiscount: true,
                      ),

                    const SizedBox(height: 15),
                    _buildNotaRow(
                      "Metode Ambil",
                      dataNota['metodeAmbil'] ?? "-",
                    ),
                    _buildNotaRow("Pembayaran", "$metodeBayar $statusLunas"),
                    _buildNotaRow("Alamat", dataNota['alamat'] ?? "-"),

                    const SizedBox(height: 20),

                    // =========================================================
                    // TOTAL AKHIR (Di-Highlight)
                    // =========================================================
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: primaryTeal.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: primaryTeal.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "TOTAL BAYAR",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: primaryTeal,
                            ),
                          ),
                          Text(
                            formatRupiah(dataNota['total'] ?? 0),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryTeal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Tombol Kembali ke Beranda
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home_rounded),
                label: const Text(
                  "KEMBALI KE BERANDA",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primaryTeal,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
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
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(width: 20),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
              fontSize: 12,
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
