import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/habit_item.dart';
import '../../providers/habit_provider.dart';
import '../../core/widgets/custom_back_button.dart';

/// Halaman Tambah Jadwal Habbit Berdasarkan Kategori
class AddHabitScheduleScreen extends StatefulWidget {
  const AddHabitScheduleScreen({super.key});

  @override
  State<AddHabitScheduleScreen> createState() => _AddHabitScheduleScreenState();
}

class _AddHabitScheduleScreenState extends State<AddHabitScheduleScreen> {
  // Set untuk menampung id habit baru yang sedang dicentang (Selected)
  final Set<String> _selectedHabitIds = {};

  // Indeks kategori yang dipilih (0: Sholat, 1: Al-Qur'an, 2: Dzikir, 3: Doa, 4: Puasa, 5: Kebiasaan Islami)
  int _selectedCategoryIndex = 0;

  // Pencarian habit
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<String> _categories = [
    'Sholat',
    'Al-Qur\'an',
    'Dzikir',
    'Doa',
    'Puasa',
    'Kebiasaan Islami',
  ];

  static const List<IconData> _categoryIcons = [
    Icons.mosque_rounded,
    Icons.menu_book_rounded,
    Icons.fingerprint_rounded,
    Icons.volunteer_activism_rounded,
    Icons.nights_stay_rounded,
    Icons.favorite_rounded,
  ];

  // Daftar lengkap seluruh kandidat habit berdasarkan 6 kategori utama
  final List<Map<String, dynamic>> _candidateHabits = [
    // ── 1. KATEGORI SHOLAT ──
    {
      'id': 'sholat_wajib_5',
      'title': 'Sholat Wajib 5 Waktu',
      'category': HabitCategory.wajib,
      'categoryGroup': 'Sholat',
      'timeSlot': 'pagi',
      'scheduledTime': '04:30 AM',
      'frequency': '5x Setiap Hari',
      'points': 50,
      'icon': Icons.mosque_rounded,
    },
    {
      'id': 'rawatib_pagi',
      'title': 'Sholat Sunnah Rawatib',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Sholat',
      'timeSlot': 'pagi',
      'scheduledTime': '05:00 AM',
      'frequency': '1x Setiap Hari',
      'points': 20,
      'icon': Icons.mosque_rounded,
    },
    {
      'id': 'tahajjud',
      'title': 'Sholat Sunnah Tahajud',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Sholat',
      'timeSlot': 'malam',
      'scheduledTime': '03:30 AM',
      'frequency': '1x Setiap Hari',
      'points': 35,
      'icon': Icons.nights_stay_rounded,
    },
    {
      'id': 'dhuha',
      'title': 'Sholat Sunnah Dhuha',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Sholat',
      'timeSlot': 'pagi',
      'scheduledTime': '08:00 AM',
      'frequency': '1x Setiap Hari',
      'points': 25,
      'icon': Icons.wb_sunny_rounded,
    },
    {
      'id': 'witir',
      'title': 'Sholat Sunnah Witir',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Sholat',
      'timeSlot': 'malam',
      'scheduledTime': '08:30 PM',
      'frequency': '1x Setiap Hari',
      'points': 25,
      'icon': Icons.brightness_2_rounded,
    },
    {
      'id': 'istikharah',
      'title': 'Sholat Sunnah Istikharah',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Sholat',
      'timeSlot': 'malam',
      'scheduledTime': '09:00 PM',
      'frequency': 'Sesuai Kebutuhan',
      'points': 20,
      'icon': Icons.mosque_rounded,
    },

    // ── 2. KATEGORI AL-QUR'AN ──
    {
      'id': 'membaca_quran',
      'title': 'Membaca Al-Qur\'an',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Al-Qur\'an',
      'timeSlot': 'pagi',
      'scheduledTime': '06:00 AM',
      'frequency': '1 Juz / Hari',
      'points': 30,
      'icon': Icons.menu_book_rounded,
    },
    {
      'id': 'menghafal_quran',
      'title': 'Menghafal Al-Qur\'an',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Al-Qur\'an',
      'timeSlot': 'pagi',
      'scheduledTime': '06:30 AM',
      'frequency': '1 Halaman / Hari',
      'points': 35,
      'icon': Icons.auto_stories_rounded,
    },
    {
      'id': 'murajaah',
      'title': 'Muraja\'ah Hafalan',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Al-Qur\'an',
      'timeSlot': 'sore',
      'scheduledTime': '05:00 PM',
      'frequency': '1x Setiap Hari',
      'points': 25,
      'icon': Icons.record_voice_over_rounded,
    },
    {
      'id': 'terjemahan_quran',
      'title': 'Membaca Terjemahan & Tadabbur',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Al-Qur\'an',
      'timeSlot': 'malam',
      'scheduledTime': '08:00 PM',
      'frequency': '5 Ayat / Hari',
      'points': 20,
      'icon': Icons.import_contacts_rounded,
    },

    // ── 3. KATEGORI DZIKIR ──
    {
      'id': 'dzikir_pagi',
      'title': 'Dzikir Pagi',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Dzikir',
      'timeSlot': 'pagi',
      'scheduledTime': '05:30 AM',
      'frequency': '1x Setiap Hari',
      'points': 20,
      'icon': Icons.fingerprint_rounded,
    },
    {
      'id': 'dzikir_petang',
      'title': 'Dzikir Petang',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Dzikir',
      'timeSlot': 'sore',
      'scheduledTime': '05:30 PM',
      'frequency': '1x Setiap Hari',
      'points': 20,
      'icon': Icons.fingerprint_rounded,
    },
    {
      'id': 'dzikir_setelah_sholat',
      'title': 'Dzikir Setelah Sholat',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Dzikir',
      'timeSlot': 'siang',
      'scheduledTime': 'Setelah Sholat',
      'frequency': '5x Setiap Hari',
      'points': 25,
      'icon': Icons.spa_rounded,
    },
    {
      'id': 'istighfar_100x',
      'title': 'Istighfar 100x',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Dzikir',
      'timeSlot': 'pagi',
      'scheduledTime': 'Sepanjang Hari',
      'frequency': '100x Setiap Hari',
      'points': 20,
      'icon': Icons.loop_rounded,
    },
    {
      'id': 'sholawat_100x',
      'title': 'Sholawat Nabi',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Dzikir',
      'timeSlot': 'siang',
      'scheduledTime': 'Sepanjang Hari',
      'frequency': '100x Setiap Hari',
      'points': 20,
      'icon': Icons.favorite_border_rounded,
    },

    // ── 4. KATEGORI DOA ──
    {
      'id': 'doa_pagi',
      'title': 'Doa Pagi Hari',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Doa',
      'timeSlot': 'pagi',
      'scheduledTime': '05:15 AM',
      'frequency': '1x Setiap Pagi',
      'points': 15,
      'icon': Icons.volunteer_activism_rounded,
    },
    {
      'id': 'doa_petang',
      'title': 'Doa Petang Hari',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Doa',
      'timeSlot': 'sore',
      'scheduledTime': '05:45 PM',
      'frequency': '1x Setiap Petang',
      'points': 15,
      'icon': Icons.volunteer_activism_rounded,
    },
    {
      'id': 'doa_sebelum_tidur',
      'title': 'Doa Sebelum Tidur',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Doa',
      'timeSlot': 'malam',
      'scheduledTime': '09:30 PM',
      'frequency': '1x Setiap Malam',
      'points': 15,
      'icon': Icons.bedtime_rounded,
    },
    {
      'id': 'doa_setelah_sholat',
      'title': 'Doa Setelah Sholat',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Doa',
      'timeSlot': 'siang',
      'scheduledTime': 'Setelah Sholat',
      'frequency': '5x Setiap Hari',
      'points': 20,
      'icon': Icons.pan_tool_alt_rounded,
    },
    {
      'id': 'doa_harian',
      'title': 'Doa Harian & Kebaikan',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Doa',
      'timeSlot': 'pagi',
      'scheduledTime': 'Kapan Saja',
      'frequency': 'Setiap Hari',
      'points': 15,
      'icon': Icons.handshake_rounded,
    },

    // ── 5. KATEGORI PUASA ──
    {
      'id': 'puasa_senin',
      'title': 'Puasa Senin',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Puasa',
      'timeSlot': 'pagi',
      'scheduledTime': 'Hari Senin',
      'frequency': '1x Setiap Pekan',
      'points': 40,
      'icon': Icons.nights_stay_rounded,
    },
    {
      'id': 'puasa_kamis',
      'title': 'Puasa Kamis',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Puasa',
      'timeSlot': 'pagi',
      'scheduledTime': 'Hari Kamis',
      'frequency': '1x Setiap Pekan',
      'points': 40,
      'icon': Icons.nights_stay_rounded,
    },
    {
      'id': 'puasa_ayyamul_bidh',
      'title': 'Puasa Ayyamul Bidh',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Puasa',
      'timeSlot': 'pagi',
      'scheduledTime': '13, 14, 15 Hijriah',
      'frequency': '3 Hari Setiap Bulan',
      'points': 50,
      'icon': Icons.brightness_3_rounded,
    },
    {
      'id': 'puasa_sunnah_lainnya',
      'title': 'Puasa Sunnah Lainnya',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Puasa',
      'timeSlot': 'pagi',
      'scheduledTime': 'Sesuai Niat',
      'frequency': 'Fleksibel',
      'points': 35,
      'icon': Icons.star_border_rounded,
    },

    // ── 6. KATEGORI KEBIASAAN ISLAMI ──
    {
      'id': 'sedekah_subuh',
      'title': 'Sedekah Subuh',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Kebiasaan Islami',
      'timeSlot': 'pagi',
      'scheduledTime': '05:30 AM',
      'frequency': '1x Setiap Hari',
      'points': 25,
      'icon': Icons.volunteer_activism_rounded,
    },
    {
      'id': 'membantu_orang_lain',
      'title': 'Membantu Orang Lain',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Kebiasaan Islami',
      'timeSlot': 'siang',
      'scheduledTime': 'Kapan Saja',
      'frequency': 'Minimal 1 Kebaikan / Hari',
      'points': 20,
      'icon': Icons.people_outline_rounded,
    },
    {
      'id': 'membaca_buku_islami',
      'title': 'Membaca Buku Islami',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Kebiasaan Islami',
      'timeSlot': 'malam',
      'scheduledTime': '08:30 PM',
      'frequency': '15 Menit / Hari',
      'points': 20,
      'icon': Icons.menu_book_rounded,
    },
    {
      'id': 'menjaga_wudhu',
      'title': 'Menjaga Wudhu / Kebiasaan Baik',
      'category': HabitCategory.sunnah,
      'categoryGroup': 'Kebiasaan Islami',
      'timeSlot': 'pagi',
      'scheduledTime': 'Sepanjang Hari',
      'frequency': 'Setiap Hari',
      'points': 20,
      'icon': Icons.water_drop_outlined,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                  content: Text('Jadwal "${updated.title}" berhasil disesuaikan!'),
                  backgroundColor: const Color(0xFF518427),
                ),
              );
            },
            child: Text('Simpan', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAddCustomHabitDialog(HabitProvider habitProv) {
    final titleController = TextEditingController();
    final freqController = TextEditingController(text: '1x Setiap Hari');
    final timeController = TextEditingController(text: '07:00 AM');
    String selectedCat = _categories[_selectedCategoryIndex];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Buat Habbit Baru',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Nama Habbit Kustom',
                    hintText: 'Misal: Tadabbur Al-Mulk',
                    labelStyle: GoogleFonts.inter(),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCat,
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    labelStyle: GoogleFonts.inter(),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) {
                    if (val != null) setDlgState(() => selectedCat = val);
                  },
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
                    labelText: 'Waktu / Jam',
                    labelStyle: GoogleFonts.inter(),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
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
                final title = titleController.text.trim();
                if (title.isEmpty) return;

                final newHabit = HabitItem(
                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                  title: title,
                  subtitle: 'Kebiasaan Baik Harian',
                  category: HabitCategory.sunnah,
                  categoryGroup: selectedCat,
                  icon: Icons.check_circle_outline_rounded,
                  points: 20,
                  timeSuggestion: freqController.text.trim(),
                  scheduledTime: timeController.text.trim(),
                  frequency: freqController.text.trim(),
                );

                habitProv.addHabit(newHabit);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Habbit "$title" berhasil dibuat!'),
                    backgroundColor: const Color(0xFF518427),
                  ),
                );
              },
              child: Text('Buat', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
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
            icon: (candidate['icon'] as IconData?) ?? Icons.mosque_rounded,
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
        backgroundColor: const Color(0xFF518427),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitProv = context.watch<HabitProvider>();
    final allExistingHabits = habitProv.allHabits;

    final currentCategory = _categories[_selectedCategoryIndex];

    // Filter daftar kandidat berdasarkan kategori & query pencarian
    final filteredCandidates = _candidateHabits.where((candidate) {
      final catGroup = candidate['categoryGroup'] as String;
      final matchesCat = catGroup.toLowerCase() == currentCategory.toLowerCase();

      if (_searchQuery.trim().isEmpty) {
        return matchesCat;
      }

      final title = (candidate['title'] as String).toLowerCase();
      final matchesSearch = title.contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

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
          leadingWidth: 56,
          leading: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: CustomBackButton(),
          ),
          titleSpacing: 10,
          title: Text(
            'Tambah Jadwal Habbit',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          actions: [
            // Tombol Tambah Habit Kustom
            IconButton(
              icon: const Icon(Icons.add_task_rounded, color: Colors.white),
              tooltip: 'Tambah Habbit Kustom',
              onPressed: () => _showAddCustomHabitDialog(habitProv),
            ),
          ],
        ),
        body: Column(
          children: [
            // ── 1. KOLOM PENCARIAN HABIT ──
            Container(
              color: const Color(0xFF518427),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: GoogleFonts.inter(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Cari nama habbit...',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF518427)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),

            // ── 2. TAB KATEGORI HORIZONTAL (6 KATEGORI) ──
            Container(
              color: Colors.white,
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                itemCount: _categories.length,
                itemBuilder: (context, idx) {
                  final isSelected = _selectedCategoryIndex == idx;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCategoryIndex = idx);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF518427) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF518427) : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _categoryIcons[idx],
                            size: 15,
                            color: isSelected ? Colors.white : const Color(0xFF4B5563),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _categories[idx],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : const Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── 3. DAFTAR KANDIDAT HABIT ──
            Expanded(
              child: filteredCandidates.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'Tidak ada habbit ditemukan',
                            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () => _showAddCustomHabitDialog(habitProv),
                            icon: const Icon(Icons.add, size: 18, color: Color(0xFF518427)),
                            label: Text(
                              'Buat Habbit Kustom',
                              style: GoogleFonts.inter(color: const Color(0xFF518427), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      children: [
                        // Header Kategori Terpilih
                        Row(
                          children: [
                            Icon(
                              _categoryIcons[_selectedCategoryIndex],
                              color: const Color(0xFF264E0B),
                              size: 19,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Kategori: $currentCategory',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // List kartu kandidat
                        ...filteredCandidates.map((candidate) {
                          final id = candidate['id'] as String;
                          final title = candidate['title'] as String;
                          final frequency = candidate['frequency'] as String;
                          final icon = (candidate['icon'] as IconData?) ?? Icons.mosque_rounded;

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

                          if (isAlreadyAdded) {
                            return _buildAlreadyAddedCard(existingHabit, title, frequency, icon);
                          }

                          return _buildSelectableCard(
                            id: id,
                            title: title,
                            frequency: frequency,
                            icon: icon,
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
  Widget _buildAlreadyAddedCard(
    HabitItem existingHabit,
    String title,
    String frequency,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F2E2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFF264E0B),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: Color(0xFF518427),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Habbit Sudah Terpilih',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF518427),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  existingHabit.title.isNotEmpty ? existingHabit.title : title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
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
    required IconData icon,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF518427) : const Color(0xFFE5E7EB),
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
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE8F2E2) : const Color(0xFFF7F6EE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? const Color(0xFF264E0B) : const Color(0xFF518427),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
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

          if (isSelected)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedHabitIds.remove(id);
                });
              },
              child: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFF518427),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedHabitIds.add(id);
                });
              },
              child: CustomPaint(
                painter: _DashedCirclePainter(
                  color: const Color(0xFF518427),
                  strokeWidth: 1.8,
                  dashCount: 12,
                ),
                child: const SizedBox(
                  width: 34,
                  height: 34,
                  child: Center(
                    child: Icon(
                      Icons.add_rounded,
                      color: Color(0xFF518427),
                      size: 20,
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: Color(0xFFF7F6EE),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled
                  ? const Color(0xFF518427)
                  : const Color(0xFF9CA3AF),
              disabledBackgroundColor: const Color(0xFF9CA3AF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            onPressed: isEnabled ? () => _onSaveSelectedHabits(habitProv) : null,
            child: Text(
              isEnabled
                  ? 'Tambah (${_selectedHabitIds.length}) Habbit Baru'
                  : 'Pilih Habbit Terlebih Dahulu',
              style: GoogleFonts.plusJakartaSans(
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

/// CustomPainter untuk lingkaran putus-putus
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
