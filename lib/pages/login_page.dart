import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Tambahan import
import '../main.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscureText = true;
  bool _rememberMe = false;

  final Color primaryTeal = const Color(0xFF114B5F);

  // =========================
  // INIT STATE (Load Data)
  // =========================
  @override
  void initState() {
    super.initState();
    _loadSavedLogin();
  }

  Future<void> _loadSavedLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('remember_me') ?? false;
      if (_rememberMe) {
        _emailCtrl.text = prefs.getString('saved_email') ?? '';
        _passCtrl.text = prefs.getString('saved_password') ?? '';
      }
    });
  }

  // =========================
  // HANDLE LOGIN
  // =========================
  void _handleLogin() async {
    // Dijadikan async untuk SharedPreferences
    if (_formKey.currentState!.validate()) {
      // Simpan preferensi Ingat Saya
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setBool('remember_me', true);
        await prefs.setString('saved_email', _emailCtrl.text);
        await prefs.setString('saved_password', _passCtrl.text);
      } else {
        await prefs.remove('remember_me');
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
      }

      setState(() {
        // =========================
        // LOGIN ADMIN
        // =========================
        if (_emailCtrl.text == "admin@satset.com" &&
            _passCtrl.text == "admin123") {
          isAdminGlobal = true;

          namaUserGlobal = "Admin Campus";
          nimUserGlobal = "ADMIN001";
          emailUserGlobal = "admin@satset.com";
        } else {
          // =========================
          // LOGIN USER
          // =========================
          isAdminGlobal = false;

          bool userFound = false;

          // Cari user berdasarkan email
          for (var user in dataCustomerGlobal) {
            if (user["email"] == _emailCtrl.text) {
              namaUserGlobal = user["nama"] ?? "";
              nimUserGlobal = user["nim"] ?? "";
              emailUserGlobal = user["email"] ?? "";

              userFound = true;
              break;
            }
          }

          // =========================
          // JIKA EMAIL TIDAK TERDAFTAR
          // =========================
          if (!userFound) {
            namaUserGlobal = _emailCtrl.text.split('@')[0];
            nimUserGlobal = "Belum terdaftar";
            emailUserGlobal = _emailCtrl.text;
          }
        }
      });

      // PINDAH KE HOME
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }

  // =========================
  // BOTTOM SHEET RESET PASSWORD
  // =========================
  void _showForgotPasswordSheet() {
    final resetEmailCtrl = TextEditingController(text: _emailCtrl.text);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),

      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 30,
          left: 25,
          right: 25,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Reset Password",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryTeal,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "Masukkan email yang terdaftar untuk menerima tautan reset password.",
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: resetEmailCtrl,
              keyboardType: TextInputType.emailAddress,

              decoration: InputDecoration(
                hintText: "Email terdaftar",

                prefixIcon: Icon(Icons.email_outlined, color: primaryTeal),

                filled: true,
                fillColor: const Color(0xFFF7F9FC),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: primaryTeal, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed: () {
                  if (resetEmailCtrl.text.isNotEmpty) {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Tautan reset dikirim ke ${resetEmailCtrl.text}",
                        ),
                        backgroundColor: primaryTeal,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  foregroundColor: Colors.white,
                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                child: const Text(
                  "KIRIM TAUTAN",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),

            child: Form(
              key: _formKey,

              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // =========================
                  // LOGO
                  // =========================
                  Container(
                    padding: const EdgeInsets.all(25),

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF114B5F), Color(0xFF1A759F)],
                      ),

                      shape: BoxShape.circle,

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),

                    child: const Icon(
                      Icons.auto_awesome_motion,
                      size: 65,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // =========================
                  // TITLE
                  // =========================
                  Text(
                    "CAMPUS FLOW",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: primaryTeal,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Easy way for your campus life",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),

                  const SizedBox(height: 45),

                  // =========================
                  // LOGIN CARD
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
                        // EMAIL
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,

                          decoration: InputDecoration(
                            hintText: "Email",

                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: primaryTeal,
                            ),

                            filled: true,
                            fillColor: const Color(0xFFF7F9FC),

                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 18,
                            ),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: primaryTeal,
                                width: 1.5,
                              ),
                            ),
                          ),

                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Email wajib diisi";
                            }

                            if (!v.contains("@")) {
                              return "Format email tidak valid";
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // PASSWORD
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscureText,

                          decoration: InputDecoration(
                            hintText: "Password",

                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: primaryTeal,
                            ),

                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),

                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),

                            filled: true,
                            fillColor: const Color(0xFFF7F9FC),

                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 18,
                            ),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(
                                color: primaryTeal,
                                width: 1.5,
                              ),
                            ),
                          ),

                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Password wajib diisi";
                            }

                            if (v.length < 6) {
                              return "Password minimal 6 karakter";
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 10),

                        // REMEMBER + FORGOT
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,

                                  child: Checkbox(
                                    value: _rememberMe,
                                    activeColor: primaryTeal,

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),

                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value!;
                                      });
                                    },
                                  ),
                                ),

                                const SizedBox(width: 8),

                                const Text(
                                  "Ingat Saya",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),

                            TextButton(
                              onPressed: _showForgotPasswordSheet,

                              child: Text(
                                "Lupa Password?",
                                style: TextStyle(
                                  color: primaryTeal,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // BUTTON LOGIN
                        SizedBox(
                          width: double.infinity,
                          height: 55,

                          child: ElevatedButton(
                            onPressed: _handleLogin,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryTeal,
                              foregroundColor: Colors.white,
                              elevation: 0,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),

                            child: const Text(
                              "Masuk",
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

                  // REGISTER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      const Text(
                        "Belum punya akun? ",
                        style: TextStyle(color: Colors.grey),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterPage(),
                            ),
                          );
                        },

                        child: Text(
                          "Daftar di sini",
                          style: TextStyle(
                            color: primaryTeal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
