class Region {
  final String id; // 唯一ID
  final String code; // 简码，如 'WC'、'EA'
  final String name; // 中文或英文名

  const Region({
    required this.id,
    required this.code,
    required this.name,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
    };
  }
}