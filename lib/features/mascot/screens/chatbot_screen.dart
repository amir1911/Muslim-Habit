import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/ai_assistant_model.dart';
import '../../../providers/habit_provider.dart';
import '../../ai_companion/models/chat_message.dart';
import '../../ai_companion/services/ai_model_service.dart';
import '../../ai_companion/screens/companion_settings_screen.dart';
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

/// Halaman Chatbot Maskot Interaktif (ChatbotScreen)
/// Mendukung respon cerdas memahami isi pesan, multi-turn context, serta persona karakter (Lulu, Nunu, Riri).
class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  String? _lastTopic; // Untuk menjaga kontinuitas konteks percakapan

  late List<_ChatMessageItem> _messages;
  bool _initialized = false;

  final List<String> _quickChips = [
    'Aku belum shalat hari ini',
    'Bagaimana menjaga konsisten shalat?',
    'Aku hari ini berhasil sholat 5 waktu!',
    'Aku lagi malas ibadah',
    'Doa sebelum tidur apa?',
    'Beri aku doa penenang hati',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final habitProv = context.read<HabitProvider>();
      final assistant = habitProv.currentAssistant;
      _messages = [
        _ChatMessageItem(
          text: _getInitialGreeting(assistant),
          isUser: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
      ];
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getInitialGreeting(AIAssistantModel assistant) {
    switch (assistant.id.toLowerCase()) {
      case 'kid':
      case 'lulu':
        return 'Assalamualaikum sahabat kecil! 🌟 Aku Lulu, siap nemenin kamu belajar dan ibadah dengan ceria hari ini! Mau cerita apa ke Lulu?';
      case 'adult':
      case 'riri':
        return 'Assalamualaikum warahmatullah. Saya Riri, pendamping ibadah Anda di Muslim Habit. Bagaimana kabar ibadah dan ketenangan batin Anda hari ini? Ada yang ingin didiskusikan?';
      case 'teen':
      case 'nunu':
      default:
        return 'Assalamualaikum! Senang banget bisa ngobrol sama kamu hari ini! Aku Nunu, teman ibadahmu. Ada yang ingin kamu ceritakan atau tanyakan seputar ibadahmu hari ini?';
    }
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

  void _handleSend(String message) async {
    final query = message.trim();
    if (query.isEmpty) return;

    final habitProv = context.read<HabitProvider>();
    final assistant = habitProv.currentAssistant;

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

    String reply = '';

    // 1. Prioritaskan integrasi live dengan Google Gemini API
    try {
      final history = _messages
          .map((m) => ChatMessage(
                id: m.timestamp.millisecondsSinceEpoch.toString(),
                userId: 'user',
                companionId: assistant.id,
                content: m.text,
                sender: m.isUser ? ChatMessageSender.user : ChatMessageSender.companion,
                timestamp: m.timestamp,
              ))
          .toList();

      final res = await AIModelService().sendMessage(
        userMessage: query,
        conversationHistory: history,
        companionId: assistant.id,
        userName: habitProv.userName,
        habitSummary: '${habitProv.completedHabitsCount}/${habitProv.totalHabitsCount} selesai',
        activePrayer: 'Sholat Wajib',
      );

      if (res.isSuccess && res.text.trim().isNotEmpty) {
        reply = res.text.trim();
      }
    } catch (_) {
      // Fallback ditangani di bawah
    }

    // 2. Fallback ke sistem respon cerdas lokal jika Gemini API offline/terkendala
    if (reply.isEmpty) {
      reply = _generateSmartReply(query, assistant);
    }

    if (!mounted) return;
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
  }

  /// Generator respon cerdas dengan pemahaman intent, topik konteks, dan gaya karakter maskot
  String _generateSmartReply(String input, AIAssistantModel assistant) {
    final lower = input.toLowerCase();
    final characterId = assistant.id.toLowerCase();
    final name = assistant.name;

    // ──────────────────────────────────────────
    // 1. KASUS: PENGGUNA BELUM SALAT
    // ──────────────────────────────────────────
    if ((lower.contains('belum') || lower.contains('blm') || lower.contains('terlewat') || lower.contains('lupa')) &&
        (lower.contains('sholat') || lower.contains('shalat') || lower.contains('solat'))) {
      _lastTopic = 'sholat_belum';
      if (characterId == 'kid' || characterId == 'lulu') {
        return 'Jangan sedih ya! 🕌 Masih ada kesempatan kok. Yuk segera wudhu bareng $name dan kerjakan sholat yang sedang berlangsung sekarang. Pelan-pelan kita belajar tepat waktu ya!';
      } else if (characterId == 'adult' || characterId == 'riri') {
        return 'Alhamdulillah Anda menyadarinya. Jangan biarkan waktu terus berlalu dalam penundaan. Segeralah ambil air wudhu dan dirikan salat yang waktunya sedang berlangsung, lalu qadha jika ada yang terlewat. Allah Maha Pengampun lagi Maha Penyayang.';
      } else {
        // Nunu (Teen)
        return 'Yuk, jangan menunda salatnya! Kamu bisa mulai dengan menunaikan salat yang waktunya sedang berlangsung sekarang. Pelan-pelan kita bangun kebiasaan baik ini bersama, ya!';
      }
    }

    // ──────────────────────────────────────────
    // 2. KASUS: CARA / TIPS KONSISTEN & ISTIQOMAH SALAT
    // ──────────────────────────────────────────
    if ((lower.contains('konsisten') || lower.contains('istiqomah') || lower.contains('tips') || lower.contains('cara')) &&
            (lower.contains('sholat') || lower.contains('shalat') || lower.contains('solat') || lower.contains('ibadah')) ||
        ((lower.contains('tidak lupa') || lower.contains('nggak lupa') || lower.contains('biar rajin')) && _lastTopic == 'sholat_belum')) {
      _lastTopic = 'sholat_tips';
      if (characterId == 'kid' || characterId == 'lulu') {
        return 'Aku punya tips seru nih! ✨\n1. Minta bantuan orang tua ingatkan waktu sholat.\n2. Siapkan sajadah dan baju sholat kesukaanmu.\n3. Jangan lupa tandai selesai di checklist Muslim Habit biar dapat bintang!';
      } else if (characterId == 'adult' || characterId == 'riri') {
        return 'Untuk menjaga konsistensi salat:\n1. Pahami bahwa salat adalah sarana komunikasi utama kita dengan Allah, bukan sekadar kewajiban formal.\n2. Jadwalkan aktivitas harian berpatokan pada waktu salat, bukan sebaliknya.\n3. Aktifkan pengingat sebelum azan di aplikasi Muslim Habit agar hati dan pikiran siap sebelum azan berkumandang.\n4. Berdoa memohon keistiqamahan: "Rabbij\'alnii muqiimash shalaati wa min dzurriyyatii".';
      } else {
        // Nunu (Teen)
        return 'Aku punya beberapa tips jitu!\n1. Pasang pengingat sebelum waktu salat di Muslim Habit agar kamu bersiap lebih awal.\n2. Siapkan sajadah dan perlengkapan salat di tempat yang mudah dijangkau.\n3. Begitu azan berkumandang, langsung berwudhu dan jangan menunda.\n4. Mulai dari langkah kecil yang konsisten kamu pertahankan setiap hari!';
      }
    }

    // ──────────────────────────────────────────
    // 3. KASUS: BERHASIL SALAT 5 WAKTU / TUNTAS IBADAH
    // ──────────────────────────────────────────
    if (lower.contains('berhasil') || lower.contains('5 waktu') || lower.contains('lima waktu') || lower.contains('selesai sholat') || lower.contains('sudah sholat')) {
      _lastTopic = 'pencapaian';
      if (characterId == 'kid' || characterId == 'lulu') {
        return 'MasyaAllah! Hebat banget kamu! 🌟 $name bangga sekali sama kamu! Terus semangat ya anak sholeh/sholehah, semoga Allah selalu sayang kamu! ✨';
      } else if (characterId == 'adult' || characterId == 'riri') {
        return 'Alhamdulillah, masyaAllah. Pencapaian yang sangat berkah. Semoga Allah menerima seluruh amal ibadah Anda, menggugurkan kekhilafan, dan mengistiqamahkan langkah Anda di jalan ketaatan.';
      } else {
        // Nunu (Teen)
        return 'MasyaAllah! Hebat sekali! Aku ikut senang dan bangga melihat semangatmu hari ini. Pertahankan kebiasaan baik ini ya sahabatku!';
      }
    }

    // ──────────────────────────────────────────
    // 4. KASUS: SEDANG MALAS BERIBADAH / FUTUR
    // ──────────────────────────────────────────
    if (lower.contains('malas') || lower.contains('mager') || lower.contains('berat') || lower.contains('futur') || lower.contains('hilang semangat')) {
      _lastTopic = 'motivasi';
      if (characterId == 'kid' || characterId == 'lulu') {
        return 'Gak apa-apa, kadang kita memang capek. Tapi yuk gerak sedikit, ambil air wudhu biar segar! Sholatnya pelan-pelan aja, $name temani dari sini ya! 🐪✨';
      } else if (characterId == 'adult' || characterId == 'riri') {
        return 'Iman manusia memang mengalami pasang dan surut. Itu adalah hal yang manusiawi. Kuncinya adalah jangan menunggu dorongan semangat datang untuk berbuat taat. Paksa diri Anda untuk memulai dari langkah paling ringan: berwudhu dan salat dua rakaat. Niscaya rahmat dan ketenangan batin akan menyusul.';
      } else {
        // Nunu (Teen)
        return 'Kadang semangat memang naik turun, itu wajar kok. Tidak apa-apa, yuk mulai dari satu langkah kecil. Jangan menunggu semangat datang baru melakukan kebaikan. Coba ambil wudhu dulu, insyaAllah badan dan hatimu jadi segar kembali!';
      }
    }

    // ──────────────────────────────────────────
    // 5. KASUS: DOA SPESIFIK & PERMINTAAN DOA
    // ──────────────────────────────────────────
    if (lower.contains('doa')) {
      _lastTopic = 'doa';

      // A. Doa sebelum tidur
      if (lower.contains('tidur')) {
        return 'Berikut doa sebelum tidur yang shahih:\n\n'
            'بِاسْمِكَ اللّٰهُمَّ أَحْيَا وَأَمُوتُ\n'
            'Bismika Allahumma ahyaa wa amuut.\n\n'
            'Artinya: "Dengan nama-Mu ya Allah, aku hidup dan aku mati." (HR. Bukhari)\n\n'
            'Selamat beristirahat ya! Jangan lupa berwudhu dan membaca ayat kursi sebelum tidur.';
      }

      // B. Doa bangun tidur
      if (lower.contains('bangun')) {
        return 'Berikut doa bangun tidur:\n\n'
            'اَلْحَمْدُ لِلّٰهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ\n'
            'Alhamdulillahil ladzii ahyaanaa ba\'da maa amaatanaa wa ilaihin nusyuur.\n\n'
            'Artinya: "Segala puji bagi Allah yang telah menghidupkan kami setelah mematikan kami, dan hanya kepada-Nya kami kembali." (HR. Bukhari)';
      }

      // C. Doa penenang hati / sedih / cemas
      if (lower.contains('tenang') || lower.contains('hati') || lower.contains('sedih') || lower.contains('cemas') || lower.contains('gelisah')) {
        return 'Bacalah doa penenang hati yang sering dibaca Rasulullah ﷺ ini:\n\n'
            'يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ\n'
            'Yaa Muqallibal quluub, tsabbit qalbii \'alaa diinik.\n\n'
            'Artinya: "Wahai Dzat yang membolak-balikkan hati, teguhkanlah hatiku di atas agama-Mu." (HR. Tirmidzi)\n\n'
            'Semoga hatimu senantiasa diliputi ketenangan dan perlindungan Allah.';
      }

      // D. Doa untuk orang tua
      if (lower.contains('orang tua') || lower.contains('ibu') || lower.contains('ayah')) {
        return 'Berikut doa untuk kedua orang tua:\n\n'
            'رَبِّ اغْفِرْ لِي وَلِوَالِدَيَّ وَارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا\n'
            'Rabbighfir lii wa liwaalidayya warhamhumaa kamaa rabbayaanii shaghiiraa.\n\n'
            'Artinya: "Ya Tuhanku, ampunilah aku dan kedua orang tuaku, serta sayangilah mereka sebagaimana mereka telah mendidikku di waktu kecil."';
      }

      // E. Doa keluar rumah
      if (lower.contains('keluar') || lower.contains('pergi') || lower.contains('kendaraan')) {
        return 'Berikut doa keluar rumah agar selalu dalam lindungan Allah:\n\n'
            'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ\n'
            'Bismillahi tawakkaltu \'alallah, laa hawla wa laa quwwata illaa billaah.\n\n'
            'Artinya: "Dengan nama Allah, aku bertawakal kepada Allah, tiada daya dan upaya kecuali dengan pertolongan Allah." (HR. Abu Dawud)';
      }

      // Doa umum
      return 'Kamu bisa membaca doa kebaikan dunia dan akhirat ini:\n\n'
          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ\n'
          'Rabbanaa aatinaa fid-dunyaa hasanah, wa fil-aakhirati hasanah, wa qinaa \'adzaaban-naar.\n\n'
          'Artinya: "Ya Tuhan kami, berikanlah kami kebaikan di dunia dan kebaikan di akhirat, dan lindungilah kami dari siksa api neraka."';
    }

    // ──────────────────────────────────────────
    // 6. KASUS: AL-QUR'AN / TILAWAH
    // ──────────────────────────────────────────
    if (lower.contains('quran') || lower.contains('tilawah') || lower.contains('mengaji') || lower.contains('baca ayat')) {
      _lastTopic = 'quran';
      if (characterId == 'kid' || characterId == 'lulu') {
        return 'Alhamdulillah! Membaca Al-Qur\'an pahalanya banyak banget lho! Satu huruf dapat 10 kebaikan 🌟. Mau baca berapa ayat hari ini? Lulu temani ya!';
      } else {
        return 'MasyaAllah, tilawah Al-Qur\'an adalah penyejuk hati terbaik. Rasulullah ﷺ bersabda bahwa Al-Qur\'an akan datang sebagai pemberi syafaat di hari kiamat bagi orang yang membacanya. Mulai dari satu halaman hari ini, lalu catat progresmu di menu Al-Qur\'an Muslim Habit!';
      }
    }

    // ──────────────────────────────────────────
    // 7. KASUS: DZIKIR & PUASA
    // ──────────────────────────────────────────
    if (lower.contains('dzikir') || lower.contains('zikir') || lower.contains('tasbih')) {
      _lastTopic = 'dzikir';
      return 'Dzikir yang paling utama adalah kalimat tauhid: "Laa ilaaha illallaah", serta memperbanyak istighfar "Astaghfirullah" dan tasbih "Subhanallah wa bihamdihi". Jangan lupa buka fitur Dzikir di Muslim Habit untuk menghitung zikir pagimu!';
    }
    if (lower.contains('puasa') || lower.contains('senin kamis') || lower.contains('sahur') || lower.contains('buka puasa')) {
      _lastTopic = 'puasa';
      return 'Puasa sunnah seperti Senin-Kamis atau Ayyamul Bidh sangat dianjurkan untuk melatih kesabaran dan membersihkan jiwa. Kamu bisa mengaktifkan alarm sahur dan melacak jadwal puasa di menu Puasa Muslim Habit!';
    }

    // ──────────────────────────────────────────
    // 8. KASUS: TERIMA KASIH / SAPAAN
    // ──────────────────────────────────────────
    if (lower.contains('makasih') || lower.contains('terima kasih') || lower.contains('syukron') || lower.contains('jazakallah')) {
      if (characterId == 'adult' || characterId == 'riri') {
        return 'Afwan wa iyyakum. Senang sekali bisa membersamai ikhtiar ibadah Anda. Semoga hari Anda selalu dipenuhi keberkahan.';
      } else {
        return 'Sama-sama sahabatku! Senang banget bisa nemenin perjalanan ibadahmu. Tetap jaga kesehatan dan semangat ya!';
      }
    }

    // ──────────────────────────────────────────
    // 9. KASUS: PERTANYAAN DI LUAR TOPIK IBADAH
    // ──────────────────────────────────────────
    final isOutTopic = lower.contains('resep') ||
        lower.contains('masak') ||
        lower.contains('game') ||
        lower.contains('presiden') ||
        lower.contains('politik') ||
        lower.contains('coding') ||
        lower.contains('film') ||
        lower.contains('nonton');

    if (isOutTopic) {
      return 'Wah, topik yang menarik! Namun sebagai teman ibadahmu di Muslim Habit, aku mengkhususkan diri untuk mendampingi seputar salat, Al-Qur\'an, doa, dzikir, dan kebiasaan baikmu. Ada target ibadah yang ingin kita bahas bersama hari ini?';
    }

    // ──────────────────────────────────────────
    // 10. FOLLOW-UP KONTEKS SEBELUMNYA ATAU PESAN DEFAULT
    // ──────────────────────────────────────────
    if (_lastTopic == 'sholat_belum' || _lastTopic == 'sholat_tips') {
      return 'Kuncinya adalah segera bangkit dan berwudhu ketika panggilan salat tiba. Jadikan salat sebagai kebutuhan hatimu, bukan beban. $name selalu ada di sini untuk saling mengingatkan!';
    }

    if (characterId == 'kid' || characterId == 'lulu') {
      return 'Wah, cerita yang bagus! Terus semangat ya berbuat kebaikan hari ini. Jangan lupa sholat dan baca Al-Qur\'an bersama $name! ✨';
    } else if (characterId == 'adult' || characterId == 'riri') {
      return 'Semoga setiap ikhtiar dan langkah kebaikan yang Anda lakukan hari ini senantiasa dimudahkan serta bernilai pahala berlimpah di sisi Allah SWT.';
    } else {
      return 'Semangat terus ya sahabatku! Apapun amalan baik yang sedang kamu usahakan hari ini, semoga Allah mudahkan, berkahi, dan jadikan ladang pahala buatmu!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitProv = context.watch<HabitProvider>();
    final mascotProv = context.watch<MascotProvider>();
    final assistant = habitProv.currentAssistant;

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
              // ── 1. HEADER CHATBOT (AVATAR KARAKTER, STATUS, TOMBOL KEMBALI) ──
              _buildChatHeader(context, assistant, mascotProv),

              // ── 2. DAFTAR PESAN PERCAKAPAN ──
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return _buildMessageBubble(msg, assistant);
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
                                color: Color(0xFF518427),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${assistant.name} sedang mengetik...',
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
              _buildInputBar(assistant),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // HEADER CHATBOT
  // ==========================================
  Widget _buildChatHeader(
    BuildContext context,
    AIAssistantModel assistant,
    MascotProvider mascotProv,
  ) {
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

          // Avatar Karakter Sesuai Pilihan
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2E3),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF518427), width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                assistant.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.pets_rounded,
                  color: Color(0xFF518427),
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
                assistant.name,
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
          const Spacer(),
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: Color(0xFF2E5714),
              size: 22,
            ),
            tooltip: 'Pengaturan ChatBot',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CompanionSettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BUBBLE PESAN
  // ==========================================
  Widget _buildMessageBubble(_ChatMessageItem msg, AIAssistantModel assistant) {
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
                  color: const Color(0xFF518427),
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
            // Mini Avatar Karakter
            CircleAvatar(
              radius: 15,
              backgroundColor: const Color(0xFFEAF2E3),
              child: ClipOval(
                child: Image.asset(
                  assistant.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.pets_rounded,
                    size: 16,
                    color: Color(0xFF518427),
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
  Widget _buildInputBar(AIAssistantModel assistant) {
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
                  hintText: 'Tulis pesan untuk ${assistant.name}...',
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
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF518427),
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
