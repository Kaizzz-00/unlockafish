import 'package:flutter/material.dart';

class AppConstants {
  // 应用信息
  static const String appName = '鱼书 FishBook';
  static const String appVersion = '1.0.0';
  
  // 主题色彩
  static const Color primaryColor = Color(0xFF0077BE); // 海洋蓝
  static const Color secondaryColor = Color(0xFF00A86B); // 海绿色
  static const Color accentColor = Color(0xFFFF6B35); // 珊瑚橙
  static const Color backgroundColor = Color(0xFFF5F9FC);
  static const Color surfaceColor = Colors.white;
  
  // 尺寸
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  
  // 动画时长
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // 数据库
  static const String databaseName = 'fishbook.db';
  static const int databaseVersion = 1;
  
  // Hive Box 名称
  static const String fishBoxName = 'fish_box';
  static const String diveLogBoxName = 'dive_log_box';
  static const String settingsBoxName = 'settings_box';
  
  // 图片尺寸
  static const double fishImageSize = 120.0;
  static const double fishThumbnailSize = 60.0;
  static const double profileImageSize = 80.0;
}

class AppStrings {
  // 导航标签
  static const String homeTab = '首页';
  static const String encyclopediaTab = '百科';
  static const String identifyTab = '识别';
  static const String diveLogTab = '潜水日志';
  static const String profileTab = '我的';
  
  // 通用
  static const String loading = '加载中...';
  static const String error = '出错了';
  static const String retry = '重试';
  static const String cancel = '取消';
  static const String confirm = '确认';
  static const String save = '保存';
  static const String delete = '删除';
  static const String edit = '编辑';
  static const String search = '搜索';
  
  // 鱼类相关
  static const String fishName = '鱼类名称';
  static const String scientificName = '学名';
  static const String commonName = '俗名';
  static const String family = '科';
  static const String habitat = '栖息地';
  static const String description = '描述';
  
  // 潜水日志相关
  static const String diveDate = '潜水日期';
  static const String diveLocation = '潜水地点';
  static const String maxDepth = '最大深度';
  static const String diveTime = '潜水时长';
  static const String waterTemperature = '水温';
  static const String visibility = '能见度';
}