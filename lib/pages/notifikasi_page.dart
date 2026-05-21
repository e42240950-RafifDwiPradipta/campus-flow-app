import 'package:flutter/material.dart';
import '../main.dart';
import 'pesanan_page.dart';

class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryTeal = const Color(0xFF1B4D5C);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text(
          "Notifikasi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: daftarPesananGlobal.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Belum ada notifikasi pesanan terbaru.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: daftarPesananGlobal.length,
              itemBuilder: (context, index) {
                // Supaya notifikasi terbaru muncul paling atas (di-reverse)
                final pesanan =
                    daftarPesananGlobal[daftarPesananGlobal.length - 1 - index];

                // Logika Status
                IconData iconStatus = Icons.sync;
                Color warnaStatus = Colors.blue;
                String pesanNotif =
                    "Pesanan ${pesanan['noPesanan']} sedang diproses.";

                if (pesanan['status'] == 'Menunggu Pembayaran') {
                  iconStatus = Icons.account_balance_wallet_outlined;
                  warnaStatus = Colors.orange;
                  pesanNotif =
                      "Selesaikan pembayaran untuk pesanan ${pesanan['noPesanan']}.";
                } else if (pesanan['status'] == 'Selesai') {
                  iconStatus = Icons.check_circle_outline;
                  warnaStatus = Colors.green;
                  pesanNotif =
                      "Hore! Pesanan ${pesanan['noPesanan']} kamu sudah selesai.";
                }

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.black.withOpacity(0.05)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: warnaStatus.withOpacity(0.1),
                      child: Icon(iconStatus, color: warnaStatus, size: 24),
                    ),
                    title: Text(
                      pesanNotif,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        pesanan['tanggal'] ?? '-',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PesananPage(),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
