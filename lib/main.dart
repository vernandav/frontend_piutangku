import 'package:flutter/material.dart';
import 'screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/form_transaksi_screen.dart';
import 'screens/form_cicilan_screen.dart';
import 'screens/riwayat_screen.dart';
import 'screens/detail_transaksi_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PiUtangku',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/form-transaksi': (context) => const FormTransaksiScreen(),
        '/riwayat': (context) => const RiwayatScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detail-transaksi') {
          final args = settings.arguments;
          if (args is int) {
            return MaterialPageRoute(
              builder: (context) => DetailTransaksiScreen(transaksiId: args),
            );
          }
        }

        if (settings.name == '/form-cicilan') {
          final args = settings.arguments;
          if (args is int) {
            return MaterialPageRoute(
              builder: (context) => FormCicilanScreen(transaksiId: args),
            );
          }
        }

        return null; // jika tidak cocok dengan route manapun
      },
    );
  }
}
