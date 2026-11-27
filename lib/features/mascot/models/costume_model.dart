import 'package:flutter/material.dart';

// ============================================================================
// KONFIGURASI PATH GAMBAR AKSESORIS UNTA
// Ubah path di bawah ini jika file gambar diletakkan di lokasi berbeda.
// Pastikan gambar berformat PNG transparan.
// ============================================================================
class AccessoryPaths {
  /// Path gambar Peci (PNG transparan di atas kepala unta)
  static const String peci = 'assets/images/accessories/peci.png';

  /// Path gambar Syal (PNG transparan melingkar di leher unta)
  static const String syal = 'assets/images/accessories/syal.png';

  /// Path gambar Lonceng (PNG transparan di leher unta)
  static const String lonceng = 'assets/images/accessories/lonceng.png';
}

/// Tipe Aksesoris Maskot Unta
enum AccessoryType {
  peci,
  syal,
  lonceng,
}

/// Model Aksesoris Mandiri untuk Maskot Unta
class AccessoryModel {
  final String id;
  final String name;
  final String description;
  final AccessoryType type;
  final String imagePath;
  final IconData icon;
  final Color themeColor;
  final String? soundEffect;

  const AccessoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.imagePath,
    required this.icon,
    this.themeColor = const Color(0xFF518427),
    this.soundEffect,
  });

  static const List<AccessoryModel> predefinedAccessories = [
    AccessoryModel(
      id: 'peci',
      name: 'Peci Islami',
      description: 'Peci putih dengan hiasan hijau dan ornamen emas di atas kepala.',
      type: AccessoryType.peci,
      imagePath: AccessoryPaths.peci,
      icon: Icons.brightness_auto_rounded,
      themeColor: Color(0xFF518427),
    ),
    AccessoryModel(
      id: 'syal',
      name: 'Syal Hijau',
      description: 'Syal hijau tua dengan ornamen emas melingkar di leher.',
      type: AccessoryType.syal,
      imagePath: AccessoryPaths.syal,
      icon: Icons.dry_cleaning_rounded,
      themeColor: Color(0xFF2E5714),
    ),
    AccessoryModel(
      id: 'lonceng',
      name: 'Lonceng Emas',
      description: 'Lonceng emas dengan tali cokelat terpasang di leher.',
      type: AccessoryType.lonceng,
      imagePath: AccessoryPaths.lonceng,
      icon: Icons.notifications_active_rounded,
      themeColor: Color(0xFFD4AF37),
      soundEffect: 'assets/audio/bel_tradisional.wav',
    ),
  ];

  static AccessoryModel? getById(String id) {
    try {
      return predefinedAccessories.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Model Kostum Maskot Nunu
class CostumeModel {
  final String id;
  final String name;
  final String description;
  final int price;
  final String imagePath;
  final IconData? icon;
  final Color themeColor;

  const CostumeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
    this.icon,
    this.themeColor = const Color(0xFF55822B),
  });

  static const List<CostumeModel> predefinedCostumes = [
    CostumeModel(
      id: 'normal',
      name: 'Normal',
      description: 'Kostum Defaul Unta',
      price: 0,
      imagePath: 'assets/images/mascot_standing.png',
      icon: Icons.pets_rounded,
      themeColor: Color(0xFF55822B),
    ),
    CostumeModel(
      id: 'sorban_emas',
      name: 'Sorban Emas',
      description: 'Tampil mewah dengan aksesoris spesial',
      price: 10,
      imagePath: 'assets/images/mascot_standing.png',
      icon: Icons.star_rounded,
      themeColor: Color(0xFFD4AF37),
    ),
    CostumeModel(
      id: 'jubah_zamrud',
      name: 'Jubah Zamrud',
      description: 'Kostum eksklusif untuk temanmu 🐪',
      price: 15,
      imagePath: 'assets/images/mascot_standing.png',
      icon: Icons.diamond_rounded,
      themeColor: Color(0xFF00A86B),
    ),
  ];

  static CostumeModel getById(String id) {
    return predefinedCostumes.firstWhere(
      (c) => c.id == id,
      orElse: () => predefinedCostumes.first,
    );
  }
}
