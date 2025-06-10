import 'package:flutter/material.dart';
import 'package:frontend_flutter_pencatatan/screens/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF193149), // ubah warna background
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 90.0, horizontal: 16.0),
          child: Column(
            children: [
              const Text(
                'PiUtangku',
                style: TextStyle(
                  fontSize: 32,
                  fontFamily: 'Righteous',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 120),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 350),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF387092),
                          Color(0xFFD0DFE7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(45),
                      border: Border.all(color: Color(0xFFD5D5D5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8), // bayangan ke bawah
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildTextField(
                          controller: usernameController,
                          label: 'Username',
                          hint: 'Your username',
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: emailController,
                          label: 'Email',
                          hint: 'Your email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: passwordController,
                          label: 'Password',
                          hint: 'Password',
                          obscureText: obscure,
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscure ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey[700],
                            ),
                            onPressed: () => setState(() => obscure = !obscure),
                          ),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () async {
                              final username = usernameController.text.trim();
                              final email = emailController.text.trim();
                              final password = passwordController.text;

                              if (username.isEmpty || email.isEmpty || password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Semua kolom wajib diisi.')),
                                );
                                return;
                              }

                              try {
                                await AuthService.register(username, email, password);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
                                );

                                Navigator.pushReplacementNamed(context, '/login');
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Registrasi gagal. Email mungkin sudah digunakan.')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF387092),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text('Create', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold,)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text.rich(
                            TextSpan(
                              text: "Already have an account? ",
                              children: [
                                TextSpan(
                                  text: "Sign in",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Color(0xFFD5D5D5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Color(0xFFD5D5D5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(color: Color(0xFF387092), width: 2),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
