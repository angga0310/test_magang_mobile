import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:perpustakaan_magang/pages/home_page.dart';
import 'package:perpustakaan_magang/pages/login_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  // Fungsi untuk cek apakah user sudah login
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id'); // bisa pakai token kalau ada
    return userId != null;
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedLabelStyle: TextStyle(fontSize: 14, fontFamily: 'Lexend'),
          unselectedLabelStyle: TextStyle(fontSize: 13, fontFamily: 'Lexend'),
        ),
      ),
      home: FutureBuilder<bool>(
        future: checkLoginStatus(),
        builder: (context, snapshot) {
          // Sementara loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Jika error saat ambil data
          if (snapshot.hasError) {
            return const Scaffold(
              body: Center(child: Text('Terjadi kesalahan.')),
            );
          }

          // Cek status login
          final isLoggedIn = snapshot.data ?? false;

          // Sudah login -> langsung ke HomePage
          if (isLoggedIn) {
            return const HomePage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
