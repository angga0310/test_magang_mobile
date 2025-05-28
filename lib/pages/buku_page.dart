import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:perpustakaan_magang/database/api.dart';
import 'package:perpustakaan_magang/model/buku.dart';
import 'package:http/http.dart' as http;
import 'package:perpustakaan_magang/pages/detail_buku.dart'; // Tambahkan ini!

class DaftarBukuPage extends StatefulWidget {
  final List<Buku>? searchResults;
  final String? searchQuery;

  const DaftarBukuPage({super.key, this.searchResults, this.searchQuery});

  @override
  State<DaftarBukuPage> createState() => _DaftarBukuPageState();
}

class _DaftarBukuPageState extends State<DaftarBukuPage> {
  late List<Buku> displayedBuku;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.searchResults != null && widget.searchResults!.isNotEmpty) {
      displayedBuku = widget.searchResults!;
      _searchController.text = widget.searchQuery ?? '';
      _isLoading = false;
    } else {
      _loadBuku();
    }
  }

  Future<void> _loadBuku() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final response = await http.get(Uri.parse(Api.urlData));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final List<Buku> allBuku =
            jsonData.map((json) => Buku.fromJson(json)).toList();
        setState(() {
          displayedBuku = allBuku;
        });
      } else {
        setState(() {
          displayedBuku = [];
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        displayedBuku = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterBuku(String query) {
    if (query.isEmpty) {
      _loadBuku();
    } else {
      setState(() {
        displayedBuku = displayedBuku.where((buku) {
          final judulLower = buku.judul.toLowerCase();
          final penulisLower = buku.penulis.toLowerCase();
          final queryLower = query.toLowerCase();
          return judulLower.contains(queryLower) ||
              penulisLower.contains(queryLower);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Buku'),
        automaticallyImplyLeading: false, // Hilangkan icon back
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari buku . . .',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onChanged: (value) {
                      _filterBuku(value);
                    },
                  ),
                ),
                Expanded(
                  child: displayedBuku.isEmpty
                      ? const Center(
                          child: Text('Tidak ada buku yang tersedia'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(8.0),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.6,
                          ),
                          itemCount: displayedBuku.length,
                          itemBuilder: (context, index) {
                            final buku = displayedBuku[index];
                            return GestureDetector(
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BookDetailPage(buku: buku),
                                  ),
                                );

                                // Jika buku dipinjam, refresh data
                                if (result == true) {
                                  _loadBuku();
                                }
                              },
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                      child: Image.network(
                                        buku.cover,
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            buku.judul,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            buku.penulis,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
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
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
