import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class FormCicilanScreen extends StatefulWidget {
  final int transaksiId;
  const FormCicilanScreen({super.key, required this.transaksiId});

  @override
  State<FormCicilanScreen> createState() => _FormCicilanScreenState();
}

class _FormCicilanScreenState extends State<FormCicilanScreen> {
  final jumlahController = TextEditingController();
  final tanggalBayarController = TextEditingController();
  File? imageFile;

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  Future<void> submitCicilan() async {
    if (jumlahController.text.isEmpty ||
        tanggalBayarController.text.isEmpty ||
        imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua data')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final uri = Uri.parse(
      'http://192.168.199.200:3000/api/cicilan/store/${widget.transaksiId}',
    );
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['jumlah'] = jumlahController.text
      ..fields['tanggal_bayar'] = tanggalBayarController.text
      ..files.add(await http.MultipartFile.fromPath(
        'bukti_transfer_url',
        imageFile!.path,
        contentType: MediaType('image', 'jpeg'),
      ));

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cicilan berhasil ditambahkan')),
      );
      Navigator.pop(context, true);
    } else {
      String errorMsg = 'Gagal menambahkan cicilan';
      try {
        final errorJson = jsonDecode(respStr);
        if (errorJson['message'] != null) {
          errorMsg = errorJson['message'];
        }
      } catch (_) {}
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
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
                        'Form Bayar Cicilan',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: jumlahController,
                        keyboardType: TextInputType.number,
                        decoration: customInputDecoration('Jumlah'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: tanggalBayarController,
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
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
                                  dialogBackgroundColor: Color(0xFFD0DFE7),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            tanggalBayarController.text =
                                picked.toIso8601String().substring(0, 10);
                          }
                        },
                        decoration: customInputDecoration('Tanggal Bayar'),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Bukti Transfer',
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 200,
                        child: ElevatedButton.icon(
                          onPressed: pickImage,
                          icon: const Icon(Icons.upload, color: Colors.black87),
                          label: const Text(
                            'Pilih Gambar',
                            style: TextStyle(color: Colors.black87),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF8F8F9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: const BorderSide(
                                color: Color(0xFF193149),
                                width: 0.5,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      if (imageFile != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(imageFile!, height: 100),
                          ),
                        ),
                      const SizedBox(height: 24),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: submitCicilan,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF387092),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(
                                  color: Color(0xFF193149),
                                  width: 0.5,
                                ),
                              ),
                              shadowColor: Colors.black.withOpacity(0.3),
                              elevation: 8,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Simpan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
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
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 54, 54, 54),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Color.fromARGB(255, 106, 106, 106)),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
    );
  }
}
