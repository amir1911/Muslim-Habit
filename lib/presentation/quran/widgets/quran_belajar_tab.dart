import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/surah_item.dart';
import '../../../providers/quran_provider.dart';
import '../../../providers/tilawah_provider.dart';
import '../../tilawah/tilawah_screen.dart';
import '../pendeteksi_bacaan_screen.dart';
import '../surah_detail_screen.dart';

class QuranBelajarTab extends StatelessWidget {
  const QuranBelajarTab({super.key});

  @override
  Widget build(BuildContext context) {
    final quranProv = context.watch<QuranProvider>();
    final tilawahProv = context.watch<TilawahProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── 1. TERAKHIR DIBACA CARD ──
        _buildTerakhirDibacaCard(context, quranProv),
        const SizedBox(height: 16),

        // ── 2. TIGA ACTION CARDS (Pedeteksi, Khataman, Hapalan) ──
        _buildActionCard(
          context: context,
          icon: Icons.menu_book_rounded,
          title: "Pedeteksi Baca Al-Qur'an",
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PendeteksiBacaanScreen()),
          ),
        ),
        const SizedBox(height: 12),

        _buildActionCard(
          context: context,
          icon: Icons.track_changes_rounded,
          title: "Mode Khataman",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TilawahScreen()),
            );
          },
        ),
        const SizedBox(height: 12),

        _buildActionCard(
          context: context,
          icon: Icons.psychology_rounded,
          title: "Mode Hapalan",
          onTap: () => _showModeHapalanModal(context),
        ),
        const SizedBox(height: 24),

        // ── 3. RINGKASAN PROGRES ──
        Text(
          'Ringkasan Progres',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E3710),
          ),
        ),
        const SizedBox(height: 12),

        // ── 4. PROGRES KHATAM CARD ──
        _buildProgresKhatamCard(context, tilawahProv),
        const SizedBox(height: 16),

        // ── 5. AYAT HARI INI CARD ──
        _buildAyatHariIniCard(context, quranProv),
        const SizedBox(height: 30),
      ],
    );
  }

  // ────────────── 1. TERAKHIR DIBACA CARD ──────────────
  Widget _buildTerakhirDibacaCard(BuildContext context, QuranProvider quranProv) {
    final surahName = quranProv.recentSurahName.isNotEmpty
        ? quranProv.recentSurahName
        : 'Al-Baqarah';
    final ayahNum = quranProv.recentAyahNumber;
    final surahNum = quranProv.recentSurahNumber;
    final juzNum = ((ayahNum - 1) ~/ 20 + 1).clamp(1, 30);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EEE0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Watermark / open book icon di kanan
          Positioned(
            right: 4,
            top: 6,
            bottom: 6,
            child: Icon(
              Icons.menu_book_rounded,
              size: 80,
              color: const Color(0xFFD6DEC7).withValues(alpha: 0.45),
            ),
          ),

          // Konten Kiri
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.history_rounded,
                    size: 19,
                    color: Color(0xFF8A997D),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Terakhir Dibaca',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF8A997D),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                surahName,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E3710),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Ayat $ayahNum • Juz $juzNum',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF8A997D),
                ),
              ),
              const SizedBox(height: 16),

              // Tombol Hijau ▶ Lanjutkan
              GestureDetector(
                onTap: () {
                  final surahItem = quranProv.surahList.firstWhere(
                    (s) => s.number == surahNum,
                    orElse: () => SurahItem(
                      number: surahNum,
                      nameLatin: surahName,
                      nameArabic: '',
                      nameId: surahName,
                      translation: '',
                      numberOfAyahs: 286,
                      revelation: 'Madaniyah',
                    ),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SurahDetailScreen(
                        surah: surahItem,
                        initialAyah: ayahNum,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF557C2B),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF557C2B).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Lanjutkan',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ────────────── 2. TIGA ACTION CARD ──────────────
  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EEE0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: const Color(0xFF557C2B),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E3710),
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Color(0xFF1E3710),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ────────────── 4. PROGRES KHATAM CARD ──────────────
  Widget _buildProgresKhatamCard(BuildContext context, TilawahProvider tilawahProv) {
    final currentJuz = tilawahProv.currentJuz > 0 ? tilawahProv.currentJuz : 2;
    final progress = (currentJuz / 30.0).clamp(0.0, 1.0);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TilawahScreen()),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE8EEE0), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progres Khatam',
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E3710),
                  ),
                ),
                Text(
                  '$currentJuz/30 Juz',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E3710),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFFE4E9DC),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF557C2B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────── 5. AYAT HARI INI CARD ──────────────
  Widget _buildAyatHariIniCard(BuildContext context, QuranProvider quranProv) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8EEE0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ayat hari ini',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3710),
            ),
          ),
          const SizedBox(height: 16),

          // Teks Arab di tengah persis seperti screenshot
          Center(
            child: Text(
              'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E3710),
                height: 1.8,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Terjemahan
          Text(
            '"Sesungguhnya bersama kesulitan ada kemudahan."',
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2C3E1F),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),

          // Referensi Surah & Ayat
          Text(
            'QS. ASH-SHARH: 6',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF8A997D),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }


  // ────────────── MODAL MODE HAPALAN ──────────────
  void _showModeHapalanModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return const _ModeHapalanSheet();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// MODAL SHEET: Pedeteksi Baca Al-Qur'an (AI Voice Analyzer)
// ─────────────────────────────────────────────────────────────
class _PedeteksiBacaanSheet extends StatefulWidget {
  const _PedeteksiBacaanSheet();

  @override
  State<_PedeteksiBacaanSheet> createState() => _PedeteksiBacaanSheetState();
}

class _PedeteksiBacaanSheetState extends State<_PedeteksiBacaanSheet>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  bool _hasResult = false;
  late AnimationController _animCtrl;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
      if (_isListening) {
        _hasResult = false;
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _isListening) {
            setState(() {
              _isListening = false;
              _hasResult = true;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        color: Color(0xFFF9F8F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF557C2B).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mic_rounded, color: Color(0xFF557C2B), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pedeteksi Baca Al-Qur'an",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E3710),
                      ),
                    ),
                    Text(
                      'AI Penguji Makhraj & Ketepatan Bacaan',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF7A8B6E),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Ayat Latihan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8EEE0)),
            ),
            child: Column(
              children: [
                Text(
                  'Ayat yang diuji: QS. Al-Ikhlas: 1',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF7A8B6E),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'قُلْ هُوَ اللَّهُ أَحَدٌ',
                  style: GoogleFonts.amiri(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E3710),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '"Katakanlah: Dialah Allah, Yang Maha Esa."',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Tombol Mic & Visualizer
          GestureDetector(
            onTap: _toggleListening,
            child: AnimatedBuilder(
              animation: _animCtrl,
              builder: (ctx, child) {
                final scale = _isListening ? 1.0 + (_animCtrl.value * 0.15) : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: _isListening ? const Color(0xFFE65100) : const Color(0xFF557C2B),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? const Color(0xFFE65100) : const Color(0xFF557C2B))
                              .withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _isListening
                ? 'Mendengarkan bacaan Anda...'
                : 'Tekan mikrofon & bacakan ayat di atas',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _isListening ? const Color(0xFFE65100) : const Color(0xFF557C2B),
            ),
          ),

          if (_hasResult) ...[
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8E9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFC5E1A5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF557C2B), size: 26),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Makhraj & Tajwid: Sangat Baik (96%)',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E3710),
                          ),
                        ),
                        Text(
                          'Pelafalan huruf Qaf dan Ha sudah tepat & fasih.',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            color: const Color(0xFF42562E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// MODAL SHEET: Mode Hapalan (Quran Memorization Trainer)
// ─────────────────────────────────────────────────────────────
class _ModeHapalanSheet extends StatefulWidget {
  const _ModeHapalanSheet();

  @override
  State<_ModeHapalanSheet> createState() => _ModeHapalanSheetState();
}

class _ModeHapalanSheetState extends State<_ModeHapalanSheet> {
  bool _blurAyah = false;
  int _repeatCount = 3;
  int _activeSurahIndex = 0;

  final List<Map<String, String>> _hafalanList = [
    {
      'surah': 'An-Nas',
      'ayah': 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
      'latin': 'Qul a\'udzu birabbin-naas',
      'arti': 'Katakanlah: Aku berlindung kepada Tuhannya manusia',
    },
    {
      'surah': 'Al-Falaq',
      'ayah': 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
      'latin': 'Qul a\'udzu birabbil-falaq',
      'arti': 'Katakanlah: Aku berlindung kepada Tuhan yang menguasai subuh',
    },
    {
      'surah': 'Al-Ikhlas',
      'ayah': 'قُلْ هُوَ اللَّهُ أَحَدٌ',
      'latin': 'Qul huwallahu ahad',
      'arti': 'Katakanlah: Dialah Allah, Yang Maha Esa',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final current = _hafalanList[_activeSurahIndex];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Color(0xFFF9F8F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF557C2B).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology_rounded, color: Color(0xFF557C2B), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mode Hapalan',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E3710),
                      ),
                    ),
                    Text(
                      'Latih & Uji Ingatan Ayat Al-Qur\'an',
                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF7A8B6E)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pilihan Surat
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _hafalanList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, i) {
                final isSel = _activeSurahIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => _activeSurahIndex = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFF557C2B) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSel ? const Color(0xFF557C2B) : const Color(0xFFE8EEE0),
                      ),
                    ),
                    child: Text(
                      _hafalanList[i]['surah']!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSel ? Colors.white : const Color(0xFF1E3710),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Kartu Uji Hapalan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE8EEE0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'QS. ${current['surah']} : Ayat 1',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF7A8B6E),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _blurAyah = !_blurAyah),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _blurAyah ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                            size: 16,
                            color: const Color(0xFF557C2B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _blurAyah ? 'Buka Teks' : 'Sembunyikan',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF557C2B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Teks Arab dengan efek sembunyi/blur
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: _blurAyah ? 0.08 : 1.0,
                  child: Text(
                    current['ayah']!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amiri(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E3710),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _blurAyah ? 'Bacakan hafalan Anda dari ingatan...' : current['arti']!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontStyle: _blurAyah ? FontStyle.italic : FontStyle.normal,
                    color: _blurAyah ? const Color(0xFF557C2B) : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tools Pengulangan & Tes
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE8EEE0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ulangi:',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      DropdownButton<int>(
                        value: _repeatCount,
                        underline: const SizedBox(),
                        isDense: true,
                        items: [3, 5, 7, 10].map((c) {
                          return DropdownMenuItem(
                            value: c,
                            child: Text('$c x', style: GoogleFonts.inter(fontSize: 12)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _repeatCount = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF557C2B),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Alhamdulillah! Catatan hafalan ayat tersimpan.'),
                        backgroundColor: Color(0xFF557C2B),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
                  label: Text(
                    'Sudah Hafal',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
