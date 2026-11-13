class DoaItem {
  final int id;
  final String grup;
  final String nama;
  final String ar;
  final String tr;
  final String idn;
  final String tentang;
  final List<String> tag;

  const DoaItem({
    required this.id,
    required this.grup,
    required this.nama,
    required this.ar,
    required this.tr,
    required this.idn,
    required this.tentang,
    required this.tag,
  });

  factory DoaItem.fromJson(Map<String, dynamic> json) {
    List<String> tags = [];
    if (json['tag'] is List) {
      tags = (json['tag'] as List).map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    } else if (json['tag'] is String) {
      final str = json['tag'] as String;
      tags = str.split(' ').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }

    return DoaItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      grup: (json['grup'] ?? '').toString().trim(),
      nama: (json['nama'] ?? '').toString().trim(),
      ar: (json['ar'] ?? '').toString().trim(),
      tr: (json['tr'] ?? '').toString().trim(),
      idn: (json['idn'] ?? '').toString().trim(),
      tentang: (json['tentang'] ?? '').toString().trim(),
      tag: tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'grup': grup,
      'nama': nama,
      'ar': ar,
      'tr': tr,
      'idn': idn,
      'tentang': tentang,
      'tag': tag,
    };
  }
}
