import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart'; // Akses isAdminGlobal, stokAtkGlobal
import 'pesanan_page.dart';
import 'admin_page.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  final Color primaryTeal = const Color(0xFF1B4D5C);

  // =========================================================
  // TAMBAHAN: Panggil pembersih otomatis saat halaman dibuka
  // =========================================================
  @override
  void initState() {
    super.initState();
    _bersihkanPesananKadaluarsa();
  }

  // Fungsi pembersih cerdas: menyesuaikan dengan role (Admin / User)
  Future<void> _bersihkanPesananKadaluarsa() async {
    try {
      final waktuBatas = DateTime.now().subtract(const Duration(minutes: 15));

      Query query = FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'Menunggu Pembayaran');

      // Jika bukan admin, pastikan HANYA membersihkan pesanan milik user ini sendiri
      if (!isAdminGlobal) {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          query = query.where('uid', isEqualTo: user.uid);
        } else {
          return; // Jika belum login, batalkan proses
        }
      }

      final snapshot = await query.get();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        if (data['createdAt'] != null) {
          DateTime waktuDibuat = (data['createdAt'] as Timestamp).toDate();

          if (waktuDibuat.isBefore(waktuBatas)) {
            await doc.reference.update({
              'status': 'Dibatalkan',
              'keterangan': 'Kadaluarsa otomatis (lebih dari 15 menit)',
            });
            debugPrint(
              "Pesanan ${doc.id} otomatis dibatalkan via NotifikasiPage.",
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error saat membersihkan data kadaluarsa di notifikasi: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
  // TAMPILAN NOTIFIKASI KHUSUS USER (PELANGGAN) DARI FIREBASE
  // ====================================================================
  Widget _buildUserNotifications(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildEmptyState("Silakan login untuk melihat notifikasi.");
    }

    return StreamBuilder<QuerySnapshot>(
      // Ambil data dari koleksi 'orders' yang uid-nya sama dengan user login
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('uid', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState("Belum ada notifikasi pesanan terbaru.");
        }

        // Urutkan data dari yang terbaru (berdasarkan timestamp)
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
            var pesanan = docs[index].data() as Map<String, dynamic>;
            String status = pesanan['status'] ?? 'Diproses';
            String noPesanan = pesanan['id'] ?? '-';

            // Tentukan Ikon, Warna, dan Pesan Berdasarkan Status
            IconData iconStatus = Icons.sync;
            Color warnaStatus = Colors.blue;
            String pesanNotif = "Pesanan $noPesanan sedang diproses.";

            if (status == 'Menunggu Pembayaran') {
              iconStatus = Icons.account_balance_wallet_outlined;
              warnaStatus = Colors.orange;
              pesanNotif = "Selesaikan pembayaran untuk pesanan $noPesanan.";
            } else if (status == 'Selesai') {
              iconStatus = Icons.check_circle_outline;
              warnaStatus = Colors.green;
              pesanNotif = "Hore! Pesanan $noPesanan kamu sudah selesai.";
            } else if (status == 'Dibatalkan') {
              iconStatus = Icons.cancel_outlined;
              warnaStatus = Colors.red;
              pesanNotif = "Mohon maaf, pesanan $noPesanan dibatalkan.";
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
      },
    );
  }

  // ====================================================================
  // TAMPILAN NOTIFIKASI KHUSUS ADMIN (PENJUAL) DARI FIREBASE
  // ====================================================================
  Widget _buildAdminNotifications(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Ambil SEMUA data pesanan untuk admin
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 1. Kumpulkan Notifikasi Peringatan Stok (Lokal)
        List<Map<String, dynamic>> stokWarnings = [];
        for (var item in stokAtkGlobal) {
          int stok = item['stok'] ?? 0;
          if (stok < 5) {
            stokWarnings.add({
              'type': 'warning_stok',
              'title': "Peringatan! Stok ${item['nama']} sisa $stok.",
              'time': "Sekarang",
              'timestamp_val': Timestamp.now(), // Untuk sorting
            });
          }
        }

        // 2. Kumpulkan Notifikasi Pesanan Baru & Batal dari Firebase
        List<Map<String, dynamic>> pesananBaru = [];
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            var pesanan = doc.data() as Map<String, dynamic>;
            String status = pesanan['status'] ?? '';

            if (status.contains('Diproses')) {
              pesananBaru.add({
                'type': 'pesanan_baru',
                'title': "Pesanan Baru Masuk: ${pesanan['id']}",
                'time': pesanan['tanggal'] ?? '-',
                'timestamp_val': pesanan['timestamp'] ?? Timestamp.now(),
              });
            } else if (status == 'Dibatalkan') {
              pesananBaru.add({
                'type': 'pesanan_batal',
                'title': "Pesanan Dibatalkan/Expired: ${pesanan['id']}",
                'time': pesanan['tanggal'] ?? '-',
                'timestamp_val': pesanan['timestamp'] ?? Timestamp.now(),
              });
            }
          }
        }

        // 3. Gabungkan Semua Notifikasi Admin dan Urutkan
        List<Map<String, dynamic>> allAdminNotifs = [
          ...stokWarnings,
          ...pesananBaru,
        ];

        allAdminNotifs.sort((a, b) {
          Timestamp tA = a['timestamp_val'];
          Timestamp tB = b['timestamp_val'];
          return tB.compareTo(tA); // Descending (terbaru di atas)
        });

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
                destination: const AdminPage(),
              );
            } else if (notif['type'] == 'pesanan_batal') {
              return _buildNotificationCard(
                context: context,
                icon: Icons.cancel_outlined,
                color: Colors.red,
                title: notif['title'],
                time: notif['time'],
                destination: const AdminPage(),
              );
            } else {
              return _buildNotificationCard(
                context: context,
                icon: Icons.storefront_outlined,
                color: const Color(0xFF1B4D5C),
                title: notif['title'],
                time: notif['time'],
                destination: const AdminPage(),
              );
            }
          },
        );
      },
    );
  }

  // ====================================================================
  // WIDGET BANTUAN REUSABLE
  // ====================================================================

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
