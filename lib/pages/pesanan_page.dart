import 'package:flutter/material.dart';
import '../main.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  @override
  Widget build(BuildContext context) {
    const Color primaryTeal = Color(0xFF1B4D5C);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text(
          "Riwayat Pesanan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: daftarPesananGlobal.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: daftarPesananGlobal.length,
              itemBuilder: (context, index) {
                final order = daftarPesananGlobal.reversed.toList()[index];
                return _buildOrderCard(context, order, primaryTeal);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 15),
          const Text(
            "Belum ada pesanan nih",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    Map<String, dynamic> order,
    Color themeColor,
  ) {
    String orderId = (order['noPesanan'] ?? order['id'] ?? "CAMPUS-000")
        .toString();

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
      child: InkWell(
        onTap: () => _showDetail(context, order),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderId,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order['tanggal'] ?? "Baru saja",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  _buildStatusBadge(
                    order['status'] ?? 'Diproses',
                    order['warnaStatus'],
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, thickness: 1, color: Colors.black12),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${(order['items'] as List).length} Produk",
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  Text(
                    formatRupiah(order['total']),
                    style: TextStyle(
                      color: themeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color? color) {
    Color badgeColor = color ?? const Color(0xFF2D7D8E);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: badgeColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  int _hitungSubtotalManual(List items) {
    int total = 0;
    for (var item in items) {
      total += (item['harga'] as int? ?? 0);
    }
    return total;
  }

  void _showDetail(BuildContext context, Map<String, dynamic> order) {
    List items = order['items'] ?? [];
    const Color primaryTeal = Color(0xFF1B4D5C);

    String metodeBayar = order['metodeBayar'] ?? '-';
    String statusLunas = metodeBayar == 'QRIS' ? '(LUNAS)' : '(BAYAR NANTI)';
    String currentStatus = order['status'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Detail Riwayat",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildStatusBadge(order['status'], order['warnaStatus']),
              ],
            ),
            const SizedBox(height: 15),

            ...items.map((item) {
              String specs = item['spesifikasi'] ?? item['detail'] ?? '';
              String note = item['catatan'] ?? item['note'] ?? '-';

              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryTeal.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: primaryTeal,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['nama'] ?? 'Item',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (specs.isNotEmpty && specs != '-')
                            Text(
                              specs,
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 12,
                              ),
                            ),
                          if (note.isNotEmpty && note != '-')
                            Text(
                              "Note: $note",
                              style: const TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: Colors.orange,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      formatRupiah(item['harga']),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),

            const Divider(height: 30, thickness: 1, color: Colors.black12),

            _buildDetailRow(
              "Subtotal Produk",
              formatRupiah(order['subtotal'] ?? _hitungSubtotalManual(items)),
            ),
            _buildDetailRow("Ongkos Kirim", formatRupiah(order['ongkir'] ?? 0)),

            if ((order['diskon'] ?? 0) > 0)
              _buildDetailRow(
                "Diskon Promo",
                "- ${formatRupiah(order['diskon'])}",
                isGreen: true,
              ),

            const SizedBox(height: 10),
            _buildDetailRow("Metode Ambil", order['metodeAmbil'] ?? "-"),
            _buildDetailRow("Pembayaran", "$metodeBayar $statusLunas"),
            if (order['alamat'] != null &&
                order['alamat'] != "-" &&
                order['metodeAmbil'] == "Diantar (COD)")
              _buildDetailRow("Alamat", order['alamat']),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Bayar",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  formatRupiah(order['total']),
                  style: const TextStyle(
                    color: primaryTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ====================================================
            // TOMBOL BATAL OLEH USER
            // ====================================================
            if (currentStatus == 'Diproses' ||
                currentStatus == 'Diproses (pembayaran tunai)')
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup bottom sheet
                    _konfirmasiBatalUser(order); // Tampilkan pop up yakin/tidak
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Batalkan Pesanan",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isGreen ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
                color: isGreen ? Colors.green : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- FUNGSI POP UP KONFIRMASI BATAL ---
  void _konfirmasiBatalUser(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Batalkan Pesanan?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Apakah kamu yakin ingin membatalkan pesanan ini? Aksi ini tidak dapat dikembalikan.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Tidak", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                order['status'] = "Dibatalkan";
                order['warnaStatus'] = Colors.red;
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Pesanan berhasil dibatalkan.",
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              "Ya, Batalkan",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
