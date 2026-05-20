import 'package:flutter/material.dart';
import '../main.dart'; // Akses data global

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Admin SatSet Print",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Colors.orange,
            labelColor: Colors.orange,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.shopping_cart), text: "Pesanan"),
              Tab(icon: Icon(Icons.inventory), text: "Stok ATK"),
              Tab(icon: Icon(Icons.people), text: "Customer"),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildPesananTab(), _buildStokTab(), _buildCustomerTab()],
        ),
      ),
    );
  }

  // --- TAB 1: KELOLA PESANAN ---
  Widget _buildPesananTab() {
    if (daftarPesananGlobal.isEmpty) {
      return const Center(child: Text("Belum ada pesanan masuk."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: daftarPesananGlobal.length,
      itemBuilder: (context, index) {
        final order = daftarPesananGlobal[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: order['warnaStatus'] ?? Colors.orange,
              child: const Icon(Icons.receipt_long, color: Colors.white),
            ),
            title: Text(
              "ID: ${order['id']}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Status: ${order['status']}"),
            children: [
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Rincian Produk:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...order['items']
                        .map<Widget>(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    "- ${item['nama']}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                Text(
                                  "Rp ${item['harga']}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    const Divider(),
                    Text("Metode: ${order['metode']}"),
                    Text(
                      "Total: Rp ${order['total']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Update Status:",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _actionButton(index, "Diproses", Colors.blue),
                        _actionButton(index, "Selesai", Colors.green),
                        _actionButton(index, "Dibatalkan", Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 2: UPDATE STOK ATK (SINKRON GLOBAL) ---
  Widget _buildStokTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: ElevatedButton.icon(
            onPressed: () => _dialogEditStok(-1),
            icon: const Icon(Icons.add),
            label: const Text("Tambah Barang Baru"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[800],
              foregroundColor: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: stokAtkGlobal.length, // Pakai data global
            itemBuilder: (context, index) {
              final item = stokAtkGlobal[index];
              return ListTile(
                leading: const Icon(Icons.edit_note, color: Colors.orange),
                title: Text(
                  item['nama'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Stok: ${item['stok']} | Rp ${item['harga']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _dialogEditStok(index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- TAB 3: DATA CUSTOMER (SINKRON GLOBAL) ---
  Widget _buildCustomerTab() {
    if (dataCustomerGlobal.isEmpty) {
      return const Center(child: Text("Belum ada customer terdaftar."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: dataCustomerGlobal.length,
      itemBuilder: (context, index) {
        final customer = dataCustomerGlobal[index];
        return Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(
              customer['nama'] ?? "User",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("${customer['nim']} | ${customer['email']}"),
            trailing: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 16,
            ),
          ),
        );
      },
    );
  }

  Widget _actionButton(int index, String status, Color color) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          daftarPesananGlobal[index]['status'] = status;
          daftarPesananGlobal[index]['warnaStatus'] = color;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Text(status, style: const TextStyle(fontSize: 10)),
    );
  }

  void _dialogEditStok(int index) {
    String title = index == -1 ? "Tambah Barang" : "Edit Stok";
    final nCtrl = TextEditingController(
      text: index == -1 ? "" : stokAtkGlobal[index]['nama'],
    );
    final sCtrl = TextEditingController(
      text: index == -1 ? "" : stokAtkGlobal[index]['stok'].toString(),
    );
    final hCtrl = TextEditingController(
      text: index == -1 ? "" : stokAtkGlobal[index]['harga'].toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nCtrl,
              decoration: const InputDecoration(labelText: "Nama Barang"),
            ),
            TextField(
              controller: sCtrl,
              decoration: const InputDecoration(labelText: "Jumlah Stok"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: hCtrl,
              decoration: const InputDecoration(labelText: "Harga"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (index == -1) {
                  stokAtkGlobal.add({
                    "nama": nCtrl.text,
                    "stok": int.parse(sCtrl.text),
                    "harga": int.parse(hCtrl.text),
                    "ikon": Icons.inventory_2, // Ikon default
                  });
                } else {
                  stokAtkGlobal[index] = {
                    "nama": nCtrl.text,
                    "stok": int.parse(sCtrl.text),
                    "harga": int.parse(hCtrl.text),
                    "ikon": stokAtkGlobal[index]['ikon'],
                  };
                }
              });
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}
