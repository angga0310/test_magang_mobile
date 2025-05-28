import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:perpustakaan_magang/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:perpustakaan_magang/database/api.dart'; // 🟩 Import Api class

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> logoutUser(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse(Api.logout.trim()),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout berhasil!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout gagal!')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi error saat logout')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Profil',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF89C8A2),
                fontFamily: 'Lexend',
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                logoutUser(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF89C8A2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Lexend',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
