import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

// GLOBAL
import '../main.dart';

// PAGES
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
import 'keranjang_page.dart';
import 'notifikasi_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _timeString = "";
  int _selectedIndex = 0;

  final Color primaryColor = const Color(0xFF114B5F);

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

  // Fitur Sapaan Dinamis
  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return "Selamat Pagi";
    } else if (hour < 15) {
      return "Selamat Siang";
    } else if (hour < 18) {
      return "Selamat Sore";
    } else {
      return "Selamat Malam";
    }
  }

  @override
  Widget build(BuildContext context) {
    String displayName = "User";
    if (namaUserGlobal.isNotEmpty) {
      displayName = namaUserGlobal.split(' ')[0];
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      drawer: _buildPremiumDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 15, 22, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F3D4C), Color(0xFF155B75)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: Column(
                children: [
                  // APPBAR
                  Row(
                    children: [
                      Builder(
                        builder: (context) {
                          return GestureDetector(
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.menu_rounded,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      // NOTIFIKASI
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotifikasiPage(),
                            ),
                          ).then((_) => setState(() {}));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.white10,
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            children: [
                              const Icon(
                                Icons.notifications_none_rounded,
                                color: Colors.white,
                              ),
                              if (daftarPesananGlobal.isNotEmpty)
                                const Positioned(
                                  right: 0,
                                  top: 0,
                                  child: CircleAvatar(
                                    radius: 4,
                                    backgroundColor: Colors.orange,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // JAM
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          _timeString,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // SAPAAN
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${_getGreeting()}, $displayName 👋",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Apa yang bisa kami bantu hari ini?",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ================= CONTENT =================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // PROMO PINDAH KE ATAS
                    Container(
                      padding: const EdgeInsets.all(18),
                      margin: const EdgeInsets.only(
                        bottom: 25,
                      ), // Jarak dengan Grid
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF114B5F), Color(0xFF1A759F)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.25),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: const BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_offer,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 15),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Promo Print Skripsi!",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Diskon 10% untuk cetak lebih dari 50 lembar",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // GRID LAYANAN
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      childAspectRatio: 0.78,
                      children: [
                        _buildPremiumCard(
                          "Layanan Print",
                          "Cetak dokumen dengan mudah & cepat",
                          Icons.print_rounded,
                          Colors.blue,
                          const PrintFeaturePage(),
                        ),
                        _buildPremiumCard(
                          "Kalender Akademik",
                          "Jadwal kuliah dan kegiatan akademik",
                          Icons.calendar_month_rounded,
                          Colors.orange,
                          const KalenderAkademikPage(),
                        ),
                        _buildPremiumCard(
                          "Jastip Makanan",
                          "Pesan makanan favoritmu lebih praktis",
                          Icons.fastfood_rounded,
                          Colors.red,
                          const JastipMakananPage(),
                        ),
                        _buildPremiumCard(
                          "Toko ATK",
                          "Alat tulis lengkap dengan harga terjangkau",
                          Icons.shopping_bag_rounded,
                          Colors.green,
                          const AtkPage(),
                        ),
                        _buildPremiumCard(
                          "Jasa Design",
                          "Desain profesional untuk kebutuhanmu",
                          Icons.design_services_rounded,
                          Colors.purple,
                          const JasaDesignPage(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ================= CARD =================
  Widget _buildPremiumCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    Widget destination,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        ).then(
          (_) => setState(() {}),
        ); // Pastikan ini ada agar keranjang ter-update saat kembali
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF2D3142),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                subtitle,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F6FA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BOTTOM NAV =================
  Widget _buildBottomNavigation() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_rounded, "Beranda", 0),
          _navItem(Icons.shopping_bag_outlined, "Keranjang", 1),
          _navItem(Icons.history_rounded, "Riwayat", 2),
          _navItem(Icons.person_outline_rounded, "Akun", 3),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool active = _selectedIndex == index;
    bool isCart = index == 1 && keranjangGlobal.isNotEmpty; // Deteksi keranjang

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });

        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const KeranjangPage()),
          ).then(
            (_) => setState(() {
              _selectedIndex = 0; // Kembalikan indikator ke Beranda setelah pop
            }),
          );
        }

        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PesananPage()),
          ).then(
            (_) => setState(() {
              _selectedIndex = 0;
            }),
          );
        }

        if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          ).then(
            (_) => setState(() {
              _selectedIndex = 0;
            }),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // STACK UNTUK BADGE KERANJANG
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: active ? primaryColor : Colors.grey),
              if (isCart)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "${keranjangGlobal.length}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: active ? primaryColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ================= DRAWER =================
  Widget _buildPremiumDrawer() {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF114B5F), Color(0xFF1A759F)],
              ),
            ),
            accountName: Text(namaUserGlobal),
            accountEmail: Text(emailUserGlobal),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Color(0xFF114B5F)),
            ),
          ),
          _drawerItem(Icons.person_outline, "Profil Saya", const ProfilePage()),
          _drawerItem(
            Icons.location_on_outlined,
            "Alamat Saya",
            const AlamatPage(),
          ),
          _drawerItem(
            Icons.history_rounded,
            "Riwayat Pesanan",
            const PesananPage(),
          ),
          if (isAdminGlobal)
            _drawerItem(
              Icons.admin_panel_settings,
              "Admin Panel",
              const AdminPage(),
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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon, color: primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 15),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        ).then((_) => setState(() {}));
      },
    );
  }
}
