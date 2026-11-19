import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/dzikir/dzikir_category_model.dart';
import '../../providers/dzikir_provider.dart';
import 'dzikir_tasbih_screen.dart';

class DzikirSessionScreen extends StatefulWidget {
  final DzikirCategoryModel category;
  final int initialIndex;

  const DzikirSessionScreen({
    super.key,
    required this.category,
    this.initialIndex = 0,
  });

  @override
  State<DzikirSessionScreen> createState() => _DzikirSessionScreenState();
}

class _DzikirSessionScreenState extends State<DzikirSessionScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DzikirProvider>();
      provider.selectCategory(widget.category, initialIndex: widget.initialIndex);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DzikirProvider>();
    final items = widget.category.items;
    final currentIndex = provider.currentDzikirIndex;
    final currentItem = items.isNotEmpty && currentIndex < items.length
        ? items[currentIndex]
        : null;

    final progressRatio = items.isNotEmpty ? (currentIndex + 1) / items.length : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A7C59),
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          widget.category.name,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP PROGRESS SECTION ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress Session',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E2D),
                        ),
                      ),
                      Text(
                        '${currentIndex + 1} dari ${items.length}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C3E2D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressRatio,
                      minHeight: 5,
                      backgroundColor: const Color(0xFFE2E7DF),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A7C59)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── SWIPEABLE DZIKIR CONTENT CARD ──
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada bacaan dzikir.',
                        style: GoogleFonts.inter(color: Colors.grey),
                      ),
                    )
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: items.length,
                      onPageChanged: (index) {
                        provider.setDzikirIndex(index);
                      },
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Target Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF7D6),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFFE6D27E).withValues(alpha: 0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF8B6B00),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${item.defaultTarget}x Target',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF7A5D00),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 28),

                                  // Teks Arab Berharakat Lengkap
                                  Text(
                                    item.arabic,
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.rtl,
                                    style: GoogleFonts.amiri(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1B432C),
                                      height: 1.9,
                                    ),
                                  ),

                                  const SizedBox(height: 22),

                                  // Transliterasi Latin
                                  Text(
                                    item.transliteration,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.italic,
                                      color: const Color(0xFF2C3E2D),
                                      height: 1.4,
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  // Terjemahan Bahasa Indonesia
                                  Text(
                                    '“${item.translation}”',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF6B7280),
                                      height: 1.5,
                                    ),
                                  ),

                                  if (item.source.isNotEmpty) ...[
                                    const SizedBox(height: 18),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        item.source,
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: const Color(0xFF6B7280),
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 16),

            // ── BOTTOM NAVIGATION CONTROLS ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  // Tombol Sebelumnya
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: currentIndex > 0 ? const Color(0xFF1F442C) : const Color(0xFFC7D3C5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: currentIndex > 0
                          ? () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Tombol Buka Tasbih
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A7C59),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: currentItem == null
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DzikirTasbihScreen(
                                      category: widget.category,
                                      initialItem: currentItem,
                                    ),
                                  ),
                                );
                              },
                        child: Text(
                          'Buka Tasbih',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Tombol Selanjutnya
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: currentIndex < items.length - 1
                          ? const Color(0xFF1F442C)
                          : const Color(0xFFC7D3C5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
                      onPressed: currentIndex < items.length - 1
                          ? () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
