import 'package:perpustakaan_magang/model/buku.dart';

class Peminjaman {
  final String id_peminjaman;
  final String id_user;
  final String id_buku;
  final DateTime tanggalPinjam;
  final DateTime? tanggalKembali;
  final String status;
  final Buku buku; // Tambahkan ini!

  Peminjaman({
    required this.id_peminjaman,
    required this.id_user,
    required this.id_buku,
    required this.tanggalPinjam,
    this.tanggalKembali,
    required this.status,
    required this.buku,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    return Peminjaman(
      id_peminjaman: json['id_peminjaman'].toString(),
      id_user: json['id_user'].toString(),
      id_buku: json['id_buku'].toString(),
      tanggalPinjam: DateTime.parse(json['tanggal_pinjam']),
      tanggalKembali: json['tanggal_kembali'] != null
          ? DateTime.parse(json['tanggal_kembali'])
          : null,
      status: json['dikembalikan'] != null
          ? json['dikembalikan'].toString()
          : 'false', // default status
      buku: json['buku'] != null
          ? Buku.fromJson(json['buku'])
          : Buku(
              id_buku: 0,
              judul: 'Unknown',
              penulis: 'Unknown',
              kategori: 'Unknown',
              deskripsi: '',
              cover: '',
              tersedia: false,
            ),
    );
  }
}
