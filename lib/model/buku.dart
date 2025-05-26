class Buku {
  final int id_buku;
  final String judul;
  final String penulis;
  final String deskripsi;
  final String kategori;
  final String cover;
  final bool tersedia;
  final DateTime? tanggalMasuk;
  final int totalDipinjam;

  Buku({
    required this.id_buku,
    required this.judul,
    required this.penulis,
    required this.deskripsi,
    required this.kategori,
    required this.cover,
    required this.tersedia,
    this.tanggalMasuk,
    this.totalDipinjam = 0,
  });

  factory Buku.fromJson(Map<String, dynamic> json) {
    return Buku(
      id_buku: json['id_buku'],
      judul: json['judul'],
      penulis: json['penulis'],
      deskripsi: json['deskripsi'],
      kategori: json['kategori'],
      cover: json['cover_url'],
      tersedia: json['tersedia'],
      tanggalMasuk: json['tanggal_masuk'] != null
          ? DateTime.parse(json['tanggal_masuk'])
          : null,
      totalDipinjam: json['total_dipinjam'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_buku': id_buku,
      'judul': judul,
      'penulis': penulis,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'cover_url': cover,
      'tersedia': tersedia,
      'tanggal_masuk': tanggalMasuk?.toIso8601String(),
      'total_dipinjam': totalDipinjam,
    };
  }
}
