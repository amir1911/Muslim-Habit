import 'package:flutter/material.dart';
import '../../../models/habit_item.dart';
import '../../../services/dzikir_service.dart';
import '../../../models/doa_category_meta.dart';
import '../../dzikir/dzikir_screen.dart';
import '../../dzikir/dzikir_session_screen.dart';
import '../../doa/doa_screen.dart';
import '../../doa/doa_category_detail_screen.dart';
import '../../sholat/sholat_screen.dart';
import '../../puasa/puasa_screen.dart';
import '../../quran/quran_screen.dart';

/// Helper sentral untuk memetakan Habit ke halaman aktivitas yang sesuai secara fungsional.
class HabitNavigationHelper {
  static void navigateToActivity(BuildContext context, HabitItem habit) {
    final id = habit.id.toLowerCase();
    final title = habit.title.toLowerCase();
    final group = habit.categoryGroup.toLowerCase();

    // ─────────────────────────────────────────────────────────────
    // 1. AKTIVITAS SHOLAT (Wajib & Sunnah)
    // ─────────────────────────────────────────────────────────────
    if (group.contains('sholat') ||
        id.contains('subuh') ||
        id.contains('dhuha') ||
        id.contains('dzuhur') ||
        id.contains('ashar') ||
        id.contains('magrib') ||
        id.contains('maghrib') ||
        id.contains('isya') ||
        title.contains('sholat') ||
        title.contains('shalat')) {
      int catIndex = habit.category == HabitCategory.sunnah ? 1 : 0;
      String? prayerKey = id;

      if (id.contains('dhuha') || title.contains('dhuha')) {
        catIndex = 1;
        prayerKey = 'dhuha';
      } else if (id.contains('tahajjud') || title.contains('tahajjud')) {
        catIndex = 1;
        prayerKey = 'tahajjud';
      } else if (id.contains('subuh') || title.contains('subuh') || title.contains('shubuh')) {
        catIndex = 0;
        prayerKey = 'subuh';
      } else if (id.contains('dzuhur') || title.contains('dzuhur')) {
        catIndex = 0;
        prayerKey = 'dzuhur';
      } else if (id.contains('ashar') || title.contains('ashar')) {
        catIndex = 0;
        prayerKey = 'ashar';
      } else if (id.contains('magrib') || id.contains('maghrib') || title.contains('magrib') || title.contains('maghrib')) {
        catIndex = 0;
        prayerKey = 'maghrib';
      } else if (id.contains('isya') || title.contains('isya')) {
        catIndex = 0;
        prayerKey = 'isya';
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SholatScreen(
            initialCategoryIndex: catIndex,
            initialPrayerKey: prayerKey,
          ),
        ),
      );
      return;
    }

    // ─────────────────────────────────────────────────────────────
    // 2. AKTIVITAS DZIKIR (Pagi, Petang, Siang, Shalat, Tidur)
    // ─────────────────────────────────────────────────────────────
    if (group.contains('dzikir') ||
        id.contains('dzikir') ||
        id.contains('zikir') ||
        title.contains('dzikir') ||
        title.contains('zikir')) {
      final dzikirCats = DzikirService().getCategories();

      if (id.contains('pagi') || title.contains('pagi')) {
        final pagiCat = dzikirCats.firstWhere(
          (c) => c.id == 'pagi',
          orElse: () => dzikirCats.first,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DzikirSessionScreen(category: pagiCat),
          ),
        );
        return;
      } else if (id.contains('petang') ||
          id.contains('sore') ||
          title.contains('petang') ||
          title.contains('sore')) {
        final petangCat = dzikirCats.firstWhere(
          (c) => c.id == 'petang',
          orElse: () => dzikirCats.first,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DzikirSessionScreen(category: petangCat),
          ),
        );
        return;
      } else if (id.contains('tidur') ||
          id.contains('malam') ||
          title.contains('tidur') ||
          title.contains('malam')) {
        final tidurCat = dzikirCats.firstWhere(
          (c) => c.id == 'tidur',
          orElse: () => dzikirCats.first,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DzikirSessionScreen(category: tidurCat),
          ),
        );
        return;
      } else if (id.contains('siang') ||
          id.contains('shalat') ||
          title.contains('siang') ||
          title.contains('shalat')) {
        final shalatCat = dzikirCats.firstWhere(
          (c) => c.id == 'shalat' || c.id == 'thayyibah',
          orElse: () => dzikirCats.first,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DzikirSessionScreen(category: shalatCat),
          ),
        );
        return;
      }

      // Default dzikir
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DzikirScreen()),
      );
      return;
    }

    // ─────────────────────────────────────────────────────────────
    // 3. AKTIVITAS DOA (Pagi, Malam, Sholat, Harian)
    // ─────────────────────────────────────────────────────────────
    if (group.contains('doa') || id.contains('doa') || title.contains('doa')) {
      if (id.contains('pagi') ||
          id.contains('malam') ||
          title.contains('pagi') ||
          title.contains('malam')) {
        final pagiMalamMeta = DoaCategoryMeta.allCategories.firstWhere(
          (c) => c.illustrationKey == 'pagi_malam' || c.title == 'Pagi & Malam',
          orElse: () => DoaCategoryMeta.allCategories.first,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DoaCategoryDetailScreen(category: pagiMalamMeta),
          ),
        );
        return;
      } else if (id.contains('sholat') || title.contains('sholat')) {
        final sholatDoaMeta = DoaCategoryMeta.allCategories.firstWhere(
          (c) => c.illustrationKey == 'sholat' || c.title == 'Sholat',
          orElse: () => DoaCategoryMeta.allCategories.first,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DoaCategoryDetailScreen(category: sholatDoaMeta),
          ),
        );
        return;
      }

      // Default doa
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DoaScreen()),
      );
      return;
    }

    // ─────────────────────────────────────────────────────────────
    // 4. AKTIVITAS PUASA (Senin-Kamis, Daud, dll)
    // ─────────────────────────────────────────────────────────────
    if (group.contains('puasa') || id.contains('puasa') || title.contains('puasa')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PuasaScreen()),
      );
      return;
    }

    // ─────────────────────────────────────────────────────────────
    // 5. AKTIVITAS AL-QUR'AN (Target Baca, Tilawah)
    // ─────────────────────────────────────────────────────────────
    if (group.contains('qur') ||
        id.contains('quran') ||
        id.contains('target_baca') ||
        title.contains('qur') ||
        title.contains('tilawah')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const QuranScreen()),
      );
      return;
    }

    // ─────────────────────────────────────────────────────────────
    // 6. FALLBACK UMUM AMAN
    // ─────────────────────────────────────────────────────────────
    if (habit.category == HabitCategory.wajib) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SholatScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DzikirScreen()),
      );
    }
  }
}
