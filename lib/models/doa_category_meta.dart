import 'package:flutter/material.dart';

class DoaCategoryMeta {
  final String title;
  final String illustrationKey;
  final Color bgColor;
  final Color? endBgColor;
  final Color badgeBgColor;
  final Color iconColor;
  final IconData icon;
  final List<String> matchingGroups;

  /// Path gambar ikon kategori (Image.asset).
  /// Isi dengan path aset Anda, contoh: 'assets/icon/pagi_malam.jpeg'
  /// Jika null, akan menggunakan ikon bawaan (icon).
  final String? imagePath;

  const DoaCategoryMeta({
    required this.title,
    required this.illustrationKey,
    required this.bgColor,
    this.endBgColor,
    required this.badgeBgColor,
    required this.iconColor,
    required this.icon,
    required this.matchingGroups,
    this.imagePath,
  });

  static const List<DoaCategoryMeta> allCategories = [
    DoaCategoryMeta(
      title: 'Pagi & Malam',
      illustrationKey: 'pagi_malam',
      bgColor: Color(0xFFD6E8FA),
      endBgColor: Color(0xFFBEDCF8),
      badgeBgColor: Color(0xFF9CC7F2),
      iconColor: Color(0xFF1E5B97),
      icon: Icons.wb_twilight_rounded,
      matchingGroups: [
        'Doa Sebelum dan Sesudah Tidur',
        'Lafal Dzikir Dan Keutamaannya',
      ],
      // MASUKKAN PATH GAMBAR DI SINI untuk kategori Pagi & Malam
      // Contoh: imagePath: 'assets/icon/pagi_malam.jpeg',
      imagePath: 'assets/icon/pagi&malam.png',
    ),
    DoaCategoryMeta(
      title: 'Sholat',
      illustrationKey: 'sholat',
      bgColor: Color(0xFFFFE5D0),
      endBgColor: Color(0xFFFFD3B5),
      badgeBgColor: Color(0xFFF9B88E),
      iconColor: Color(0xFFB5500E),
      icon: Icons.person_pin_circle_rounded,
      matchingGroups: [
        'Beberapa Doa Terkait Shalat',
        'Bacaan Terkait Adzan',
        'Doa Saat Wudhu',
        'Doa di Kamar Mandi',
      ],
      // MASUKKAN PATH GAMBAR DI SINI untuk kategori Sholat
      // Contoh: imagePath: 'assets/icon/sholat.jpeg',
      imagePath: 'assets/icon/shalat1.png',
    ),
    DoaCategoryMeta(
      title: 'Alam Semesta',
      illustrationKey: 'alam',
      bgColor: Color(0xFFFFFBE0),
      endBgColor: Color(0xFFFFF4BF),
      badgeBgColor: Color(0xFFF7E279),
      iconColor: Color(0xFFA68406),
      icon: Icons.public_rounded,
      matchingGroups: [
        'Doa Menghadapi Fenomena Alam',
        'Bacaan Bila Kagum Terhadap Sesuatu',
      ],
      // MASUKKAN PATH GAMBAR DI SINI untuk kategori Alam Semesta
      // Contoh: imagePath: 'assets/icon/alam_semesta.jpeg',
      imagePath: 'assets/icon/alam.png',
    ),
    DoaCategoryMeta(
      title: 'Haji & Umrah',
      illustrationKey: 'haji',
      bgColor: Color(0xFFFFEAD5),
      endBgColor: Color(0xFFFFDCBC),
      badgeBgColor: Color(0xFFF7BF8A),
      iconColor: Color(0xFFB85D13),
      icon: Icons.mosque_rounded,
      matchingGroups: [
        'Ucapan Terkait Hari Raya.',
        'Doa Terkait Ramadhan',
        'Doa Terkait Puasa',
      ],
      // MASUKKAN PATH GAMBAR DI SINI untuk kategori Haji & Umrah
      // Contoh: imagePath: 'assets/icon/haji_umrah.jpeg',
      imagePath: 'assets/icon/haji.png',
    ),
    DoaCategoryMeta(
      title: 'Perjalanan',
      illustrationKey: 'perjalanan',
      bgColor: Color(0xFFDFE3FC),
      endBgColor: Color(0xFFCCD3FA),
      badgeBgColor: Color(0xFFAFB9F5),
      iconColor: Color(0xFF4552B5),
      icon: Icons.directions_walk_rounded,
      matchingGroups: [
        'Doa Perjalanan',
        'Doa Keluar Dan Masuk Rumah',
      ],
      // MASUKKAN PATH GAMBAR DI SINI untuk kategori Perjalanan
      // Contoh: imagePath: 'assets/icon/perjalanan.jpeg',
      imagePath: 'assets/icon/perjalanan.png',
    ),
    DoaCategoryMeta(
      title: 'Kebahagiaan & Kesulitan',
      illustrationKey: 'kebahagiaan',
      bgColor: Color(0xFFE5E2F7),
      endBgColor: Color(0xFFD4D0F2),
      badgeBgColor: Color(0xFFBCB7E8),
      iconColor: Color(0xFF55529A),
      icon: Icons.sentiment_satisfied_alt_rounded,
      matchingGroups: [
        'Doa Saat Sedih dan Sulit',
        'Doa Saat Mendapat Kabar',
        'Doa Terkait Harta dan Hutang',
        'Doa Memohon Keteguhan Hati',
      ],
      // MASUKKAN PATH GAMBAR DI SINI untuk kategori Kebahagiaan & Kesulitan
      // Contoh: imagePath: 'assets/icon/kebahagiaan.jpeg',
      imagePath: 'assets/icon/kebahagian.png',
    ),
    DoaCategoryMeta(
      title: 'Menyembah Allah',
      illustrationKey: 'menyembah_allah',
      bgColor: Color(0xFFFFF9CE),
      endBgColor: Color(0xFFFFF0A8),
      badgeBgColor: Color(0xFFF7DD63),
      iconColor: Color(0xFF9E8006),
      icon: Icons.auto_awesome_rounded,
      matchingGroups: [
        'Doa Memohon Kebaikan',
        'Doa Memohon Ampun, Rahmat Dan Kebaikan Lainnya',
        'Istighfar Dan Taubat',
        'Doa memohon surga dan berlindung dari neraka',
      ],
      // MASUKKAN PATH GAMBAR DI SINI untuk kategori Menyembah Allah
      // Contoh: imagePath: 'assets/icon/menyembah_allah.jpeg',
      imagePath: 'assets/icon/allah.png',
    ),
    DoaCategoryMeta(
      title: 'Etika yang Baik',
      illustrationKey: 'etika',
      bgColor: Color(0xFFFFF6D7),
      endBgColor: Color(0xFFFFEBBA),
      badgeBgColor: Color(0xFFFADB77),
      iconColor: Color(0xFF997808),
      icon: Icons.volunteer_activism_rounded,
      matchingGroups: [
        'Doa memohon akhlak mulia',
        'Beberapa Adab Dan Keutamaan',
        'Doa Terkait Majelis',
        'Doa Memohon Ilmu',
        'Doa Berpakaian',
      ],
      // MASUKKAN PATH GAMBAR DI SINI untuk kategori Etika yang Baik
      // Contoh: imagePath: 'assets/icon/etika.jpeg',
      imagePath: 'assets/icon/etika.png',
    ),
    DoaCategoryMeta(
      title: 'Rumah & Keluarga',
      illustrationKey: 'rumah_keluarga',
      bgColor: Color(0xFFFFF5D3),
      endBgColor: Color(0xFFFFE8AE),
      badgeBgColor: Color(0xFFFCDA6A),
      iconColor: Color(0xFFA17805),
      icon: Icons.family_restroom_rounded,
      matchingGroups: [
        'Doa Terkait Orang Tua',
        'Doa Terkait Istri Dan Anak',
        'Doa Kepada Anak Yang Baru Lahir',
        'Doa Pernikahan',
        'Doa Keluar Dan Masuk Rumah',
      ],
      // MASUKKAN PATH GAMBAR DI SINI untuk kategori Rumah & Keluarga
      // Contoh: imagePath: 'assets/icon/rumah_keluarga.jpeg',
      imagePath: 'assets/icon/keluarga.png',
    ),
    DoaCategoryMeta(
      title: 'Makanan & Minuman',
      illustrationKey: 'makanan',
      bgColor: Color(0xFFFFECD0),
      endBgColor: Color(0xFFFFDCB3),
      badgeBgColor: Color(0xFFFAC46E),
      iconColor: Color(0xFFB06F03),
      icon: Icons.restaurant_rounded,
      matchingGroups: [
        'Doa Terkait Makan',
      ],
      // MASUKKAN PATH GAMBAR DI SINI untuk kategori Makanan & Minuman
      // Contoh: imagePath: 'assets/icon/makanan_minuman.jpeg',
      imagePath: 'assets/icon/makan.png',
    ),
    DoaCategoryMeta(
      title: 'Perlindungan Diri',
      illustrationKey: 'perlindungan',
      bgColor: Color(0xFFE2F2D5),
      endBgColor: Color(0xFFCCE7B9),
      badgeBgColor: Color(0xFFAED793),
      iconColor: Color(0xFF3B7314),
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
      // MASUKKAN PATH GAMBAR DI SINI untuk kategori Perlindungan Diri
      // Contoh: imagePath: 'assets/icon/perlindungan_diri.jpeg',
      imagePath: 'assets/icon/pelindung.png',
    ),
    DoaCategoryMeta(
      title: 'Kesehatan & Doa Jenazah',
      illustrationKey: 'kesehatan',
      bgColor: Color(0xFFFFE1E1),
      endBgColor: Color(0xFFFFC9C9),
      badgeBgColor: Color(0xFFF99E9E),
      iconColor: Color(0xFFAD2D2D),
      icon: Icons.health_and_safety_rounded,
      matchingGroups: [
        'Doa Saat Sakit',
        'Doa untuk Orang Sakit',
        'Doa Menjelang Wafat',
        'Doa Jenazah',
      ],
      // MASUKKAN PATH GAMBAR DI SINI untuk kategori Kesehatan & Doa Jenazah
      // Contoh: imagePath: 'assets/icon/kesehatan_jenazah.jpeg',
      imagePath: 'assets/icon/kesehatan.png',
    ),
  ];
}
