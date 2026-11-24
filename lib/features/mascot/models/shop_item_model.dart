import 'package:flutter/material.dart';

enum ShopCategory { kostum, ramuan, lainnya }

class ShopItemModel {
  final String id;
  final String name;
  final String description;
  final int price;
  final ShopCategory category;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const ShopItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  static const List<ShopItemModel> allItems = [
    // ── KATEGORI KOSTUM ──
    ShopItemModel(
      id: 'jubah_zamrud',
      name: 'Jubah Zamrud',
      description: 'Kostum eksklusif untuk temanmu 🐪',
      price: 15,
      category: ShopCategory.kostum,
      icon: Icons.diamond_rounded,
      iconColor: Color(0xFF00C853),
      iconBgColor: Color(0xFFE8F5E9),
    ),
    ShopItemModel(
      id: 'sorban_emas',
      name: 'Sorban Emas',
      description: 'Tampil mewah dengan aksesoris spesial',
      price: 10,
      category: ShopCategory.kostum,
      icon: Icons.auto_awesome_rounded,
      iconColor: Color(0xFFFFB300),
      iconBgColor: Color(0xFFFFF8E1),
    ),

    // ── KATEGORI RAMUAN ──
    ShopItemModel(
      id: 'ramuan_penyegar',
      name: 'Ramuan Penyegar',
      description:
          'Ramuan Favorit Nunu, Rasanya seperti Blueberry! Beri Nunu ini untuk naikkan Poin Afeksi!',
      price: 5,
      category: ShopCategory.ramuan,
      icon: Icons.science_rounded,
      iconColor: Color(0xFF1E88E5),
      iconBgColor: Color(0xFFE3F2FD),
    ),
    ShopItemModel(
      id: 'ramuan_bintang',
      name: 'Ramuan Bintang-Bintang',
      description: 'Dapatkan +2x XP dari semua kebiasaan selama 1 hari penuh.',
      price: 8,
      category: ShopCategory.ramuan,
      icon: Icons.star_half_rounded,
      iconColor: Color(0xFF8E24AA),
      iconBgColor: Color(0xFFF3E5F5),
    ),

    // ── KATEGORI LAINNYA ──
    ShopItemModel(
      id: 'pecahan_mahkota',
      name: 'Pecahan Mahkota Bintang',
      description:
          'Koleksi 25 Pecahan Mahkota Bintang Untuk mendapatkan premium gratis',
      price: 20,
      category: ShopCategory.lainnya,
      icon: Icons.military_tech_rounded,
      iconColor: Color(0xFFFFB300),
      iconBgColor: Color(0xFFFFF8E1),
    ),
    ShopItemModel(
      id: 'voucher_nonton',
      name: 'Voucher Nonton 50% Diskon',
      description: 'Nonton Dengan diskon yang besar!',
      price: 30,
      category: ShopCategory.lainnya,
      icon: Icons.confirmation_number_rounded,
      iconColor: Color(0xFFE91E63),
      iconBgColor: Color(0xFFFCE4EC),
    ),
  ];
}
