import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thesis_app/auth/auth_gate.dart';

const supabaseUrl = 'https://ypbanzykohokfcorbkom.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlwYmFuenlrb2hva2Zjb3Jia29tIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE4NTE2NzQsImV4cCI6MjA1NzQyNzY3NH0.8BnStl8byaE4rvYUu_AcZG0_qUYsqYbxsvQixOBWuEg';

Future<void> main() async {
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Skripsi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AuthGate(),
    );
  }
}
