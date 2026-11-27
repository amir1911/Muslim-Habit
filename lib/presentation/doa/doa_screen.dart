import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/doa_category_meta.dart';
import '../../providers/doa_provider.dart';
import '../../core/widgets/custom_back_button.dart';
import 'doa_category_detail_screen.dart';
import 'doa_detail_screen.dart';
import 'widgets/doa_category_card.dart';
import 'widgets/doa_list_item_card.dart';

class DoaScreen extends StatefulWidget {
  const DoaScreen({super.key});

  @override
  State<DoaScreen> createState() => _DoaScreenState();
}

class _DoaScreenState extends State<DoaScreen> {
  // 0: "Semua Doa", 1: "Doa Saya"
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doaProvider = context.watch<DoaProvider>();

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AppBar(
          backgroundColor: const Color(0xFF518427),
          elevation: 0,
          leadingWidth: 56,
          leading: const Padding(
            padding: EdgeInsets.only(left: 10),
            child: CustomBackButton(),
          ),
          titleSpacing: 10,
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'Cari doa harian...',
                    hintStyle: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
                    border: InputBorder.none,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                )
              : Text(
                  'Doa-doa',
                  style: GoogleFonts.balooTammudu2(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: IconButton(
                icon: Icon(
                  _isSearching ? Icons.close_rounded : Icons.search_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  setState(() {
                    if (_isSearching) {
                      _isSearching = false;
                      _searchController.clear();
                      _searchQuery = '';
                    } else {
                      _isSearching = true;
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
      body: doaProvider.isLoading && doaProvider.allDoa.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF518427)),
            )
          : Column(
              children: [
                const SizedBox(height: 16),

                // ─── TAB TOGGLE SWITCH: "Semua Doa" vs "Doa Saya" ───
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E0D4),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      children: [
                        // Tab "Semua Doa"
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTabIndex = 0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _selectedTabIndex == 0
                                    ? const Color(0xFF518427)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Semua Doa',
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: _selectedTabIndex == 0
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: _selectedTabIndex == 0
                                      ? Colors.white
                                      : const Color(0xFF333333),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Tab "Doa Saya"
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTabIndex = 1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _selectedTabIndex == 1
                                    ? const Color(0xFF518427)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Doa Saya',
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: _selectedTabIndex == 1
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: _selectedTabIndex == 1
                                      ? Colors.white
                                      : const Color(0xFF333333),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ─── CONTENT AREA ───
                Expanded(
                  child: _isSearching && _searchQuery.isNotEmpty
                      ? _buildSearchResults(context, doaProvider)
                      : (_selectedTabIndex == 0
                          ? _buildSemuaDoaTab(context, doaProvider)
                          : _buildDoaSayaTab(context, doaProvider)),
                ),
              ],
            ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TAB 1: SEMUA DOA (GRID KATEGORI)
  // ─────────────────────────────────────────────────────────────
  Widget _buildSemuaDoaTab(BuildContext context, DoaProvider provider) {
    final categories = DoaCategoryMeta.allCategories;

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 36),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.34,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final count = provider.getCountForCategory(cat.matchingGroups);

        return DoaCategoryCard(
          category: cat,
          count: count,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DoaCategoryDetailScreen(category: cat),
              ),
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TAB 2: DOA SAYA (LIST FAVORIT / DISIMPAN)
  // ─────────────────────────────────────────────────────────────
  Widget _buildDoaSayaTab(BuildContext context, DoaProvider provider) {
    final favList = provider.favoriteDoaList;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
      children: [
        // Section Header: Praying Icon + "Kategori"
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF6B8E4E).withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.volunteer_activism_rounded,
                size: 18,
                color: Color(0xFF4A6F29),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Kategori',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E2818),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        if (favList.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFECEADF)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.bookmark_border_rounded,
                  size: 54,
                  color: Color(0xFFB5BAAE),
                ),
                const SizedBox(height: 12),
                Text(
                  'Belum ada Doa Saya',
                  style: GoogleFonts.balooTammudu2(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E2818),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Buka doa apa pun dari tab "Semua Doa" lalu klik ikon bookmark untuk menyimpannya di sini.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF6B7264),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: favList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final doa = favList[index];
              return DoaListItemCard(
                index: index + 1,
                doa: doa,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoaDetailScreen(doa: doa),
                    ),
                  );
                },
              );
            },
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SEARCH RESULTS OVERLAY
  // ─────────────────────────────────────────────────────────────
  Widget _buildSearchResults(BuildContext context, DoaProvider provider) {
    final q = _searchQuery.toLowerCase();
    final results = provider.allDoa.where((d) {
      return d.nama.toLowerCase().contains(q) ||
          d.idn.toLowerCase().contains(q) ||
          d.tr.toLowerCase().contains(q) ||
          d.grup.toLowerCase().contains(q);
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off_rounded, size: 52, color: Colors.grey),
              const SizedBox(height: 12),
              Text(
                'Tidak ada doa ditemukan',
                style: GoogleFonts.balooTammudu2(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Coba gunakan kata kunci lain.',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final doa = results[index];
        return DoaListItemCard(
          index: index + 1,
          doa: doa,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DoaDetailScreen(doa: doa)),
            );
          },
        );
      },
    );
  }
}
