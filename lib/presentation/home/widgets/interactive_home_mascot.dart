import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/habit_provider.dart';
import '../../../features/mascot/screens/mascot_hub_screen.dart';
import '../../../features/mascot/models/costume_model.dart';
import '../../../features/mascot/providers/mascot_provider.dart';

class _MascotReaction {
  final String asset;
  final String dialog;

  const _MascotReaction({
    required this.asset,
    required this.dialog,
  });
}

/// Widget Maskot Interaktif Muslim Habit
/// Menggunakan 4 aset gambar resmi:
/// - `mascot 4.png` : Idle / Standar Ramah / Menyapa
/// - `mascot 1.png` : Tertawa / Sangat Gembira (Laughing / Excited)
/// - `mascot 2.png` : Mengunyah Daun / Semangat (Eating / Playful)
/// - `mascot 3.png` : Santai / Tidur / Istirahat Damai (Resting / Serene)
class InteractiveHomeMascot extends StatefulWidget {
  final double height;
  final VoidCallback? onOpenHub;

  const InteractiveHomeMascot({
    super.key,
    this.height = 165,
    this.onOpenHub,
  });

  @override
  State<InteractiveHomeMascot> createState() => _InteractiveHomeMascotState();
}

class _InteractiveHomeMascotState extends State<InteractiveHomeMascot>
    with TickerProviderStateMixin {
  // Path 4 Aset Maskot
  static const String assetLaugh = 'assets/images/mascot 1.png';
  static const String assetEat = 'assets/images/mascot 2.png';
  static const String assetRest = 'assets/images/mascot 3.png';
  static const String assetIdle = 'assets/images/mascot 4.png';

  // Daftar Reaksi Interaktif saat Maskot Ditekan
  static const List<_MascotReaction> _tapReactions = [
    _MascotReaction(
      asset: assetLaugh,
      dialog: 'Wah! Ha Ha Ha! Kamu lucu sekali!',
    ),
    _MascotReaction(
      asset: assetEat,
      dialog: 'YUM! Enak Banget! Apalagi Kalau Kmu Ngerjain Habbitmu!',
    ),
    _MascotReaction(
      asset: assetRest,
      dialog: 'Kamu tahu gak? Kamu Bisa Menekan Bubble Speech-ku Untuk Membuka Chatbot!',
    ),
    _MascotReaction(
      asset: assetIdle,
      dialog: 'Assalamualaikum! Senang sekali bertemu denganmu hari ini!',
    ),
    _MascotReaction(
      asset: assetLaugh,
      dialog: 'Hehehe! Kamu datang lagi! Ayo semangat beribadah!',
    ),
    _MascotReaction(
      asset: assetEat,
      dialog: 'Nyam nyam! Kalau kamu rajin tilawah, aku makin berenergi!',
    ),
    _MascotReaction(
      asset: assetRest,
      dialog: 'Rehat sejenak sambil berdzikir bikin hati jadi adem dan tenang...',
    ),
    _MascotReaction(
      asset: assetLaugh,
      dialog: 'MasyaAllah, kamu hebat dan istiqomah hari ini!',
    ),
  ];

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  Timer? _idleTimer;
  bool _isInteracting = false;
  int _reactionIndex = -1;

  late String _currentAsset;
  late String _currentDialog;

  @override
  void initState() {
    super.initState();

    // 1. Animasi Idle Breathing / Floating Halus
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -2.5, end: 2.5).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    // 2. Animasi Tap Bounce (Membesar sedikit lalu kembali)
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 50,
      ),
    ]).animate(_bounceController);

    // Inisialisasi awal
    _currentAsset = assetIdle;
    _currentDialog = 'Assalamualaikum! Senang bertemu denganmu!';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _setInitialIdle();
      }
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _bounceController.dispose();
    _idleTimer?.cancel();
    super.dispose();
  }

  void _setInitialIdle() {
    final habitProv = context.read<HabitProvider>();
    final idle = _getContextualIdle(habitProv);
    setState(() {
      _currentAsset = idle.asset;
      _currentDialog = idle.dialog;
    });
  }

  /// Menentukan ekspresi & dialog berdasarkan waktu serta data capaian pengguna
  _MascotReaction _getContextualIdle(HabitProvider habitProv) {
    final now = DateTime.now();
    final hour = now.hour;
    final completedCount = habitProv.completedHabitsCount;
    final totalCount = habitProv.totalHabitsCount;

    // 1. Jika seluruh habit hari ini sudah diselesaikan
    if (totalCount > 0 && completedCount >= totalCount) {
      return const _MascotReaction(
        asset: assetLaugh,
        dialog: 'MasyaAllah! Semua target habitmu hari ini sudah tuntas!',
      );
    }

    // 2. Berdasarkan rentang waktu hari
    if (hour >= 4 && hour < 10) {
      return const _MascotReaction(
        asset: assetIdle,
        dialog: 'Selamat pagi! Awali harimu dengan Bismillah dan sholat Subuh ya.',
      );
    } else if (hour >= 10 && hour < 15) {
      return const _MascotReaction(
        asset: assetIdle,
        dialog: 'Sudah siang nih, yuk rehat sejenak untuk sholat dan dzikir.',
      );
    } else if (hour >= 15 && hour < 18) {
      return const _MascotReaction(
        asset: assetEat,
        dialog: 'Semangat sore! Jangan lupa tuntaskan target ibadahmu hari ini.',
      );
    } else {
      // Malam hari (18:00 - 04:00)
      return const _MascotReaction(
        asset: assetRest,
        dialog: 'Malam penuh berkah. Jangan lupa doa sebelum tidur ya...',
      );
    }
  }

  /// Penanganan saat maskot disentuh
  void _handleTapMascot() {
    HapticFeedback.lightImpact();

    // Jalankan animasi bounce
    _bounceController.forward(from: 0.0);

    setState(() {
      _isInteracting = true;
      _reactionIndex = (_reactionIndex + 1) % _tapReactions.length;
      final reaction = _tapReactions[_reactionIndex];
      _currentAsset = reaction.asset;
      _currentDialog = reaction.dialog;
    });

    // Reset timer: kembali ke idle otomatis setelah 6 detik tanpa sentuhan
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _isInteracting = false;
          final habitProv = context.read<HabitProvider>();
          final idle = _getContextualIdle(habitProv);
          _currentAsset = idle.asset;
          _currentDialog = idle.dialog;
        });
      }
    });
  }

  void _handleOpenMascotHub() {
    HapticFeedback.selectionClick();
    if (widget.onOpenHub != null) {
      widget.onOpenHub!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MascotHubScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mascotProv = context.watch<MascotProvider?>();
    final activeAccessories = mascotProv?.equippedAccessories ?? [];
    final hasPeci = activeAccessories.contains('peci');
    final hasSyal = activeAccessories.contains('syal');
    final hasLonceng = activeAccessories.contains('lonceng');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 1. BALON PERCAKAPAN (SPEECH BUBBLE) ──
        GestureDetector(
          onTap: _handleOpenMascotHub,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                constraints: const BoxConstraints(maxWidth: 190),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                      child: child,
                    ),
                  ),
                  child: Text(
                    _currentDialog,
                    key: ValueKey<String>(_currentDialog),
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E350E),
                      height: 1.3,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 28),
                child: ClipPath(
                  clipper: _MascotSpeechArrowClipper(),
                  child: Container(
                    width: 12,
                    height: 8,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 2),

        // ── 2. KARAKTER MASKOT VIRTUAL INTERAKTIF ──
        GestureDetector(
          onTap: _handleTapMascot,
          onDoubleTap: _handleOpenMascotHub,
          onLongPress: _handleOpenMascotHub,
          behavior: HitTestBehavior.opaque,
          child: AnimatedBuilder(
            animation: Listenable.merge([_floatAnimation, _bounceAnimation]),
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: Transform.scale(
                  scale: _bounceAnimation.value,
                  alignment: Alignment.bottomCenter,
                  child: child,
                ),
              );
            },
            child: SizedBox(
              height: widget.height,
              child: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.92, end: 1.0).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Image.asset(
                      _currentAsset,
                      key: ValueKey<String>(_currentAsset),
                      height: widget.height,
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/mascot_standing.png',
                          height: widget.height,
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                        );
                      },
                    ),
                  ),

                  // Syal
                  if (hasSyal)
                    Positioned(
                      top: widget.height * 0.33,
                      child: SizedBox(
                        width: widget.height * 0.52,
                        height: widget.height * 0.24,
                        child: Image.asset(
                          AccessoryPaths.syal,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),

                  // Lonceng
                  if (hasLonceng)
                    Positioned(
                      top: widget.height * 0.40,
                      child: SizedBox(
                        width: widget.height * 0.26,
                        height: widget.height * 0.22,
                        child: Image.asset(
                          AccessoryPaths.lonceng,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),

                  // Peci
                  if (hasPeci)
                    Positioned(
                      top: widget.height * 0.02,
                      child: SizedBox(
                        width: widget.height * 0.36,
                        height: widget.height * 0.20,
                        child: Image.asset(
                          AccessoryPaths.peci,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MascotSpeechArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width * 0.7, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
