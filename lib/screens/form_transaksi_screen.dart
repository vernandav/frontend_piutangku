import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FormTransaksiScreen extends StatefulWidget {
  final int? editId;
  const FormTransaksiScreen({super.key, this.editId});

  @override
  State<FormTransaksiScreen> createState() => _FormTransaksiScreenState();
}

class _FormTransaksiScreenState extends State<FormTransaksiScreen> {
  final _formKey = GlobalKey<FormState>();

  String? tipeTransaksi;
  final namaLawanController = TextEditingController();
  final totalController = TextEditingController();
  final tanggalMulaiController = TextEditingController();
  String? metodeCicilan;
  final targetPelunasanController = TextEditingController();
  final jatuhTempoController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.editId != null) {
      fetchTransaksiById(widget.editId!);
    }
  }

  Future<void> fetchTransaksiById(int id) async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final res = await http.get(
      Uri.parse('http://192.168.199.200:3000/api/transaksi/edit/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body)['data'][0];
      setState(() {
        tipeTransaksi = data['tipe'];
        namaLawanController.text = data['nama_lawan'];
        totalController.text =
            data['total'].toString().replaceAll(RegExp(r'\D'), '');
        tanggalMulaiController.text =
            _formatDateLocal(data['tanggal_mulai']);
        metodeCicilan = data['metode_cicilan'];
        targetPelunasanController.text =
            data['target_pelunasan_bulan']?.toString() ?? '';
        jatuhTempoController.text =
            _formatDateLocal(data['tanggal_jatuh_tempo']);
      });
    }
    setState(() => isLoading = false);
  }

  Future<void> submitTransaksi() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = widget.editId == null
        ? 'http://192.168.199.200:3000/api/transaksi/store'
        : 'http://192.168.199.200:3000/api/transaksi/update/${widget.editId}';

    final method = widget.editId == null ? http.post : http.patch;

    final response = await method(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'tipe': tipeTransaksi,
        'nama_lawan': namaLawanController.text,
        'total': int.tryParse(totalController.text) ?? 0,
        'tanggal_mulai': tanggalMulaiController.text,
        'target_pelunasan_bulan':
            int.tryParse(targetPelunasanController.text) ?? null,
        'metode_cicilan': metodeCicilan,
        'tanggal_jatuh_tempo': jatuhTempoController.text,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.editId == null
              ? 'Transaksi berhasil ditambahkan'
              : 'Transaksi berhasil diperbarui'),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan transaksi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF193149),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
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
                        'Form Transaksi',
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD0DFE7), Color(0xFF6B8E9C)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            decoration: customInputDecoration('Tipe Utang'),
                            value: tipeTransaksi,
                            items: const [
                              DropdownMenuItem(
                                  value: 'utang', child: Text('Utang')),
                              DropdownMenuItem(
                                  value: 'piutang', child: Text('Piutang')),
                            ],
                            onChanged: (val) =>
                                setState(() => tipeTransaksi = val),
                            validator: (val) =>
                                val == null ? 'Pilih tipe transaksi' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: namaLawanController,
                            decoration: customInputDecoration(
                                'Nama Lawan Utang/Piutang'),
                            validator: (val) => val!.isEmpty
                                ? 'Masukkan nama lawan transaksi'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: totalController,
                            decoration: customInputDecoration('Total'),
                            keyboardType: TextInputType.number,
                            validator: (val) =>
                                val!.isEmpty ? 'Masukkan total' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: tanggalMulaiController,
                            readOnly: true,
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFF6B8E9C),
                                        onPrimary: Colors.white,
                                        surface: Color(0xFFD0DFE7),
                                        onSurface: Colors.black,
                                      ),
                                      dialogBackgroundColor:
                                          Color(0xFFD0DFE7),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  tanggalMulaiController.text =
                                      _formatDateLocal(pickedDate.toIso8601String());
                                });
                              }
                            },
                            decoration:
                                customInputDecoration('Tanggal Mulai'),
                            validator: (val) =>
                                val!.isEmpty ? 'Masukkan tanggal mulai' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: jatuhTempoController,
                            readOnly: true,
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFF6B8E9C),
                                        onPrimary: Colors.white,
                                        surface: Color(0xFFD0DFE7),
                                        onSurface: Colors.black,
                                      ),
                                      dialogBackgroundColor:
                                          Color(0xFFD0DFE7),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  jatuhTempoController.text =
                                      _formatDateLocal(pickedDate.toIso8601String());
                                });
                              }
                            },
                            decoration:
                                customInputDecoration('Tanggal Jatuh Tempo'),
                            validator: (val) => val!.isEmpty
                                ? 'Masukkan tanggal jatuh tempo'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            decoration:
                                customInputDecoration('Metode Cicilan'),
                            value: metodeCicilan,
                            items: const [
                              DropdownMenuItem(
                                  value: 'per_bulan',
                                  child: Text('Per Bulan')),
                              DropdownMenuItem(
                                  value: 'per_minggu',
                                  child: Text('Per Minggu')),
                            ],
                            onChanged: (val) =>
                                setState(() => metodeCicilan = val),
                            validator: (val) =>
                                val == null ? 'Pilih metode cicilan' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: targetPelunasanController,
                            decoration:
                                customInputDecoration('Target Pelunasan'),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  submitTransaksi();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF387092),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(
                                      color: Color(0xFF193149), width: 0.5),
                                ),
                                shadowColor: Colors.black.withOpacity(0.3),
                                elevation: 8,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text(
                                'Simpan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
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

  InputDecoration customInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87),
      fillColor: Colors.white,
      filled: true,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide:
            const BorderSide(color: Color.fromARGB(255, 54, 54, 54), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide:
            const BorderSide(color: Color.fromARGB(255, 106, 106, 106)),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
    );
  }

  String _formatDateLocal(String isoDate) {
    final date = DateTime.parse(isoDate).toLocal();
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
