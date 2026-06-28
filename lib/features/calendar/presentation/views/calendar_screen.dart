import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rangrej_fleet/app/routes.dart';
import 'package:rangrej_fleet/core/di/injector.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/features/earnings/domain/repositories/earnings_repository.dart';
import 'package:rangrej_fleet/shared/widgets/common_widgets.dart';
import 'package:rangrej_fleet/shared/views/main_layout.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool _isLoading = false;
  final List<Map<String, dynamic>> _weeksData = [];
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  void initState() {
    super.initState();
    _loadCalendarWeeks();
  }

  Future<void> _loadCalendarWeeks({bool forceRefresh = false}) async {
    setState(() => _isLoading = true);
    _weeksData.clear();

    final repository = sl<EarningsRepository>();
    final today = DateTime.now();

    // Load state for last 8 weeks
    for (int i = 0; i < 8; i++) {
      final targetDate = today.subtract(Duration(days: i * 7));
      final daysToSubtract = targetDate.weekday - 1;
      final start = targetDate.subtract(Duration(days: daysToSubtract));
      final weekStart = DateTime(start.year, start.month, start.day);
      final weekEnd = weekStart.add(const Duration(days: 6));

      final (earning, _) = await repository.getCompanyEarningForWeek(weekStart, forceRefresh: forceRefresh);

      _weeksData.add({
        'weekStart': weekStart,
        'weekEnd': weekEnd,
        'earning': earning,
      });
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Fleet Calendar'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => MainLayout.scaffoldKey.currentState?.openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadCalendarWeeks(forceRefresh: true),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _weeksData.isEmpty
              ? const AppEmptyWidget(
                  message: 'No calendar schedules available',
                  icon: Icons.calendar_today_outlined,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(AppDimensions.lg),
                  itemCount: _weeksData.length,
                  itemBuilder: (context, index) {
                    final data = _weeksData[index];
                    final DateTime start = data['weekStart'];
                    final DateTime end = data['weekEnd'];
                    final earning = data['earning'];

                    final rangeStr =
                        '${DateFormat('MMM dd').format(start)} - ${DateFormat('MMM dd, yyyy').format(end)}';

                    return Padding(
                      key: ValueKey(start.toString()),
                      padding: const EdgeInsets.only(bottom: AppDimensions.md),
                      child: AppCard(
                        onTap: () {
                          // Nav to earnings
                          context.push(AppRoutes.earnings);
                        },
                        padding: const EdgeInsets.all(AppDimensions.lg),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppDimensions.md),
                              decoration: BoxDecoration(
                                color: (earning != null)
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.warning.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                (earning != null) ? Icons.check_circle : Icons.pending_actions,
                                color: (earning != null) ? AppColors.success : AppColors.warning,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rangeStr,
                                    style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  if (earning != null) ...[
                                    Text(
                                      'Gross: ${_currencyFormat.format(earning.grossRevenue)} | Payouts: ${_currencyFormat.format(earning.totalDriverPayouts)}',
                                      style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Net Earnings: ${_currencyFormat.format(earning.ownerShare)}',
                                      style: AppTextStyles.caption.copyWith(
                                        color: earning.ownerShare >= 0 ? AppColors.success : AppColors.error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ] else
                                    Text(
                                      'Payout calculations pending',
                                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.grey400),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
