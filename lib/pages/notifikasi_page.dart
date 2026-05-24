import 'package:flutter/material.dart';
import '../main.dart';
import 'pesanan_page.dart';
import 'admin_page.dart';

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
      body: isAdminGlobal
          ? _buildAdminNotifications(context) // Jika Admin
          : _buildUserNotifications(context), // Jika User Biasa
    );
  }

  // ====================================================================
  // TAMPILAN NOTIFIKASI KHUSUS USER (PELANGGAN)
  // ====================================================================
  Widget _buildUserNotifications(BuildContext context) {
    if (daftarPesananGlobal.isEmpty) {
      return _buildEmptyState("Belum ada notifikasi pesanan terbaru.");
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: daftarPesananGlobal.length,
      itemBuilder: (context, index) {
        // Supaya notifikasi terbaru muncul paling atas (di-reverse)
        final pesanan =
            daftarPesananGlobal[daftarPesananGlobal.length - 1 - index];
        String status = pesanan['status'] ?? 'Diproses';

        // Tentukan Ikon, Warna, dan Pesan Berdasarkan Status
        IconData iconStatus = Icons.sync;
        Color warnaStatus = Colors.blue;
        String pesanNotif = "Pesanan ${pesanan['noPesanan']} sedang diproses.";

        if (status == 'Menunggu Pembayaran') {
          iconStatus = Icons.account_balance_wallet_outlined;
          warnaStatus = Colors.orange;
          pesanNotif =
              "Selesaikan pembayaran untuk pesanan ${pesanan['noPesanan']}.";
        } else if (status == 'Selesai') {
          iconStatus = Icons.check_circle_outline;
          warnaStatus = Colors.green;
          pesanNotif =
              "Hore! Pesanan ${pesanan['noPesanan']} kamu sudah selesai.";
        } else if (status == 'Dibatalkan') {
          iconStatus = Icons.cancel_outlined;
          warnaStatus = Colors.red;
          pesanNotif =
              "Mohon maaf, pesanan ${pesanan['noPesanan']} dibatalkan.";
        }

        return _buildNotificationCard(
          context: context,
          icon: iconStatus,
          color: warnaStatus,
          title: pesanNotif,
          time: pesanan['tanggal'] ?? '-',
          destination: const PesananPage(),
        );
      },
    );
  }

  // ====================================================================
  // TAMPILAN NOTIFIKASI KHUSUS ADMIN (PENJUAL)
  // ====================================================================
  Widget _buildAdminNotifications(BuildContext context) {
    // 1. Kumpulkan Notifikasi Peringatan Stok (Stok < 5)
    List<Map<String, dynamic>> stokWarnings = [];
    for (var item in stokAtkGlobal) {
      int stok = item['stok'] ?? 0;
      if (stok < 5) {
        stokWarnings.add({
          'type': 'warning_stok',
          'title': "Peringatan! Stok ${item['nama']} sisa $stok.",
          'time': "Sekarang", // Stok dicek realtime
        });
      }
    }

    // 2. Kumpulkan Notifikasi Pesanan Baru (Hanya yang status Diproses)
    List<Map<String, dynamic>> pesananBaru = [];
    for (var pesanan in daftarPesananGlobal) {
      if (pesanan['status'] == 'Diproses') {
        pesananBaru.add({
          'type': 'pesanan_baru',
          'title': "Pesanan Baru Masuk: ${pesanan['noPesanan']}",
          'time': pesanan['tanggal'] ?? '-',
        });
      }
    }

    // 3. Gabungkan Semua Notifikasi Admin
    List<Map<String, dynamic>> allAdminNotifs = [
      ...stokWarnings,
      ...pesananBaru,
    ];

    if (allAdminNotifs.isEmpty) {
      return _buildEmptyState("Belum ada aktivitas admin terbaru.");
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: allAdminNotifs.length,
      itemBuilder: (context, index) {
        final notif = allAdminNotifs[index];

        if (notif['type'] == 'warning_stok') {
          return _buildNotificationCard(
            context: context,
            icon: Icons.warning_amber_rounded,
            color: Colors.red,
            title: notif['title'],
            time: notif['time'],
            destination:
                const AdminPage(), // Diarahkan ke Admin Panel (Tab Stok)
          );
        } else {
          return _buildNotificationCard(
            context: context,
            icon: Icons.storefront_outlined,
            color: const Color(0xFF1B4D5C), // primaryTeal
            title: notif['title'],
            time: notif['time'],
            destination:
                const AdminPage(), // Diarahkan ke Admin Panel (Tab Pesanan)
          );
        }
      },
    );
  }

  // ====================================================================
  // WIDGET BANTUAN REUSABLE
  // ====================================================================

  // Widget jika layar kosong
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 15),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // Desain Kartu Notifikasi Universal
  Widget _buildNotificationCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String time,
    required Widget destination,
  }) {
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
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            time,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
      ),
    );
  }
}
