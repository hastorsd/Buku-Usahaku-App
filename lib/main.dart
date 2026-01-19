import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thesis_app/auth/auth_gate.dart';
import 'package:thesis_app/screens/splash/splash_screen.dart';

const supabaseUrl = '';
const supabaseKey =
    '';

Future<void> main() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  await initializeDateFormatting('id_ID', '');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buku Usahaku!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Colors.blue, // ganti dari ungu jadi biru
          secondary: Colors.blueAccent,
        ),
      ),
      home: SplashScreen(),
    );
  }
}
