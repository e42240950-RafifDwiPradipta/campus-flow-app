import 'package:flutter/material.dart';
import '../main.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaCtrl = TextEditingController();
  final _nimCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _isPasswordHidden = true;

  // =========================
  // HANDLE REGISTER
  // =========================
  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        // =========================
        // DATA CUSTOMER ADMIN
        // =========================
        dataCustomerGlobal.add({
          "nama": _namaCtrl.text,
          "nim": _nimCtrl.text,
          "email": _emailCtrl.text,
          "prodi": "Bisnis Digital",
        });

        // =========================
        // DATA USER LOGIN
        // =========================
        namaUserGlobal = _namaCtrl.text;
        nimUserGlobal = _nimCtrl.text;
        emailUserGlobal = _emailCtrl.text;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pendaftaran Berhasil!"),
          backgroundColor: Color(0xFF114B5F),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Kembali ke Login
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nimCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF114B5F);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: primaryColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // =========================
                  // ICON HEADER
                  // =========================
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF114B5F), Color(0xFF1A759F)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      color: Colors.white,
                      size: 55,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =========================
                  // TITLE
                  // =========================
                  const Text(
                    "Daftar Akun",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Lengkapi data diri untuk bergabung\ndengan Campus Flow",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),

                  const SizedBox(height: 40),

                  // =========================
                  // FORM CARD
                  // =========================
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [
                        // NAMA
                        _buildTextField(
                          _namaCtrl,
                          "Nama Lengkap",
                          Icons.person_outline,
                        ),

                        const SizedBox(height: 18),

                        // NIM
                        _buildTextField(_nimCtrl, "NIM", Icons.badge_outlined),

                        const SizedBox(height: 18),

                        // EMAIL
                        _buildTextField(
                          _emailCtrl,
                          "Email",
                          Icons.email_outlined,
                          isEmail: true,
                        ),

                        const SizedBox(height: 18),

                        // PASSWORD
                        _buildTextField(
                          _passCtrl,
                          "Password",
                          Icons.lock_outline,
                          isPassword: true,
                        ),

                        const SizedBox(height: 35),

                        // =========================
                        // BUTTON REGISTER
                        // =========================
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _handleRegister,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),

                            child: const Text(
                              "Daftar Sekarang",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // =========================
                  // FOOTER LOGIN
                  // =========================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Sudah punya akun? ",
                        style: TextStyle(color: Colors.grey),
                      ),

                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          "Masuk",
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================
  // WIDGET INPUT
  // =========================
  Widget _buildTextField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool isPassword = false,
    bool isEmail = false,
  }) {
    return TextFormField(
      controller: ctrl,

      obscureText: isPassword ? _isPasswordHidden : false,

      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,

      decoration: InputDecoration(
        hintText: hint,

        prefixIcon: Icon(icon, color: const Color(0xFF114B5F)),

        // PASSWORD EYE
        suffixIcon: isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _isPasswordHidden = !_isPasswordHidden;
                  });
                },
                icon: Icon(
                  _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                ),
              )
            : null,

        filled: true,
        fillColor: const Color(0xFFF7F9FC),

        contentPadding: const EdgeInsets.symmetric(vertical: 18),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF114B5F), width: 1.5),
        ),
      ),

      validator: (v) {
        if (v == null || v.isEmpty) {
          return "$hint wajib diisi";
        }

        if (isEmail && !v.contains("@")) {
          return "Format email tidak valid";
        }

        if (isPassword && v.length < 6) {
          return "Password minimal 6 karakter";
        }

        return null;
      },
    );
  }
}
