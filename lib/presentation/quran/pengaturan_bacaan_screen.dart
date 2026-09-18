import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pembaca_narator_screen.dart';

class PengaturanBacaanScreen extends StatefulWidget {
  const PengaturanBacaanScreen({super.key});

  @override
  State<PengaturanBacaanScreen> createState() => _PengaturanBacaanScreenState();
}

class _PengaturanBacaanScreenState extends State<PengaturanBacaanScreen> {
  int _tabIndex = 2; // Default tab Audio (index 2)

  // Settings state
  bool _qariEnabled = true;
  bool _terjemahanEnabled = false;
  bool _autoScroll = true;
  final String _selectedQari = 'Ali al Hudhaify';
  final String _selectedNarrator = 'Kemenag Edisi Revisi 2002';

  // Tampilan settings
  bool _showArabic = true;
  bool _showLatin = true;
  bool _showTranslation = true;
  double _arabicFontSize = 26;

  // Teks settings
  bool _showTafsir = false;
  bool _showWordByWord = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A7023),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pengaturan',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── Tab Selector ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Container(
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E7D8),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  _buildTab(0, 'Tampilan'),
                  _buildTab(1, 'Teks'),
                  _buildTab(2, 'Audio'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Tab Content ──
          Expanded(
            child: _tabIndex == 0
                ? _buildTampilanTab()
                : _tabIndex == 1
                    ? _buildTeksTab()
                    : _buildAudioTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF4A7023) : const Color(0xFF42562E),
            ),
          ),
        ),
      ),
    );
  }

  // ── TAMPILAN TAB ──────────────────────────────────────────
  Widget _buildTampilanTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        _buildSectionLabel('TEKS YANG DITAMPILKAN'),
        _buildToggleTile('Tampilkan Teks Arab', _showArabic, (val) => setState(() => _showArabic = val)),
        _buildToggleTile('Tampilkan Transliterasi Latin', _showLatin, (val) => setState(() => _showLatin = val)),
        _buildToggleTile('Tampilkan Terjemahan', _showTranslation, (val) => setState(() => _showTranslation = val)),

        const SizedBox(height: 16),
        _buildSectionLabel('UKURAN TEKS ARAB'),
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8EEE0)),
          ),
          child: Column(
            children: [
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                style: GoogleFonts.amiri(
                  fontSize: _arabicFontSize,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E3710),
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.text_decrease_rounded, size: 18, color: Color(0xFF4A7023)),
                  Expanded(
                    child: Slider(
                      value: _arabicFontSize,
                      min: 16,
                      max: 40,
                      divisions: 6,
                      activeColor: const Color(0xFF4A7023),
                      onChanged: (val) => setState(() => _arabicFontSize = val),
                    ),
                  ),
                  const Icon(Icons.text_increase_rounded, size: 18, color: Color(0xFF4A7023)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── TEKS TAB ────────────────────────────────────────────────
  Widget _buildTeksTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        _buildSectionLabel('FITUR TEKS TAMBAHAN'),
        _buildToggleTile('Tampilkan Tafsir Singkat', _showTafsir, (val) => setState(() => _showTafsir = val)),
        _buildToggleTile('Tampilkan Terjemahan per Kata', _showWordByWord, (val) => setState(() => _showWordByWord = val)),

        const SizedBox(height: 16),
        _buildSectionLabel('MODA BACA'),
        _buildNavTile('Penanda Tajwid', 'Warnai huruf sesuai aturan tajwid'),
        _buildNavTile('Moda Malam', 'Tampilan gelap untuk bacaan malam'),
      ],
    );
  }

  // ── AUDIO TAB ────────────────────────────────────────────────
  Widget _buildAudioTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        // Qori Al Quran
        _buildSectionLabel('QORI AL QUR\'AN'),
        _buildToggleTile('Aktifkan', _qariEnabled, (val) => setState(() => _qariEnabled = val)),
        if (_qariEnabled) ...[
          _buildNavTile(
            'Pembaca atau narator terpilih',
            _selectedQari,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PembacanNaratorScreen()),
            ).then((_) {
              // Refresh jika kembali
              setState(() {});
            }),
          ),
        ],
        const SizedBox(height: 16),

        // Qori Terjemahan
        _buildSectionLabel('QARI TERJEMAHAN AL-QURAN'),
        _buildToggleTile(
          'Mengaktifkan pembaca terjemahan',
          _terjemahanEnabled,
          (val) => setState(() => _terjemahanEnabled = val),
        ),
        if (_terjemahanEnabled) ...[
          _buildNavTile(
            'Pembaca yang dipilih',
            '🇮🇩 $_selectedNarrator',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PembacanNaratorScreen()),
            ),
          ),
        ],
        const SizedBox(height: 16),

        // Kontrol Pemutaran
        _buildSectionLabel('KONTROL PEMUTARAN'),
        _buildToggleTile('Aktifkan gulir otomatis', _autoScroll, (val) => setState(() => _autoScroll = val)),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: Colors.grey[500],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildToggleTile(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EEE0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E3710),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF4A7023),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile(String label, String subtitle, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8EEE0)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E3710),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
