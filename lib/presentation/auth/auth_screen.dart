import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/habit_provider.dart';

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
  final _phoneController = TextEditingController(text: '+62 813-1234-5534');
  final _passwordController = TextEditingController(text: '12345678');

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isRegister = widget.isRegisterInitial;
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

  void _handleSubmit() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      if (_isRegister && _nameController.text.trim().isNotEmpty) {
        context.read<HabitProvider>().setUserName(_nameController.text.trim());
      }
      widget.onSuccess();
    }
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

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF9F8F2);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Peeking Camel Mascot at Top-Right
            Positioned(
              top: -10,
              right: -5,
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
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF2E531C),
                          size: 20,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Kembali',
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
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
                              backgroundColor: const Color(0xFF557C2B),
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
                                : Text(
                                    _isRegister ? 'Buat Akun' : 'Masuk',
                                    style: GoogleFonts.balooTammudu2(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
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

                        // Social Buttons (Google & Facebook)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSocialButton(
                              isGoogle: true,
                              onTap: _handleSubmit,
                            ),
                            const SizedBox(width: 16),
                            _buildSocialButton(
                              isGoogle: false,
                              onTap: _handleSubmit,
                            ),
                          ],
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
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tautan reset kata sandi telah dikirim ke email Anda.'),
                  backgroundColor: Color(0xFF557C2B),
                ),
              );
            },
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
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE2E4D5),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              // Indonesia Flag and Down Arrow
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 6),
                child: Row(
                  children: [
                    // Mini Indonesian Flag
                    Container(
                      width: 22,
                      height: 15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: Colors.black12, width: 0.5),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          Expanded(child: Container(color: const Color(0xFFFF0000))),
                          Expanded(child: Container(color: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF5E6B52),
                      size: 18,
                    ),
                  ],
                ),
              ),

              // Vertical divider
              Container(
                width: 1,
                height: 24,
                color: const Color(0xFFE2E4D5),
                margin: const EdgeInsets.only(right: 12),
              ),

              // Phone Number Field
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2D3C21),
                  ),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 13),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required bool isGoogle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Color(0xFF557C2B),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: isGoogle
            ? Text(
                'G',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              )
            : Text(
                'f',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
