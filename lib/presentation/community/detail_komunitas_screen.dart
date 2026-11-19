import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/community/community_model.dart';
import '../../models/community/community_post_model.dart';
import '../../providers/community_provider.dart';

class DetailKomunitasScreen extends StatefulWidget {
  final CommunityModel community;

  const DetailKomunitasScreen({super.key, required this.community});

  @override
  State<DetailKomunitasScreen> createState() => _DetailKomunitasScreenState();
}

class _DetailKomunitasScreenState extends State<DetailKomunitasScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final TextEditingController _postCtrl = TextEditingController();
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityProvider>().getPostsForCommunity(widget.community.communityId);
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _postCtrl.dispose();
    super.dispose();
  }

  void _submitPost() async {
    final text = _postCtrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _isPosting = true);
    final provider = context.read<CommunityProvider>();
    await provider.createPost(
      communityId: widget.community.communityId,
      content: text,
    );
    _postCtrl.clear();
    setState(() => _isPosting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Postingan berhasil dibagikan ke komunitas! 🌿'),
          backgroundColor: Color(0xFF4A7C59),
        ),
      );
    }
  }

  void _showCommentSheet(BuildContext context, CommunityPostModel post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CommentSheet(post: post, communityId: widget.community.communityId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();
    final currentUid = provider.currentUser.userId;
    // Ambil data komunitas terupdate dari provider
    final comm = provider.allCommunities.firstWhere(
      (c) => c.communityId == widget.community.communityId,
      orElse: () => widget.community,
    );
    final isJoined = comm.memberIds.contains(currentUid);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF8),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: const Color(0xFF4A7C59),
              elevation: 0,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4A7C59), Color(0xFF2D5A3C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.groups_rounded, size: 34, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          comm.name,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Info Card (Member count & Join/Leave button) ──
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comm.name,
                                style: GoogleFonts.inter(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    comm.privacyLabel,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('•', style: GoogleFonts.inter(color: const Color(0xFFCBD5E1))),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${comm.memberCount} Anggota',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF4A7C59),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (isJoined) {
                              provider.leaveCommunity(comm.communityId);
                            } else {
                              provider.joinCommunity(comm.communityId);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isJoined ? const Color(0xFFF1F5F9) : const Color(0xFF4A7C59),
                            foregroundColor: isJoined ? const Color(0xFF64748B) : Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: Text(
                            isJoined ? 'Keluar' : 'Gabung',
                            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      comm.description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Tab Bar ──
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabCtrl,
                  labelColor: const Color(0xFF4A7C59),
                  unselectedLabelColor: const Color(0xFF94A3B8),
                  indicatorColor: const Color(0xFF4A7C59),
                  indicatorWeight: 3,
                  labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                  tabs: const [
                    Tab(text: 'Postingan'),
                    Tab(text: 'Anggota'),
                    Tab(text: 'Aturan'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            // ── TAB 1: POSTINGAN ──
            _buildPostsTab(context, provider, comm, isJoined),

            // ── TAB 2: ANGGOTA ──
            _buildMembersTab(context, comm),

            // ── TAB 3: ATURAN ──
            _buildRulesTab(context, comm),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TAB 1: POSTINGAN & DISKUSI
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildPostsTab(
    BuildContext context,
    CommunityProvider provider,
    CommunityModel comm,
    bool isJoined,
  ) {
    return FutureBuilder<List<CommunityPostModel>>(
      future: provider.getPostsForCommunity(comm.communityId),
      builder: (context, snapshot) {
        final posts = snapshot.data ?? [];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Input Post Card (jika sudah bergabung) ──
            if (isJoined)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: _postCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Bagikan pengalaman ibadah, tadabbur, atau motivasi...',
                        hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                        border: InputBorder.none,
                      ),
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _isPosting ? null : _submitPost,
                      icon: const Icon(Icons.send_rounded, size: 15),
                      label: Text(
                        'Posting',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A7C59),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Bergabunglah dengan komunitas ini untuk ikut berdiskusi dan berbagi postingan.',
                        style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Posts List ──
            if (posts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'Belum ada postingan di komunitas ini. Jadilah yang pertama!',
                    style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                  ),
                ),
              )
            else
              ...posts.map((post) => _buildPostCard(context, post, provider, comm.communityId)),
          ],
        );
      },
    );
  }

  Widget _buildPostCard(
    BuildContext context,
    CommunityPostModel post,
    CommunityProvider provider,
    String communityId,
  ) {
    final isLiked = post.isLikedBy(provider.currentUser.userId);
    final timeStr = DateFormat('d MMM yyyy, HH:mm').format(post.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFE2E8F0),
                child: Text(
                  post.userName.isNotEmpty ? post.userName[0].toUpperCase() : 'U',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF4A7C59),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.userName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      timeStr,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Post Content
          Text(
            post.content,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              height: 1.45,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 6),

          // Action buttons (Like & Comment)
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  provider.toggleLikePost(communityId, post.postId);
                },
                icon: Icon(
                  isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 18,
                  color: isLiked ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                ),
                label: Text(
                  '${post.likes.length}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isLiked ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () => _showCommentSheet(context, post),
                icon: const Icon(Icons.mode_comment_outlined, size: 17, color: Color(0xFF64748B)),
                label: Text(
                  '${post.commentCount} Komentar',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TAB 2: ANGGOTA
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildMembersTab(BuildContext context, CommunityModel comm) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMemberTile('Admin Utama', 'Admin', Icons.verified_user_rounded, const Color(0xFF4A7C59)),
        _buildMemberTile('Maulana Adiatma', 'Moderator', Icons.shield_rounded, const Color(0xFF2563EB)),
        _buildMemberTile('Fatimah Dwi Fitri', 'Anggota', Icons.person_rounded, const Color(0xFF64748B)),
        _buildMemberTile('Alya Fahira', 'Anggota', Icons.person_rounded, const Color(0xFF64748B)),
        _buildMemberTile('Ikhsan Nur Saputra', 'Anggota', Icons.person_rounded, const Color(0xFF64748B)),
      ],
    );
  }

  Widget _buildMemberTile(String name, String role, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              role,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // TAB 3: ATURAN
  // ─────────────────────────────────────────────────────────────────────────────
  Widget _buildRulesTab(BuildContext context, CommunityModel comm) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.rule_rounded, color: Color(0xFF4A7C59), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Aturan & Adab Komunitas',
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                comm.rules,
                style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF334155), height: 1.5),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _buildRuleItem('1. Menggunakan bahasa yang santun dan menjunjung tinggi adab ukhuwah.'),
              _buildRuleItem('2. Tidak menyebarkan berita bohong (hoaks) atau ujaran kebencian.'),
              _buildRuleItem('3. Menjaga privasi sesama anggota komunitas.'),
              _buildRuleItem('4. Diskusi difokuskan pada peningkatan iman dan amal shaleh.'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF64748B), height: 1.4),
      ),
    );
  }
}

class _CommentSheet extends StatefulWidget {
  final CommunityPostModel post;
  final String communityId;

  const _CommentSheet({required this.post, required this.communityId});

  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  final TextEditingController _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Komentar',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<CommunityCommentModel>>(
              future: provider.getCommentsForPost(widget.post.postId),
              builder: (context, snapshot) {
                final comments = snapshot.data ?? [];
                if (comments.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada komentar. Tulis komentar pertamamu!',
                      style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, i) {
                    final c = comments[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFFE2E8F0),
                            child: Text(
                              c.userName[0],
                              style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF4A7C59)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAF7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.userName,
                                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    c.content,
                                    style: GoogleFonts.inter(fontSize: 12.5, color: const Color(0xFF334155)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentCtrl,
                  decoration: InputDecoration(
                    hintText: 'Tulis komentar santun...',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF1F5F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () async {
                  final text = _commentCtrl.text.trim();
                  if (text.isEmpty) return;
                  await provider.addComment(
                    communityId: widget.communityId,
                    postId: widget.post.postId,
                    content: text,
                  );
                  _commentCtrl.clear();
                  setState(() {});
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF4A7C59),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
