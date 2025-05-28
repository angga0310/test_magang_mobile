import 'package:flutter/material.dart';
import 'package:perpustakaan_magang/controller/login.dart';
import 'package:perpustakaan_magang/model/user.dart';
import 'package:perpustakaan_magang/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(fontFamily: 'Lexend', fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontFamily: 'Lexend'),
        prefixIcon: Icon(icon, color: const Color(0xFF89C8A2)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF89C8A2), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/lottie/reading.json',
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Perpustakaan Digital',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF89C8A2),
                        fontFamily: 'Lexend',
                      ),
                    ),
                    const SizedBox(height: 36),
                    buildTextField(
                      label: 'Email',
                      icon: Icons.email,
                      controller: emailController,
                    ),
                    const SizedBox(height: 16),
                    buildTextField(
                      label: 'Password',
                      icon: Icons.lock,
                      controller: passwordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF89C8A2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Lottie.asset(
                'assets/lottie/loading.json', // Lottie loading animation
                width: 150,
                height: 150,
              ),
            ),
          ),
      ],
    );
  }

  void login() async {
    final email = emailController.text;
    final password = passwordController.text;

    setState(() => isLoading = true);

    final result = await ApiService.login(email, password);

    setState(() => isLoading = false);

    if (result['success']) {
      User user = result['user'];
      print('DEBUG: User id = ${user.id}');

      // Simpan data user ke Shared Preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id.toString());
      print('DEBUG: user_id disimpan = ${user.id}');

      // Pindah ke HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'],
              style: const TextStyle(fontFamily: 'Lexend')),
        ),
      );
    }
  }
}
