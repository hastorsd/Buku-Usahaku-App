import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(
      String email, String password) async {
    return await _supabaseClient.auth
        .signInWithPassword(email: email, password: password);
  }

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmailPassword(
      String email, String password) async {
    return await _supabaseClient.auth.signUp(email: email, password: password);
  }

  // Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      const webClientId =
          '298878042296-g0ga0i3709fm522d67a24cmu4die51lp.apps.googleusercontent.com';
      const iosClientId =
          '298878042296-pallucmh5osjphr0f0oc88udlgr4rt0t.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Google Sign-In dibatalkan.';
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw 'Gagal untuk mengambil token Google.';
      }

      return await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      throw 'Google Sign-In Error: $e';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  // Get user email
  String? getCurrentUserEmail() {
    final session = _supabaseClient.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
}
