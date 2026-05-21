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
  // BUILD UTAMA
  // =========================================================

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
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Admin Dashboard",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Kelola pesanan, stok, dan jadwal akademik",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatCard(
                Icons.shopping_cart,
                daftarPesananGlobal.length.toString(),
                "Pesanan",
              ),
              _buildStatCard(
                Icons.people,
                dataCustomerGlobal.length.toString(),
                "Customer",
              ),
              _buildStatCard(
                Icons.inventory,
                stokAtkGlobal.length.toString(),
                "Produk",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String title) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // 1. PESANAN TAB (DENGAN FITUR BATAL)
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

        String orderId =
            order['id'] ?? order['idPesanan'] ?? "CAMPUS-000${index + 1}";
        int total = order['total'] ?? 0;
        String status = order['status'] ?? "Diproses";
        Color statusColor = order['warnaStatus'] ?? Colors.orange;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            onTap: () => _showOrderDetail(order, index),
            leading: CircleAvatar(
              backgroundColor: statusColor,
              child: Icon(
                status == "Dibatalkan"
                    ? Icons.cancel_outlined
                    : Icons.receipt_long,
                color: Colors.white,
              ),
            ),
            title: Text(
              orderId,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("$status - Rp $total"),

            // Logika Tombol Trailing (Selesai & Batal)
            trailing: status == "Selesai"
                ? const Icon(Icons.check_circle, color: Colors.green, size: 32)
                : status == "Dibatalkan"
                ? const Icon(Icons.cancel, color: Colors.red, size: 32)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.cancel_outlined,
                          color: Colors.red,
                        ),
                        tooltip: "Batalkan Pesanan",
                        onPressed: () {
                          setState(() {
                            daftarPesananGlobal[index]['status'] = "Dibatalkan";
                            daftarPesananGlobal[index]['warnaStatus'] =
                                Colors.red;
                          });
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            daftarPesananGlobal[index]['status'] = "Selesai";
                            daftarPesananGlobal[index]['warnaStatus'] =
                                Colors.green;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green,
                          elevation: 0,
                          side: const BorderSide(color: Colors.green),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Selesai"),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  // =========================================================
  // LOGIKA DETAIL PESANAN & DOWNLOAD PDF PINTAR
  // =========================================================
  void _showOrderDetail(Map<String, dynamic> order, int index) {
    List items = order['items'] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Detail Riwayat",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // ====================================================
              // PENGURAIAN ITEM LENGKAP (SAMA PERSIS DENGAN USER)
              // ====================================================
              ...items.map((item) {
                String namaItem = item['nama']?.toString().toLowerCase() ?? '';
                bool isPrint =
                    namaItem.contains('print') ||
                    namaItem.contains('dokumen') ||
                    item['file'] != null;

                // 1. Ekstrak Subtitle / Spesifikasi
                String subtitle = "";
                if (item['spesifikasi'] != null) {
                  subtitle = item['spesifikasi'];
                } else if (item['subtitle'] != null) {
                  subtitle = item['subtitle'];
                } else {
                  List<String> subParts = [];
                  if (item['ukuranKertas'] != null)
                    subParts.add(item['ukuranKertas']);
                  if (item['jumlahHalaman'] != null)
                    subParts.add("${item['jumlahHalaman']} Hal");
                  if (item['halaman'] != null && item['jumlahHalaman'] == null)
                    subParts.add("${item['halaman']} Hal");
                  if (item['warna'] != null) subParts.add(item['warna']);
                  if (item['pakaiJilid'] == true ||
                      item['jilid'] == true ||
                      item['jilid'] == 'Ya')
                    subParts.add("Jilid");

                  if (item['pesanan'] != null) subParts.add(item['pesanan']);
                  if (item['menu'] != null) subParts.add(item['menu']);

                  if (namaItem.contains('desain') ||
                      namaItem.contains('design')) {
                    subParts.add("File: ${item['file'] ?? 'Tidak ada'}");
                  }

                  subtitle = subParts.isNotEmpty
                      ? subParts.join(", ")
                      : "${item['jumlah'] ?? 1} pcs";
                }

                // 2. Ekstrak Notes (WA, Detail, Catatan Gabungan)
                String catatanRaw = item['catatan'] ?? item['note'] ?? '';
                String noWa = item['noWa'] ?? item['whatsapp'] ?? '';
                String detail = item['detail'] ?? '';

                List<String> noteParts = [];
                if (noWa.isNotEmpty) noteParts.add("WA: $noWa");
                if (detail.isNotEmpty && !namaItem.contains('titip'))
                  noteParts.add("Detail: $detail");
                if (catatanRaw.isNotEmpty) noteParts.add(catatanRaw);

                String finalNote = noteParts.join(" | ");

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ikon (Persis Tampilan User)
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Icon(
                          isPrint
                              ? Icons.description_outlined
                              : Icons.shopping_bag_outlined,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Informasi Teks Ekstra Lengkap
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['nama'] ?? 'Item',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                            if (finalNote.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                "Note: $finalNote",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Harga & Tombol Download PDF
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Rp ${item['harga'] ?? 0}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (isPrint) ...[
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Mengunduh file PDF ke perangkat...",
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.download_rounded,
                                      color: Colors.green,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "PDF",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),

              const Divider(height: 30),

              // Menampilkan Info Tambahan dengan Key yang Benar (Sama dengan User)
              _buildDetailRow(
                "Metode Ambil",
                order['metodeAmbil'] ?? order['metode'] ?? "-",
              ),
              _buildDetailRow(
                "Pembayaran",
                order['metodePembayaran'] ??
                    order['metodeBayar'] ??
                    order['pembayaran'] ??
                    "-",
              ),
              _buildDetailRow("Alamat", order['alamat'] ?? "-"),

              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Bayar",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "Rp ${order['total'] ?? 0}",
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
        );
      },
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(title, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // 2. STOK TAB
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
  // 3. CUSTOMER TAB
  // =========================================================

  Widget _buildCustomerTab() {
    return ListView.builder(
      itemCount: dataCustomerGlobal.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(dataCustomerGlobal[index]['nama'] ?? ''),
            subtitle: Text(dataCustomerGlobal[index]['nim'] ?? ''),
          ),
        );
      },
    );
  }

  // =========================================================
  // 4. AKADEMIK TAB
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
  // DIALOG EDIT (AKADEMIK)
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
  // DIALOG EDIT (STOK)
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
