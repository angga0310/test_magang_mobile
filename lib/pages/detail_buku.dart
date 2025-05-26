import 'package:flutter/material.dart';
import 'package:perpustakaan_magang/controller/pinjam.dart';
import 'package:perpustakaan_magang/database/api.dart';
import 'package:perpustakaan_magang/model/buku.dart';
import 'package:perpustakaan_magang/model/peminjaman.dart';

class BookDetailPage extends StatelessWidget {
  final Buku buku;

  const BookDetailPage({super.key, required this.buku});

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
                  '${Api.ipServer}${buku.cover}',
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
                label: const Text("Pinjam Buku"),
                onPressed: buku.tersedia
                    ? () {
                        _handlePinjam();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Buku berhasil dipinjam")),
                        );
                        // Navigator.pop(context); // atau setState di parent
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

  void _handlePinjam() async {
    final result = await pinjamBuku(
      idUser: '1',
      idBuku: '2',
    );

    if (result['success']) {
      Peminjaman peminjaman = result['data'];
      print('Peminjaman berhasil: ${peminjaman.id_peminjaman}');
    } else {
      print('Gagal: ${result['message']}');
    }
  }
}
