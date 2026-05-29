import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';

class AlamatPage extends StatefulWidget {
  const AlamatPage({super.key});

  @override
  State<AlamatPage> createState() => _AlamatPageState();
}

class _AlamatPageState extends State<AlamatPage> {
  final Color primaryTeal = const Color(0xFF1B4D5C);

  final TextEditingController _labelCtrl = TextEditingController();
  final TextEditingController _detailCtrl = TextEditingController();

  // =========================================================
  // FIREBASE: TAMBAH ALAMAT BARU
  // =========================================================
  void _tampilkanInputAlamat() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 25,
          left: 25,
          right: 25,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tambah Alamat Baru",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _labelCtrl,
              decoration: InputDecoration(
                labelText: "Label Alamat",
                hintText: "Contoh: Kos, Kantor, Rumah",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _detailCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Alamat Lengkap",
                hintText: "Tuliskan jalan, nomor rumah, atau detail gedung...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () async {
                if (_labelCtrl.text.isNotEmpty && _detailCtrl.text.isNotEmpty) {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    try {
                      // Tembak data ke Firestore
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .collection('alamat')
                          .add({
                            "label": _labelCtrl.text,
                            "detail": _detailCtrl.text,
                            "isUtama": false, // Default tidak utama
                            "timestamp": FieldValue.serverTimestamp(),
                          });

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Alamat berhasil ditambahkan!"),
                            backgroundColor: Color(0xFF1B4D5C),
                          ),
                        );
                      }

                      _labelCtrl.clear();
                      _detailCtrl.clear();
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Gagal menambah alamat: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "SIMPAN ALAMAT",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // FIREBASE: HAPUS ALAMAT
  // =========================================================
  Future<void> _hapusAlamat(String docId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('alamat')
            .doc(docId)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Alamat berhasil dihapus"),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Gagal menghapus: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // =========================================================
  // FIREBASE: SET ALAMAT UTAMA
  // =========================================================
  Future<void> _setAlamatUtama(String docId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Ambil semua alamat user ini dulu
        var collectionRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('alamat');
        var snapshot = await collectionRef.get();

        // Gunakan Batch Update agar pengubahan banyak data dilakukan serentak
        WriteBatch batch = FirebaseFirestore.instance.batch();
        for (var doc in snapshot.docs) {
          // Jika ID cocok, set true. Sisanya set false.
          batch.update(doc.reference, {'isUtama': doc.id == docId});
        }
        await batch.commit();
      } catch (e) {
        debugPrint("Gagal update alamat utama: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        title: const Text(
          "Alamat Saya",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(25, 10, 25, 30),
            decoration: BoxDecoration(
              color: primaryTeal,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Text(
              "Atur alamat pengirimanmu agar proses Jastip & antar dokumen makin cepat.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),

          // =========================================================
          // FIREBASE: STREAM BUILDER DAFTAR ALAMAT
          // =========================================================
          Expanded(
            child: user == null
                ? const Center(
                    child: Text("Silakan login untuk melihat alamat."),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('alamat')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _buildEmptyState();
                      }

                      var docs = snapshot.data!.docs;

                      // Sinkronisasi data ke variabel global (Opsional, agar fungsi lama yang belum Firebase tidak error)
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        daftarAlamatGlobal = docs
                            .map((doc) => doc.data() as Map<String, dynamic>)
                            .toList();
                      });

                      return ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final item =
                              docs[index].data() as Map<String, dynamic>;
                          final String docId = docs[index].id;
                          return _buildAlamatCard(item, docId);
                        },
                      );
                    },
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton.icon(
              onPressed: _tampilkanInputAlamat,
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text(
                "TAMBAH ALAMAT BARU",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 5,
                shadowColor: primaryTeal.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 15),
          const Text(
            "Belum ada alamat tersimpan.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAlamatCard(Map<String, dynamic> item, String docId) {
    bool isUtama = item['isUtama'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUtama ? primaryTeal : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => _setAlamatUtama(docId), // Panggil Fungsi Firebase
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: isUtama ? primaryTeal : Colors.grey[100],
                  child: Icon(
                    Icons.location_on,
                    color: isUtama ? Colors.white : Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item['label'] ?? 'Alamat',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (isUtama)
                            Container(
                              margin: const EdgeInsets.only(left: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: primaryTeal.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                "Utama",
                                style: TextStyle(
                                  color: primaryTeal,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item['detail'] ?? '',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => _showKonfirmasiHapus(docId),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showKonfirmasiHapus(String docId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Hapus Alamat?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Apakah kamu yakin ingin menghapus alamat ini dari daftar?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("BATAL"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _hapusAlamat(docId); // Hapus lewat Firebase
            },
            child: const Text(
              "HAPUS",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
