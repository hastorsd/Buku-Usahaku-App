/*

AUTH GATE - This will continuously listen for auth state changes.

------------------------------------------------------------------------------

unauthenticated -> Login Page
authenticated   -> Profile Page

*/

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thesis_app/auth_screens/login.dart';
import 'package:thesis_app/navigation_menu.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Listen to auth state changes
      stream: Supabase.instance.client.auth.onAuthStateChange,

      // Build appropriate page based on auth state
      builder: (context, snapshot) {
        // loading...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // check if there is a valid session currently
        final session = /* if */ snapshot.hasData
            ? /* return */ snapshot.data!.session
            : /* else return */ null;

        if (session != null) {
          return const NavigationMenu();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
