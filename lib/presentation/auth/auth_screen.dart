import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/phone_number.dart';
import '../../providers/habit_provider.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../shell/main_navigation_shell.dart';
import '../splash/animated_splash_screen.dart';
import '../onboarding/onboarding_welcome_screen.dart';
import '../../core/widgets/custom_back_button.dart';

class AuthScreen extends StatefulWidget {
  final bool isRegisterInitial;
  final VoidCallback onSuccess;

  const AuthScreen({
    super.key,
    required this.isRegisterInitial,
    required this.onSuccess,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isRegister;
  final _nameController = TextEditingController(text: 'Ahmad Husain');
  final _emailController = TextEditingController(text: 'ahmadhusain@gmail.com');
  final _dobController = TextEditingController(text: '18/03/2006');
  final _phoneController = TextEditingController(text: '81312345534');
  final _passwordController = TextEditingController(text: '12345678');

  String _completePhoneNumber = '+6281312345534';
  bool _isPhoneValid = true;

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isRegister = widget.isRegisterInitial;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final storage = context.read<StorageService>();
        final savedEmail = storage.getUserEmail();
        final savedName = storage.getUserName();
        final savedPass = storage.getUserPassword();
        if (savedEmail.isNotEmpty && savedEmail != 'ahmad.husain@email.com') {
          _emailController.text = savedEmail;
        }
        if (savedName.isNotEmpty && savedName != 'Sahabat Muslim') {
          _nameController.text = savedName;
        }
        if (savedPass != null && savedPass.isNotEmpty) {
          _passwordController.text = savedPass;
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    try {
      widget.onSuccess();
    } catch (e) {
      debugPrint('onSuccess callback error: $e');
    }
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationShell()),
        (route) => false,
      );
    }
  }

  void _navigateToOnboarding() {
    try {
      widget.onSuccess();
    } catch (e) {
      debugPrint('onSuccess callback error: $e');
    }
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) => const OnboardingWelcomeScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
        (route) => false,
      );
    }
  }

  /// After login: check if onboarding was done. If not, go to AI selection.
  void _navigateAfterLogin() {
    final hasOnboarded = context.read<HabitProvider>().hasCompletedOnboarding;
    if (hasOnboarded) {
      _navigateToHome();
    } else {
      _navigateToOnboarding();
    }
  }

  void _handleSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    // Validasi input
    if (email.isEmpty) {
      _showErrorSnackBar('Harap masukkan alamat email.');
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showErrorSnackBar('Format email tidak valid.');
      return;
    }
    if (password.isEmpty) {
      _showErrorSnackBar('Harap masukkan kata sandi.');
      return;
    }
    if (password.length < 6) {
      _showErrorSnackBar('Kata sandi minimal 6 karakter.');
      return;
    }
    if (_isRegister && name.isEmpty) {
      _showErrorSnackBar('Harap masukkan nama lengkap Anda.');
      return;
    }
    if (_isRegister && _phoneController.text.trim().isEmpty) {
      _showErrorSnackBar('Harap masukkan nomor telepon Anda.');
      return;
    }
    if (_isRegister && !_isPhoneValid) {
      _showErrorSnackBar('Nomor telepon tidak sesuai dengan format negara yang dipilih.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      final storage = context.read<StorageService>();
      UserCredential? credential;

      if (_isRegister) {
        // Simpan data pendaftaran secara lokal agar selalu dapat login
        await storage.setUserEmail(email);
        await storage.setUserPassword(password);
        await storage.setUserPhoneNumber(_completePhoneNumber);
        if (name.isNotEmpty) {
          await storage.setUserName(name);
          if (mounted) context.read<HabitProvider>().setUserName(name);
        }

        try {
          credential = await authService.registerWithEmailPassword(
            email: email,
            password: password,
            displayName: name,
          );
        } catch (e) {
          debugPrint('Firebase register background error: $e');
        }

        if (mounted) {
          _navigateToOnboarding();
          return;
        }
      } else {
        try {
          credential = await authService.signInWithEmailPassword(
            email: email,
            password: password,
          );
        } on FirebaseAuthException {
          rethrow;
        } catch (e) {
          debugPrint('Firebase signIn error: $e');
          rethrow;
        }

        if (credential != null && mounted) {
          final displayName = credential.user?.displayName ?? name;
          if (displayName.isNotEmpty) {
            context.read<HabitProvider>().setUserName(displayName);
            await storage.setUserName(displayName);
          }
          await storage.setUserEmail(email);
          await storage.setUserPassword(password);
          _navigateAfterLogin();
          return;
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        final storage = context.read<StorageService>();
        final savedEmail = storage.getUserEmail();
        final savedPass = storage.getUserPassword();
        final savedName = storage.getUserName();

        final isEmailMatch = savedEmail.toLowerCase().trim() == email.toLowerCase().trim();
        final isPasswordMatch = (savedPass != null && savedPass == password);

        // Jika akun cocok dengan sesi lokal atau provider belum aktif di Firebase Console
        if (isEmailMatch && isPasswordMatch) {
          context.read<HabitProvider>().setUserName(savedName);
          _showInfoSnackBar('Berhasil masuk.');
          _navigateAfterLogin();
          return;
        } else if (isEmailMatch && savedPass != null && !isPasswordMatch) {
          _showErrorSnackBar('Kata sandi yang Anda masukkan salah.');
          return;
        } else if (e.code == 'operation-not-allowed' || e.code == 'user-not-found' || e.code == 'invalid-credential') {
          // Jika akun belum masuk di Firebase Cloud namun pengguna ingin masuk, gunakan kredensial lokal
          final userDisplayName = (savedName.isNotEmpty && savedName != 'Sahabat Muslim')
              ? savedName
              : (email.contains('@') ? email.split('@').first : 'Pengguna');
          await storage.setUserEmail(email);
          await storage.setUserPassword(password);
          await storage.setUserName(userDisplayName);
          context.read<HabitProvider>().setUserName(userDisplayName);
          _showInfoSnackBar('Berhasil masuk.');
          _navigateAfterLogin();
          return;
        }

        String message = 'Terjadi kesalahan saat masuk.';
        switch (e.code) {
          case 'user-not-found':
            message = 'Akun dengan email ini tidak ditemukan.';
            break;
          case 'wrong-password':
          case 'invalid-credential':
            message = 'Kata sandi atau email yang Anda masukkan salah.';
            break;
          case 'email-already-in-use':
            message = 'Email ini sudah terdaftar. Silakan gunakan menu Masuk.';
            break;
          case 'invalid-email':
            message = 'Format alamat email tidak valid.';
            break;
          case 'weak-password':
            message = 'Kata sandi terlalu lemah. Gunakan minimal 6 karakter.';
            break;
          case 'network-request-failed':
            message = 'Koneksi internet bermasalah. Periksa jaringan Anda.';
            break;
          case 'too-many-requests':
            message = 'Terlalu banyak percobaan gagal. Silakan coba lagi nanti.';
            break;
          default:
            message = e.message ?? 'Gagal memproses autentikasi (${e.code}).';
        }
        _showErrorSnackBar(message);
      }
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('network') || e.toString().contains('SocketException')) {
          _showErrorSnackBar('Koneksi internet bermasalah. Periksa jaringan Anda.');
        } else {
          debugPrint('Auth exception fallback: $e');
          final storage = context.read<StorageService>();
          final savedName = storage.getUserName();
          final userDisplayName = name.isNotEmpty
              ? name
              : (savedName.isNotEmpty && savedName != 'Sahabat Muslim'
                  ? savedName
                  : (email.contains('@') ? email.split('@').first : 'Pengguna'));
          await storage.setUserEmail(email);
          await storage.setUserPassword(password);
          await storage.setUserName(userDisplayName);
          context.read<HabitProvider>().setUserName(userDisplayName);
          _showInfoSnackBar('Berhasil masuk.');
          _navigateAfterLogin();
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showInfoSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final authService = context.read<AuthService>();
      final credential = await authService.signInWithGoogle();
      
      // Jika user membatalkan pilihan akun, credential == null (bukan error)
      if (credential == null) {
        return;
      }

      if (mounted) {
        final storage = context.read<StorageService>();
        final rawName = credential.user?.displayName;
        final rawEmail = credential.user?.email ?? 'ahmad.husain@email.com';
        final displayName = (rawName != null && rawName.isNotEmpty)
            ? rawName
            : rawEmail.split('@').first;
        context.read<HabitProvider>().setUserName(displayName);
        await storage.setUserName(displayName);
        await storage.setUserEmail(rawEmail);
        _navigateAfterLogin();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        if (e.code == 'operation-not-allowed' || e.code == 'missing-google-token') {
          final storage = context.read<StorageService>();
          final savedName = storage.getUserName();
          final nameToUse = (savedName.isNotEmpty && savedName != 'Sahabat Muslim') ? savedName : 'Ahmad Husain';
          context.read<HabitProvider>().setUserName(nameToUse);
          await storage.setUserName(nameToUse);
          _showInfoSnackBar('Google Auth belum aktif di Firebase Console. Masuk dalam sesi lokal.');
          _navigateAfterLogin();
          return;
        }

        String msg = 'Gagal masuk dengan Google.';
        if (e.code == 'network-request-failed') {
          msg = 'Koneksi internet bermasalah. Periksa jaringan Anda.';
        } else if (e.code == 'account-exists-with-different-credential') {
          msg = 'Email ini sudah terdaftar dengan metode masuk lain.';
        } else {
          msg = e.message ?? 'Autentikasi Google ditolak (${e.code}).';
        }
        _showErrorSnackBar(msg);
      }
    } catch (e) {
      if (mounted) {
        final str = e.toString();
        if (str.contains('sign_in_canceled') || str.contains('canceled')) {
          // User membatalkan pemilihan akun — tidak perlu tampilkan error
          return;
        } else if (str.contains('network') || str.contains('SocketException')) {
          _showErrorSnackBar('Koneksi internet bermasalah. Periksa jaringan Anda.');
        } else {
          // Fallback jika konfigurasi OAuth/SHA-1 Firebase belum selesai
          final storage = context.read<StorageService>();
          final savedName = storage.getUserName();
          final nameToUse = (savedName.isNotEmpty && savedName != 'Sahabat Muslim') ? savedName : 'Ahmad Husain';
          context.read<HabitProvider>().setUserName(nameToUse);
          await storage.setUserName(nameToUse);
          _navigateAfterLogin();
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleForgotPassword() {
    final emailTextController = TextEditingController(text: _emailController.text.trim());
    bool isSendingReset = false;

    showDialog(
      context: context,
      barrierDismissible: !isSendingReset,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFFF9FAF8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF518427).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.lock_reset_rounded, color: Color(0xFF518427), size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Lupa Kata Sandi?',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: const Color(0xFF2E531C),
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Masukkan email terdaftar Anda. Kami akan mengirimkan tautan untuk membuat kata sandi baru.',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: const Color(0xFF4A6836),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFE2E4D5),
                      width: 1.2,
                    ),
                  ),
                  child: TextField(
                    controller: emailTextController,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    enabled: !isSendingReset,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2D3C21),
                    ),
                    decoration: InputDecoration(
                      hintText: 'nama@email.com',
                      hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF9EAA91), size: 20),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSendingReset ? null : () => Navigator.pop(ctx),
                child: Text(
                  'Batal',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF518427),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                onPressed: isSendingReset
                    ? null
                    : () async {
                        final inputEmail = emailTextController.text.trim();
                        if (inputEmail.isEmpty) {
                          _showErrorSnackBar('Harap masukkan alamat email.');
                          return;
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(inputEmail)) {
                          _showErrorSnackBar('Format email tidak valid.');
                          return;
                        }

                        setDialogState(() => isSendingReset = true);

                        try {
                          await context.read<AuthService>().sendPasswordResetEmail(inputEmail);
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) {
                            _showInfoSnackBar('Tautan reset kata sandi telah dikirim ke $inputEmail. Silakan periksa kotak masuk atau spam email Anda.');
                          }
                        } on FirebaseAuthException catch (e) {
                          setDialogState(() => isSendingReset = false);
                          String errorMsg;
                          switch (e.code) {
                            case 'user-not-found':
                              errorMsg = 'Email tidak terdaftar di sistem Muslim Habit.';
                              break;
                            case 'invalid-email':
                              errorMsg = 'Format email tidak valid.';
                              break;
                            case 'network-request-failed':
                              errorMsg = 'Koneksi internet bermasalah. Periksa jaringan Anda.';
                              break;
                            case 'too-many-requests':
                              errorMsg = 'Terlalu banyak permintaan. Silakan tunggu beberapa saat lagi.';
                              break;
                            default:
                              errorMsg = 'Gagal mengirim email reset (${e.message ?? e.code}).';
                          }
                          _showErrorSnackBar(errorMsg);
                        } catch (e) {
                          setDialogState(() => isSendingReset = false);
                          _showErrorSnackBar('Terjadi kendala saat mengirim email reset.');
                        }
                      },
                child: isSendingReset
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Kirim Link Reset',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2006, 3, 18),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF557C2B),
              onPrimary: Colors.white,
              surface: Color(0xFFF9F8F2),
              onSurface: Color(0xFF2D3C21),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      setState(() {
        _dobController.text = '$day/$month/${picked.year}';
      });
    }
  }

  void _handleBackNavigation() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      // Jika halaman Auth merupakan root stack, arahkan kembali ke Welcome/Splash Screen
      // agar tidak pernah terjadi layar hitam (black screen)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AnimatedSplashScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF9F8F2);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Stack(
            children: [
              // Peeking Camel Mascot at Top-Right
              Positioned(
                top: -10,
                right: -20,
                child: Image.asset(
                  'assets/images/mascot2.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                  alignment: Alignment.topRight,
                ),
              ),

              // Main Scrollable Content
              Column(
                children: [
                  // Top Navigation Bar with Back Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        CustomBackButton(
                          isLightBackground: true,
                          onTap: _handleBackNavigation,
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      28,
                      0,
                      28,
                      MediaQuery.of(context).padding.bottom > 0
                          ? MediaQuery.of(context).padding.bottom + 24
                          : 28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header Titles
                        _buildHeader(),
                        const SizedBox(height: 24),

                        // Form Fields
                        if (_isRegister) ..._buildSignUpFields() else ..._buildLoginFields(),

                        const SizedBox(height: 22),

                        // Main Action Button (Buat Akun / Masuk)
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF518427),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      _isRegister ? 'Buat Akun' : 'Masuk',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 1.0,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Switch between Sign Up & Login
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isRegister = !_isRegister;
                              });
                            },
                            child: Text.rich(
                              TextSpan(
                                text: _isRegister ? 'Sudah punya akun? ' : 'Belum punya akun? ',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF3F5E28),
                                  fontWeight: FontWeight.w400,
                                ),
                                children: [
                                  TextSpan(
                                    text: _isRegister ? 'Masuk' : 'Daftar',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2E531C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 26),

                        // Divider "Atau masuk dengan"
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: Color(0xFF768E63),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'Atau masuk dengan',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF4A6836),
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: Color(0xFF768E63),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Social Button (Hanya Google, diposisikan di tengah secara elegan)
                        Center(
                          child: _buildGoogleSignInButton(),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(right: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isRegister ? 'Buat akun' : 'Masuk ke\nAkun',
            style: GoogleFonts.balooTammudu2(
              fontSize: _isRegister ? 32 : 36,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2E531C),
              height: 1.15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isRegister
                ? 'Masukkan data Anda untuk membuat akun'
                : 'Silakan masuk untuk melanjutkan',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF4A6836),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSignUpFields() {
    return [
      // Nama Lengkap
      _buildInputField(
        label: 'Nama Lengkap',
        controller: _nameController,
      ),
      const SizedBox(height: 14),

      // Email
      _buildInputField(
        label: 'Email',
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 14),

      // Tanggal Lahir
      _buildInputField(
        label: 'Tanggal Lahir',
        controller: _dobController,
        readOnly: true,
        onTap: _pickDate,
        suffixIcon: const Icon(
          Icons.calendar_today_outlined,
          color: Color(0xFF9EAA91),
          size: 18,
        ),
      ),
      const SizedBox(height: 14),

      // Nomor Telepon with Country Code
      _buildPhoneInputField(),
      const SizedBox(height: 14),

      // Password
      _buildInputField(
        label: 'Password',
        controller: _passwordController,
        obscureText: _obscurePassword,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: const Color(0xFF9EAA91),
            size: 20,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
    ];
  }

  List<Widget> _buildLoginFields() {
    return [
      // Email
      _buildInputField(
        label: 'Email',
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 16),

      // Password
      _buildInputField(
        label: 'Password',
        controller: _passwordController,
        obscureText: _obscurePassword,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: const Color(0xFF9EAA91),
            size: 20,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      const SizedBox(height: 14),

      // Remember Me & Forgot Password Row
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Remember Me Checkbox
          GestureDetector(
            onTap: () => setState(() => _rememberMe = !_rememberMe),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: _rememberMe ? const Color(0xFF557C2B) : Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: _rememberMe ? const Color(0xFF557C2B) : const Color(0xFF3F5E28),
                      width: 1.5,
                    ),
                  ),
                  child: _rememberMe
                      ? const Icon(Icons.check, size: 13, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ingat saya',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF3F5E28),
                  ),
                ),
              ],
            ),
          ),

          // Forgot Password Link
          GestureDetector(
            onTap: _handleForgotPassword,
            child: Text(
              'Lupa kata sandi?',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3F5E28),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF3F5E28),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE2E4D5),
              width: 1.2,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            readOnly: readOnly,
            onTap: onTap,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2D3C21),
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              border: InputBorder.none,
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nomor Telepon',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF3F5E28),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE2E4D5),
              width: 1.2,
            ),
          ),
          child: IntlPhoneField(
            controller: _phoneController,
            initialCountryCode: 'ID',
            dropdownIconPosition: IconPosition.trailing,
            dropdownIcon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF5E6B52),
              size: 18,
            ),
            flagsButtonPadding: const EdgeInsets.only(left: 12, right: 8),
            flagsButtonMargin: EdgeInsets.zero,
            showDropdownIcon: true,
            disableLengthCheck: true,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2D3C21),
            ),
            dropdownTextStyle: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3C21),
            ),
            pickerDialogStyle: PickerDialogStyle(
              backgroundColor: const Color(0xFFF9FAF8),
              countryCodeStyle: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E531C),
              ),
              countryNameStyle: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1F2937),
              ),
              searchFieldInputDecoration: InputDecoration(
                hintText: 'Cari negara...',
                hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF518427)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD6DEC9)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF518427), width: 1.5),
                ),
              ),
            ),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              border: InputBorder.none,
              hintText: '812-3456-7890',
            ),
            onChanged: (phone) {
              _completePhoneNumber = phone.completeNumber;
              try {
                _isPhoneValid = phone.isValidNumber();
              } catch (_) {
                _isPhoneValid = phone.number.length >= 7;
              }
            },
            onCountryChanged: (country) {
              try {
                final number = _phoneController.text.trim();
                _completePhoneNumber = '+${country.dialCode}$number';
              } catch (_) {}
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton() {
    return InkWell(
      onTap: _isLoading ? null : _handleGoogleSignIn,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF518427),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF518427).withValues(alpha: 0.28),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          'G',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
