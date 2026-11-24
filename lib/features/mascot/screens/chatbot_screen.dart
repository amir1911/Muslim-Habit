import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/mascot_provider.dart';

class _ChatMessageItem {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  _ChatMessageItem({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

/// Halaman Chatbot Maskot Nunu (ChatbotScreen)
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  final List<_ChatMessageItem> _messages = [
    _ChatMessageItem(
      text: 'Assalamualaikum! Senang banget bisa ngobrol sama kamu hari ini! Ada yang ingin kamu ceritakan atau tanyakan seputar ibadahmu?',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];

  final List<String> _quickChips = [
    'Aku hari ini berhasil sholat 5 waktu!',
    'Bagaimana tips istiqomah ibadah?',
    'Beri aku doa penenang hati',
    'Semangati aku hari ini!',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend(String message) {
    final query = message.trim();
    if (query.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      _messages.add(
        _ChatMessageItem(
          text: query,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });
    _textController.clear();
    _scrollToBottom();

    // Simulasi respon cerdas Nunu dengan typing delay
    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      final reply = _generateNunuReply(query);
      setState(() {
        _isTyping = false;
        _messages.add(
          _ChatMessageItem(
            text: reply,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });
      _scrollToBottom();
    });
  }

  String _generateNunuReply(String input) {
    final lower = input.toLowerCase();

    if (lower.contains('sholat 5 waktu') || lower.contains('berhasil') || lower.contains('selesai')) {
      return 'MasyaAllah! Hebat banget! Aku bangga banget sama kamu. Yuk, terus pertahankan kebiasaan baik ini ya sahabatku!';
    }
    if (lower.contains('tips') || lower.contains('istiqomah') || lower.contains('malas')) {
      return 'Kuncinya adalah mulai dari amalan kecil yang konsisten, sebagaimana sabda Rasulullah ﷺ: "Amalan yang paling dicintai Allah adalah yang terus-menerus meskipun sedikit." Jangan lupa pasang niat ikhlas ya!';
    }
    if (lower.contains('doa') || lower.contains('tenang') || lower.contains('sedih')) {
      return 'Bacalah doa ini: "Yaa Muqallibal quluub, tsabbit qalbii \'alaa diinik" (Wahai Dzat yang membolak-balikkan hati, teguhkanlah hatiku di atas agama-Mu). Semoga hatimu selalu diliputi ketenangan!';
    }
    if (lower.contains('semangat') || lower.contains('capek') || lower.contains('lelah')) {
      return 'Semangat terus ya! Ingat, setiap langkah dan letihmu dalam kebaikan dicatat sebagai pahala berlimpah di sisi Allah. Nunu selalu ada di sini mendukungmu!';
    }
    if (lower.contains('quran') || lower.contains('tilawah') || lower.contains('ayat')) {
      return 'Alhamdulillah! Membaca satu huruf Al-Qur\'an bernilai sepuluh kebaikan lho. Mau baca berapa ayat hari ini? Nunu temani ya!';
    }
    if (lower.contains('makasih') || lower.contains('terima kasih')) {
      return 'Sama-sama sahabatku! Senang banget bisa menemani perjalanan ibadahmu. Tetap jaga kesehatan dan semangat ya!';
    }

    return 'MasyaAllah, terima kasih sudah berbagi cerita sama aku. Apapun yang sedang kamu usahakan hari ini, semoga Allah mudahkan dan berkahi setiap langkahmu!';
  }

  @override
  Widget build(BuildContext context) {
    final mascotProv = context.watch<MascotProvider>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F6EE),
        body: SafeArea(
          child: Column(
            children: [
              // ── 1. HEADER CHATBOT (AVATAR NUNU, STATUS, TOMBOL KEMBALI) ──
              _buildChatHeader(context, mascotProv),

              // ── 2. DAFTAR PESAN PERCAKAPAN ──
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return _buildMessageBubble(msg, mascotProv);
                  },
                ),
              ),

              // ── 3. TYPING INDICATOR ──
              if (_isTyping)
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF55822B),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Nunu sedang mengetik...',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontStyle: FontStyle.italic,
                                color: const Color(0xFF75856B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // ── 4. QUICK ACTION CHIPS ──
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _quickChips.length,
                  itemBuilder: (context, index) {
                    final chip = _quickChips[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(
                          chip,
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2E5714),
                          ),
                        ),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFD6DEC9)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        onPressed: () => _handleSend(chip),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // ── 5. INPUT BARIS PESAN ──
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // HEADER CHATBOT
  // ==========================================
  Widget _buildChatHeader(BuildContext context, MascotProvider mascotProv) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE5EDE0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFF2E5714),
              size: 28,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),

          // Avatar Nunu
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2E3),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF55822B), width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/mascot_nunu.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.pets_rounded,
                  color: Color(0xFF55822B),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Nama & Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nunu',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2E5714),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00C853),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Teman Ibadahmu',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF75856B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BUBBLE PESAN
  // ==========================================
  Widget _buildMessageBubble(_ChatMessageItem msg, MascotProvider mascotProv) {
    final timeStr = DateFormat('HH:mm').format(msg.timestamp);

    if (msg.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              timeStr,
              style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF9E9E9E)),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF55822B),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E5714).withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  msg.text,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: Colors.white,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Mini Avatar Nunu
            CircleAvatar(
              radius: 15,
              backgroundColor: const Color(0xFFEAF2E3),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/mascot_nunu.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.pets_rounded,
                    size: 16,
                    color: Color(0xFF55822B),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                    bottomLeft: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  msg.text,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: const Color(0xFF1F2937),
                    height: 1.35,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              timeStr,
              style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF9E9E9E)),
            ),
          ],
        ),
      );
    }
  }

  // ==========================================
  // INPUT BARIS PESAN
  // ==========================================
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5EDE0), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F6EE),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFD6DEC9)),
              ),
              child: TextField(
                controller: _textController,
                textInputAction: TextInputAction.send,
                onSubmitted: _handleSend,
                decoration: InputDecoration(
                  hintText: 'Tulis pesan untuk Nunu...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF9E9E9E),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF55822B),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: () => _handleSend(_textController.text),
            ),
          ),
        ],
      ),
    );
  }
}
