import 'package:flutter/material.dart';
import 'package:thesis_app/auth/auth_service.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // get auth service
  final authService = AuthService();

  // text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // password visibility
  bool _isPasswordHidden = true;

  // confirm password visibility
  bool _isConfirmPasswordHidden = true;

  // sign up with google
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

  // sign up button pressed
  void signUp() async {
    // prepare data
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // check that password match
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Password tidak sama")));
    }

    // attempt sign up
    try {
      await authService.signUpWithEmailPassword(email, password);

      // pop this register page
      Navigator.pop(context);

      // catch any error
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
      appBar: AppBar(
        title: Text("Daftar"),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 50),
        children: [
          // email form
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)))),
          ),

          SizedBox(
            height: 10,
          ),

          // password form
          TextField(
            controller: _passwordController,
            obscureText: _isPasswordHidden,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.lock),
              labelText: "Password",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordHidden = !_isPasswordHidden;
                  });
                },
              ),
            ),
          ),

          SizedBox(
            height: 10,
          ),

          // confirm password form
          TextField(
            controller: _confirmPasswordController,
            obscureText: _isConfirmPasswordHidden,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.lock_reset),
                labelText: "Confirm Password",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)))),
          ),

          const SizedBox(height: 15),

          // button
          ElevatedButton(
            onPressed: signUp,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black, // text color
              padding: EdgeInsets.symmetric(
                  horizontal: 50, vertical: 15), // increase button size
            ),
            child: const Text(
              "Daftar",
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
              // // Apple
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

          // GestureDetector(
          //     onTap: () => Navigator.push(context,
          //         MaterialPageRoute(builder: (context) => LoginPage())),
          //     child: Center(child: Text("Sudah punya akun? Masuk di sini!")))
        ],
      ),
    );
  }
}
