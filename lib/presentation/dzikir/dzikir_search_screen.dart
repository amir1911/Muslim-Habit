import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/dzikir/dzikir_item_model.dart';
import '../../providers/dzikir_provider.dart';
import 'dzikir_session_screen.dart';
import '../../core/widgets/custom_back_button.dart';

class DzikirSearchScreen extends StatefulWidget {
  final String? initialQuery;

  const DzikirSearchScreen({super.key, this.initialQuery});

  @override
  State<DzikirSearchScreen> createState() => _DzikirSearchScreenState();
}

class _DzikirSearchScreenState extends State<DzikirSearchScreen> {
  late TextEditingController _searchCtrl;
  List<DzikirItemModel> _results = [];

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.initialQuery ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_searchCtrl.text.isNotEmpty) {
        _performSearch(_searchCtrl.text);
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    final provider = context.read<DzikirProvider>();
    setState(() {
      _results = provider.searchDzikir(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DzikirProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF518427),
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 8),
          child: CustomBackButton(),
        ),
        title: Text(
          'Pencarian Dzikir',
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
            // Search Input Box
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  onChanged: _performSearch,
                  style: GoogleFonts.inter(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Cari dzikir, doa, atau transliterasi...',
                    hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF518427)),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            // Quick suggestion chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildChip('Subhanallah'),
                    _buildChip('Alhamdulillah'),
                    _buildChip('Astaghfirullah'),
                    _buildChip('Ayat Kursi'),
                    _buildChip('Sayyidul Istighfar'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Search results list
            Expanded(
              child: _searchCtrl.text.trim().isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_rounded, size: 56, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'Ketik nama dzikir untuk mencari',
                            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : _results.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.info_outline_rounded, size: 56, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text(
                                'Dzikir tidak ditemukan',
                                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _results.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = _results[index];
                            final cat = provider.categories.firstWhere(
                              (c) => c.id == item.categoryId,
                              orElse: () => provider.categories.first,
                            );

                            return GestureDetector(
                              onTap: () {
                                final itemIndex = cat.items.indexWhere((i) => i.id == item.id);
                                provider.selectCategory(cat, initialIndex: itemIndex != -1 ? itemIndex : 0);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DzikirSessionScreen(
                                      category: cat,
                                      initialIndex: itemIndex != -1 ? itemIndex : 0,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
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
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF518427).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.spa_rounded, color: Color(0xFF518427), size: 22),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF1B432C),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            item.transliteration,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                              color: const Color(0xFF518427),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Kategori: ${cat.name}',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                      color: Color(0xFF518427),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        labelStyle: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF518427), fontWeight: FontWeight.w600),
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF9AC07A)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onPressed: () {
          _searchCtrl.text = label;
          _performSearch(label);
        },
      ),
    );
  }
}
