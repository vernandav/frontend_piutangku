import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'form_cicilan_screen.dart';

class DetailTransaksiScreen extends StatefulWidget {
  final int transaksiId;
  const DetailTransaksiScreen({super.key, required this.transaksiId});

  @override
  State<DetailTransaksiScreen> createState() => _DetailTransaksiScreenState();
}

class _DetailTransaksiScreenState extends State<DetailTransaksiScreen> {
  Map<String, dynamic>? transaksi;
  List<Map<String, dynamic>> cicilanList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.get(
      Uri.parse(
        'http://192.168.199.200:3000/api/transaksi/detail/${widget.transaksiId}',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final jsonData = json.decode(res.body);

    print(jsonData['transaksi']); 

      setState(() {
        transaksi = jsonData['transaksi'];
        cicilanList = List<Map<String, dynamic>>.from(jsonData['cicilan']);
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil detail transaksi')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteCicilan(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.delete(
      Uri.parse('http://192.168.199.200:3000/api/cicilan/delete/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cicilan berhasil dihapus')));
      fetchDetail();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal menghapus cicilan')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF193149),
      body: SafeArea(
        child:
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
                : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0x336B8E9C),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                'Detail Transaksi',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    // Informasi Transaksi
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD0DFE7),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoHeader(),
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      _capitalize(transaksi!['tipe']),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      transaksi!['nama_lawan'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Column(
                                children: [
                                  _infoRow('Status', _capitalize(transaksi!['status'])),
                                  if (transaksi!.containsKey('metode_cicilan') &&
                                      transaksi!['metode_cicilan'] != null &&
                                      transaksi!['metode_cicilan'].toString().isNotEmpty)
                                    _infoRow('Metode Cicilan', _formatMetodeCicilan(transaksi!['metode_cicilan'])),
                                  if (transaksi!.containsKey('target_pelunasan_bulan') &&
                                      transaksi!['target_pelunasan_bulan'] != null)
                                    _infoRow('Target Pelunasan',
                                        transaksi!['target_pelunasan_bulan'].toString()),
                                  _infoRow('Total', transaksi!['total']),
                                  _infoRow('Cicilan', transaksi!['jumlah_cicilan']),
                                  _infoRow('Sisa', transaksi!['sisa_cicilan']),
                                  if (transaksi!.containsKey('minimum_cicilan') && transaksi!['minimum_cicilan'] != null)
                                    _infoRow('Minimum Cicilan', transaksi!['minimum_cicilan']),
                                  _infoRow('Tanggal Mulai',
                                      transaksi!['tanggal_mulai'].toString().substring(0, 10)),
                                  _infoRow('Tanggal Jatuh Tempo',
                                      transaksi!['tanggal_jatuh_tempo'].toString().substring(0, 10)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Riwayat Cicilan
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 450),
                          child: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFD0DFE7), Color(0xFF387092)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(32),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                24,
                                24,
                                40,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _infoHeader(title: 'Riwayat Cicilan'),

                                  // Header
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF193149),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: const Row(
                                      children: [
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              'Tanggal Bayar',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              'Jumlah Dibayar',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              'Bukti Transfer',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // List Cicilan
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: cicilanList.length,
                                      itemBuilder: (context, index) {
                                        final item = cicilanList[index];
                                        final buktiUrl =
                                            item['bukti_transfer_url'];

                                        return Stack(
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 6,
                                                  ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        item['tanggal_bayar']
                                                            .substring(0, 10),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        item['jumlah'],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            if (buktiUrl !=
                                                                    null &&
                                                                buktiUrl
                                                                    .isNotEmpty) {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (
                                                                      context,
                                                                    ) => Dialog(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .transparent,
                                                                      child: InteractiveViewer(
                                                                        child: ClipRRect(
                                                                          borderRadius: BorderRadius.circular(
                                                                            10,
                                                                          ),
                                                                          child: Image.network(
                                                                            'http://192.168.199.200:3000/uploads/$buktiUrl',
                                                                            fit:
                                                                                BoxFit.contain,
                                                                            errorBuilder:
                                                                                (
                                                                                  context,
                                                                                  error,
                                                                                  _,
                                                                                ) => const Icon(
                                                                                  Icons.broken_image,
                                                                                ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                              );
                                                            }
                                                          },
                                                          child: Container(
                                                            height: 40,
                                                            width: 40,
                                                            clipBehavior:
                                                                Clip.antiAlias,
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    5,
                                                                  ),
                                                              color:
                                                                  Colors
                                                                      .black12,
                                                            ),
                                                            child:
                                                                buktiUrl != null
                                                                    ? Image.network(
                                                                      'http://192.168.199.200:3000/uploads/$buktiUrl',
                                                                      fit:
                                                                          BoxFit
                                                                              .cover,
                                                                      errorBuilder:
                                                                          (
                                                                            context,
                                                                            error,
                                                                            _,
                                                                          ) => const Icon(
                                                                            Icons.broken_image,
                                                                          ),
                                                                    )
                                                                    : const Icon(
                                                                      Icons
                                                                          .image_not_supported,
                                                                    ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 4,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Positioned(
                                              top: 4,
                                              right: 10,
                                              child: GestureDetector(
                                                onTap:
                                                    () => deleteCicilan(
                                                      item['id'],
                                                    ),
                                                child: const CircleAvatar(
                                                  radius: 10,
                                                  backgroundColor: Colors.red,
                                                  child: Icon(
                                                    Icons.close,
                                                    size: 12,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Tombol Tambah Cicilan
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => FormCicilanScreen(
                                                  transaksiId:
                                                      widget.transaksiId,
                                                ),
                                          ),
                                        );
                                        fetchDetail(); // refresh setelah tambah cicilan
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF387092,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            32,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Tambah Cicilan',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _infoHeader({String title = 'Informasi Transaksi'}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF6B8E9C),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(flex: 3, child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

String _formatMetodeCicilan(String value) {
  switch (value.toLowerCase()) {
    case 'per_bulan':
      return 'Per-Bulan';
    case 'per_minggu':
      return 'Per-Minggu';
    default:
      return _capitalize(value);
  }
}

  String _capitalize(String text) =>
      text.isNotEmpty
          ? '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}'
          : '';
}
