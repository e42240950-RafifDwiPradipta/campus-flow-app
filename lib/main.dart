import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // 1. Wajib import ini
import 'pages/splash_screen.dart';

// --- GUDANG DATA GLOBAL CAMPUS FLOW ---

// 1. Identitas User (Inisialisasi awal kosong agar nanti diisi saat Login)
String namaUserGlobal = "";
String nimUserGlobal = "";
String emailUserGlobal =
    ""; // Variabel ini yang akan kita panggil di Drawer & Profil
bool isAdminGlobal = false;

// 2. Data Transaksi & Keranjang
List<Map<String, dynamic>> daftarPesananGlobal = [];
List<Map<String, dynamic>> keranjangGlobal = [];

// 3. Data Stok ATK
List<Map<String, dynamic>> stokAtkGlobal = [
  {"nama": "Buku Tulis", "stok": 25, "harga": 12500, "ikon": Icons.menu_book},
  {"nama": "Pulpen Gel", "stok": 50, "harga": 250, "ikon": Icons.edit},
  {
    "nama": "Penghapus",
    "stok": 10,
    "harga": 18500,
    "ikon": Icons.auto_fix_normal,
  },
];

// 4. Data Customer (Untuk Panel Admin)
List<Map<String, String>> dataCustomerGlobal = [
  {
    "nama": "Farhan",
    "nim": "T61003550",
    "email": "farhan@campusflow.com",
    "prodi": "Teknik Informatika",
  },
];

// 5. Data Alamat User
List<Map<String, dynamic>> daftarAlamatGlobal = [
  {
    "label": "Rumah / Kos",
    "detail": "Jl. Mastrip No. 123, Bondowoso",
    "isUtama": true,
  },
  {
    "label": "Kampus 2",
    "detail": "Gedung A, Depan Lab Bisnis Digital",
    "isUtama": false,
  },
];

void main() {
  runApp(const CampusFlowApp());
}

class CampusFlowApp extends StatelessWidget {
  const CampusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus Flow',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B4D5C),
          primary: const Color(0xFF1B4D5C),
          secondary: const Color(0xFF2D7D8E),
        ),

        // 2. Terapkan Poppins ke seluruh teks di aplikasi
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),

        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
