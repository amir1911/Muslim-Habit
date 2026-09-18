import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PembacanNaratorScreen extends StatefulWidget {
  const PembacanNaratorScreen({super.key});

  @override
  State<PembacanNaratorScreen> createState() => _PembacanNaratorScreenState();
}

class _PembacanNaratorScreenState extends State<PembacanNaratorScreen> {
  int _tabIndex = 0; // 0: Qari, 1: Narrator
  final Set<int> _downloadedIndices = {};

  final _qariList = const [
    _QariItem(
      name: 'Saad Al-Ghamdi',
      language: 'Arabic',
      identifier: 'ar.saad.alghamdi',
      avatar: '🧔',
    ),
    _QariItem(
      name: 'Ali al Hudhaify',
      language: 'Arabic',
      identifier: 'ar.hudhaify',
      avatar: '👳',
    ),
    _QariItem(
      name: 'Abdul Rahman As Sudais',
      language: 'Arabic',
      identifier: 'ar.abdurrahmansudais',
      avatar: '🧔',
    ),
    _QariItem(
      name: 'Sheikh Bander Baleelah',
      language: 'Arabic',
      identifier: 'ar.bandar.baleelah',
      avatar: '👳',
    ),
    _QariItem(
      name: 'Abdul Basit Abdus Samad',
      language: 'Arabic',
      identifier: 'ar.abdulbasitmurattal',
      avatar: '🧔',
    ),
    _QariItem(
      name: 'Mishari Rashid al-Afasy',
      language: 'Arabic',
      identifier: 'ar.alafasy',
      avatar: '👳',
    ),
  ];

  final _narratorList = const [
    _QariItem(
      name: 'Kemenag Edisi Revisi 2002',
      language: 'Indonesia',
      identifier: 'id.indonesian',
      avatar: '🇮🇩',
    ),
    _QariItem(
      name: 'Muhammad Arifin Ilham',
      language: 'Indonesia',
      identifier: 'id.indonesian',
      avatar: '🇮🇩',
    ),
    _QariItem(
      name: 'Eman Elshahat',
      language: 'English',
      identifier: 'en.asad',
      avatar: '🌍',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final list = _tabIndex == 0 ? _qariList : _narratorList;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A7023),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pembaca & Narator',
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
                  _buildTab(0, 'Qari'),
                  _buildTab(1, 'Narrator'),
                ],
              ),
            ),
          ),

          // ── Info text ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(
              'Unduh suara Qari favorit untuk didengarkan tanpa koneksi internet.',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: Colors.grey[600],
              ),
            ),
          ),

          // ── List ──
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: list.length,
              itemBuilder: (ctx, i) => _buildQariTile(i, list[i]),
            ),
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
              fontSize: 13.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF4A7023) : const Color(0xFF42562E),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQariTile(int index, _QariItem qari) {
    final isDownloaded = _downloadedIndices.contains(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
      child: Row(
        children: [
          // Avatar emoji dalam circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8EEE0),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(qari.avatar, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  qari.name,
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E3710),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  qari.language,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF7A8B6E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isDownloaded ? '114/114 diunduh' : '0/114 diunduh',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: isDownloaded ? const Color(0xFF4A7023) : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          // Tombol unduh
          GestureDetector(
            onTap: () {
              if (!isDownloaded) {
                _showDownloadDialog(index, qari.name);
              } else {
                setState(() => _downloadedIndices.remove(index));
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDownloaded
                    ? const Color(0xFF4A7023).withValues(alpha: 0.12)
                    : const Color(0xFFF0F4E8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDownloaded ? const Color(0xFF4A7023) : const Color(0xFFD0DCB8),
                  width: 1.5,
                ),
              ),
              child: Icon(
                isDownloaded ? Icons.check_rounded : Icons.download_rounded,
                color: const Color(0xFF4A7023),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDownloadDialog(int index, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Unduh $name', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text(
          'Fitur unduh audio offline memerlukan koneksi internet. Audio akan diputar secara streaming saat ini.',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A7023),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              setState(() => _downloadedIndices.add(index));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$name dipilih sebagai qari aktif.',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  backgroundColor: const Color(0xFF4A7023),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text('Pilih', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _QariItem {
  final String name;
  final String language;
  final String identifier;
  final String avatar;
  const _QariItem({
    required this.name,
    required this.language,
    required this.identifier,
    required this.avatar,
  });
}
