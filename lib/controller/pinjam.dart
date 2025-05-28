import 'dart:convert';

import 'package:perpustakaan_magang/database/api.dart';
import 'package:http/http.dart' as http;
import 'package:perpustakaan_magang/model/peminjaman.dart';

Future<Map<String, dynamic>> pinjamBuku({
  required String idUser,
  required String idBuku,
}) async {
  final url = Uri.parse('${Api.urlPinjam}');

  try {
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'id_user': idUser,
        'id_buku': idBuku,
        'tanggal_pinjam': DateTime.now().toIso8601String(),
        'tanggal_kembali':
            DateTime.now().add(Duration(days: 7)).toIso8601String(),
      }),
    );
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      // Sukses - parsing ke model Peminjaman
      final data = json.decode(response.body);
      final peminjamanData = data['data'];
      final peminjaman = Peminjaman.fromJson(peminjamanData);
      print('Data: $data');
      print('Data["data"]: ${data['data']}');

      return {
        'success': true,
        'message': data['message'],
        'data': peminjaman,
      };
    } else if (response.statusCode == 400) {
      final data = json.decode(response.body);
      return {
        'success': false,
        'message': data['message'] ?? 'Buku sedang tidak tersedia.',
      };
    } else {
      final data = json.decode(response.body);
      return {
        'success': false,
        'message': data['message'] ?? 'Terjadi kesalahan.',
        'error': data['error'],
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'Terjadi kesalahan saat mengirim request.',
      'error': e.toString(),
    };
  }
}
