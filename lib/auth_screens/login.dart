import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:thesis_app/auth/auth_service.dart';
import 'package:thesis_app/auth_screens/register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // get auth service
  final authService = AuthService();

  // text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // password visibility
  bool _isPasswordHidden = true;

  // login button pressed
  void login() async {
    // prepare data
    final email = _emailController.text;
    final password = _passwordController.text;

    // attempt to login
    try {
      await authService.signInWithEmailPassword(email, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  // Tambahkan di dalam _LoginPageState
  void loginWithGoogle() async {
    try {
      await authService.signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Masuk"),
      // ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 250.0,
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30.0,
                  fontFamily: 'Agne',
                  color: Colors.black,
                ),
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Catat produk Anda',
                      textAlign: TextAlign.center, // Teks rata tengah
                      speed: Duration(
                          milliseconds: 100), // Ubah durasi untuk memperlambat
                    ),
                    TypewriterAnimatedText(
                      'Catat pesanan Anda',
                      textAlign: TextAlign.center, // Teks rata tengah
                      speed: Duration(milliseconds: 100),
                    ),
                    TypewriterAnimatedText(
                      'Rekap keuangan secara otomatis',
                      textAlign: TextAlign.center, // Teks rata tengah
                      speed: Duration(milliseconds: 100),
                    ),
                    TypewriterAnimatedText(
                      'Bagikan data pesanan ke pelanggan setia Anda',
                      textAlign: TextAlign.center, // Teks rata tengah
                      speed: Duration(milliseconds: 100),
                    ),
                  ],
                  repeatForever: true,
                  pause: Duration(
                      milliseconds: 1000), // Jeda antar teks lebih lama
                ),
              ),
            ),
          ),
          SizedBox(
            height: 70,
          ),
          ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 50),
            children: [
              // email form
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: "contoh@example.com",
                  hintStyle: TextStyle(
                      color: Colors.grey), // Set hint text color to gray
                  labelText: "Email",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  prefixIcon: Icon(Icons.email),
                ),
              ),

              const SizedBox(height: 10),

              // password form
              TextField(
                controller: _passwordController,
                obscureText: _isPasswordHidden,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordHidden
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordHidden = !_isPasswordHidden;
                      });
                    },
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Text("Lupa Password?"),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // button
              ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black, // text color
                  padding: EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15), // increase button size
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15), // increase text size
                ),
              ),

              const SizedBox(height: 20),

              // Teks pemisah
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      indent: 20,
                      color: Colors.grey[300],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "atau lanjutkan dengan",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      endIndent: 20,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Tombol Google, Facebook, Apple
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google
                  ElevatedButton(
                    onPressed: loginWithGoogle,
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(), backgroundColor: Colors.white,
                      padding: EdgeInsets.all(10), // Button color
                    ),
                    child: Image.asset(
                      'assets/images/google.png', // Pastikan ikon ada di folder assets
                      width: 30,
                    ),
                  ),
                  // const SizedBox(width: 20),
                  // Apple
                  // ElevatedButton(
                  //   onPressed: () {
                  //     // Tambahkan fungsi login Apple
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     shape: CircleBorder(), backgroundColor: Colors.white,
                  //     padding: EdgeInsets.all(10), // Button color
                  //   ),
                  //   child: Image.asset(
                  //     'assets/images/apple.png',
                  //     width: 30,
                  //   ),
                  // ),
                ],
              ),

              const SizedBox(height: 50),

              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterPage())),
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      text: "Belum punya akun? ", // Teks biasa
                      children: [
                        TextSpan(
                          text: "Daftar di sini!", // Teks bold
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
