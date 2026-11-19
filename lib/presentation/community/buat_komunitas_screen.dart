import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/community_provider.dart';

class BuatKomunitasScreen extends StatefulWidget {
  const BuatKomunitasScreen({super.key});

  @override
  State<BuatKomunitasScreen> createState() => _BuatKomunitasScreenState();
}

class _BuatKomunitasScreenState extends State<BuatKomunitasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _rulesCtrl = TextEditingController();

  String _selectedCategory = 'Al-Qur\'an';
  bool _isPrivate = false;
  bool _isLoading = false;

  final List<String> _categories = [
    'Al-Qur\'an',
    'Tahajud',
    'Dhuha',
    'Kajian Islam',
    'Hafalan',
    'Ibadah Harian',
    'Muslim Produktif',
    'Diskusi Keislaman',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _rulesCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<CommunityProvider>();
    await provider.createCommunity(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _selectedCategory,
      isPrivate: _isPrivate,
      rules: _rulesCtrl.text.trim().isNotEmpty
          ? _rulesCtrl.text.trim()
          : 'Menjaga adab ukhuwah Islami dan saling menghormati.',
    );

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Komunitas "${_nameCtrl.text}" berhasil dibuat! 🌿'),
          backgroundColor: const Color(0xFF4A7C59),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(
          'Buat Komunitas',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Card Icon / Cover Preview ──
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A7C59), Color(0xFF2D5A3C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A7C59).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.groups_rounded, size: 44, color: Colors.white),
              ),
            ),
            const SizedBox(height: 24),

            // ── Nama Komunitas ──
            Text('Nama Komunitas', style: _labelStyle),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameCtrl,
              decoration: _inputDecoration('Contoh: Pejuang Subuh Berjamaah'),
              validator: (val) => val == null || val.trim().isEmpty ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 18),

            // ── Kategori Komunitas ──
            Text('Kategori Komunitas', style: _labelStyle),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF4A7C59)),
                  items: _categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ── Deskripsi ──
            Text('Deskripsi Komunitas', style: _labelStyle),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: _inputDecoration('Tujuan dan visi komunitas Islami ini...'),
              validator: (val) => val == null || val.trim().isEmpty ? 'Deskripsi wajib diisi' : null,
            ),
            const SizedBox(height: 18),

            // ── Aturan Komunitas ──
            Text('Aturan Komunitas (Opsional)', style: _labelStyle),
            const SizedBox(height: 6),
            TextFormField(
              controller: _rulesCtrl,
              maxLines: 2,
              decoration: _inputDecoration('Contoh: Menjaga lisan, tidak berdebat kusir...'),
            ),
            const SizedBox(height: 18),

            // ── Jenis Komunitas (Publik / Privat) ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A7C59).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPrivate ? Icons.lock_rounded : Icons.public_rounded,
                      color: const Color(0xFF4A7C59),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isPrivate ? 'Komunitas Privat (Invite Only)' : 'Komunitas Publik',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          _isPrivate
                              ? 'Anggota butuh persetujuan admin untuk bergabung'
                              : 'Semua pengguna Muslim Habit dapat langsung bergabung',
                          style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isPrivate,
                    activeColor: const Color(0xFF4A7C59),
                    onChanged: (val) => setState(() => _isPrivate = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Tombol Simpan ──
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A7C59),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Buat Komunitas',
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle get _labelStyle => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF334155),
      );

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF4A7C59), width: 1.5),
      ),
    );
  }
}
