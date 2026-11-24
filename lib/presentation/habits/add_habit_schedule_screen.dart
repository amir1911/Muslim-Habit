import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/habit_item.dart';
import '../../providers/habit_provider.dart';

/// Halaman Tambah Jadwal Habbit (AddHabitScheduleScreen)
class AddHabitScheduleScreen extends StatefulWidget {
  const AddHabitScheduleScreen({super.key});

  @override
  State<AddHabitScheduleScreen> createState() => _AddHabitScheduleScreenState();
}

class _AddHabitScheduleScreenState extends State<AddHabitScheduleScreen> {
  // Set untuk menampung id habit baru yang sedang dicentang (Selected)
  final Set<String> _selectedHabitIds = {};

  // Daftar opsi kebiasaan sholat sunnah yang dapat ditambahkan
  final List<Map<String, dynamic>> _candidateHabits = [
    {
      'id': 'rawatib_pagi',
      'title': 'Sholat Sunnah Rawatib',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Sholat Sunnah',
      'timeSlot': 'pagi',
      'scheduledTime': '05:00 AM',
      'frequency': '1x Setiap Hari',
      'points': 20,
    },
    {
      'id': 'tahajjud',
      'title': 'Sholat Sunnah Tahajud',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Sholat Sunnah',
      'timeSlot': 'malam',
      'scheduledTime': '03:30 AM',
      'frequency': '1x Setiap Hari',
      'points': 35,
    },
    {
      'id': 'rawatib_ba_da',
      'title': 'Sholat Sunnah Rawatib',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Sholat Sunnah',
      'timeSlot': 'siang',
      'scheduledTime': '12:30 PM',
      'frequency': '1x Setiap Hari',
      'points': 20,
    },
    {
      'id': 'witir',
      'title': 'Sholat Sunnah Witir',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Sholat Sunnah',
      'timeSlot': 'malam',
      'scheduledTime': '08:30 PM',
      'frequency': '1x Setiap Hari',
      'points': 25,
    },
    {
      'id': 'istikharah',
      'title': 'Sholat Sunnah Istikharah',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Sholat Sunnah',
      'timeSlot': 'malam',
      'scheduledTime': '09:00 PM',
      'frequency': '1x Setiap Hari',
      'points': 20,
    },
  ];

  void _showEditScheduleDialog(HabitItem habit) {
    final titleController = TextEditingController(text: habit.title);
    final freqController = TextEditingController(text: habit.frequency);
    final timeController = TextEditingController(text: habit.scheduledTime);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sesuaikan Jadwal Habbit',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Nama Habbit',
                labelStyle: GoogleFonts.inter(),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: freqController,
              decoration: InputDecoration(
                labelText: 'Frekuensi',
                labelStyle: GoogleFonts.inter(),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeController,
              decoration: InputDecoration(
                labelText: 'Jadwal / Alarm',
                labelStyle: GoogleFonts.inter(),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF55822B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final updated = habit.copyWith(
                title: titleController.text.trim(),
                frequency: freqController.text.trim(),
                scheduledTime: timeController.text.trim(),
              );
              context.read<HabitProvider>().updateHabit(updated);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Jadwal "${updated.title}" berhasil disesuaikan!'),
                  backgroundColor: const Color(0xFF55822B),
                ),
              );
            },
            child: Text('Simpan', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _onSaveSelectedHabits(HabitProvider habitProv) {
    if (_selectedHabitIds.isEmpty) return;

    int addedCount = 0;
    for (final candidate in _candidateHabits) {
      final id = candidate['id'] as String;
      if (_selectedHabitIds.contains(id)) {
        // Cek jika belum ada di provider
        final alreadyAdded = habitProv.allHabits.any(
          (h) => h.id == id,
        );

        if (!alreadyAdded) {
          final newHabit = HabitItem(
            id: id,
            title: candidate['title'] as String,
            subtitle: 'Kebiasaan Sunnah Harian',
            category: candidate['category'] as HabitCategory,
            categoryGroup: candidate['categoryGroup'] as String,
            icon: Icons.mosque_rounded,
            points: candidate['points'] as int,
            timeSuggestion: candidate['frequency'] as String,
            timeSlot: candidate['timeSlot'] as String,
            scheduledTime: candidate['scheduledTime'] as String,
            frequency: candidate['frequency'] as String,
          );
          habitProv.addHabit(newHabit);
          addedCount++;
        }
      }
    }

    HapticFeedback.mediumImpact();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          addedCount > 0
              ? '$addedCount habbit baru berhasil ditambahkan!'
              : 'Habbit berhasil diperbarui!',
        ),
        backgroundColor: const Color(0xFF55822B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitProv = context.watch<HabitProvider>();
    final allExistingHabits = habitProv.allHabits;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF55822B),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F6EE),
        appBar: AppBar(
          backgroundColor: const Color(0xFF55822B),
          elevation: 0,
          leading: IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF84B74E),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(
            'Tambah Jadwal Habbit',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                children: [
                  // ── HEADER BAGIAN: IKON KALENDER HIJAU + JUDUL TEBAL KATEGORI ──
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Color(0xFF264E0B),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Kebiasaan Sholat Sunnah',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── DAFTAR 3 KONDISI STATE KARTU HABIT ──
                  ..._candidateHabits.map((candidate) {
                    final id = candidate['id'] as String;
                    final title = candidate['title'] as String;
                    final frequency = candidate['frequency'] as String;

                    // Cek apakah sudah terdaftar di HabitProvider sebelumnya
                    HabitItem? existingHabit;
                    for (final h in allExistingHabits) {
                      if (h.id == id ||
                          h.title.toLowerCase().trim() == title.toLowerCase().trim()) {
                        existingHabit = h;
                        break;
                      }
                    }

                    final bool isAlreadyAdded = existingHabit != null;
                    final bool isSelected = _selectedHabitIds.contains(id);

                    // Kondisi 3: Sudah Terpilih Sebelumnya (Already Added)
                    if (isAlreadyAdded) {
                      return _buildAlreadyAddedCard(existingHabit, title, frequency);
                    }

                    // Kondisi 2: Sedang Dicentang (Selected)
                    // Kondisi 1: Tersedia untuk Ditambahkan (Default)
                    return _buildSelectableCard(
                      id: id,
                      title: title,
                      frequency: frequency,
                      isSelected: isSelected,
                    );
                  }),
                ],
              ),
            ),

            // ── TOMBOL UTAMA BAWAH (TAMBAH HABBIT BARU) ──
            _buildBottomActionButton(habitProv),
          ],
        ),
      ),
    );
  }

  // ========================================================
  // KARTU STATE 3: SUDAH TERPILIH SEBELUMNYA (ALREADY ADDED)
  // ========================================================
  Widget _buildAlreadyAddedCard(HabitItem existingHabit, String title, String frequency) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Lingkaran Ikon Masjid Hijau Muda
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mosque_rounded,
              color: Color(0xFF264E0B),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Teks Label & Judul Habit
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Label Kecil "✓ Habbit Sudah Terpilih"
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: Color(0xFF55822B),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Habbit Sudah Terpilih',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF55822B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),

                // Judul Habit
                Text(
                  existingHabit.title.isNotEmpty ? existingHabit.title : title,
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),

                // Frekuensi
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      existingHabit.frequency.isNotEmpty
                          ? existingHabit.frequency
                          : frequency,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tombol Ikon Edit
          GestureDetector(
            onTap: () => _showEditScheduleDialog(existingHabit),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.edit_note_rounded,
                color: Color(0xFF6B7280),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // KARTU STATE 1 & 2: DEFAULT / SEDANG DICENTANG (SELECTED)
  // ========================================================
  Widget _buildSelectableCard({
    required String id,
    required String title,
    required String frequency,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF55822B) : const Color(0xFFE5E7EB),
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Lingkaran Ikon Masjid Hijau Muda
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F2E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mosque_rounded,
              color: Color(0xFF264E0B),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Judul Habit & Frekuensi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      frequency,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Tombol Aksi Kanan: Dashed Circle (+) atau Solid Green Circle (✓)
          if (isSelected)
            // State 2: Solid Green Circle dengan Centang Putih (✓)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedHabitIds.remove(id);
                });
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF55822B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            )
          else
            // State 1: Dashed Circle dengan Ikon (+) Hijau
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedHabitIds.add(id);
                });
              },
              child: CustomPaint(
                painter: _DashedCirclePainter(
                  color: const Color(0xFF55822B),
                  strokeWidth: 1.8,
                  dashCount: 12,
                ),
                child: const SizedBox(
                  width: 36,
                  height: 36,
                  child: Center(
                    child: Icon(
                      Icons.add_rounded,
                      color: Color(0xFF55822B),
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ========================================================
  // TOMBOL UTAMA BAWAH (TAMBAH HABBIT BARU)
  // ========================================================
  Widget _buildBottomActionButton(HabitProvider habitProv) {
    final bool isEnabled = _selectedHabitIds.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F6EE),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled
                  ? const Color(0xFF55822B)
                  : const Color(0xFF757575),
              disabledBackgroundColor: const Color(0xFF757575),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: isEnabled ? () => _onSaveSelectedHabits(habitProv) : null,
            child: Text(
              'Tambah Habbit Baru',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// CustomPainter untuk menggambar lingkaran putus-putus (Dashed Circle)
class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;

  _DashedCirclePainter({
    required this.color,
    this.strokeWidth = 1.8,
    this.dashCount = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final circumference = 2 * math.pi * radius;
    final dashLength = circumference / (dashCount * 2);
    final dashAngle = dashLength / radius;

    double currentAngle = 0;
    while (currentAngle < 2 * math.pi) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        dashAngle,
        false,
        paint,
      );
      currentAngle += dashAngle * 2;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.dashCount != dashCount;
}
