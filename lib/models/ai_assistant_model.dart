class AIAssistantModel {
  final String id; // 'kid', 'teen', 'adult'
  final String name; // 'Lulu', 'Nunu', 'Riri'
  final String levelTitle; // 'Level Kid', 'Level Teen', 'Level Adult'
  final String description; // Penjelasan ringkas
  final String imagePath; // Asset image
  final String detailImagePath; // Asset image di detail page
  final String greetingBubble; // "Hai, aku Lulu! Silahkan pilih target ibadahmu ya..."
  final String homeMotivationDefault; // Motivasi khas untuk Home screen
  final List<String> targets; // Daftar target ibadah

  const AIAssistantModel({
    required this.id,
    required this.name,
    required this.levelTitle,
    required this.description,
    required this.imagePath,
    required this.detailImagePath,
    required this.greetingBubble,
    required this.homeMotivationDefault,
    required this.targets,
  });

  static const List<AIAssistantModel> assistants = [
    // 1. Lulu - Level Kid
    AIAssistantModel(
      id: 'kid',
      name: 'Lulu',
      levelTitle: 'Level Kid',
      description:
          'Nunu adalah teman AI yang mendukung kebiasaan Islam kita. Ia membantu mengatur jadwal sholat, mengingat waktu puasa, dan memberikan info doa. Nunu juga melacak kebiasaan baik, seperti membaca Al-Qur\'an setiap hari, sehingga kita lebih disiplin dalam ibadah.',
      imagePath: 'assets/images/mascot_lulu.png',
      detailImagePath: 'assets/images/mascot_lulu_detail.png',
      greetingBubble: 'Hai, aku Lulu! Silahkan pilih target ibadahmu ya...',
      homeMotivationDefault: 'Semangat belajar & ibadah hari ini ya, adik sholeh/sholehah!',
      targets: [
        'Melaksanakan sholat 5 waktu setiap hari',
        'Membaca Al-Qur\'an minimal 15 ayat (disarankan 20 ayat).',
      ],
    ),

    // 2. Nunu - Level Teen
    AIAssistantModel(
      id: 'teen',
      name: 'Nunu',
      levelTitle: 'Level Teen',
      description:
          'Nunu adalah teman AI yang mendukung kebiasaan Islam kita. Ia membantu mengatur jadwal sholat, mengingat waktu puasa, dan memberikan info doa. Nunu juga melacak kebiasaan baik, seperti membaca Al-Qur\'an setiap hari, sehingga kita lebih disiplin dalam ibadah.',
      imagePath: 'assets/images/mascot_nunu.png',
      detailImagePath: 'assets/images/mascot_nunu_detail.png',
      greetingBubble: 'Hai, aku Nunu! Silahkan pilih target ibadahmu ya...',
      homeMotivationDefault: 'Tetap konsisten & istiqomah dengan ibadahmu hari ini!',
      targets: [
        'Melaksanakan sholat 5 waktu setiap hari',
        'Membaca Al-Qur\'an minimal 15 ayat (disarankan 20 ayat).',
        'Melaksanakan sholat sunnah minimal sekali sehari, dengan pilihan sebagai berikut: Rawatib, Dhuha, atau Qiyamul Lail.',
      ],
    ),

    // 3. Riri - Level Adult
    AIAssistantModel(
      id: 'adult',
      name: 'Riri',
      levelTitle: 'Level Adult',
      description:
          'Riri adalah maskot yang tegas dan siap membantu kita menjalankan kebiasaan Islam. Ia mengatur jadwal sholat, mengingatkan waktu puasa, dan memberikan info doa. Riri juga melacak kebiasaan baik, seperti membaca Al-Qur\'an setiap hari, untuk meningkatkan disiplin beribadah.',
      imagePath: 'assets/images/mascot_riri.png',
      detailImagePath: 'assets/images/mascot_riri_detail.png',
      greetingBubble: 'Hai, aku Riri! Silahkan pilih target ibadahmu ya...',
      homeMotivationDefault: 'Semoga harimu penuh berkah dan bernilai ibadah di sisi Allah.',
      targets: [
        'Melaksanakan sholat 5 waktu setiap hari',
        'Membaca Al-Qur\'an minimal 20 ayat.',
        'Melaksanakan sholat sunnah minimal sekali sehari, dengan pilihan sebagai berikut: Rawatib, Dhuha, atau Qiyamul Lail.',
        'Membaca Dzikir minimal sekali setiap hari.',
      ],
    ),
  ];

  static AIAssistantModel getById(String? id) {
    if (id == null) return assistants[1]; // default teen / Nunu
    return assistants.firstWhere(
      (a) => a.id.toLowerCase() == id.toLowerCase(),
      orElse: () => assistants[1],
    );
  }
}

