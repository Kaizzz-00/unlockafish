import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../pages/home_page.dart'; // 导入selectedIndexProvider

class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppConstants.appName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 欢迎卡片
            _buildWelcomeCard(context),
            const SizedBox(height: AppConstants.paddingLarge),
            
            // 快速操作
            _buildQuickActions(context, ref),
            const SizedBox(height: AppConstants.paddingLarge),
            
            // 统计信息
            _buildStatsSection(context),
            const SizedBox(height: AppConstants.paddingLarge),
            
            // 最近活动
            _buildRecentActivity(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppConstants.primaryColor, AppConstants.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '欢迎来到 UnlockAFish',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '解锁鱼类图鉴，开启识别与收藏之旅',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: AppConstants.paddingMedium),
          Row(
            children: [
              Icon(
                Icons.waves,
                color: Colors.white.withOpacity(0.8),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '现在就开始解锁你的第一条鱼',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '快速操作',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.camera_alt,
                title: '识别鱼类',
                subtitle: '拍照识别',
                color: AppConstants.accentColor,
                onTap: () {
                  // 切换到识别页面
                  ref.read(selectedIndexProvider.notifier).state = 2;
                },
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.book,
                title: '鱼类百科',
                subtitle: '浏览学习',
                color: AppConstants.secondaryColor,
                onTap: () {
                  // 切换到百科页面
                  ref.read(selectedIndexProvider.notifier).state = 1;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.add_circle,
                title: '记录潜水',
                subtitle: '新建日志',
                color: AppConstants.primaryColor,
                onTap: () {
                  // 切换到潜水日志页面
                  ref.read(selectedIndexProvider.notifier).state = 3;
                },
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.person,
                title: '个人中心',
                subtitle: '设置管理',
                color: Colors.grey[600]!,
                onTap: () {
                  // 切换到个人页面
                  ref.read(selectedIndexProvider.notifier).state = 4;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '我的统计',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Row(
          children: [
            Expanded(
              child: _buildStatCard('已识别鱼类', '0', Icons.visibility),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: _buildStatCard('潜水次数', '0', Icons.waves),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: _buildStatCard('收藏鱼类', '0', Icons.favorite),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppConstants.primaryColor,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '最近活动',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          decoration: BoxDecoration(
            color: AppConstants.surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Text(
                '暂无活动记录',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '开始使用鱼书来记录你的海洋探索吧！',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}