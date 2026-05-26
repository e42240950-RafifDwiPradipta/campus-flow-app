import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart'; // Akses formatRupiah

class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  final Color primaryTeal = const Color(0xFF1B4D5C);

  // Fungsi untuk menentukan warna badge berdasarkan teks status
  Color _getColorForStatus(String status) {
    if (status.contains('Selesai')) return Colors.green;
    if (status.contains('Dibatalkan')) return Colors.red;
    if (status.contains('Menunggu Pembayaran')) return Colors.orange;
    return primaryTeal; // Default untuk "Diproses"
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

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
      // =========================================================
      // FIREBASE: MENGAMBIL DATA ORDER MILIK USER
      // =========================================================
      body: user == null
          ? _buildEmptyState("Silakan login terlebih dahulu.")
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('uid', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Terjadi kesalahan: ${snapshot.error}"),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState("Belum ada pesanan nih.");
                }

                // Urutkan dari yang terbaru (Lokal Sort agar tidak kena error Index Firestore)
                var docs = snapshot.data!.docs;
                docs.sort((a, b) {
                  var dataA = a.data() as Map<String, dynamic>;
                  var dataB = b.data() as Map<String, dynamic>;
                  Timestamp? tA = dataA['timestamp'] as Timestamp?;
                  Timestamp? tB = dataB['timestamp'] as Timestamp?;
                  if (tA == null || tB == null) return 0;
                  return tB.compareTo(tA);
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var order = docs[index].data() as Map<String, dynamic>;
                    return _buildOrderCard(context, order, primaryTeal);
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(String pesan) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 15),
          Text(
            pesan,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
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
    String orderId = (order['id'] ?? "CAMPUS-000").toString();
    String status = order['status'] ?? 'Diproses';

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
                  _buildStatusBadge(status, _getColorForStatus(status)),
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
                    "${(order['items'] as List?)?.length ?? 0} Produk",
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  Text(
                    formatRupiah(order['total'] ?? 0),
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

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, Map<String, dynamic> order) {
    List items = order['items'] ?? [];
    String metodeBayar = order['metodeBayar'] ?? '-';
    String statusLunas = metodeBayar == 'QRIS' ? '(LUNAS)' : '(BAYAR NANTI)';
    String currentStatus = order['status'] ?? '';
    String orderId = order['id'];

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
                _buildStatusBadge(
                  currentStatus,
                  _getColorForStatus(currentStatus),
                ),
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
                      child: Icon(
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
                      formatRupiah(item['harga'] ?? 0),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),

            const Divider(height: 30, thickness: 1, color: Colors.black12),

            _buildDetailRow(
              "Subtotal Produk",
              formatRupiah(order['subtotal'] ?? 0),
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
                  formatRupiah(order['total'] ?? 0),
                  style: TextStyle(
                    // <--- Hapus kata 'const' di sini
                    color: primaryTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ====================================================
            // TOMBOL BATAL (UPDATE FIREBASE)
            // ====================================================
            if (currentStatus.contains('Diproses'))
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup bottom sheet
                    _konfirmasiBatalUser(
                      orderId,
                    ); // Panggil fungsi batal firebase
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

  // =========================================================
  // FIREBASE: FUNGSI BATALKAN PESANAN
  // =========================================================
  void _konfirmasiBatalUser(String orderId) {
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
            onPressed: () async {
              Navigator.pop(ctx); // Tutup dialog konfirmasi

              try {
                // Update status di Firestore menjadi Dibatalkan
                await FirebaseFirestore.instance
                    .collection('orders')
                    .doc(orderId)
                    .update({'status': 'Dibatalkan'});

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Pesanan berhasil dibatalkan.",
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Gagal membatalkan: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
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
