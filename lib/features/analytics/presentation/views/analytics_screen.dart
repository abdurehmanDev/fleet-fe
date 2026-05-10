import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/shared/widgets/common_widgets.dart';
import 'package:rangrej_fleet/shared/views/main_layout.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  
  String _selectedDriver = 'All Drivers';
  final List<String> _drivers = ['All Drivers', 'Rahul Sharma', 'Amit Kumar', 'Suresh Patel'];

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFilterRow(),
            const SizedBox(height: AppDimensions.lg),
            
            _buildStatsGrid(),
            const SizedBox(height: AppDimensions.xl),
            
            Text('Company Performance (Last 4 Weeks)', style: AppTextStyles.heading2),
            const SizedBox(height: AppDimensions.md),
            _buildCompanyBarChart(),
            const SizedBox(height: AppDimensions.xl),
            
            if (_selectedDriver != 'All Drivers') ...[
              Text('$_selectedDriver Performance', style: AppTextStyles.heading2),
              const SizedBox(height: AppDimensions.md),
              _buildDriverLineChart(),
              const SizedBox(height: AppDimensions.xl),
            ],
            
            Text('Earnings Distribution (Latest Week)', style: AppTextStyles.heading2),
            const SizedBox(height: AppDimensions.md),
            _buildDistributionPieChart(),
            const SizedBox(height: AppDimensions.xl * 2),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
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
                value: _selectedDriver,
                isExpanded: true,
                icon: const Icon(Icons.person, color: AppColors.primary),
                items: _drivers.map((driver) {
                  return DropdownMenuItem<String>(
                    value: driver,
                    child: Text(driver, style: AppTextStyles.bodyMedium),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedDriver = value);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppDimensions.md,
      mainAxisSpacing: AppDimensions.md,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Drivers', '15', AppColors.info, Icons.people),
        _buildStatCard('Total Vehicles', '12', AppColors.accent, Icons.directions_car),
        _buildStatCard('Total Revenue', '₹2.4L', AppColors.primary, Icons.account_balance_wallet),
        _buildStatCard('Owner Earnings', '₹85K', AppColors.success, Icons.monetization_on),
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
          Text(value, style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildCompanyBarChart() {
    return AppCard(
      child: SizedBox(
        height: 250,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 80,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    const style = TextStyle(color: AppColors.grey600, fontWeight: FontWeight.bold, fontSize: 10);
                    String text;
                    switch (value.toInt()) {
                      case 0: text = 'Wk 1'; break;
                      case 1: text = 'Wk 2'; break;
                      case 2: text = 'Wk 3'; break;
                      case 3: text = 'Wk 4'; break;
                      default: text = ''; break;
                    }
                    return SideTitleWidget(axisSide: meta.axisSide, space: 4, child: Text(text, style: style));
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    if (value % 20 != 0) return const SizedBox.shrink();
                    return Text('${value.toInt()}k', style: const TextStyle(color: AppColors.grey600, fontSize: 10));
                  },
                ),
              ),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              checkToShowHorizontalLine: (value) => value % 20 == 0,
              getDrawingHorizontalLine: (value) => const FlLine(color: AppColors.grey200, strokeWidth: 1),
              drawVerticalLine: false,
            ),
            borderData: FlBorderData(show: false),
            barGroups: [
              _makeGroupData(0, 60, 40, 20),
              _makeGroupData(1, 65, 42, 23),
              _makeGroupData(2, 55, 38, 17),
              _makeGroupData(3, 70, 45, 25),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData _makeGroupData(int x, double revenue, double payouts, double owner) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: revenue, color: AppColors.primary, width: 8, borderRadius: BorderRadius.circular(2)),
        BarChartRodData(toY: payouts, color: AppColors.error, width: 8, borderRadius: BorderRadius.circular(2)),
        BarChartRodData(toY: owner, color: AppColors.success, width: 8, borderRadius: BorderRadius.circular(2)),
      ],
    );
  }

  Widget _buildDriverLineChart() {
    return AppCard(
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
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Wk ${value.toInt() + 1}', style: const TextStyle(fontSize: 10, color: AppColors.grey600)),
                    );
                  },
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: 3,
            minY: 0,
            maxY: 20,
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(0, 12),
                  FlSpot(1, 15),
                  FlSpot(2, 10),
                  FlSpot(3, 16),
                ],
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
    );
  }

  Widget _buildDistributionPieChart() {
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
                      value: 35,
                      title: '35%',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: AppColors.error,
                      value: 65,
                      title: '65%',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIndicator(AppColors.success, 'Owner Share'),
                const SizedBox(height: 12),
                _buildIndicator(AppColors.error, 'Driver Payouts'),
              ],
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
}
