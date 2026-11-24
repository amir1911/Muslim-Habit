import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/habit_item.dart';
import '../../providers/habit_provider.dart';
import 'add_habit_schedule_screen.dart';

/// Halaman Edit atau Tambah Habbit (EditHabitScreen)
class EditHabitScreen extends StatefulWidget {
  const EditHabitScreen({super.key});

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _activeFilterChip = 'Sholat Dhuha';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showEditHabitDialog(HabitItem habit) {
    final titleController = TextEditingController(text: habit.title);
    final freqController = TextEditingController(text: habit.frequency);
    final timeController = TextEditingController(text: habit.scheduledTime);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Edit Habbit & Alarm',
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
                labelText: 'Frekuensi / Keterangan',
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
              backgroundColor: const Color(0xFF518427),
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
                  content: Text('Habbit "${updated.title}" berhasil diperbarui!'),
                  backgroundColor: const Color(0xFF518427),
                ),
              );
            },
            child: Text('Perbarui', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitProv = context.watch<HabitProvider>();
    final allHabits = habitProv.allHabits;

    // Filter habits berdasarkan search query atau filter chip
    final filteredHabits = allHabits.where((h) {
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.toLowerCase().trim();
        return h.title.toLowerCase().contains(query) ||
            h.categoryGroup.toLowerCase().contains(query);
      }
      if (_activeFilterChip != null && _activeFilterChip!.isNotEmpty) {
        final chipQuery = _activeFilterChip!.toLowerCase().trim();
        return h.title.toLowerCase().contains(chipQuery) ||
            h.categoryGroup.toLowerCase().contains(chipQuery);
      }
      return true;
    }).toList();

    const categories = [
      {'title': 'Sholat Wajib', 'icon': Icons.mosque_rounded},
      {'title': 'Sholat Sunnah', 'icon': Icons.mosque_rounded},
      {'title': 'Puasa', 'icon': Icons.nightlight_round},
      {'title': 'Target Baca Al-Qur\'an', 'icon': Icons.menu_book_rounded},
      {'title': 'Doa', 'icon': Icons.front_hand_rounded},
      {'title': 'Dzikir', 'icon': Icons.chat_bubble_outline_rounded},
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF518427),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F6EE),
        appBar: AppBar(
          backgroundColor: const Color(0xFF518427),
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
            'Edit atau Tambah Habbit',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                // Focus ke search field jika ditekan
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF518427),
          elevation: 4,
          shape: const CircleBorder(),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddHabitScheduleScreen(),
              ),
            );
          },
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
            children: [
              // ── 1. SEARCH BAR (KOTAK PENCARIAN PUTIH) ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                      if (val.isNotEmpty) {
                        _activeFilterChip = null;
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari Habbit Untuk Disesuaikan',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF9CA3AF),
                    ),
                    border: InputBorder.none,
                    suffixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF6B7280),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ── 2. BARIS FILTER CHIP (X Sholat Dhuha) ──
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_activeFilterChip != null) {
                          _activeFilterChip = null;
                        } else {
                          _activeFilterChip = 'Sholat Dhuha';
                          _searchQuery = '';
                          _searchController.clear();
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _activeFilterChip != null
                            ? const Color(0xFFF3F4F1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFD1D5DB)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _activeFilterChip != null
                                ? 'X  $_activeFilterChip'
                                : '+  Sholat Dhuha',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ── 3. DAFTAR HABIT PER KATEGORI ──
              ...categories.map((cat) {
                final catTitle = cat['title'] as String;
                final catIcon = cat['icon'] as IconData;
                final items = filteredHabits
                    .where((h) =>
                        h.categoryGroup.toLowerCase().trim() ==
                        catTitle.toLowerCase().trim())
                    .toList();

                if (items.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Kategori (Ikon Kotak Hijau Tua + Judul Tebal)
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF264E0B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(catIcon, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          catTitle,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Daftar Kartu Putih Habit
                    ...items.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Lingkaran Ikon Masjid Hijau Muda
                            Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8F2E2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.mosque_rounded,
                                color: Color(0xFF264E0B),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Nama Habit Berwarna Hijau & Frekuensi
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF264E0B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.schedule_rounded,
                                        size: 13,
                                        color: Color(0xFF6B7280),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.frequency,
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
                              onTap: () => _showEditHabitDialog(item),
                              child: Container(
                                padding: const EdgeInsets.all(6),
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
                    }),

                    const SizedBox(height: 14),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
