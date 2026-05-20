import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();

    _namaCtrl = TextEditingController(text: namaUserGlobal);
    _nimCtrl = TextEditingController(text: nimUserGlobal);
    _emailCtrl = TextEditingController(text: emailUserGlobal);
    _noHpCtrl = TextEditingController(text: "+62 812-3456-7890");
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nimCtrl.dispose();
    _emailCtrl.dispose();
    _noHpCtrl.dispose();
    super.dispose();
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
                _isEditing = !_isEditing;
              });
            },
            icon: Icon(_isEditing ? Icons.check_circle : Icons.edit),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== HEADER =====
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
                  // FOTO PROFIL
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFF114B5F),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // NAMA
                  _buildEditableHeader(
                    _namaCtrl,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),

                  const SizedBox(height: 8),

                  // NIM
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

            const SizedBox(height: 25),

            // ===== INFORMASI =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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

                  // NIM SENDIRI
                  _buildProfileCard(
                    icon: Icons.badge,
                    title: "NIM",
                    value: _nimCtrl.text,
                    isEditable: true,
                    controller: _nimCtrl,
                  ),

                  // EMAIL SENDIRI
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

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== HEADER EDITABLE =====
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
              decoration: const InputDecoration(border: InputBorder.none),
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

  // ===== TITLE SECTION =====
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

  // ===== PROFILE CARD =====
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
          // ICON
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF114B5F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: const Color(0xFF114B5F)),
          ),

          const SizedBox(width: 15),

          // TEXT
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
