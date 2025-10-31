import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class DiveLogPage extends StatelessWidget {
  const DiveLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.diveLogTab),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.waves,
              size: 64,
              color: AppConstants.secondaryColor,
            ),
            SizedBox(height: AppConstants.paddingMedium),
            Text(
              '潜水日志',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppConstants.secondaryColor,
              ),
            ),
            SizedBox(height: AppConstants.paddingSmall),
            Text(
              '即将推出...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}