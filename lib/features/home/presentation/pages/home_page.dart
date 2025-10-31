import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../encyclopedia/presentation/pages/encyclopedia_page.dart';
import '../../../fish_identification/presentation/pages/identification_page.dart';
import '../../../dive_log/presentation/pages/dive_log_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../widgets/home_dashboard.dart';

// 当前选中的底部导航索引
final selectedIndexProvider = StateProvider<int>((ref) => 0);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    
    final pages = [
      const HomeDashboard(),
      const EncyclopediaPage(),
      const IdentificationPage(),
      const DiveLogPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (index) {
          ref.read(selectedIndexProvider.notifier).state = index;
        },
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: AppStrings.homeTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: AppStrings.encyclopediaTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            activeIcon: Icon(Icons.camera_alt),
            label: AppStrings.identifyTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.waves_outlined),
            activeIcon: Icon(Icons.waves),
            label: AppStrings.diveLogTab,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: AppStrings.profileTab,
          ),
        ],
      ),
    );
  }
}