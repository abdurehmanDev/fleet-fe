import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rangrej_fleet/app/routes.dart';
import 'package:rangrej_fleet/core/di/injector.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:rangrej_fleet/features/drivers/domain/entities/driver_entity.dart';
import 'package:rangrej_fleet/shared/widgets/common_widgets.dart';
import 'package:rangrej_fleet/shared/views/main_layout.dart';
import 'package:shimmer/shimmer.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AnalyticsBloc>()..add(const LoadAnalyticsData()),
      child: const _AnalyticsView(),
    );
  }
}

class _AnalyticsView extends StatefulWidget {
  const _AnalyticsView();

  @override
  State<_AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<_AnalyticsView> {
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  String _selectedDriverName = 'All Drivers';
  String _selectedDriverId = 'All Drivers';

  String _formatWeekLabel(String weekStr) {
    if (weekStr.isEmpty) return '';
    try {
      final date = DateTime.parse(weekStr);
      return DateFormat('MMM dd').format(date);
    } catch (_) {
      return weekStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analytics & Reports'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => MainLayout.scaffoldKey.currentState?.openDrawer(),
          ),
        ),
      ),
      body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
        builder: (context, state) {
          if (state is AnalyticsLoading) {
            return _buildShimmer();
          }

          if (state is AnalyticsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: AppDimensions.md),
                    Text(state.message, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
                    const SizedBox(height: AppDimensions.lg),
                    ElevatedButton(
                      onPressed: () => context.read<AnalyticsBloc>().add(const LoadAnalyticsData()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is AnalyticsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<AnalyticsBloc>().add(const LoadAnalyticsData());
                await context.read<AnalyticsBloc>().stream.firstWhere(
                      (s) => s is AnalyticsLoaded || s is AnalyticsError,
                    );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppDimensions.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFilterRow(state.drivers),
                    const SizedBox(height: AppDimensions.lg),
                    _buildStatsGrid(state.overviewStats),
                    const SizedBox(height: AppDimensions.xl),
                    Text('Company Performance Overview', style: AppTextStyles.heading2),
                    const SizedBox(height: AppDimensions.md),
                    _buildCompanyBarChart(state.companyPerformance),
                    const SizedBox(height: AppDimensions.xl),
                    if (_selectedDriverId != 'All Drivers' && state.driverPerformance != null) ...[
                      Text('$_selectedDriverName Performance History', style: AppTextStyles.heading2),
                      const SizedBox(height: AppDimensions.md),
                      _buildDriverLineChart(state.driverPerformance!),
                      const SizedBox(height: AppDimensions.xl),
                    ],
                    Text('Earnings Allocation Split', style: AppTextStyles.heading2),
                    const SizedBox(height: AppDimensions.md),
                    _buildDistributionPieChart(state.overviewStats),
                    const SizedBox(height: AppDimensions.xl * 2),
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

  Widget _buildFilterRow(List<DriverEntity> drivers) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: AppColors.grey200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDriverId,
                isExpanded: true,
                icon: const Icon(Icons.person, color: AppColors.primary),
                items: [
                  const DropdownMenuItem<String>(
                    value: 'All Drivers',
                    child: Text('All Drivers', style: AppTextStyles.bodyMedium),
                  ),
                  ...drivers.map((driver) {
                    return DropdownMenuItem<String>(
                      value: driver.id,
                      child: Text(driver.name, style: AppTextStyles.bodyMedium),
                    );
                  })
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedDriverId = value;
                      if (value == 'All Drivers') {
                        _selectedDriverName = 'All Drivers';
                      } else {
                        _selectedDriverName = drivers.firstWhere((d) => d.id == value).name;
                      }
                    });
                    context.read<AnalyticsBloc>().add(
                          LoadDriverSpecificAnalytics(
                            driverId: _selectedDriverId,
                            driverName: _selectedDriverName,
                          ),
                        );
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    double revenue = 0.0;
    if (stats.containsKey('currentWeek')) {
      final currentWeek = stats['currentWeek'] as Map<String, dynamic>?;
      revenue = double.tryParse(currentWeek?['revenue']?.toString() ?? '') ?? 0.0;
    } else {
      revenue = double.tryParse(stats['totalPayouts']?.toString() ?? '0.0') ?? 0.0;
    }

    final double opsCost = double.tryParse(stats['estimatedOperatingCosts']?.toString() ?? '0.0') ?? 0.0;
    final double netProfit = revenue - opsCost;

    final totalDriversStr = stats['totalDrivers']?.toString() ?? stats['total_drivers']?.toString() ?? '25';
    final totalVehiclesStr = stats['totalVehicles']?.toString() ?? stats['total_vehicles']?.toString() ?? '6';

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppDimensions.md,
      mainAxisSpacing: AppDimensions.md,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Drivers', totalDriversStr, AppColors.info, Icons.people),
        _buildStatCard('Total Vehicles', totalVehiclesStr, AppColors.accent, Icons.directions_car),
        _buildStatCard('Total Revenue', _currencyFormat.format(revenue), AppColors.primary, Icons.account_balance_wallet),
        _buildStatCard('Owner Net Flow', _currencyFormat.format(netProfit), AppColors.success, Icons.monetization_on),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.caption.copyWith(color: AppColors.grey600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(value, style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildCompanyBarChart(List<Map<String, dynamic>> performance) {
    if (performance.isEmpty) {
      return const AppCard(
        child: SizedBox(
          height: 150,
          child: Center(child: Text('No performance data available')),
        ),
      );
    }

    final barGroups = <BarChartGroupData>[];
    double maxVal = 100.0;

    for (int i = 0; i < performance.length; i++) {
      final p = performance[i];
      final double revenue = double.tryParse(p['companyRevenue']?.toString() ?? p['revenue']?.toString() ?? '') ?? 0.0;
      final double payouts = double.tryParse(p['driverPayouts']?.toString() ?? p['payouts']?.toString() ?? '') ?? 0.0;
      final double owner = double.tryParse(p['ownerEarnings']?.toString() ?? p['ownerShare']?.toString() ?? '') ?? 0.0;

      if (revenue > maxVal) maxVal = revenue;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: revenue, color: AppColors.primary, width: 8, borderRadius: BorderRadius.circular(2)),
            BarChartRodData(toY: payouts, color: AppColors.error, width: 8, borderRadius: BorderRadius.circular(2)),
            BarChartRodData(toY: owner, color: AppColors.success, width: 8, borderRadius: BorderRadius.circular(2)),
          ],
        ),
      );
    }

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxVal * 1.2,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      final idx = value.toInt();
                      if (idx >= 0 && idx < performance.length) {
                        final weekStr = performance[idx]['week']?.toString() ?? performance[idx]['label']?.toString() ?? '';
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4,
                          child: Text(_formatWeekLabel(weekStr), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 45,
                    getTitlesWidget: (value, meta) {
                      return Text('₹${value.toInt()}', style: const TextStyle(color: AppColors.grey600, fontSize: 9));
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDriverLineChart(List<Map<String, dynamic>> driverPerformance) {
    if (driverPerformance.isEmpty) {
      return const AppCard(
        child: SizedBox(height: 150, child: Center(child: Text('No historical driver data available'))),
      );
    }

    final spots = <FlSpot>[];
    double maxVal = 20.0;

    for (int i = 0; i < driverPerformance.length; i++) {
      final double val = double.tryParse(driverPerformance[i]['amount']?.toString() ?? '') ?? 0.0;
      if (val > maxVal) maxVal = val;
      spots.add(FlSpot(i.toDouble(), val));
    }

    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx >= 0 && idx < driverPerformance.length) {
                        final weekStr = driverPerformance[idx]['week']?.toString() ?? driverPerformance[idx]['label']?.toString() ?? '';
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 4,
                          child: Text(_formatWeekLabel(weekStr), style: const TextStyle(fontSize: 9, color: AppColors.grey600)),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 45,
                    getTitlesWidget: (value, meta) {
                      return Text('₹${value.toInt()}', style: const TextStyle(color: AppColors.grey600, fontSize: 9));
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (driverPerformance.length - 1).toDouble(),
              minY: 0,
              maxY: maxVal * 1.2,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.info,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.info.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDistributionPieChart(Map<String, dynamic> stats) {
    double revenue = 0.0;
    if (stats.containsKey('currentWeek')) {
      final currentWeek = stats['currentWeek'] as Map<String, dynamic>?;
      revenue = double.tryParse(currentWeek?['revenue']?.toString() ?? '') ?? 0.0;
    } else {
      revenue = double.tryParse(stats['totalPayouts']?.toString() ?? '0.0') ?? 0.0;
    }

    final double opsCost = double.tryParse(stats['estimatedOperatingCosts']?.toString() ?? '0.0') ?? 0.0;
    final double ownerShare = revenue - opsCost;

    final double total = revenue + ownerShare;
    final double driverPct = total > 0 ? (revenue / total) * 100 : 50;
    final double ownerPct = total > 0 ? (ownerShare / total) * 100 : 50;

    return AppCard(
      child: SizedBox(
        height: 200,
        child: Row(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: AppColors.success,
                      value: ownerPct,
                      title: '${ownerPct.toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: AppColors.error,
                      value: driverPct,
                      title: '${driverPct.toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: AppDimensions.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIndicator(AppColors.success, 'Owner Share'),
                  const SizedBox(height: 12),
                  _buildIndicator(AppColors.error, 'Driver Payouts'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 8),
        Text(text, style: AppTextStyles.bodyMedium),
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
            Container(height: 48, color: AppColors.white),
            const SizedBox(height: AppDimensions.lg),
            Container(height: 150, color: AppColors.white),
            const SizedBox(height: AppDimensions.lg),
            Container(height: 250, color: AppColors.white),
          ],
        ),
      ),
    );
  }
}
