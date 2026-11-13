import 'package:flutter/material.dart';

class DoaCategoryMeta {
  final String title;
  final String illustrationKey;
  final Color bgColor;
  final Color badgeBgColor;
  final Color iconColor;
  final IconData icon;
  final List<String> matchingGroups;

  const DoaCategoryMeta({
    required this.title,
    required this.illustrationKey,
    required this.bgColor,
    required this.badgeBgColor,
    required this.iconColor,
    required this.icon,
    required this.matchingGroups,
  });

  static const List<DoaCategoryMeta> allCategories = [
    DoaCategoryMeta(
      title: 'Pagi & Malam',
      illustrationKey: 'pagi_malam',
      bgColor: Color(0xFFC7DDF5),
      badgeBgColor: Color(0xFF90BBE7),
      iconColor: Color(0xFF285E9A),
      icon: Icons.wb_twilight_rounded,
      matchingGroups: [
        'Doa Sebelum dan Sesudah Tidur',
        'Lafal Dzikir Dan Keutamaannya',
      ],
    ),
    DoaCategoryMeta(
      title: 'Sholat',
      illustrationKey: 'sholat',
      bgColor: Color(0xFFFFDAB9),
      badgeBgColor: Color(0xFFF7BF90),
      iconColor: Color(0xFFC25D18),
      icon: Icons.person_pin_circle_rounded,
      matchingGroups: [
        'Beberapa Doa Terkait Shalat',
        'Bacaan Terkait Adzan',
        'Doa Saat Wudhu',
        'Doa di Kamar Mandi',
      ],
    ),
    DoaCategoryMeta(
      title: 'Alam Semesta',
      illustrationKey: 'alam',
      bgColor: Color(0xFFFFF7C2),
      badgeBgColor: Color(0xFFF5E487),
      iconColor: Color(0xFFB39207),
      icon: Icons.public_rounded,
      matchingGroups: [
        'Doa Menghadapi Fenomena Alam',
        'Bacaan Bila Kagum Terhadap Sesuatu',
      ],
    ),
    DoaCategoryMeta(
      title: 'Haji & Umrah',
      illustrationKey: 'haji',
      bgColor: Color(0xFFFFE0BA),
      badgeBgColor: Color(0xFFFAC387),
      iconColor: Color(0xFFBF6617),
      icon: Icons.mosque_rounded,
      matchingGroups: [
        'Ucapan Terkait Hari Raya.',
        'Doa Terkait Ramadhan',
        'Doa Terkait Puasa',
      ],
    ),
    DoaCategoryMeta(
      title: 'Perjalanan',
      illustrationKey: 'perjalanan',
      bgColor: Color(0xFFC8CEF6),
      badgeBgColor: Color(0xFFA5B0EE),
      iconColor: Color(0xFF4C58B3),
      icon: Icons.directions_walk_rounded,
      matchingGroups: [
        'Doa Perjalanan',
        'Doa Keluar Dan Masuk Rumah',
      ],
    ),
    DoaCategoryMeta(
      title: 'Kebahagiaan & Kesulitan',
      illustrationKey: 'kebahagiaan',
      bgColor: Color(0xFFD2D1EE),
      badgeBgColor: Color(0xFFB1B0E3),
      iconColor: Color(0xFF5D5B99),
      icon: Icons.sentiment_satisfied_alt_rounded,
      matchingGroups: [
        'Doa Saat Sedih dan Sulit',
        'Doa Saat Mendapat Kabar',
        'Doa Terkait Harta dan Hutang',
        'Doa Memohon Keteguhan Hati',
      ],
    ),
    DoaCategoryMeta(
      title: 'Menyembah Allah',
      illustrationKey: 'menyembah_allah',
      bgColor: Color(0xFFFFF5B8),
      badgeBgColor: Color(0xFFF5E06C),
      iconColor: Color(0xFFA88A08),
      icon: Icons.auto_awesome_rounded,
      matchingGroups: [
        'Doa Memohon Kebaikan',
        'Doa Memohon Ampun, Rahmat Dan Kebaikan Lainnya',
        'Istighfar Dan Taubat',
        'Doa memohon surga dan berlindung dari neraka',
      ],
    ),
    DoaCategoryMeta(
      title: 'Etika yang Baik',
      illustrationKey: 'etika',
      bgColor: Color(0xFFFFF2C2),
      badgeBgColor: Color(0xFFFCE187),
      iconColor: Color(0xFF9E7E0D),
      icon: Icons.volunteer_activism_rounded,
      matchingGroups: [
        'Doa memohon akhlak mulia',
        'Beberapa Adab Dan Keutamaan',
        'Doa Terkait Majelis',
        'Doa Memohon Ilmu',
        'Doa Berpakaian',
      ],
    ),
    DoaCategoryMeta(
      title: 'Rumah & Keluarga',
      illustrationKey: 'rumah_keluarga',
      bgColor: Color(0xFFFFF0B8),
      badgeBgColor: Color(0xFFFCDF77),
      iconColor: Color(0xFFA67D08),
      icon: Icons.family_restroom_rounded,
      matchingGroups: [
        'Doa Terkait Orang Tua',
        'Doa Terkait Istri Dan Anak',
        'Doa Kepada Anak Yang Baru Lahir',
        'Doa Pernikahan',
        'Doa Keluar Dan Masuk Rumah',
      ],
    ),
    DoaCategoryMeta(
      title: 'Makanan & Minuman',
      illustrationKey: 'makanan',
      bgColor: Color(0xFFFFE6B5),
      badgeBgColor: Color(0xFFFCCC76),
      iconColor: Color(0xFFBA7704),
      icon: Icons.restaurant_rounded,
      matchingGroups: [
        'Doa Terkait Makan',
      ],
    ),
    DoaCategoryMeta(
      title: 'Perlindungan Diri',
      illustrationKey: 'perlindungan',
      bgColor: Color(0xFFD6E9C6),
      badgeBgColor: Color(0xFFB4D898),
      iconColor: Color(0xFF437C19),
      icon: Icons.shield_rounded,
      matchingGroups: [
        'Doa Perlindungan',
        'Doa Berlindung Dari Keburukan',
        'Doa Memohon Kebaikan Dan Berlindung Dari Keburukan',
        'Doa Berlindung dari setan',
        'Doa Berlindung Dari Syirik',
        'Doa Berlindung Dari Empat Hal',
        'Doa Berlindung Dari Kecelakaan Dan Kematian Yang Mengerikan',
        'Doa Bertemu Musuh Dan Penguasa',
        'Doa Berlindung Dari Orang Zalim Dan Orang Kafir',
      ],
    ),
    DoaCategoryMeta(
      title: 'Kesehatan & Doa Jenazah',
      illustrationKey: 'kesehatan',
      bgColor: Color(0xFFFFD6D6),
      badgeBgColor: Color(0xFFF7A8A8),
      iconColor: Color(0xFFB53434),
      icon: Icons.health_and_safety_rounded,
      matchingGroups: [
        'Doa Saat Sakit',
        'Doa untuk Orang Sakit',
        'Doa Menjelang Wafat',
        'Doa Jenazah',
      ],
    ),
  ];
}
