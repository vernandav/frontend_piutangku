import 'package:flutter/material.dart';
import 'package:frontend_flutter_pencatatan/screens/form_transaksi_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  String selectedFilter = 'Semua';
  final searchController = TextEditingController();
  List<Map<String, dynamic>> allTransaksi = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRiwayat();
  }

  Future<void> fetchRiwayat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final res = await http.get(
        Uri.parse('http://localhost:3000/api/transaksi/riwayat'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body)['data'];
        setState(() {
          allTransaksi =
              data.map<Map<String, dynamic>>((e) {
                return {
                  'id': e['id'],
                  'tipe': _capitalize(e['tipe']),
                  'nama': e['nama_lawan'],
                  'total': _extractNumber(e['total']),
                  'cicilan': _extractNumber(e['jumlah_cicilan']),
                  'status': _capitalize(e['status']),
                  'tanggal':
                      '${e['tanggal_mulai'].substring(0, 10)} - ${e['tanggal_jatuh_tempo'].substring(0, 10)}',
                };
              }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Gagal ambil data');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteTransaksi(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.delete(
      Uri.parse('http://localhost:3000/api/transaksi/delete/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil dihapus')),
      );
      fetchRiwayat();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus transaksi')),
      );
    }
  }

  String _capitalize(String input) =>
      input[0].toUpperCase() + input.substring(1).toLowerCase();

  int _extractNumber(String formatted) =>
      int.tryParse(formatted.replaceAll(RegExp(r'\D'), '')) ?? 0;

  @override
  Widget build(BuildContext context) {
    final filtered =
        allTransaksi.where((item) {
          final filter = selectedFilter;
          final query = searchController.text.toLowerCase();
          final cocokNama = item['nama'].toString().toLowerCase().contains(
            query,
          );
          final cocokFilter =
              (filter == 'Semua') ||
              item['tipe'].toString().toLowerCase() == filter.toLowerCase() ||
              item['status'].toString().toLowerCase() == filter.toLowerCase();
          return cocokNama && cocokFilter;
        }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF193149),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0x336B8E9C),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Daftar Riwayat',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 40,
                width: 425,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(64),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),

            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      ['Semua', 'Utang', 'Piutang', 'Aktif', 'Lunas'].map((
                        filter,
                      ) {
                        final isSelected = selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            selectedColor: Colors.white,
                            backgroundColor: const Color(0xFF6B8E9C),
                            showCheckmark: false,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : Colors.white,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onSelected:
                                (_) => setState(() => selectedFilter = filter),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 14),
            isLoading
                ? const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
                : Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFD0DFE7), Color(0xFF387092)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(45),
                        topRight: Radius.circular(45),
                      ),
                    ),
                    child: GridView.builder(
                      padding: const EdgeInsets.only(bottom: 32),
                      itemCount: filtered.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 210,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final sisa = item['total'] - item['cicilan'];
                        return Align(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: 180,
                            child: GestureDetector(
                              onTap: () {
                                //Ganti ini arahkan ke halaman detail_transaksi dengan by id:
                                Navigator.pushNamed(
                                  context,
                                  '/detail-transaksi',
                                  arguments: item['id'], // ✅ Sekarang aman
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: const Color(0xFF535353),
                                  ),
                                  borderRadius: BorderRadius.circular(35),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(2, 4), // arah bayangan
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Center(
                                      child: Text(
                                        item['tipe'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Center(child: Text(item['nama'])),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Total"),
                                        Text("Rp ${item['total']}"),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Cicilan"),
                                        Text("Rp ${item['cicilan']}"),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Sisa"),
                                        Text("Rp $sisa"),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Status"),
                                        Text("${item['status']}"),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Center(
                                      child: Text(
                                        item['tanggal'],
                                        style: const TextStyle(fontSize: 11),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        TextButton(
                                          onPressed: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => FormTransaksiScreen(editId: item['id']),
                                              ),
                                            );
                                            if (result == true) {
                                              fetchRiwayat();
                                            }
                                          },
                                          child: const Text(
                                            "Edit",
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            deleteTransaksi(item['id']);
                                          },
                                          child: const Text(
                                            "Delete",
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
