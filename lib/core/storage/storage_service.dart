import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

class StorageService {
  static Box? _fishBox;
  static Box? _diveLogBox;
  static Box? _settingsBox;
  
  static Box get fishBox => _fishBox!;
  static Box get diveLogBox => _diveLogBox!;
  static Box get settingsBox => _settingsBox!;
  
  static Future<void> init() async {
    try {
      // 打开各个存储盒子
      _fishBox = await Hive.openBox(AppConstants.fishBoxName);
      _diveLogBox = await Hive.openBox(AppConstants.diveLogBoxName);
      _settingsBox = await Hive.openBox(AppConstants.settingsBoxName);
      
      print('存储服务初始化成功');
    } catch (e) {
      print('存储服务初始化失败: $e');
      rethrow;
    }
  }
  
  // 通用存储方法
  static Future<void> put(String boxName, String key, dynamic value) async {
    final box = await Hive.openBox(boxName);
    await box.put(key, value);
  }
  
  static T? get<T>(String boxName, String key, {T? defaultValue}) {
    final box = Hive.box(boxName);
    return box.get(key, defaultValue: defaultValue);
  }
  
  static Future<void> delete(String boxName, String key) async {
    final box = Hive.box(boxName);
    await box.delete(key);
  }
  
  static Future<void> clear(String boxName) async {
    final box = Hive.box(boxName);
    await box.clear();
  }
  
  // 设置相关方法
  static Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }
  
  static T? getSetting<T>(String key, {T? defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue);
  }
  
  // 关闭所有存储盒子
  static Future<void> close() async {
    await _fishBox?.close();
    await _diveLogBox?.close();
    await _settingsBox?.close();
  }
}