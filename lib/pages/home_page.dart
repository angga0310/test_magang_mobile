import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:perpustakaan_magang/database/api.dart';
import 'package:perpustakaan_magang/model/buku.dart';
import 'package:perpustakaan_magang/model/peminjaman.dart';
import 'package:perpustakaan_magang/pages/buku_page.dart';
import 'package:perpustakaan_magang/pages/detail_buku.dart';
import 'package:perpustakaan_magang/pages/profile_page.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  String userName = '';
  String userEmail = '';
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<Buku> bukuList = [];
  List<Peminjaman> peminjamanList = [];
  List<Buku>? searchResults;
  String? searchQuery;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    loadAllData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getString('user_id');
    print('DEBUG: idUser di fetchPeminjaman = $idUser');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          userName = prefs.getString('user_name') ?? 'Guest';
          userEmail = prefs.getString('user_email') ?? '';
        });
      }
    });
  }

  Future<void> loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch buku tetap dijalankan dulu
      final fetchedBuku = await fetchBuku();

      // Update bukuList dulu
      setState(() {
        bukuList = fetchedBuku;
      });

      // Lalu coba fetchPeminjaman
      final fetchedPeminjaman = await fetchPeminjaman();
      final sortedPeminjaman = sortPeminjamanList(fetchedPeminjaman);

      setState(() {
        peminjamanList = sortedPeminjaman;
      });
    } catch (e) {
      print('ERROR di loadAllData: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return _buildHomeContent();
    } else if (_selectedIndex == 1) {
      return DaftarBukuPage(
        searchResults: searchResults,
        searchQuery: searchQuery,
      );
    } else {
      return const ProfilePage();
    }
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: loadAllData,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.notifications, color: Color(0xFF89C8A2)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selamat\nDatang',
                          style: TextStyle(
                            color: Color(0xFF89C8A2),
                            fontSize: 24,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'Lexend',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Positioned(
                        bottom: -1,
                        child: Image.asset(
                          'assets/images/boy2.png',
                          width: 90,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onSubmitted: (_) => _searchAndNavigate(),
                        style: const TextStyle(
                          fontFamily: 'Lexend',
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Cari buku . . .',
                          hintStyle: TextStyle(
                            fontFamily: 'Lexend',
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Text(
                      'Sedang dipinjam',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (peminjamanList.length > 2)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: TextButton(
                        onPressed: () {
                          // Navigasi
                        },
                        child: const Text(
                          'Selengkapnya',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              _buildPeminjamanList(peminjamanList),
              // const SizedBox(height: 40),
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 12),
                    child: Text(
                      'Rekomendasi Buku',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Lexend',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: TextButton(
                      onPressed: () {
                        _onItemTapped(1);
                      },
                      child: const Text(
                        'Selengkapnya',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _buildBukuList(bukuList),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeminjamanList(List<Peminjaman> listPeminjaman) {
    if (listPeminjaman.isEmpty) {
      return const Center(child: Text('Tidak ada buku dipinjam'));
    }

    final displayedList = listPeminjaman.take(3).toList();

    Widget buildCard(Peminjaman pinjam) {
      final buku = pinjam.buku;
      final DateTime sekarang = DateTime.now();
      final DateTime tanggalKembali = pinjam.tanggalKembali ?? sekarang;
      final int selisihHari = tanggalKembali.difference(sekarang).inDays;

      Color cardColor;
      if (selisihHari < 0) {
        cardColor = Colors.red.shade50;
      } else if (selisihHari <= 2) {
        cardColor = Colors.yellow.shade50;
      } else {
        cardColor = Colors.green.shade50;
      }

      return Stack(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: buku.cover.isNotEmpty
                    ? Image.network(
                        buku.cover,
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                      )
                    : const Icon(Icons.book, size: 50),
              ),
              title: Text(
                buku.judul,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Penulis: ${buku.penulis}',
                        style: const TextStyle(
                            fontSize: 10,
                            fontFamily: 'Lexend',
                            color: Colors.black54)),
                    Text(
                      'Pinjam: ${pinjam.tanggalPinjam.toLocal().toString().substring(0, 10)}',
                      style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'Lexend',
                          color: Colors.black54),
                    ),
                    Text(
                      'Kembali: ${pinjam.tanggalKembali?.toLocal().toString().substring(0, 10) ?? '-'}',
                      style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'Lexend',
                          color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (selisihHari < 0)
            Positioned(
              right: 20,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Telat ${selisihHari.abs()} hari',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'Lexend',
                  ),
                ),
              ),
            ),
        ],
      );
    }

    // ≤ 2 item → Column
    if (displayedList.length <= 2) {
      return Column(
        children: displayedList.map(buildCard).toList(),
      );
    }

    // > 2 item → ListView scrollable
    const double itemHeight = 100;
    final double containerHeight = itemHeight * 2;

    return SizedBox(
      height: containerHeight,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: displayedList.length,
        itemBuilder: (context, index) {
          final pinjam = displayedList[index];
          return buildCard(pinjam);
        },
      ),
    );
  }

  Widget _buildBukuList(List<Buku> bukuList) {
    if (bukuList.isEmpty) {
      return const Center(child: Text('Tidak ada buku'));
    }

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: bukuList.length,
        itemBuilder: (context, index) {
          final buku = bukuList[index];
          return GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BookDetailPage(buku: buku)),
              );

              if (result == true) {
                // refresh data buku & peminjaman
                loadAllData();
              }
            },
            child: Container(
              width: 150,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: Image.network(
                        buku.cover,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            buku.judul,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'Lexend',
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            buku.penulis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontFamily: 'Lexend',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Stack(
        children: [
          _buildBody(),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.6),
              child: Center(
                child: Lottie.asset(
                  'assets/lottie/loading.json',
                  width: 150,
                  height: 150,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF89C8A2),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontFamily: 'Lexend', fontSize: 14),
        unselectedLabelStyle:
            const TextStyle(fontFamily: 'Lexend', fontSize: 13),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Daftar Buku',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  void _searchAndNavigate() {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) return;

    final hasilCari = bukuList.where((buku) {
      final judul = buku.judul.toLowerCase();
      final penulis = buku.penulis.toLowerCase();
      return judul.contains(query) || penulis.contains(query);
    }).toList();

    // Simpan hasil & query
    setState(() {
      searchResults = hasilCari;
      searchQuery = query;
      _selectedIndex = 1; // Pindah ke tab Daftar Buku
    });
  }

  List<Peminjaman> sortPeminjamanList(List<Peminjaman> list) {
    final DateTime sekarang = DateTime.now();

    list.sort((a, b) {
      final DateTime tanggalKembaliA = a.tanggalKembali ?? sekarang;
      final DateTime tanggalKembaliB = b.tanggalKembali ?? sekarang;

      final int selisihA = tanggalKembaliA.difference(sekarang).inDays;
      final int selisihB = tanggalKembaliB.difference(sekarang).inDays;

      // Buku telat dulu, urut dari yang paling lama telat
      if (selisihA < 0 && selisihB < 0) {
        return selisihA.compareTo(selisihB);
      }
      if (selisihA < 0) return -1;
      if (selisihB < 0) return 1;

      // Kalau dua-duanya belum telat, urut dari yang tanggal kembali paling dekat
      return selisihA.compareTo(selisihB);
    });

    return list;
  }

  Future<List<Buku>> fetchBuku() async {
    final response = await http.get(Uri.parse(Api.urlData));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => Buku.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data buku');
    }
  }

  Future<List<Peminjaman>> fetchPeminjaman() async {
    final prefs = await SharedPreferences.getInstance();
    final idUser = prefs.getString('user_id');

    if (idUser == null) {
      throw Exception('User ID tidak ditemukan');
    }

    final url = '${Api.urlDataPeminjaman}?id_user=$idUser';
    final response = await http.get(Uri.parse(url));

    // print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];

      if (data.isEmpty) {
        return [];
      }

      return data.map((item) {
        return Peminjaman.fromJson(item);
      }).toList();
    } else {
      throw Exception('Gagal memuat data peminjaman');
    }
  }
}
