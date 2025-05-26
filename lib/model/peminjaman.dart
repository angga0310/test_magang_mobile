class Peminjaman {
  final String id_peminjaman;
  final String id_user;
  final String id_buku;
  final DateTime tanggalPinjam;
  final DateTime tanggalKembali;
  final String status;

  Peminjaman({
    required this.id_peminjaman,
    required this.id_user,
    required this.id_buku,
    required this.tanggalPinjam,
    required this.tanggalKembali,
    required this.status,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    return Peminjaman(
      id_peminjaman: json['id_peminjaman'],
      id_user: json['id_user'],
      id_buku: json['id_buku'],
      tanggalPinjam: DateTime.parse(json['tanggalPinjam']),
      tanggalKembali: DateTime.parse(json['tanggalKembali']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_peminjaman': id_peminjaman,
      'id_user': id_user,
      'id_buku': id_buku,
      'tanggalPinjam': tanggalPinjam.toIso8601String(),
      'tanggalKembali': tanggalKembali.toIso8601String(),
      'status': status,
    };
  }
}
