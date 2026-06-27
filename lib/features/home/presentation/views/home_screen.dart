import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rangrej_fleet/app/routes.dart';
import 'package:rangrej_fleet/core/di/injector.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:rangrej_fleet/shared/views/main_layout.dart';
import 'package:rangrej_fleet/shared/widgets/common_widgets.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DashboardBloc>()..add(const LoadDashboardData()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

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
                    _buildHeroSection(summary),
                    const SizedBox(height: AppDimensions.xl),
                    _buildWeeklyOverview(overview),
                    const SizedBox(height: AppDimensions.xl),
                    Text('Analytical Insights', style: AppTextStyles.heading2),
                    const SizedBox(height: AppDimensions.md),
                    _buildAnalyticalInsights(state.companyTrend),
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

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeroSection(dynamic summary) {
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
              Text('Fleet Overview', style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeroStat('Drivers', summary.totalDrivers.toString()),
              _buildHeroStat('Active vehicles', summary.totalVehicles.toString()),
              _buildHeroStat('Completed trips', summary.completedTrips.toString()),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHeroStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTextStyles.heading1.copyWith(color: AppColors.white, fontSize: 24)),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.white.withOpacity(0.6))),
      ],
    );
  }

  Widget _buildWeeklyOverview(dynamic overview) {
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
                Text('Weekly Status', style: AppTextStyles.heading3),
                const SizedBox(height: 4),
                Text(
                  'Your current active payouts: ${_currencyFormat.format(overview.totalDriverPayouts)}',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticalInsights(List<Map<String, dynamic>> companyTrend) {
    return Column(
      children: [
        _buildChartCard('Revenue Trend', _buildLineChart(companyTrend)),
        const SizedBox(height: AppDimensions.md),
        _buildChartCard('Earnings Distribution', _buildBarChart(companyTrend)),
      ],
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart, color: AppColors.primary, size: 20),
              const SizedBox(width: AppDimensions.sm),
              Text(title, style: AppTextStyles.labelLarge),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          SizedBox(height: 180, child: chart),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<Map<String, dynamic>> companyTrend) {
    if (companyTrend.isEmpty) {
      return const Center(child: Text('No trend data available'));
    }

    final sortedTrend = List<Map<String, dynamic>>.from(companyTrend);
    sortedTrend.sort((a, b) => a['week'].toString().compareTo(b['week'].toString()));

    final spots = <FlSpot>[];
    for (int i = 0; i < sortedTrend.length; i++) {
      final revenue = double.tryParse(sortedTrend[i]['companyRevenue']?.toString() ?? '') ?? 0.0;
      spots.add(FlSpot(i.toDouble(), revenue));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedTrend.length) {
                  final dateStr = sortedTrend[index]['week']?.toString() ?? '';
                  String label = dateStr;
                  try {
                    final date = DateTime.parse(dateStr);
                    label = DateFormat('MMM dd').format(date);
                  } catch (_) {}
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(label, style: const TextStyle(fontSize: 10)),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> companyTrend) {
    if (companyTrend.isEmpty) {
      return const Center(child: Text('No trend data available'));
    }

    final sortedTrend = List<Map<String, dynamic>>.from(companyTrend);
    sortedTrend.sort((a, b) => a['week'].toString().compareTo(b['week'].toString()));

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < sortedTrend.length; i++) {
      final ownerEarnings = double.tryParse(sortedTrend[i]['ownerEarnings']?.toString() ?? '') ?? 0.0;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: ownerEarnings,
              color: AppColors.accent,
              width: 14,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedTrend.length) {
                  final dateStr = sortedTrend[index]['week']?.toString() ?? '';
                  String label = dateStr;
                  try {
                    final date = DateTime.parse(dateStr);
                    label = DateFormat('MMM dd').format(date);
                  } catch (_) {}
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(label, style: const TextStyle(fontSize: 10)),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        barGroups: barGroups,
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
          title: 'Calculate Weekly Earnings',
          description: 'Quick tool to estimate projected revenue based on current driver splits.',
          icon: Icons.calculate,
          color: AppColors.warning,
          route: AppRoutes.earnings,
        ),
        const SizedBox(height: AppDimensions.md),
        _buildOperationCard(
          context,
          title: 'Analytics Insights',
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

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.grey200,
      highlightColor: AppColors.grey100,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          children: [
            Container(height: 120, color: AppColors.white),
            const SizedBox(height: AppDimensions.lg),
            Container(height: 70, color: AppColors.white),
            const SizedBox(height: AppDimensions.lg),
            Container(height: 180, color: AppColors.white),
            const SizedBox(height: AppDimensions.md),
            Container(height: 180, color: AppColors.white),
          ],
        ),
      ),
    );
  }
}
