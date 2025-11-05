import 'dart:convert';

class Fish {
  final String id;
  final String scientificName;
  final List<String> commonNames;
  final String family;
  final List<String> regions; // 区域代码集合，如 ["WC", "EA"]
  final double? sizeMaxCm;
  final String? description;
  final String? image; // 资产路径或网络URL

  const Fish({
    required this.id,
    required this.scientificName,
    required this.commonNames,
    required this.family,
    required this.regions,
    this.sizeMaxCm,
    this.description,
    this.image,
  });

  factory Fish.fromJson(Map<String, dynamic> json) {
    return Fish(
      id: json['id'] as String,
      scientificName: json['scientificName'] as String,
      commonNames: (json['commonNames'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      family: json['family'] as String? ?? '',
      regions: (json['regions'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      sizeMaxCm: (json['sizeMaxCm'] is num) ? (json['sizeMaxCm'] as num).toDouble() : null,
      description: json['description'] as String?,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scientificName': scientificName,
      'commonNames': commonNames,
      'family': family,
      'regions': regions,
      'sizeMaxCm': sizeMaxCm,
      'description': description,
      'image': image,
    };
  }

  @override
  String toString() => jsonEncode(toJson());
}