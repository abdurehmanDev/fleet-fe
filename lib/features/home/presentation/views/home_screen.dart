import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rangrej_fleet/app/routes.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/shared/views/main_layout.dart';
import 'package:rangrej_fleet/shared/widgets/common_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Rangrej Fleet'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => MainLayout.scaffoldKey.currentState?.openDrawer(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            const SizedBox(height: AppDimensions.xl),
            _buildWeeklyOverview(),
            const SizedBox(height: AppDimensions.xl),
            Text('Analytical Insights', style: AppTextStyles.heading2),
            const SizedBox(height: AppDimensions.md),
            _buildAnalyticalInsights(),
            const SizedBox(height: AppDimensions.xl),
            Text('Explore Operations', style: AppTextStyles.heading2),
            const SizedBox(height: AppDimensions.md),
            _buildExploreOperations(context),
            const SizedBox(height: AppDimensions.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.business, color: AppColors.white, size: 28),
              const SizedBox(width: AppDimensions.sm),
              Text('Fleet Management', style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            'Streamlining your logistics with grounded, organic efficiency.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyOverview() {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.trending_up, color: AppColors.success, size: 28),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weekly Overview', style: AppTextStyles.heading3),
                const SizedBox(height: 4),
                Text(
                  'Your fleet\'s performance is up by 12% this week.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticalInsights() {
    return Column(
      children: [
        _buildChartCard('Revenue vs Payouts', Icons.bar_chart, AppColors.primary),
        const SizedBox(height: AppDimensions.md),
        _buildChartCard('Earnings Distribution', Icons.pie_chart, AppColors.accent),
      ],
    );
  }

  Widget _buildChartCard(String title, IconData icon, Color color) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: AppDimensions.sm),
              Text(title, style: AppTextStyles.labelLarge),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Center(
              child: Text(
                'Chart UI Placeholder',
                style: AppTextStyles.caption.copyWith(color: AppColors.grey600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreOperations(BuildContext context) {
    return Column(
      children: [
        _buildOperationCard(
          context,
          title: 'All Drivers',
          description: 'Manage schedules, certifications, and driver performance logs.',
          icon: Icons.people,
          color: AppColors.info,
          route: AppRoutes.drivers,
        ),
        const SizedBox(height: AppDimensions.md),
        _buildOperationCard(
          context,
          title: 'All Vehicles',
          description: 'Track maintenance, fuel efficiency, and real-time location status.',
          icon: Icons.directions_car,
          color: AppColors.success,
          route: AppRoutes.vehicles,
        ),
        const SizedBox(height: AppDimensions.md),
        _buildOperationCard(
          context,
          title: 'Calculate My Earnings',
          description: 'Quick tool to estimate projected revenue based on current load volume.',
          icon: Icons.calculate,
          color: AppColors.warning,
          route: AppRoutes.earnings,
        ),
        const SizedBox(height: AppDimensions.md),
        _buildOperationCard(
          context,
          title: 'Analytics',
          description: 'Deep dive into operational costs, fuel spend, and market trends.',
          icon: Icons.assessment,
          color: AppColors.primary,
          route: AppRoutes.analytics,
        ),
      ],
    );
  }

  Widget _buildOperationCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppDimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelLarge),
                  const SizedBox(height: 4),
                  Text(description, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.grey400),
          ],
        ),
      ),
    );
  }
}

