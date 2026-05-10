import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rangrej_fleet/app/routes.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/shared/widgets/common_widgets.dart';
import 'package:rangrej_fleet/shared/views/main_layout.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0; // For bottom navigation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Weekly Earnings Dashboard'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => MainLayout.scaffoldKey.currentState?.openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: AppDimensions.xl),
            _buildStatsCards(),
            const SizedBox(height: AppDimensions.xl),
            _buildSelectedWeekCard(),
            const SizedBox(height: AppDimensions.xl),
            _buildDriverEarningsDetail(),
            const SizedBox(height: AppDimensions.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary,
          child: Icon(Icons.business, color: AppColors.white, size: 28),
        ),
        const SizedBox(width: AppDimensions.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rangrej Fleet', style: AppTextStyles.heading2),
            const SizedBox(height: 4),
            Text('Admin Profile', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildDashboardCard(
            title: 'Total Drivers',
            value: '42',
            subtitle: '+3 New this week',
            icon: Icons.trending_up,
            iconColor: AppColors.success,
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: _buildDashboardCard(
            title: 'Active Earnings',
            value: '₹ 2,84,500',
            subtitle: 'Current Period Average',
            icon: Icons.account_balance_wallet,
            iconColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedWeekCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Selected Week', style: AppTextStyles.labelLarge),
              const Icon(Icons.calendar_month, color: AppColors.info),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Text('Week 43', style: AppTextStyles.heading1.copyWith(color: AppColors.info)),
          const SizedBox(height: 4),
          Text('Autumn Peak Season', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildDriverEarningsDetail() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Driver Earnings Detail', style: AppTextStyles.heading3),
        const SizedBox(height: AppDimensions.md),
        AppCard(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            children: [
              _buildDetailRow('Total Weekly Earnings', '₹ 5,34,700', isBold: true),
              const Padding(padding: EdgeInsets.symmetric(vertical: AppDimensions.sm), child: Divider()),
              _buildDetailRow('Cash Collected', '₹ 82,450', valueColor: AppColors.error),
              const SizedBox(height: AppDimensions.sm),
              _buildDetailRow('Tolls Paid', '₹ 12,890', valueColor: AppColors.success),
              const Padding(padding: EdgeInsets.symmetric(vertical: AppDimensions.sm), child: Divider(thickness: 2)),
              _buildDetailRow('Net Amount', '₹ 4,39,360', isBold: true, valueColor: AppColors.primary, fontSize: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppDimensions.sm),
          Text(value, style: AppTextStyles.heading2),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(color: iconColor, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? valueColor, double? fontSize}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? AppTextStyles.labelLarge.copyWith(fontSize: fontSize)
              : AppTextStyles.bodyMedium,
        ),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? AppColors.textPrimary,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}

