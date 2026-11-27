import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/custom_back_button.dart';
import '../../../models/ai_assistant_model.dart';
import '../../../providers/habit_provider.dart';
import '../providers/ai_chat_provider.dart';
import '../services/habit_focus_service.dart';

/// Halaman Pengaturan ChatBot (CompanionSettingsScreen)
class CompanionSettingsScreen extends StatefulWidget {
  const CompanionSettingsScreen({super.key});

  @override
  State<CompanionSettingsScreen> createState() => _CompanionSettingsScreenState();
}

class _CompanionSettingsScreenState extends State<CompanionSettingsScreen> {
  HabitFocusLockStatus? _lockStatus;
  bool _isLoadingStatus = true;

  @override
  void initState() {
    super.initState();
    _loadFocusLockStatus();
  }

  Future<void> _loadFocusLockStatus() async {
    final status = await HabitFocusService.getLockStatus();
    if (mounted) {
      setState(() {
        _lockStatus = status;
        _isLoadingStatus = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, _) {
        final companion = habitProvider.currentAssistant;
        return Scaffold(
          backgroundColor: const Color(0xFFF7F6EE),
          appBar: _buildAppBar(context),
          body: _buildBody(context, companion, habitProvider),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF7F6EE),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leadingWidth: 56,
      leading: const Padding(
        padding: EdgeInsets.only(left: 10),
        child: CustomBackButton(isLightBackground: true),
      ),
      titleSpacing: 10,
      title: Text(
        'Pengaturan ChatBot',
        style: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF2E5714),
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AIAssistantModel companion,
    HabitProvider habitProvider,
  ) {
    final status = _lockStatus;
    final canChange = status?.canChange ?? false;
    final remainingDays = status?.remainingDays ?? HabitFocusService.lockPeriodDays;

    final String focusSubtitle = _isLoadingStatus
        ? 'Memeriksa status periode fokus...'
        : (canChange
            ? 'Dapat diubah sekarang'
            : 'Fokus habit dapat diubah kembali dalam $remainingDays hari');

    final Color focusSubtitleColor = canChange
        ? const Color(0xFF518427)
        : const Color(0xFFBB6600);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // ── SEKSI 1: PERSONALITY (Tentang Nunu & Ubah Fokus Habit) ──
          _buildSection(
            label: 'PERSONALITY',
            children: [
              _buildSettingsTile(
                icon: Icons.auto_fix_high_rounded,
                title: 'Tentang ${companion.name}',
                subtitle: companion.levelTitle,
                onTap: () => _showAboutDialog(context, companion),
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.track_changes_rounded,
                title: 'Ubah Fokus Habit',
                subtitle: focusSubtitle,
                subtitleColor: focusSubtitleColor,
                onTap: () => _handleFocusHabitTap(context, habitProvider),
              ),
            ],
          ),

          // ── SEKSI 2: BAHASA (Ubah Bahasa, Nada Bicara, Suara) ──
          _buildSection(
            label: 'BAHASA & SUARA',
            children: [
              _buildSettingsTile(
                icon: Icons.language_rounded,
                title: 'Ubah Bahasa Saya',
                subtitle: 'Bahasa Indonesia (Aktif)',
                onTap: () => _showComingSoon(context, 'Pilihan bahasa daerah & internasional'),
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.record_voice_over_rounded,
                title: 'Ubah Nada Bicara',
                subtitle: 'Ramah, Sopan & Santun',
                onTap: () => _showComingSoon(context, 'Pilihan nada bicara santai & formal'),
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.volume_up_rounded,
                title: 'Ubah Suara',
                subtitle: 'Suara Audio Karakter',
                onTap: () => _showComingSoon(context, 'Variasi suara narator audio'),
              ),
            ],
          ),

          // ── SEKSI 3: BANTUAN ──
          _buildSection(
            label: 'BANTUAN',
            children: [
              _buildSettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Bantuan',
                subtitle: 'Panduan penggunaan & kontak support',
                onTap: () => _showHelpDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── TOMBOL HAPUS RIWAYAT PERCAKAPAN ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () => _confirmClearHistory(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFCC3333)),
                foregroundColor: const Color(0xFFCC3333),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Hapus Riwayat Percakapan',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String label,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF75856B),
              letterSpacing: 1.1,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? subtitleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF7E0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF518427)),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1F2937),
        ),
      ),
      subtitle: subtitle != null
          ? Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: subtitleColor ?? const Color(0xFF6B7280),
                ),
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 56,
      endIndent: 16,
      color: Color(0xFFF1F5F9),
    );
  }

  // ===========================================================================
  // LOGIKA PENGUNCIAN & PERUBAHAN FOKUS HABIT (1 BULAN)
  // ===========================================================================
  void _handleFocusHabitTap(BuildContext context, HabitProvider habitProvider) async {
    final status = _lockStatus;
    if (status == null) return;

    if (!status.canChange) {
      // Masih terkunci < 1 bulan: Tampilkan informasi sisa hari secara dinamis
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.lock_clock_rounded, color: Color(0xFFBB6600)),
              const SizedBox(width: 8),
              Text(
                'Fokus Habit Terkunci',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFEDD5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFFC2410C), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Fokus habit dapat diubah kembali dalam ${status.remainingDays} hari.',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFC2410C),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Untuk membangun kebiasaan yang istiqomah dan berdampak nyata, fokus habit dirancang untuk dijalani minimal selama 1 bulan penuh sebelum dapat diganti.',
                style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF4B5563), height: 1.4),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF518427),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Mengerti', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      // Sudah >= 1 bulan: Buka pemilihan fokus habit baru
      _showChangeFocusModal(context, habitProvider);
    }
  }

  void _showChangeFocusModal(BuildContext context, HabitProvider habitProvider) {
    String selectedId = habitProvider.currentAssistant.id;
    final assistants = AIAssistantModel.assistants;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.85,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Ubah Fokus Habit',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2E5714),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pilih karakter pendamping dan target habit baru untuk 1 bulan ke depan:',
                  style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF6B7280)),
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: assistants.length,
                    itemBuilder: (context, idx) {
                      final item = assistants[idx];
                      final isSelected = item.id.toLowerCase() == selectedId.toLowerCase();

                      return GestureDetector(
                        onTap: () {
                          setModalState(() => selectedId = item.id);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFEFF7E0) : const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF518427) : const Color(0xFFE5E7EB),
                              width: isSelected ? 1.8 : 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(item.imagePath, width: 44, height: 44),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          item.name,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF1F2937),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF518427).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            item.levelTitle,
                                            style: GoogleFonts.inter(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF518427),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.description,
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5,
                                        color: const Color(0xFF4B5563),
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Target: ${item.targets.join(", ")}',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2E5714),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                color: isSelected ? const Color(0xFF518427) : Colors.grey,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final success = await HabitFocusService.updateHabitFocus(selectedId);
                      if (success) {
                        await habitProvider.completeOnboarding(selectedId);
                        await _loadFocusLockStatus();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Fokus habit berhasil diperbarui! Periode 1 bulan dimulai.'),
                              backgroundColor: const Color(0xFF518427),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF518427),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'Terapkan Fokus Habit Baru',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AIAssistantModel companion) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Image.asset(companion.imagePath, width: 38, height: 38),
            const SizedBox(width: 10),
            Text(companion.name,
                style: GoogleFonts.plusJakartaSans(color: const Color(0xFF2E5714), fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          companion.description,
          style: GoogleFonts.inter(fontSize: 13, height: 1.5, color: const Color(0xFF374151)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup',
                style: GoogleFonts.inter(color: const Color(0xFF518427), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fitur $feature sedang dikembangkan.'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Bantuan & Dukungan', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        content: Text(
          'Jika Anda mengalami masalah seputar aplikasi Muslim Habit atau fitur ChatBot, silakan hubungi tim kami melalui support@muslimhabit.id.',
          style: GoogleFonts.inter(fontSize: 13, height: 1.5, color: const Color(0xFF374151)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup',
                style: GoogleFonts.inter(color: const Color(0xFF518427), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Hapus Riwayat?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
        content: Text(
          'Seluruh riwayat percakapan akan dihapus dan tidak dapat dikembalikan.',
          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF4B5563)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: GoogleFonts.inter(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AIChatProvider>().clearHistory();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Riwayat percakapan berhasil dibersihkan'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Hapus', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
