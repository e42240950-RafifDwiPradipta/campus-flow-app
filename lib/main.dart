import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'pages/splash_screen.dart';

// --- TAMBAHAN FIREBASE ---
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// --- GUDANG DATA GLOBAL CAMPUS FLOW ---

// 1. Identitas User
String namaUserGlobal = "";
String nimUserGlobal = "";
String emailUserGlobal = "";
String noWaUserGlobal = ""; // Sudah diletakkan di posisi yang benar
String? fotoUserGlobal;
bool isAdminGlobal = false;

// 2. Data Transaksi, Keranjang & Notifikasi
List<Map<String, dynamic>> daftarPesananGlobal = [];
List<Map<String, dynamic>> keranjangGlobal = [];
List<Map<String, dynamic>> notifikasiGlobal =
    []; // Sudah dideklarasikan di sini

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

// 4. Data Customer
List<Map<String, String>> dataCustomerGlobal = [
  {
    "nama": "Farhan",
    "nim": "T61003550",
    "email": "farhan@campusflow.com",
    "noWa": "+62 81234567890",
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

// 6. Kalender
List<Map<String, dynamic>> dataKalenderGlobal = [
  {
    "title": "UAS Semester Genap",
    "date": "8 - 12 Jun 2026",
    "icon": Icons.edit_calendar,
    "color": Colors.orange,
    "markerStart": DateTime(2026, 6, 8),
    "markerEnd": DateTime(2026, 6, 12),
  },
];

// Fungsi Global Format Rupiah
String formatRupiah(num angka) {
  return NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(angka);
}

void main() async {
  // Wajib ditambahkan sebelum inisialisasi Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Menyalakan mesin Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
