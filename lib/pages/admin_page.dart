import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart'; // Akses formatRupiah

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color primaryColor = const Color(0xFF114B5F);

  String _searchPesanan = "";
  String _filterPesanan = "Semua";
  String _searchCustomer = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // PANGGIL SI TUKANG SAPU SETIAP KALI ADMIN MEMBUKA HALAMAN INI
    _bersihkanPesananKadaluarsa();
  }

  // FUNGSI BARU UNTUK AUTO-CANCEL PESANAN EXPIRED (15 MENIT)
  Future<void> _bersihkanPesananKadaluarsa() async {
    try {
      final waktuBatas = DateTime.now().subtract(const Duration(minutes: 15));

      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'Menunggu Pembayaran')
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        if (data['createdAt'] != null) {
          DateTime waktuDibuat = (data['createdAt'] as Timestamp).toDate();

          if (waktuDibuat.isBefore(waktuBatas)) {
            await doc.reference.update({
              'status': 'Dibatalkan',
              'keterangan': 'Kadaluarsa otomatis (lebih dari 15 menit)',
            });
            debugPrint(
              "Pesanan ${doc.id} otomatis dibatalkan karena kadaluarsa.",
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error saat membersihkan data kadaluarsa: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getColorForStatus(String status) {
    if (status.contains('Selesai')) return Colors.green;
    if (status.contains('Dibatalkan')) return Colors.red;
    if (status.contains('Menunggu Pembayaran')) return Colors.orange;
    return primaryColor; // Default untuk "Diproses"
  }

  void _tampilkanKonfirmasi(
    String judul,
    String pesan,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(judul, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(pesan),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Batal",
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text(
              "Ya, Lanjutkan",
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

  void _simulasiDownload(String namaFile) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(child: Text("Mengunduh $namaFile...")),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$namaFile berhasil disimpan di Folder Download!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<QueryDocumentSnapshot> allOrders = snapshot.hasData
              ? snapshot.data!.docs
              : [];

          allOrders.sort((a, b) {
            Timestamp? tA =
                (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
            Timestamp? tB =
                (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
            if (tA == null || tB == null) return 0;
            return tB.compareTo(tA);
          });

          int pesananAktif = 0;
          int totalPendapatan = 0;

          for (var doc in allOrders) {
            var order = doc.data() as Map<String, dynamic>;
            String status = order['status'] ?? '';

            if (status.contains('Diproses') ||
                status == 'Menunggu Pembayaran') {
              pesananAktif++;
            }
            if (status == 'Selesai') {
              totalPendapatan += (order['total'] as int? ?? 0);
            }
          }

          return SafeArea(
            child: Column(
              children: [
                _buildHeader(allOrders.length, totalPendapatan),
                TabBar(
                  controller: _tabController,
                  labelColor: primaryColor,
                  indicatorColor: primaryColor,
                  tabs: [
                    Tab(
                      icon: Badge(
                        isLabelVisible: pesananAktif > 0,
                        label: Text(pesananAktif.toString()),
                        child: const Icon(Icons.receipt_long),
                      ),
                    ),
                    const Tab(icon: Icon(Icons.inventory)),
                    const Tab(icon: Icon(Icons.people)),
                    const Tab(icon: Icon(Icons.calendar_month)),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPesananTab(allOrders),
                      _buildStokTab(),
                      _buildCustomerTab(),
                      _buildAcademicTab(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(int totalPesanan, int totalPendapatan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, const Color(0xFF1A759F)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text(
              "Admin Dashboard",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatCard(Icons.shopping_cart, "$totalPesanan", "Pesanan"),
                _buildStatCard(
                  Icons.monetization_on,
                  formatRupiah(totalPendapatan),
                  "Pendapatan",
                ),
                _buildStatCard(Icons.people, "Live", "Customer"),
                _buildStatCard(Icons.inventory, "Live", "Produk"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String title) {
    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TAB PESANAN (FIREBASE)
  // =========================================================
  Widget _buildPesananTab(List<QueryDocumentSnapshot> allOrders) {
    final List<QueryDocumentSnapshot> filteredOrders = allOrders.where((doc) {
      var order = doc.data() as Map<String, dynamic>;
      String id = (order['id'] ?? "").toString().toLowerCase();
      String status = order['status'] ?? "Diproses";

      bool matchesSearch = id.contains(_searchPesanan.toLowerCase());
      bool matchesFilter =
          _filterPesanan == "Semua" || status == _filterPesanan;
      return matchesSearch && matchesFilter;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
          child: TextField(
            onChanged: (v) => setState(() => _searchPesanan = v),
            decoration: InputDecoration(
              hintText: "Cari nomor pesanan...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children:
                [
                  "Semua",
                  "Diproses",
                  "Diproses (pembayaran tunai)",
                  "Selesai",
                  "Dibatalkan",
                ].map((status) {
                  bool isSelected = _filterPesanan == status;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: isSelected,
                      selectedColor: primaryColor.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? primaryColor : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      onSelected: (v) =>
                          setState(() => _filterPesanan = status),
                    ),
                  );
                }).toList(),
          ),
        ),
        Expanded(
          child: filteredOrders.isEmpty
              ? const Center(
                  child: Text(
                    "Pesanan tidak ditemukan",
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final doc = filteredOrders[index];
                    final order = doc.data() as Map<String, dynamic>;
                    String docId = doc.id;

                    String orderId = (order['id'] ?? "CAMPUS-000").toString();
                    String status = order['status'] ?? "Diproses";
                    Color statusColor = _getColorForStatus(status);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        onTap: () => _showOrderDetail(order, docId),
                        leading: CircleAvatar(
                          backgroundColor: statusColor,
                          child: Icon(
                            status == "Dibatalkan"
                                ? Icons.cancel
                                : Icons.receipt,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          orderId,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "$status - ${formatRupiah(order['total'] ?? 0)}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (status.contains("Diproses") ||
                                status == "Menunggu Pembayaran") ...[
                              IconButton(
                                icon: const Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.red,
                                ),
                                onPressed: () => _tampilkanKonfirmasi(
                                  "Batalkan Pesanan?",
                                  "Yakin ingin membatalkan pesanan $orderId?",
                                  () async => await FirebaseFirestore.instance
                                      .collection('orders')
                                      .doc(docId)
                                      .update({'status': 'Dibatalkan'}),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                ),
                                onPressed: () => _tampilkanKonfirmasi(
                                  "Selesaikan Pesanan?",
                                  "Pastikan barang sudah diterima/dibayar oleh pelanggan.",
                                  () async => await FirebaseFirestore.instance
                                      .collection('orders')
                                      .doc(docId)
                                      .update({'status': 'Selesai'}),
                                ),
                              ),
                            ] else
                              Icon(
                                status == "Selesai"
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: statusColor,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showOrderDetail(Map<String, dynamic> order, String docId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Detail Pesanan",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (order['status'].toString().contains('Diproses') ||
                    order['status'] == 'Menunggu Pembayaran')
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _tampilkanKonfirmasi(
                        "Batalkan Pesanan?",
                        "Membatalkan pesanan dari dalam menu detail.",
                        () async => await FirebaseFirestore.instance
                            .collection('orders')
                            .doc(docId)
                            .update({'status': 'Dibatalkan'}),
                      );
                    },
                    icon: const Icon(Icons.cancel, color: Colors.red, size: 16),
                    label: const Text(
                      "Batalkan",
                      style: TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
              ],
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pemesan:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    order['namaPemesan'] ?? 'Tanpa Nama',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    order['email'] ?? '-',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            ...(order['items'] as List? ?? []).map((item) {
              String namaLowerCase = (item['nama'] ?? '')
                  .toString()
                  .toLowerCase();
              bool isPrint = namaLowerCase.contains('print');
              bool isDesign =
                  namaLowerCase.contains('desain') ||
                  namaLowerCase.contains('design') ||
                  namaLowerCase.contains('foto');
              String namaFile =
                  item['file'] ?? item['referensi'] ?? 'dokumen_terlampir.pdf';

              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  item['nama'] ?? 'Item',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['spesifikasi'] ?? '',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      "Note: ${item['catatan'] ?? item['note'] ?? '-'}",
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatRupiah(item['harga'] ?? 0),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isDesign || isPrint)
                      IconButton(
                        icon: Icon(
                          isPrint ? Icons.picture_as_pdf : Icons.image,
                          color: isPrint ? Colors.red : Colors.blue,
                          size: 20,
                        ),
                        tooltip: "Unduh File",
                        onPressed: () => _simulasiDownload(namaFile),
                      ),
                  ],
                ),
              );
            }).toList(),
            const Divider(),
            _buildDetailRow("Ongkir", formatRupiah(order['ongkir'] ?? 0)),
            _buildDetailRow(
              "Pembayaran",
              "${order['metodeBayar'] ?? '-'} ${order['metodeBayar'] == 'QRIS' ? '(LUNAS)' : ''}",
            ),
            _buildDetailRow("Alamat", order['alamat'] ?? "-"),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Tagihan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  formatRupiah(order['total'] ?? 0),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TAB CUSTOMER (FIREBASE)
  // =========================================================
  Widget _buildCustomerTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            onChanged: (v) => setState(() => _searchCustomer = v),
            decoration: InputDecoration(
              hintText: "Cari nama atau email customer...",
              prefixIcon: const Icon(Icons.person_search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                return const Center(child: Text("Belum ada data customer."));

              var docs = snapshot.data!.docs.where((doc) {
                var data = doc.data() as Map<String, dynamic>;
                String nama = (data['nama'] ?? data['name'] ?? "")
                    .toString()
                    .toLowerCase();
                String email = (data['email'] ?? "").toString().toLowerCase();
                String search = _searchCustomer.toLowerCase();
                return nama.contains(search) || email.contains(search);
              }).toList();

              if (docs.isEmpty)
                return const Center(child: Text("Customer tidak ditemukan."));

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var customer = docs[index].data() as Map<String, dynamic>;
                  String docId = docs[index].id;
                  String nama =
                      customer['nama'] ?? customer['name'] ?? 'Tanpa Nama';
                  String email = customer['email'] ?? 'Tidak ada email';

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => _showCustomerDetailFirebase(customer),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: primaryColor.withOpacity(0.1),
                          child: Icon(Icons.person, color: primaryColor),
                        ),
                        title: Text(
                          nama,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(email),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_sweep,
                            color: Colors.red,
                          ),
                          tooltip: "Hapus Akun User",
                          onPressed: () => _tampilkanKonfirmasi(
                            "Hapus Akun Customer?",
                            "Apakah kamu yakin ingin menghapus permanen akun $nama dari database?",
                            () async {
                              await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(docId)
                                  .delete();
                              if (mounted)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Akun customer berhasil dihapus",
                                    ),
                                  ),
                                );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showCustomerDetailFirebase(Map<String, dynamic> customer) {
    String nama = customer['nama'] ?? customer['name'] ?? 'Tanpa Nama';
    String email = customer['email'] ?? '-';
    String infoTambahan =
        customer['nim'] ?? customer['noWa'] ?? customer['phone'] ?? '-';
    String jurusan = customer['jurusan'] ?? 'Bisnis Digital';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFF1B4D5C),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 15),
              Text(
                nama,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow("Email", email),
              const Divider(),
              _buildDetailRow("NIM / Info", infoTambahan),
              const Divider(),
              _buildDetailRow("Jurusan/Prodi", jurusan),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // TAB STOK ATK (FIREBASE: koleksi 'stok_atk')
  // =========================================================
  Widget _buildStokTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            onPressed: () => _dialogEditStok(null, null),
            icon: const Icon(Icons.add),
            label: const Text("Tambah Produk"),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('stok_atk')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                return const Center(child: Text("Belum ada data stok."));

              var docs = snapshot.data!.docs;

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var item = docs[index].data() as Map<String, dynamic>;
                  String docId = docs[index].id;

                  int stok = item['stok'] ?? 0;
                  bool stokMenipis = stok < 5;
                  String? urlGambar = item['gambar'];
                  String namaBarang = item['nama'] ?? 'Item';

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color: stokMenipis
                            ? Colors.red.shade300
                            : Colors.transparent,
                        width: stokMenipis ? 1.5 : 0,
                      ),
                    ),
                    child: ListTile(
                      leading: urlGambar != null && urlGambar.isNotEmpty
                          ? Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: primaryColor.withOpacity(0.05),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  urlGambar,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.inventory_2,
                                    color: stokMenipis
                                        ? Colors.red
                                        : primaryColor,
                                  ),
                                ),
                              ),
                            )
                          : Icon(
                              Icons.inventory_2,
                              color: stokMenipis ? Colors.red : primaryColor,
                            ),
                      title: Text(
                        namaBarang,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: stokMenipis ? Colors.red : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        "Stok : $stok | ${formatRupiah(item['harga'] ?? 0)}",
                        style: TextStyle(
                          color: stokMenipis
                              ? Colors.red.shade700
                              : Colors.grey[600],
                          fontWeight: stokMenipis
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (stokMenipis)
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red,
                                size: 22,
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _dialogEditStok(docId, item),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _dialogEditStok(String? docId, Map<String, dynamic>? currentData) {
    final isEdit = docId != null;
    final nCtrl = TextEditingController(text: currentData?['nama'] ?? "");
    final sCtrl = TextEditingController(
      text: currentData?['stok']?.toString() ?? "",
    );
    final hCtrl = TextEditingController(
      text: currentData?['harga']?.toString() ?? "",
    );
    final gCtrl = TextEditingController(text: currentData?['gambar'] ?? "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEdit ? "Edit Produk" : "Tambah Produk"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nCtrl,
              decoration: const InputDecoration(labelText: "Nama Produk"),
            ),
            TextField(
              controller: sCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Stok"),
            ),
            TextField(
              controller: hCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Harga (Rp)"),
            ),
            TextField(
              controller: gCtrl,
              decoration: const InputDecoration(
                labelText: "Link Gambar (URL)",
                hintText: "https://example.com/gambar.jpg",
              ),
            ),
          ],
        ),
        actions: [
          if (isEdit)
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('stok_atk')
                    .doc(docId)
                    .delete();
                if (mounted) Navigator.pop(context);
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nCtrl.text.isNotEmpty &&
                  sCtrl.text.isNotEmpty &&
                  hCtrl.text.isNotEmpty) {
                final newData = {
                  "nama": nCtrl.text,
                  "stok": int.tryParse(sCtrl.text) ?? 0,
                  "harga": int.tryParse(hCtrl.text) ?? 0,
                  "gambar": gCtrl.text,
                };

                if (isEdit) {
                  await FirebaseFirestore.instance
                      .collection('stok_atk')
                      .doc(docId)
                      .update(newData);
                } else {
                  await FirebaseFirestore.instance
                      .collection('stok_atk')
                      .add(newData);
                }

                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TAB AKADEMIK (FIREBASE: koleksi 'kalender_akademik')
  // =========================================================
  Widget _buildAcademicTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton.icon(
            onPressed: () => _dialogEditAkademik(null, null),
            icon: const Icon(Icons.calendar_month),
            label: const Text("Tambah Jadwal"),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('kalender_akademik')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                return const Center(child: Text("Belum ada data jadwal."));

              var docs = snapshot.data!.docs;

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  var item = docs[index].data() as Map<String, dynamic>;
                  String docId = docs[index].id;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        item['title'] ?? 'Kegiatan',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(item['date'] ?? '-'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _dialogEditAkademik(docId, item),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _dialogEditAkademik(String? docId, Map<String, dynamic>? currentData) {
    final isEdit = docId != null;
    final tCtrl = TextEditingController(text: currentData?['title'] ?? "");

    // Ambil warna dari integer yang disimpan, atau default orange
    Color selectedColor = currentData != null && currentData['color'] != null
        ? Color(currentData['color'])
        : Colors.orange;

    DateTimeRange? range;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(isEdit ? "Edit Jadwal" : "Tambah Jadwal"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tCtrl,
                decoration: const InputDecoration(labelText: "Nama Kegiatan"),
              ),
              const SizedBox(height: 15),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) setDialog(() => range = picked);
                },
                icon: const Icon(Icons.date_range),
                // PERBAIKAN STRUKTUR IF-ELSE (TERNARY)
                label: Text(
                  range != null
                      ? "${DateFormat('dd MMM').format(range!.start)} - ${DateFormat('dd MMM').format(range!.end)}"
                      : (isEdit
                            ? (currentData?['date']?.toString() ??
                                  "Pilih Rentang")
                            : "Pilih Rentang"),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Colors.orange, Colors.blue, Colors.red, Colors.green]
                    .map((color) {
                      return GestureDetector(
                        onTap: () => setDialog(() => selectedColor = color),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedColor == color
                                  ? Colors.black87
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      );
                    })
                    .toList(),
              ),
            ],
          ),
          actions: [
            if (isEdit)
              TextButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('kalender_akademik')
                      .doc(docId)
                      .delete();
                  if (mounted) Navigator.pop(context);
                },
                child: const Text("Hapus", style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (tCtrl.text.isNotEmpty && (range != null || isEdit)) {
                  final newData = {
                    "title": tCtrl.text,
                    "date": range != null
                        ? "${DateFormat('dd MMM').format(range!.start)} - ${DateFormat('dd MMM yyyy').format(range!.end)}"
                        : currentData?['date'],
                    "color":
                        selectedColor.value, // Simpan warna sebagai Integer
                    "markerStart": range?.start ?? currentData?['markerStart'],
                    "markerEnd": range?.end ?? currentData?['markerEnd'],
                  };

                  if (isEdit) {
                    await FirebaseFirestore.instance
                        .collection('kalender_akademik')
                        .doc(docId)
                        .update(newData);
                  } else {
                    await FirebaseFirestore.instance
                        .collection('kalender_akademik')
                        .add(newData);
                  }

                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }
}
