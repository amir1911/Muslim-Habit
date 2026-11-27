import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/doa_category_meta.dart';
import '../../models/doa_item.dart';
import '../../providers/doa_provider.dart';
import '../../core/widgets/custom_back_button.dart';
import 'doa_detail_screen.dart';
import 'widgets/doa_list_item_card.dart';

class DoaCategoryDetailScreen extends StatefulWidget {
  final DoaCategoryMeta category;

  const DoaCategoryDetailScreen({
    super.key,
    required this.category,
  });

  @override
  State<DoaCategoryDetailScreen> createState() => _DoaCategoryDetailScreenState();
}

class _DoaCategoryDetailScreenState extends State<DoaCategoryDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doaProvider = context.watch<DoaProvider>();
    final allDoas = doaProvider.getDoaForCategory(widget.category.matchingGroups);

    final filtered = _query.isEmpty
        ? allDoas
        : allDoas.where((d) {
            final q = _query.toLowerCase();
            return d.nama.toLowerCase().contains(q) ||
                d.idn.toLowerCase().contains(q) ||
                d.tr.toLowerCase().contains(q);
          }).toList();

    // Doa hari ini recommendation (misal item pertama yang belum dibaca hari ini)
    DoaItem? featuredDoa;
    for (final item in allDoas) {
      if (!doaProvider.isReadToday(item.id)) {
        featuredDoa = item;
        break;
      }
    }
    featuredDoa ??= allDoas.isNotEmpty ? allDoas.first : null;

    final readCount = allDoas.where((d) => doaProvider.isReadToday(d.id)).length;
    final totalCount = allDoas.length;
    final progressVal = totalCount > 0 ? (readCount / totalCount).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: AppBar(
          backgroundColor: const Color(0xFF518427),
          elevation: 0,
          leading: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: CustomBackButton(),
          ),
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'Cari dalam ${widget.category.title}...',
                    hintStyle: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
                    border: InputBorder.none,
                  ),
                  onChanged: (val) => setState(() => _query = val),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.category.title,
                      style: GoogleFonts.balooTammudu2(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                    Text(
                      '$totalCount Bagian',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
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
                      _query = '';
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
      body: _buildBody(context, doaProvider, allDoas, filtered, featuredDoa, readCount, totalCount, progressVal),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DoaProvider doaProvider,
    List<DoaItem> allDoas,
    List<DoaItem> filtered,
    DoaItem? featuredDoa,
    int readCount,
    int totalCount,
    double progressVal,
  ) {
    // ── State: Sedang memuat dari API ──
    if (doaProvider.isLoading && doaProvider.allDoa.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF518427)),
            SizedBox(height: 16),
            Text('Memuat doa dari server...'),
          ],
        ),
      );
    }

    // ── State: Error / Gagal memuat ──
    if (doaProvider.errorMessage != null && doaProvider.allDoa.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 56, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat doa',
                style: GoogleFonts.balooTammudu2(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E2818),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Periksa koneksi internet Anda dan coba lagi.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => doaProvider.loadDoaList(forceRefresh: true),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF518427),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── State: Data tersedia (normal) ──
    return ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        children: [
          // ─── HERO BANNER: "Doa hari ini" ───
          if (featuredDoa != null && !_isSearching) ...[
            _buildFeaturedCard(context, featuredDoa, readCount, totalCount, progressVal, doaProvider),
            const SizedBox(height: 22),
          ],

          // ─── SECTION HEADER: "Kategori" ───
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

          // ─── LIST OF DOA CARDS ───
          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    'Tidak ada doa yang cocok',
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final doa = filtered[idx];
                return DoaListItemCard(
                  index: idx + 1,
                  doa: doa,
                  onTap: () {
                    doaProvider.markAsRead(doa.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DoaDetailScreen(doa: doa)),
                    );
                  },
                );
              },
            ),
        ],
    );
  }

  Widget _buildFeaturedCard(
    BuildContext context,
    DoaItem featured,
    int readCount,
    int totalCount,
    double progress,
    DoaProvider provider,
  ) {
    final isRead = provider.isReadToday(featured.id);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF385523),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF385523).withValues(alpha: 0.28),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Sparkling star icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Text info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Doa hari ini',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${featured.nama} - ${isRead ? "Sudah dibaca" : "Belum dibaca"}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // "Baca" Button
              ElevatedButton(
                onPressed: () {
                  provider.markAsRead(featured.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DoaDetailScreen(doa: featured)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF385523),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: const Size(0, 34),
                ),
                child: Text(
                  'Baca',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Bar and Text
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: Colors.white.withValues(alpha: 0.22),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$readCount/$totalCount doa hari ini',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.88),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
