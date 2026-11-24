import 'package:flutter/material.dart';

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
