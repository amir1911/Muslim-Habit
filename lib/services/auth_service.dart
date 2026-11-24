import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Konfigurasi GoogleSignIn dengan serverClientId Web Client ID Firebase jika tersedia
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '124725735669-j3fr9oh5fqkpvc3deg5s9v47dbepd4hg.apps.googleusercontent.com',
  );

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── LOGIN DENGAN EMAIL & PASSWORD ───
  Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      debugPrint('Error signInWithEmailPassword: $e');
      rethrow;
    }
  }

  // ─── REGISTER DENGAN EMAIL & PASSWORD ───
  Future<UserCredential?> registerWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (displayName != null && displayName.isNotEmpty) {
        await userCredential.user?.updateDisplayName(displayName);
      }
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      debugPrint('Error registerWithEmailPassword: $e');
      rethrow;
    }
  }

  // ─── RESET PASSWORD ───
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      debugPrint('Error sendPasswordResetEmail: $e');
      rethrow;
    }
  }

  // ─── LOGIN DENGAN GOOGLE ───
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Pastikan sesi lama di-disconnect/signout agar dialog pemilihan akun selalu muncul
      try {
        if (await _googleSignIn.isSignedIn()) {
          await _googleSignIn.signOut();
        }
      } catch (_) {}

      // 1. Munculkan Google Account Selector
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Pengguna membatalkan pemilihan akun secara sadar
        return null;
      }

      // 2. Ambil token autentikasi dari Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Validasi token untuk mencegah Null check operator error
      if (googleAuth.idToken == null && googleAuth.accessToken == null) {
        throw FirebaseAuthException(
          code: 'missing-google-token',
          message: 'Token otorisasi Google tidak ditemukan. Periksa konfigurasi SHA-1 di Firebase Console.',
        );
      }

      // 3. Buat kredensial Firebase Auth
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Masuk ke Firebase dengan kredensial tersebut
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      debugPrint('Error signInWithGoogle: $e');
      rethrow;
    }
  }

  // ─── SIGN OUT ───
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      debugPrint('Error signOut: $e');
    }
  }
}
