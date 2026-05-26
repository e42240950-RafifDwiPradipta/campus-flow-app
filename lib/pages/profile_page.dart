import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _namaCtrl;
  late TextEditingController _nimCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _noHpCtrl;

  bool _isEditing = false;
  bool _isPicking = false; // FLAG PENTING: Mencegah double tap

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // ==========================================
    // PERBAIKAN 1: Ambil data dari Global State
    // ==========================================
    _namaCtrl = TextEditingController(text: namaUserGlobal);
    _nimCtrl = TextEditingController(text: nimUserGlobal);
    _emailCtrl = TextEditingController(text: emailUserGlobal);
    _noHpCtrl = TextEditingController(
      text: noWaUserGlobal,
    ); // Sudah tersinkron!
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nimCtrl.dispose();
    _emailCtrl.dispose();
    _noHpCtrl.dispose();
    super.dispose();
  }

  // --- FUNGSI GANTI FOTO ---
  Future<void> _gantiFoto() async {
    if (_isPicking) return; // Kalau sedang milih foto, jangan proses klik baru

    setState(() {
      _isPicking = true;
    });

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          fotoUserGlobal = pickedFile.path;
        });
      }
    } catch (e) {
      debugPrint("Error ganti foto: $e");
    } finally {
      setState(() {
        _isPicking = false; // Buka kunci lagi setelah selesai atau gagal
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF114B5F);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: const Text(
          "Profil Saya",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                // ==========================================
                // PERBAIKAN 2: Simpan perubahan ke Global
                // ==========================================
                if (_isEditing) {
                  namaUserGlobal = _namaCtrl.text;
                  nimUserGlobal = _nimCtrl.text;
                  emailUserGlobal = _emailCtrl.text;
                  noWaUserGlobal = _noHpCtrl.text;
                }
                _isEditing = !_isEditing; // Toggle mode edit
              });
            },
            icon: Icon(_isEditing ? Icons.check_circle : Icons.edit),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== HEADER PROFIL =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 30, bottom: 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF114B5F), Color(0xFF1A759F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _isEditing ? _gantiFoto : null,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.white,
                            backgroundImage: fotoUserGlobal != null
                                ? FileImage(File(fotoUserGlobal!))
                                      as ImageProvider
                                : null,
                            child: fotoUserGlobal == null
                                ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: primaryColor,
                                  )
                                : null,
                          ),
                        ),
                        if (_isEditing)
                          const Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 16,
                              child: Icon(
                                Icons.camera_alt,
                                color: primaryColor,
                                size: 18,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildEditableHeader(
                    _namaCtrl,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: _buildEditableHeader(
                      _nimCtrl,
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // ===== INFORMASI =====
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildSectionTitle("Informasi Akademik"),
                  _buildProfileCard(
                    icon: Icons.school,
                    title: "Perguruan Tinggi",
                    value: "Politeknik Negeri Jember",
                  ),
                  _buildProfileCard(
                    icon: Icons.location_on,
                    title: "Kampus",
                    value: "Kampus 2 Bondowoso",
                  ),
                  const SizedBox(height: 20),
                  _buildSectionTitle("Informasi Pribadi"),
                  _buildProfileCard(
                    icon: Icons.badge,
                    title: "NIM",
                    value: _nimCtrl.text,
                    isEditable: true,
                    controller: _nimCtrl,
                  ),
                  _buildProfileCard(
                    icon: Icons.email,
                    title: "Email",
                    value: _emailCtrl.text,
                    isEditable: true,
                    controller: _emailCtrl,
                  ),
                  _buildProfileCard(
                    icon: Icons.phone,
                    title: "WhatsApp",
                    value: _noHpCtrl.text,
                    isEditable: true,
                    controller: _noHpCtrl,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableHeader(
    TextEditingController controller, {
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.white,
  }) {
    return _isEditing
        ? SizedBox(
            width: 220,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: fontSize,
                fontWeight: fontWeight,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          )
        : Text(
            controller.text,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 5),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF114B5F),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required IconData icon,
    required String title,
    required String value,
    bool isEditable = false,
    TextEditingController? controller,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF114B5F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: const Color(0xFF114B5F)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 5),
                _isEditing && isEditable
                    ? TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    : Text(
                        value,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
