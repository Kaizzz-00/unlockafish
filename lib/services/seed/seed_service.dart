import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/storage/storage_service.dart';

class SeedService {
  static const _uuid = Uuid();

  /// 如果鱼类百科盒子为空，则从assets导入示例数据
  static Future<void> importIfEmpty() async {
    final box = StorageService.fishBox;
    if (box.isNotEmpty) {
      return;
    }

    try {
      final jsonStr = await rootBundle.loadString('assets/data/fish_seed.json');
      final List<dynamic> data = jsonDecode(jsonStr);

      for (final item in data) {
        final map = item as Map<String, dynamic>;
        // 确保有ID
        final id = (map['id'] as String?) ?? _uuid.v4();
        map['id'] = id;
        await box.put(id, map);
      }

      // 记录一次导入标记
      await StorageService.put(AppConstants.settingsBoxName, 'seed_imported', true);
      // 可选：记录导入时间
      await StorageService.put(AppConstants.settingsBoxName, 'seed_imported_at', DateTime.now().toIso8601String());
    } catch (e) {
      // 简单错误记录；后续可接入更完善的日志上报
      await StorageService.put(AppConstants.settingsBoxName, 'seed_import_error', e.toString());
      rethrow;
    }
  }
}