import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color primaryColor = const Color(0xFF114B5F);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // =========================================================
  // LOGIKA HITUNG PENDAPATAN (Hanya yang Selesai)
  // =========================================================
  int _hitungTotalPendapatan() {
    return daftarPesananGlobal
        .where((order) => order['status'] == 'Selesai')
        .fold(0, (sum, item) => sum + (item['total'] as int? ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            TabBar(
              controller: _tabController,
              labelColor: primaryColor,
              indicatorColor: primaryColor,
              tabs: const [
                Tab(icon: Icon(Icons.receipt_long)),
                Tab(icon: Icon(Icons.inventory)),
                Tab(icon: Icon(Icons.people)),
                Tab(icon: Icon(Icons.calendar_month)),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPesananTab(),
                  _buildStokTab(),
                  _buildCustomerTab(),
                  _buildAcademicTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // HEADER & STAT CARD
  // =========================================================
  Widget _buildHeader() {
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
                _buildStatCard(
                  Icons.shopping_cart,
                  "${daftarPesananGlobal.length}",
                  "Pesanan",
                ),
                _buildStatCard(
                  Icons.monetization_on,
                  "Rp ${_hitungTotalPendapatan()}",
                  "Pendapatan",
                ),
                _buildStatCard(
                  Icons.people,
                  "${dataCustomerGlobal.length}",
                  "Customer",
                ),
                _buildStatCard(
                  Icons.inventory,
                  "${stokAtkGlobal.length}",
                  "Produk",
                ),
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
  // 1. TAB PESANAN
  // =========================================================
  Widget _buildPesananTab() {
    if (daftarPesananGlobal.isEmpty) {
      return const Center(
        child: Text(
          "Belum ada pesanan masuk",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: daftarPesananGlobal.length,
      itemBuilder: (context, index) {
        final order = daftarPesananGlobal[index];
        String orderId = (order['id'] ?? order['noPesanan'] ?? "CAMPUS-000")
            .toString();
        String status = order['status'] ?? "Diproses";
        Color statusColor = order['warnaStatus'] ?? Colors.orange;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            onTap: () => _showOrderDetail(order, index),
            leading: CircleAvatar(
              backgroundColor: statusColor,
              child: Icon(
                status == "Dibatalkan" ? Icons.cancel : Icons.receipt,
                color: Colors.white,
              ),
            ),
            title: Text(
              orderId,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("$status - Rp ${order['total']}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (status == "Diproses") ...[
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                    onPressed: () => setState(() {
                      order['status'] = "Dibatalkan";
                      order['warnaStatus'] = Colors.red;
                    }),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                    onPressed: () => setState(() {
                      order['status'] = "Selesai";
                      order['warnaStatus'] = Colors.green;
                    }),
                  ),
                ] else
                  Icon(
                    status == "Selesai" ? Icons.check_circle : Icons.cancel,
                    color: statusColor,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // DETAIL PESANAN & TOMBOL DOWNLOAD FILE PASTI MUNCUL
  // =========================================================
  void _showOrderDetail(Map<String, dynamic> order, int index) {
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
                if (order['status'] != 'Selesai' &&
                    order['status'] != 'Dibatalkan')
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        order['status'] = "Dibatalkan";
                        order['warnaStatus'] = Colors.red;
                      });
                      Navigator.pop(context);
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
            ...(order['items'] as List).map((item) {
              // DETEKSI LAYANAN UNTUK MEMUNCULKAN TOMBOL DOWNLOAD
              String namaLowerCase = (item['nama'] ?? '')
                  .toString()
                  .toLowerCase();
              bool isPrint = namaLowerCase.contains('print');
              bool isDesign =
                  namaLowerCase.contains('desain') ||
                  namaLowerCase.contains('design') ||
                  namaLowerCase.contains('foto');

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
                      "Rp ${item['harga'] ?? 0}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // TOMBOL DOWNLOAD FOTO/GAMBAR
                    if (isDesign)
                      IconButton(
                        icon: const Icon(
                          Icons.image,
                          color: Colors.blue,
                          size: 20,
                        ),
                        tooltip: "Unduh Foto/Referensi",
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Mengunduh Foto/Referensi..."),
                            ),
                          );
                        },
                      ),
                    // TOMBOL DOWNLOAD PDF
                    if (isPrint)
                      IconButton(
                        icon: const Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                          size: 20,
                        ),
                        tooltip: "Unduh Dokumen PDF",
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Mengunduh Dokumen PDF..."),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              );
            }).toList(),
            const Divider(),
            _buildDetailRow("Ongkir", "Rp ${order['ongkir'] ?? 0}"),
            _buildDetailRow(
              "Pembayaran",
              "${order['metodeBayar'] ?? order['metodeBayar'] ?? order['pembayaran'] ?? '-'} (LUNAS)",
            ),
            _buildDetailRow("Alamat", order['alamat'] ?? "-"),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Bayar",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "Rp ${order['total']}",
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
  // 2. STOK TAB (DIKEMBALIKAN UTUH)
  // =========================================================
  Widget _buildStokTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            onPressed: () => _dialogEditStok(-1),
            icon: const Icon(Icons.add),
            label: const Text("Tambah Produk"),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: stokAtkGlobal.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: Text(stokAtkGlobal[index]['nama']),
                  subtitle: Text(
                    "Stok : ${stokAtkGlobal[index]['stok']} | Rp ${stokAtkGlobal[index]['harga']}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _dialogEditStok(index),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // =========================================================
  // 3. TAB CUSTOMER (FITUR HAPUS AKUN)
  // =========================================================
  Widget _buildCustomerTab() {
    if (dataCustomerGlobal.isEmpty) {
      return const Center(child: Text("Belum ada data customer"));
    }
    return ListView.builder(
      itemCount: dataCustomerGlobal.length,
      itemBuilder: (context, index) {
        final customer = dataCustomerGlobal[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(
              customer['nama'] ?? 'User',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              customer['nim'] ?? customer['noWa'] ?? 'Data tidak lengkap',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.red),
              tooltip: "Nonaktifkan/Hapus Akun",
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Hapus Akun?"),
                    content: const Text(
                      "User ini akan dihapus permanen dan dinonaktifkan.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Batal"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            dataCustomerGlobal.removeAt(index);
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Akun customer berhasil dihapus"),
                            ),
                          );
                        },
                        child: const Text(
                          "Hapus",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // =========================================================
  // 4. AKADEMIK TAB (DIKEMBALIKAN UTUH)
  // =========================================================
  Widget _buildAcademicTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton.icon(
            onPressed: () => _dialogEditAkademik(-1),
            icon: const Icon(Icons.calendar_month),
            label: const Text("Tambah Jadwal"),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: dataKalenderGlobal.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: ListTile(
                  title: Text(
                    dataKalenderGlobal[index]['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(dataKalenderGlobal[index]['date']),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _dialogEditAkademik(index),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // =========================================================
  // DIALOG EDIT AKADEMIK (DIKEMBALIKAN UTUH)
  // =========================================================
  void _dialogEditAkademik(int index) {
    final isEdit = index != -1;
    final tCtrl = TextEditingController(
      text: isEdit ? dataKalenderGlobal[index]['title'] : "",
    );
    Color selectedColor = isEdit
        ? dataKalenderGlobal[index]['color']
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
                label: Text(
                  range != null
                      ? "${DateFormat('dd MMM').format(range!.start)} - ${DateFormat('dd MMM').format(range!.end)}"
                      : (isEdit
                            ? dataKalenderGlobal[index]['date']
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
                onPressed: () {
                  setState(() => dataKalenderGlobal.removeAt(index));
                  Navigator.pop(context);
                },
                child: const Text("Hapus", style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                if (tCtrl.text.isNotEmpty && (range != null || isEdit)) {
                  setState(() {
                    final newData = {
                      "title": tCtrl.text,
                      "date": range != null
                          ? "${DateFormat('dd MMM').format(range!.start)} - ${DateFormat('dd MMM yyyy').format(range!.end)}"
                          : dataKalenderGlobal[index]['date'],
                      "color": selectedColor,
                      "markerStart":
                          range?.start ??
                          dataKalenderGlobal[index]['markerStart'],
                      "markerEnd":
                          range?.end ?? dataKalenderGlobal[index]['markerEnd'],
                    };
                    if (isEdit)
                      dataKalenderGlobal[index] = newData;
                    else
                      dataKalenderGlobal.add(newData);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // DIALOG EDIT STOK (DIKEMBALIKAN UTUH)
  // =========================================================
  void _dialogEditStok(int index) {
    final isEdit = index != -1;
    final nCtrl = TextEditingController(
      text: isEdit ? stokAtkGlobal[index]['nama'] : "",
    );
    final sCtrl = TextEditingController(
      text: isEdit ? stokAtkGlobal[index]['stok'].toString() : "",
    );
    final hCtrl = TextEditingController(
      text: isEdit ? stokAtkGlobal[index]['harga'].toString() : "",
    );

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
          ],
        ),
        actions: [
          if (isEdit)
            TextButton(
              onPressed: () {
                setState(() => stokAtkGlobal.removeAt(index));
                Navigator.pop(context);
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nCtrl.text.isNotEmpty &&
                  sCtrl.text.isNotEmpty &&
                  hCtrl.text.isNotEmpty) {
                setState(() {
                  final newData = {
                    "nama": nCtrl.text,
                    "stok": int.tryParse(sCtrl.text) ?? 0,
                    "harga": int.tryParse(hCtrl.text) ?? 0,
                    "ikon": isEdit
                        ? stokAtkGlobal[index]['ikon']
                        : Icons.inventory_2,
                  };
                  if (isEdit)
                    stokAtkGlobal[index] = newData;
                  else
                    stokAtkGlobal.add(newData);
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}
