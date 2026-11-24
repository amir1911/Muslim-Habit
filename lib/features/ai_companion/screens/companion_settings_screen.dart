import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/habit_provider.dart';
import '../../../models/ai_assistant_model.dart';
import '../providers/ai_chat_provider.dart';

class CompanionSettingsScreen extends StatelessWidget {
  const CompanionSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, _) {
        final companion = habitProvider.currentAssistant;
        return Scaffold(
          backgroundColor: const Color(0xFFF9F8F2),
          appBar: _buildAppBar(context),
          body: _buildBody(context, companion, habitProvider),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF4A7220),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Pengaturan ChatBot',
        style: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(
      BuildContext context, AIAssistantModel companion, HabitProvider habitProvider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildSection(
            label: 'PERSONALITY',
            children: [
              _buildSettingsTile(
                icon: Icons.auto_fix_high_rounded,
                title: 'Tentang ${companion.name}',
                subtitle: null,
                onTap: () => _showAboutDialog(context, companion),
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.track_changes_rounded,
                title: 'Ubah Fokus Habbit',
                subtitle: 'Fokus Habbit Tidak Bisa Diubah Selama 1 Bulan',
                subtitleColor: const Color(0xFFBB6600),
                onTap: () => _showFocusLockedSnackbar(context),
              ),
            ],
          ),
          _buildSection(
            label: 'BAHASA',
            children: [
              _buildSettingsTile(
                icon: Icons.favorite_border_rounded,
                title: 'Ubah Bahasa Saya',
                onTap: () => _showComingSoon(context),
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.favorite_border_rounded,
                title: 'Ubah Nada Bicara',
                onTap: () => _showComingSoon(context),
              ),
              _buildDivider(),
              _buildSettingsTile(
                icon: Icons.favorite_border_rounded,
                title: 'Ubah Suara',
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),
          _buildSection(
            label: 'BANTUAN',
            children: [
              _buildSettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Bantuan',
                onTap: () => _showHelpDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: () => _confirmClearHistory(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFCC3333)),
                foregroundColor: const Color(0xFFCC3333),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Hapus Riwayat Percakapan'),
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
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF999999),
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFEEF7E4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF518427)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1A1A1A),
        ),
      ),
      subtitle: subtitle != null
          ? Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: subtitleColor ?? Colors.grey.shade500,
                ),
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 56,
      endIndent: 16,
      color: Color(0xFFF0F0F0),
    );
  }

  void _showAboutDialog(BuildContext context, AIAssistantModel companion) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Image.asset(companion.imagePath, width: 40, height: 40),
            const SizedBox(width: 10),
            Text(companion.name,
                style: const TextStyle(color: Color(0xFF518427))),
          ],
        ),
        content: Text(
          companion.description,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup',
                style: TextStyle(color: Color(0xFF518427))),
          ),
        ],
      ),
    );
  }

  void _showFocusLockedSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fokus Habbit tidak bisa diubah selama 1 bulan'),
        backgroundColor: Color(0xFFBB6600),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur ini segera hadir'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Bantuan'),
        content: const Text(
          'Jika kamu mengalami masalah, hubungi tim MuslimHabit melalui email support@muslimhabit.id atau melalui fitur pesan di aplikasi.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup',
                style: TextStyle(color: Color(0xFF518427))),
          ),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Riwayat?'),
        content: const Text(
          'Seluruh riwayat percakapan akan dihapus dan tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AIChatProvider>().clearHistory();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Riwayat percakapan berhasil dihapus')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

