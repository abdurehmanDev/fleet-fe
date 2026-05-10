import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rangrej_fleet/app/routes.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Rangrej Fleet', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primary)),
              const SizedBox(height: AppDimensions.xl),
              Text('404', style: AppTextStyles.heading1.copyWith(fontSize: 80, color: AppColors.primary)),
              const SizedBox(height: AppDimensions.md),
              Text('Page not found', style: AppTextStyles.heading2),
              const SizedBox(height: AppDimensions.md),
              Text(
                "The destination you're looking for seems to have drifted off the map. Let's get your fleet back on track.",
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.xl),
              
              _buildBulletPoint('Check your fleet status while we redirect you.'),
              const SizedBox(height: AppDimensions.sm),
              _buildBulletPoint('Verify the URL address or navigation path.'),
              const SizedBox(height: AppDimensions.sm),
              _buildBulletPoint('Your recent logs are safe in the dashboard.'),
              
              const SizedBox(height: AppDimensions.xxl),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.home),
                icon: const Icon(Icons.home),
                label: const Text('Return to Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.xl, vertical: AppDimensions.md),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.circle, size: 8, color: AppColors.primary),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: Text(text, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
        ),
      ],
    );
  }
}
