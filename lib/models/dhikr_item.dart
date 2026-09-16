class DhikrItem {
  final String id;
  final String arabic;
  final String latin;
  final String translation;
  final int targetCount;
  int currentCount;
  int totalCompletedCycles;

  DhikrItem({
    required this.id,
    required this.arabic,
    required this.latin,
    required this.translation,
    this.targetCount = 33,
    this.currentCount = 0,
    this.totalCompletedCycles = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currentCount': currentCount,
      'totalCompletedCycles': totalCompletedCycles,
    };
  }
}
