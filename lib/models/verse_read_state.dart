/// State setiap ayat dalam halaman Baca Al-Qur'an
enum VerseReadState {
  /// Belum dibaca (default)
  unread,

  /// Sedang difokuskan / ayat aktif setelah scroll otomatis
  active,

  /// Sudah dibaca (user sudah tap ayat ini)
  read,
}
