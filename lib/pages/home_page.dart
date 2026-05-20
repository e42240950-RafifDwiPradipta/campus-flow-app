import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../main.dart';
import 'atk_page.dart';
import 'print_feature_page.dart';
import 'jastip_makanan_page.dart';
import 'kalender_akademik_page.dart';
import 'jasa_design_page.dart';
import 'profile_page.dart';
import 'alamat_page.dart';
import 'pesanan_page.dart';
import 'admin_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _timeString = "";

  @override
  void initState() {
    super.initState();
    _timeString = DateFormat('HH:mm').format(DateTime.now());
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
  }

  void _getTime() {
    if (mounted) {
      setState(() {
        _timeString = DateFormat('HH:mm').format(DateTime.now());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // PROTEKSI: Mencegah error jika namaUserGlobal kosong atau null
    String displayName = "User";
    if (namaUserGlobal.isNotEmpty) {
      displayName = namaUserGlobal.split(' ')[0];
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      drawer: _buildFullDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4D5C),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 18),
            child: Text(
              _timeString,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Teal Melengkung
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(25, 5, 25, 45),
            decoration: const BoxDecoration(
              color: Color(0xFF1B4D5C),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo, $displayName 👋",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Apa yang bisa kami bantu hari ini?",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Menu Grid
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(25),
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: [
                _buildMenuCard(
                  context,
                  "Layanan Print",
                  Icons.print,
                  const Color(0xFFE3F2FD),
                  Colors.blue,
                  const PrintFeaturePage(),
                ),
                _buildMenuCard(
                  context,
                  "Kalender Akademik",
                  Icons.calendar_today,
                  const Color(0xFFFFF3E0),
                  Colors.orange,
                  const KalenderAkademikPage(),
                ),
                _buildMenuCard(
                  context,
                  "Jastip Makanan",
                  Icons.fastfood,
                  const Color(0xFFFFEBEE),
                  Colors.red,
                  const JastipMakananPage(),
                ),
                _buildMenuCard(
                  context,
                  "Toko ATK",
                  Icons.shopping_bag,
                  const Color(0xFFE8F5E9),
                  Colors.green,
                  const AtkPage(),
                ),
                _buildMenuCard(
                  context,
                  "Jasa Design",
                  Icons.design_services,
                  const Color(0xFFF3E5F5),
                  Colors.purple,
                  const JasaDesignPage(),
                ),
              ],
            ),
          ),

          _buildBottomPromo(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color bgColor,
    Color iconColor,
    Widget destination,
  ) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination),
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04), // Shadow lebih halus
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPromo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B4D5C), Color(0xFF2D7D8E)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B4D5C).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.stars, color: Colors.white, size: 35),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Promo Gemastik!",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "Diskon cetak skripsi 15%",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF1B4D5C)),
            accountName: Text(
              namaUserGlobal,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(emailUserGlobal),
            currentAccountPicture: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Color(0xFF1B4D5C)),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Color(0xFF1B4D5C)),
            title: const Text("Riwayat Pesanan"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PesananPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.location_on_outlined,
              color: Color(0xFF1B4D5C),
            ),
            title: const Text("Alamat Saya"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AlamatPage()),
              );
            },
          ),
          if (isAdminGlobal)
            ListTile(
              leading: const Icon(
                Icons.admin_panel_settings,
                color: Colors.blueGrey,
              ),
              title: const Text("Admin Panel"),
              subtitle: const Text(
                "Kelola Stok & Pesanan",
                style: TextStyle(fontSize: 10),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminPage()),
                );
              },
            ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Keluar",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              isAdminGlobal = false;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
