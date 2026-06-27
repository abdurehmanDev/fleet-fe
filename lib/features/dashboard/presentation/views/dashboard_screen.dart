import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rangrej_fleet/app/routes.dart';
import 'package:rangrej_fleet/core/di/injector.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/features/dashboard/data/models/dashboard_summary_model.dart';
import 'package:rangrej_fleet/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:rangrej_fleet/shared/widgets/common_widgets.dart';
import 'package:rangrej_fleet/shared/views/main_layout.dart';
import 'package:shimmer/shimmer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DashboardBloc>()..add(const LoadDashboardData()),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatefulWidget {
  const _DashboardView();

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

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
            onPressed: () {
              context.push(AppRoutes.notifications);
            },
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return _buildShimmer();
          }

          if (state is DashboardError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: AppDimensions.md),
                    Text(state.message, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppDimensions.lg),
                    ElevatedButton(
                      onPressed: () => context.read<DashboardBloc>().add(const LoadDashboardData()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is DashboardLoaded) {
            final summary = state.summary;
            final overview = state.overview;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(const LoadDashboardData());
                await context.read<DashboardBloc>().stream.firstWhere(
                      (s) => s is DashboardLoaded || s is DashboardError,
                    );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: AppDimensions.xl),
                    _buildStatsCards(summary, overview),
                    const SizedBox(height: AppDimensions.xl),
                    _buildSelectedWeekCard(overview),
                    const SizedBox(height: AppDimensions.xl),
                    _buildDriverEarningsDetail(overview),
                    const SizedBox(height: AppDimensions.xxl),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
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
            Text('Owner Dashboard', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCards(DashboardSummaryModel summary, WeeklyOverviewModel overview) {
    return Row(
      children: [
        Expanded(
          child: _buildDashboardCard(
            title: 'Total Drivers',
            value: summary.totalDrivers.toString(),
            subtitle: '${summary.activeDrivers} registered',
            icon: Icons.people,
            iconColor: AppColors.success,
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        Expanded(
          child: _buildDashboardCard(
            title: 'Active Payouts',
            value: _currencyFormat.format(overview.totalDriverPayouts),
            subtitle: 'Current period payouts',
            icon: Icons.account_balance_wallet,
            iconColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedWeekCard(WeeklyOverviewModel overview) {
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Selected Week Period', style: AppTextStyles.labelLarge),
              Icon(Icons.calendar_month, color: AppColors.info),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Text(
            overview.week.isNotEmpty ? overview.week : 'Current Week',
            style: AppTextStyles.heading2.copyWith(color: AppColors.info),
          ),
          const SizedBox(height: 4),
          Text('Live Operational Summary', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildDriverEarningsDetail(WeeklyOverviewModel overview) {
    final netShare = overview.companyEarning - overview.totalDriverPayouts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Driver Earnings Detail', style: AppTextStyles.heading3),
        const SizedBox(height: AppDimensions.md),
        AppCard(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            children: [
              _buildDetailRow('Total Weekly Payouts', _currencyFormat.format(overview.totalDriverPayouts), isBold: true),
              const Padding(padding: EdgeInsets.symmetric(vertical: AppDimensions.sm), child: Divider()),
              _buildDetailRow('Total Company Revenue', _currencyFormat.format(overview.companyEarning), valueColor: AppColors.warning),
              const SizedBox(height: AppDimensions.sm),
              _buildDetailRow('Active Vehicles Count', overview.activeVehicles.toString(), valueColor: AppColors.success),
              const Padding(padding: EdgeInsets.symmetric(vertical: AppDimensions.sm), child: Divider(thickness: 2)),
              _buildDetailRow(
                'Owner Net Flow',
                _currencyFormat.format(netShare),
                isBold: true,
                valueColor: netShare >= 0 ? AppColors.success : AppColors.error,
                fontSize: 20,
              ),
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
          Text(value, style: AppTextStyles.heading2, maxLines: 1, overflow: TextOverflow.ellipsis),
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
          style: isBold ? AppTextStyles.labelLarge.copyWith(fontSize: fontSize) : AppTextStyles.bodyMedium,
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

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.grey200,
      highlightColor: AppColors.grey100,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          children: [
            Container(height: 70, color: AppColors.white),
            const SizedBox(height: AppDimensions.lg),
            Row(
              children: [
                Expanded(child: Container(height: 120, color: AppColors.white)),
                const SizedBox(width: AppDimensions.md),
                Expanded(child: Container(height: 120, color: AppColors.white)),
              ],
            ),
            const SizedBox(height: AppDimensions.lg),
            Container(height: 100, color: AppColors.white),
            const SizedBox(height: AppDimensions.lg),
            Container(height: 200, color: AppColors.white),
          ],
        ),
      ),
    );
  }
}
