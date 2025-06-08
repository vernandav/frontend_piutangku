import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? dashboardData;
  bool isLoading = true;
  List<dynamic> upcomingDue = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

Future<void> fetchData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await http.get(
      Uri.parse('http://192.168.199.200:3000/api/transaksi'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      final List<dynamic> transaksiList = data['data'];

      // Cek transaksi yang akan jatuh tempo besok
      final besok = DateTime.now().add(const Duration(days: 1));
      final besokDate = DateTime(besok.year, besok.month, besok.day);

      upcomingDue = transaksiList.where((transaksi) {
        final jatuhTempo = DateTime.tryParse(transaksi['tanggal_jatuh_tempo']);
        if (jatuhTempo == null) return false;
        final jatuhTempoDate = DateTime(jatuhTempo.year, jatuhTempo.month, jatuhTempo.day);
        return jatuhTempoDate == besokDate;
      }).toList();

      setState(() {
        dashboardData = data;
        isLoading = false;
      });
    } else {
      throw Exception('Gagal ambil data');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gagal mengambil data dashboard')),
    );
    setState(() => isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF193149),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF11222C), Color(0xFF387092)],
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(45),
                          bottomRight: Radius.circular(45),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Hello!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  Text(
                                    dashboardData?['nama'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      await prefs.clear();
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/login',
                                      );
                                    },
                                    child: const Text(
                                      'Logout',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Piutangku',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Righteous',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.60,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCBD8E3),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 36,
                                        margin: const EdgeInsets.only(
                                          left: 4,
                                          top: 4,
                                          bottom: 4,
                                        ),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF11222C),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(40),
                                          ),
                                        ),
                                        child: TextButton.icon(
                                          onPressed: () async {
                                            await Navigator.pushNamed(
                                              context,
                                              '/form-transaksi',
                                            );
                                            fetchData();
                                          },
                                          icon: const Icon(
                                            Icons.add_circle_outline,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          label: const Text(
                                            "Transaksi",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 44,
                                        alignment: Alignment.center,
                                        child: Stack(
                                          children: [
                                            TextButton.icon(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) => Dialog(
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                    child: Container(
                                                      padding: const EdgeInsets.all(20),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFD0DFE7), // background utama
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          // Label "Notifikasi"
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                            decoration: BoxDecoration(
                                                              color: const Color(0xFF6B8E9C),
                                                              borderRadius: BorderRadius.circular(30),
                                                            ),
                                                            child: const Text(
                                                              'Notifikasi',
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 18,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(height: 20),

                                                          // Daftar Notifikasi Scrollable
                                                          ConstrainedBox(
                                                            constraints: const BoxConstraints(maxHeight: 400),
                                                            child: SingleChildScrollView(
                                                              child: Column(
                                                                children: upcomingDue.map((tx) {
                                                                  return Container(
                                                                    margin: const EdgeInsets.only(bottom: 12),
                                                                    padding: const EdgeInsets.all(16),
                                                                    decoration: BoxDecoration(
                                                                      color: Colors.white,
                                                                      borderRadius: BorderRadius.circular(30),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color: Colors.black.withOpacity(0.2),
                                                                          blurRadius: 4,
                                                                          offset: const Offset(0, 4),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        const Text(
                                                                          'Utang/Piutang jatuh tempo besok!',
                                                                          style: TextStyle(
                                                                            fontWeight: FontWeight.bold,
                                                                            fontSize: 14.5,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(height: 4),
                                                                        RichText(
                                                                          text: TextSpan(
                                                                            children: [
                                                                              TextSpan(
                                                                                text: tx['nama_lawan'],
                                                                                style: const TextStyle(
                                                                                  fontWeight: FontWeight.bold,
                                                                                  color: Colors.black,
                                                                                  fontSize: 13,
                                                                                ),
                                                                              ),
                                                                              TextSpan(
                                                                                text: ' - Jatuh tempo: ${tx['tanggal_jatuh_tempo']}',
                                                                                style: const TextStyle(
                                                                                  color: Colors.black87,
                                                                                  fontSize: 13,
                                                                                  fontWeight: FontWeight.w500,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                              ),
                                                            ),
                                                          ),

                                                          const SizedBox(height: 20),
                                                          Align(
                                                            alignment: Alignment.bottomRight,
                                                            child: TextButton(
                                                              onPressed: () => Navigator.pop(context),
                                                              child: const Text(
                                                                "Tutup",
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 15,
                                                                  color: Color(0xFF193149),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.notifications, color: Colors.black),
                                              label: const Text(
                                                "Notifikasi",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            if (upcomingDue.isNotEmpty)
                                              const Positioned(
                                                right: 82,
                                                top: 10,
                                                child: CircleAvatar(
                                                  radius: 4,
                                                  backgroundColor: Colors.red,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 100,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            SummaryCard(
                              title: "Total Utang",
                              value:
                                  "${dashboardData?['summary']['jumlah_utang'] ?? 0}",
                            ),
                            SummaryCard(
                              title: "Total Piutang",
                              value:
                                  "${dashboardData?['summary']['jumlah_piutang'] ?? 0}",
                            ),
                            SummaryCard(
                              title: "Masih Aktif",
                              value:
                                  "${dashboardData?['summary']['jumlah_aktif'] ?? 0}",
                            ),
                            SummaryCard(
                              title: "Sudah Lunas",
                              value:
                                  "${dashboardData?['summary']['jumlah_lunas'] ?? 0}",
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0xFF387092), Color(0xFFD0DFE7)],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(45),
                            topRight: Radius.circular(45),
                          ),
                        ),
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Transaksi Terbaru',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    await Navigator.pushNamed(
                                      context,
                                      '/riwayat',
                                    );
                                    fetchData();
                                  },
                                  child: const Text(
                                    'Lihat Semua',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 229, 228, 228),
                                      shadows: [
                                        Shadow(
                                          color: Colors.black54,
                                          offset: Offset(1, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Center(
                                  child: Wrap(
                                    alignment: WrapAlignment.center,
                                    spacing: 16,
                                    runSpacing: 16,
                                    children:
                                        dashboardData?['data']?.map<Widget>((
                                          item,
                                        ) {
                                          final total =
                                              int.tryParse(
                                                item['total']
                                                    .toString()
                                                    .replaceAll(
                                                      RegExp(r'\D'),
                                                      '',
                                                    ),
                                              ) ??
                                              0;
                                          final cicilan =
                                              int.tryParse(
                                                item['jumlah_cicilan']
                                                    .toString()
                                                    .replaceAll(
                                                      RegExp(r'\D'),
                                                      '',
                                                    ),
                                              ) ??
                                              0;
                                          final sisa = total - cicilan;
                                          return TransaksiCard(
                                            item: {
                                              'id': item['id'],
                                              'tipe': item['tipe'],
                                              'nama': item['nama_lawan'],
                                              'total': total,
                                              'cicilan': cicilan,
                                              'status': item['status'],
                                              'tanggal':
                                                  '${item['tanggal_mulai'].substring(0, 10)} hingga ${item['tanggal_jatuh_tempo'].substring(0, 10)}',
                                              'sisa': sisa,
                                            },
                                          );
                                        }).toList() ??
                                        [],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;

  const SummaryCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Color(0xFF95CDB9),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class TransaksiCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const TransaksiCard({required this.item, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/detail-transaksi',
          arguments: item['id'], // ✅ Sekarang aman
        );
      },
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(45),
          border: Border.all(
            color: const Color.fromARGB(255, 83, 83, 83),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                item['tipe'].toString().substring(0, 1).toUpperCase() +
                    item['tipe'].toString().substring(1).toLowerCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Center(child: Text(item['nama'], textAlign: TextAlign.center)),
            const SizedBox(height: 8),
            ...[
              ['Total', 'Rp ${item['total']}'],
              ['Cicilan', 'Rp ${item['cicilan']}'],
              ['Sisa', 'Rp ${item['sisa']}'],
              ['Status', item['status']],
            ].map((pair) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      pair[0],
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      pair[1],
                      style: const TextStyle(fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 8),
            Text(
              item['tanggal'],
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
