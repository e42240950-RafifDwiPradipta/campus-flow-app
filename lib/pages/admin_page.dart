import 'dart:io';
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

  String _searchPesanan = "";
  String _filterPesanan = "Semua";
  String _searchCustomer = "";

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

  int _hitungTotalPendapatan() {
    return daftarPesananGlobal
        .where((order) => order['status'] == 'Selesai')
        .fold(0, (sum, item) => sum + (item['total'] as int? ?? 0));
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

  @override
  Widget build(BuildContext context) {
    int pesananAktif = daftarPesananGlobal.where((order) {
      String status = order['status'] ?? '';
      return status == 'Diproses' ||
          status == 'Diproses (pembayaran tunai)' ||
          status == 'Menunggu Pembayaran';
    }).length;

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
                  formatRupiah(_hitungTotalPendapatan()),
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

  Widget _buildPesananTab() {
    final List filteredOrders = daftarPesananGlobal.where((order) {
      String id = (order['id'] ?? order['noPesanan'] ?? "")
          .toString()
          .toLowerCase();
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
                    final order = filteredOrders[index];
                    String orderId =
                        (order['id'] ?? order['noPesanan'] ?? "CAMPUS-000")
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
                          "$status - ${formatRupiah(order['total'])}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (status == "Diproses" ||
                                status == "Diproses (pembayaran tunai)" ||
                                status == "Menunggu Pembayaran") ...[
                              IconButton(
                                icon: const Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.red,
                                ),
                                onPressed: () => _tampilkanKonfirmasi(
                                  "Batalkan Pesanan?",
                                  "Yakin ingin membatalkan pesanan $orderId?",
                                  () => setState(() {
                                    order['status'] = "Dibatalkan";
                                    order['warnaStatus'] = Colors.red;
                                  }),
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
                                  () => setState(() {
                                    order['status'] = "Selesai";
                                    order['warnaStatus'] = Colors.green;
                                  }),
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
                if (order['status'] == 'Diproses' ||
                    order['status'] == 'Diproses (pembayaran tunai)' ||
                    order['status'] == 'Menunggu Pembayaran')
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _tampilkanKonfirmasi(
                        "Batalkan Pesanan?",
                        "Membatalkan pesanan dari dalam menu detail.",
                        () => setState(() {
                          order['status'] = "Dibatalkan";
                          order['warnaStatus'] = Colors.red;
                        }),
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
            ...(order['items'] as List).map((item) {
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
                      formatRupiah(item['harga'] ?? 0),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
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
            _buildDetailRow("Ongkir", formatRupiah(order['ongkir'] ?? 0)),
            _buildDetailRow(
              "Pembayaran",
              "${order['metodeBayar'] ?? order['pembayaran'] ?? '-'} ${order['metodeBayar'] == 'QRIS' ? '(LUNAS)' : ''}",
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
                  formatRupiah(order['total']),
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
              final item = stokAtkGlobal[index];
              int stok = item['stok'] ?? 0;
              bool stokMenipis = stok < 5;
              String? urlGambar = item['gambar'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                                color: stokMenipis ? Colors.red : primaryColor,
                              ),
                            ),
                          ),
                        )
                      : Icon(
                          Icons.inventory_2,
                          color: stokMenipis ? Colors.red : primaryColor,
                        ),
                  title: Text(
                    item['nama'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: stokMenipis ? Colors.red : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    "Stok : $stok | ${formatRupiah(item['harga'])}",
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
                        onPressed: () => _dialogEditStok(index),
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

  Widget _buildCustomerTab() {
    final List filteredCustomers = dataCustomerGlobal.where((customer) {
      String nama = (customer['nama'] ?? "").toString().toLowerCase();
      String nim = (customer['nim'] ?? customer['noWa'] ?? "")
          .toString()
          .toLowerCase();
      return nama.contains(_searchCustomer.toLowerCase()) ||
          nim.contains(_searchCustomer.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            onChanged: (v) => setState(() => _searchCustomer = v),
            decoration: InputDecoration(
              hintText: "Cari nama atau data customer...",
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
          child: filteredCustomers.isEmpty
              ? const Center(child: Text("Customer tidak ditemukan"))
              : ListView.builder(
                  itemCount: filteredCustomers.length,
                  itemBuilder: (context, index) {
                    final customer = filteredCustomers[index];

                    final bool isCurrentUser = customer['nim'] == nimUserGlobal;
                    final bool hasFoto =
                        isCurrentUser && fotoUserGlobal != null;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => _showCustomerDetail(customer),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: primaryColor.withOpacity(0.1),
                            backgroundImage: hasFoto
                                ? FileImage(File(fotoUserGlobal!))
                                      as ImageProvider
                                : null,
                            child: hasFoto
                                ? null
                                : Icon(Icons.person, color: primaryColor),
                          ),
                          title: Text(
                            customer['nama'] ?? 'User',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            customer['nim'] ??
                                customer['noWa'] ??
                                'Data tidak lengkap',
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_sweep,
                              color: Colors.red,
                            ),
                            tooltip: "Nonaktifkan/Hapus Akun",
                            onPressed: () => _tampilkanKonfirmasi(
                              "Hapus Akun Customer?",
                              "Apakah kamu yakin ingin menghapus permanen akun ${customer['nama']}?",
                              () {
                                setState(() {
                                  dataCustomerGlobal.remove(customer);
                                });
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
                ),
        ),
      ],
    );
  }

  void _showCustomerDetail(Map<String, dynamic> customer) {
    final bool isCurrentUser = customer['nim'] == nimUserGlobal;
    final bool hasFoto = isCurrentUser && fotoUserGlobal != null;

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
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFF1B4D5C),
                backgroundImage: hasFoto
                    ? FileImage(File(fotoUserGlobal!)) as ImageProvider
                    : null,
                child: hasFoto
                    ? null
                    : const Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 15),
              Text(
                customer['nama'] ?? 'Tanpa Nama',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildDetailRow("NIM", customer['nim'] ?? '-'),
              const Divider(),
              _buildDetailRow("Email", customer['email'] ?? '-'),
              const Divider(),
              _buildDetailRow("No. WhatsApp", customer['noWa'] ?? '-'),
              const Divider(),
              _buildDetailRow(
                "Jurusan/Prodi",
                customer['jurusan'] ?? 'Bisnis Digital',
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

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
    final gCtrl = TextEditingController(
      text: isEdit ? (stokAtkGlobal[index]['gambar'] ?? "") : "",
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
                    "gambar": gCtrl.text,
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
