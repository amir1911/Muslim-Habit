import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/habit_provider.dart';
import '../models/shop_item_model.dart';
import '../providers/mascot_provider.dart';
import '../widgets/dashed_circle_button.dart';

/// Halaman Toko Maskot (TokoScreen)
/// Revisi total layout responsif & proporsional sesuai desain referensi
class TokoScreen extends StatefulWidget {
  const TokoScreen({super.key});

  @override
  State<TokoScreen> createState() => _TokoScreenState();
}

class _TokoScreenState extends State<TokoScreen> {
  ShopCategory _selectedCategory = ShopCategory.ramuan; // Default sesuai referensi

  @override
  Widget build(BuildContext context) {
    final habitProv = context.watch<HabitProvider>();
    final mascotProv = context.watch<MascotProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F6EE),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            // Rasio skala dinamis berdasarkan lebar asli gambar background (402 px)
            final scale = screenWidth / 402.0;
            // Tinggi area booth yang tepat agar langit, kanopi, Nunu, dan konter terlihat utuh
            // Konter kayu berakhir di y=615 pada gambar asli, dan tab duduk di y=615 sampai y=710
            final boothContainerHeight = 715.0 * scale;
            final tabsTopPosition = 612.0 * scale;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. AREA BOOTH TOKO INTERAKTIF (GAMBAR LOKAL ASLI + TABS) ──
                  SizedBox(
                    width: screenWidth,
                    height: boothContainerHeight,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Gambar Asli Background Booth Toko (Langit + Kanopi + Nunu + Konter + Jalan)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Image.asset(
                            'assets/images/shop_booth_bg.png',
                            width: screenWidth,
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/home_bg_day.png',
                              width: screenWidth,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),

                        // Gradasi Halus di Bawah Jalan Setapak Menyatu dengan Warna Krem #F7F6EE
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 70 * scale,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFFF7F6EE).withValues(alpha: 0.0),
                                  const Color(0xFFF7F6EE).withValues(alpha: 0.7),
                                  const Color(0xFFF7F6EE),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Header Atas (Kembali, Judul "Toko", Streak, Saldo Bintang, Keranjang)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: SafeArea(
                            bottom: false,
                            child: _buildTopBar(context, habitProv),
                          ),
                        ),

                        // 3 Tab Kategori (Kostum, Ramuan, Lainnya) diletakkan di bawah konter di jalan rumput
                        Positioned(
                          top: tabsTopPosition,
                          left: 0,
                          right: 0,
                          child: _buildCategoryTabs(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── 2. JUDUL & SUBJUDUL KATEGORI PRODUK ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCategoryTitle(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E350E),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _getCategorySubtitle(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF75856B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── 3. DAFTAR KARTU PRODUK (PADDING & SUDUT MEMBULAT 20PX) ──
                  _buildProductList(context, habitProv, mascotProv),
                  const SizedBox(height: 50),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================
  // HEADER ATAS
  // ==========================================
  Widget _buildTopBar(BuildContext context, HabitProvider habitProv) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Row(
        children: [
          // Tombol Kembali
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFF2E5714),
                size: 30,
              ),
            ),
          ),
          const SizedBox(width: 4),

          // Judul "Toko"
          Text(
            'Toko',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2E5714),
            ),
          ),

          const Spacer(),

          // Pill Streak Api
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF55822B),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: Color(0xFFFFB300),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${habitProv.streakCount}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Pill Saldo Bintang
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF55822B),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFD700),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${habitProv.userPoints}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Tombol Keranjang Belanja Bulat
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF55822B),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3 TAB KATEGORI (KOSTUM, RAMUAN, LAINNYA)
  // ==========================================
  Widget _buildCategoryTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildCategoryTabItem(
            category: ShopCategory.kostum,
            label: 'Kostum',
            icon: Icons.checkroom_rounded,
          ),
          _buildCategoryTabItem(
            category: ShopCategory.ramuan,
            label: 'Ramuan',
            icon: Icons.science_rounded,
          ),
          _buildCategoryTabItem(
            category: ShopCategory.lainnya,
            label: 'Lainnya',
            icon: Icons.card_giftcard_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabItem({
    required ShopCategory category,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedCategory == category;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedCategory = category;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        width: 86,
        height: isSelected ? 86 : 76,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF55822B)
              : const Color(0xFF55822B).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(18),
          border: isSelected
              ? Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E5714).withValues(alpha: isSelected ? 0.35 : 0.18),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 5),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // DAFTAR KARTU PRODUK (RADIUS 20PX, SPACING 14-16PX)
  // ==========================================
  Widget _buildProductList(
    BuildContext context,
    HabitProvider habitProv,
    MascotProvider mascotProv,
  ) {
    final items = ShopItemModel.allItems
        .where((item) => item.category == _selectedCategory)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: items.map((item) {
          final isPurchased = mascotProv.isItemPurchased(item.id);

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.025),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Thumbnail Ikon Produk
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: item.iconBgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.iconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),

                // Nama & Deskripsi Produk
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.description,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: const Color(0xFF6B7280),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 15, color: Color(0xFFFFB300)),
                          const SizedBox(width: 4),
                          Text(
                            '${item.price} Bintang',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF55822B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Tombol Beli / Status Dimiliki
                if (isPurchased)
                  const SolidCheckCircle(
                    size: 34,
                    color: Color(0xFF55822B),
                  )
                else
                  DashedCircleButton(
                    size: 34,
                    onTap: () {
                      _handlePurchase(context, item, habitProv, mascotProv);
                    },
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _handlePurchase(
    BuildContext context,
    ShopItemModel item,
    HabitProvider habitProv,
    MascotProvider mascotProv,
  ) {
    HapticFeedback.mediumImpact();
    final result = mascotProv.buyShopItem(item, habitProv);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Berhasil membeli ${item.name}!'),
          backgroundColor: const Color(0xFF55822B),
        ),
      );
    } else if (result == 'SUCCESS_FEED') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nunu meminum ${item.name}! Poin afeksi bertambah!'),
          backgroundColor: const Color(0xFF55822B),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String _getCategoryTitle() {
    switch (_selectedCategory) {
      case ShopCategory.kostum:
        return 'Kostum';
      case ShopCategory.ramuan:
        return 'Ramuan Ajaib';
      case ShopCategory.lainnya:
        return 'Hadiah Menarik Lainnya';
    }
  }

  String _getCategorySubtitle() {
    switch (_selectedCategory) {
      case ShopCategory.kostum:
        return 'Beri Untamu Kostum Indah!';
      case ShopCategory.ramuan:
        return 'Proteksi dan booster kebiasaanmu';
      case ShopCategory.lainnya:
        return 'Cek Hadiah menarik yang berubah berkala!';
    }
  }
}
