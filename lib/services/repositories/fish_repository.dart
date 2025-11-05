import 'package:hive_flutter/hive_flutter.dart';

import '../../core/storage/storage_service.dart';
import '../../models/fish.dart';

class FishRepository {
  Box get _box => StorageService.fishBox;

  Future<List<Fish>> getAll() async {
    final values = _box.values.cast<Map>().map((e) => Map<String, dynamic>.from(e as Map)).toList();
    return values.map(Fish.fromJson).toList();
  }

  Future<Fish?> getById(String id) async {
    final raw = _box.get(id);
    if (raw is Map) {
      return Fish.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }
}