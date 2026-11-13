import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SholatListItemCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String actionLabel;
  final String actionTime;
  final bool isRecorded;
  final VoidCallback onCheckTap;
  final VoidCallback? onCardTap;

  const SholatListItemCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.actionLabel,
    required this.actionTime,
    required this.isRecorded,
    required this.onCheckTap,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBF6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE8E5D3).withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Top Part: Icon masjid, Title, Subtitle, Check Circle
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                // Mosque green square badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7EED7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.mosque_outlined,
                      size: 20,
                      color: Color(0xFF557C2B),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Title + Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: const Color(0xFF2C3E1F),
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 11,
                              color: Color(0xFF8B967D),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              subtitle!,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                                color: const Color(0xFF8B967D),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Check button
                GestureDetector(
                  onTap: onCheckTap,
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isRecorded ? const Color(0xFF557C2B) : const Color(0xFFE2E7D3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: isRecorded ? Colors.white : Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider thin line
          Container(
            height: 1,
            color: const Color(0xFFEFECE0),
          ),

          // Bottom Action bar: e.g. "Catat Waktu Ini" -> "05:15"
          InkWell(
            onTap: onCardTap,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    actionLabel,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8B967D),
                      decoration: actionLabel.contains('Catat')
                          ? TextDecoration.underline
                          : TextDecoration.none,
                      decorationColor: const Color(0xFF8B967D),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: Color(0xFF8B967D),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        actionTime,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C3E1F),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

