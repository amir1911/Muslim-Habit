import 'dzikir_item_model.dart';

class DzikirCategoryModel {
  final String id;
  final String name;
  final String subtitle;
  final String iconAsset;
  final bool isFeatured;
  final List<DzikirItemModel> items;

  DzikirCategoryModel({
    required this.id,
    required this.name,
    required this.subtitle,
    this.iconAsset = '',
    this.isFeatured = false,
    required this.items,
  });

  int get itemCount => items.length;
  String get description => subtitle;
}

class DzikirHistoryModel {
  final String id;
  final String dateKey; // YYYY-MM-DD
  final String categoryName;
  final String dzikirName;
  final int count;
  final int target;
  final bool isCompleted;
  final DateTime timestamp;

  DzikirHistoryModel({
    required this.id,
    required this.dateKey,
    required this.categoryName,
    required this.dzikirName,
    required this.count,
    required this.target,
    required this.isCompleted,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateKey': dateKey,
      'categoryName': categoryName,
      'dzikirName': dzikirName,
      'count': count,
      'target': target,
      'isCompleted': isCompleted,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory DzikirHistoryModel.fromJson(Map<String, dynamic> json) {
    return DzikirHistoryModel(
      id: json['id'] as String? ?? '',
      dateKey: json['dateKey'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      dzikirName: json['dzikirName'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      target: json['target'] as int? ?? 33,
      isCompleted: json['isCompleted'] as bool? ?? false,
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
