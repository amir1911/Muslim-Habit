import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tajwid_text.dart';

/// Modal / Bottom Sheet Tajwid Legend untuk memberikan panduan lengkap 16 hukum tajwid
class TajwidLegendSheet extends StatelessWidget {
  const TajwidLegendSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const TajwidLegendSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Kelompokkan 16 aturan tajwid ke dalam kategori yang rapi
    final categories = <String, List<TajwidRuleInfo>>{};
    for (final rule in kTajwidRules) {
      categories.putIfAbsent(rule.category, () => []).add(rule);
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF518427).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.palette_outlined,
                        color: Color(0xFF3B6114),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Panduan 16 Hukum Tajwid',
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1E3710),
                            ),
                          ),
                          Text(
                            'Kode warna huruf sesuai kaidah makhraj & tajwid',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF7A8B6E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFE8EEE0)),

              // Scrollable content of 16 rules grouped by category
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    ...categories.entries.map((entry) {
                      return _buildCategorySection(entry.key, entry.value);
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategorySection(String title, List<TajwidRuleInfo> rules) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF518427),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: const Color(0xFF518427),
                ),
              ),
            ],
          ),
        ),
        ...rules.map((rule) => _buildLegendCard(rule)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildLegendCard(TajwidRuleInfo rule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EEE0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color indicator dot
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: rule.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: rule.color.withValues(alpha: 0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      rule.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E3710),
                      ),
                    ),
                    if (rule.example.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE0EAD8)),
                        ),
                        child: Text(
                          rule.example.split('،').first.trim(),
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.amiri(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: rule.color,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  rule.description,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF4A4A4A),
                    height: 1.4,
                  ),
                ),
                if (rule.example.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Contoh: ${rule.example}',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.amiri(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF518427),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
