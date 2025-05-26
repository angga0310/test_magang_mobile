import 'package:flutter/material.dart';
import 'package:perpustakaan_magang/pages/home_page.dart';
import 'package:perpustakaan_magang/pages/login_pages.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                selectedLabelStyle:
                    TextStyle(fontSize: 14, fontFamily: 'Lexend'),
                unselectedLabelStyle:
                    TextStyle(fontSize: 13, fontFamily: 'Lexend'))),
        home: const LoginPage());
  }
}
