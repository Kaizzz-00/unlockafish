import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class IdentificationPage extends StatelessWidget {
  const IdentificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.identifyTab),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 64,
              color: AppConstants.accentColor,
            ),
            SizedBox(height: AppConstants.paddingMedium),
            Text(
              'AI鱼类识别',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppConstants.accentColor,
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