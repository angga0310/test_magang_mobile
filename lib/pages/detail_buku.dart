import 'package:flutter/material.dart';
import 'package:get/get.dart'; // tambahkan ini!
import 'package:shared_preferences/shared_preferences.dart';
import 'package:perpustakaan_magang/controller/pinjam.dart';
import 'package:perpustakaan_magang/model/buku.dart';
import 'package:perpustakaan_magang/model/peminjaman.dart';

class BookDetailPage extends StatefulWidget {
  final Buku buku;

  const BookDetailPage({super.key, required this.buku});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late Buku buku;
  bool isPinjamLoading = false;

  @override
  void initState() {
    super.initState();
    buku = widget.buku; // supaya bisa diubah local state
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text("Detail Buku"),
        backgroundColor: const Color(0xFF89C8A2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  buku.cover,
                  height: 200,
                  width: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              buku.judul,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Lexend',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Penulis: ${buku.penulis}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Kategori: ${buku.kategori}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              buku.deskripsi,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Status: ${buku.tersedia ? "Tersedia" : "Sedang Dipinjam"}",
              style: TextStyle(
                fontSize: 14,
                color: buku.tersedia ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.book),
                label: isPinjamLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("Pinjam Buku"),
                onPressed: buku.tersedia && !isPinjamLoading
                    ? () {
                        _handlePinjam(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF89C8A2),
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handlePinjam(BuildContext context) async {
    try {
      setState(() {
        isPinjamLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final idUser = prefs.getString('user_id');

      if (idUser == null) {
        Get.snackbar("Gagal", "User tidak ditemukan. Silakan login.",
            backgroundColor: Colors.red, colorText: Colors.white);
        setState(() {
          isPinjamLoading = false;
        });
        return;
      }

      final idBuku = buku.id_buku.toString();
      final result = await pinjamBuku(idUser: idUser, idBuku: idBuku);

      setState(() {
        isPinjamLoading = false;
      });

      if (result['success']) {
        Peminjaman peminjaman = result['data'];

        // Auto set tanggalKembali 7 hari jika null
        if (peminjaman.tanggalKembali == null) {
          final tanggalKembali =
              peminjaman.tanggalPinjam.add(const Duration(days: 7));
          peminjaman = Peminjaman(
            id_peminjaman: peminjaman.id_peminjaman,
            id_user: peminjaman.id_user,
            id_buku: peminjaman.id_buku,
            tanggalPinjam: peminjaman.tanggalPinjam,
            tanggalKembali: tanggalKembali,
            status: peminjaman.status,
            buku: peminjaman.buku,
          );
        }

        print('Peminjaman berhasil: ${peminjaman.id_peminjaman}');
        print('Tanggal Pinjam: ${peminjaman.tanggalPinjam}');
        print('Tanggal Kembali: ${peminjaman.tanggalKembali}');

        // Update status buku jadi tidak tersedia
        setState(() {
          buku = Buku(
            id_buku: buku.id_buku,
            judul: buku.judul,
            penulis: buku.penulis,
            deskripsi: buku.deskripsi,
            kategori: buku.kategori,
            cover: buku.cover,
            tersedia: false, // update status
            tanggalMasuk: buku.tanggalMasuk,
            totalDipinjam: buku.totalDipinjam,
          );
        });

        Get.snackbar("Berhasil", "Buku berhasil dipinjam!",
            backgroundColor: Colors.green, colorText: Colors.white);
        Navigator.pop(context, true);
      } else {
        Get.snackbar("Gagal", result['message'] ?? "Gagal meminjam buku",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isPinjamLoading = false;
      });
      Get.snackbar("Error", "Terjadi kesalahan.",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
