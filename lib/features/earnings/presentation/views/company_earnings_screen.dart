import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rangrej_fleet/core/di/injector.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/features/earnings/domain/entities/company_earning_entity.dart';
import 'package:rangrej_fleet/features/earnings/presentation/bloc/company_earnings_bloc.dart';
import 'package:rangrej_fleet/shared/helpers/ui_helper.dart';
import 'package:rangrej_fleet/shared/widgets/common_widgets.dart';
import 'package:rangrej_fleet/shared/views/main_layout.dart';
import 'package:shimmer/shimmer.dart';

class CompanyEarningsScreen extends StatelessWidget {
  const CompanyEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CompanyEarningsBloc>()
        ..add(LoadCompanyEarningsForWeek(weekStart: _getStartOfWeek(DateTime.now()))),
      child: const _CompanyEarningsView(),
    );
  }

  static DateTime _getStartOfWeek(DateTime date) {
    int daysToSubtract = date.weekday - 1;
    return date.subtract(Duration(days: daysToSubtract));
  }
}

class _CompanyEarningsView extends StatefulWidget {
  const _CompanyEarningsView();

  @override
  State<_CompanyEarningsView> createState() => _CompanyEarningsViewState();
}

class _CompanyEarningsViewState extends State<_CompanyEarningsView> {
  DateTime _currentDate = DateTime.now();
  final _revenueController = TextEditingController();

  double _totalDriverPayouts = 0.0;
  double _companyRevenue = 0.0;
  double _operatingCosts = 0.0;
  int _activeDrivers = 0;
  int _completedTrips = 0;
  bool _isSaved = false;
  bool _dataLoaded = false;

  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  DateTime get _weekStart {
    int daysToSubtract = _currentDate.weekday - 1;
    final start = _currentDate.subtract(Duration(days: daysToSubtract));
    return DateTime(start.year, start.month, start.day);
  }

  DateTime get _weekEnd {
    return _weekStart.add(const Duration(days: 6));
  }

  String get _weekPeriodStr {
    final startFormat = DateFormat('MMM dd');
    final endFormat = DateFormat('MMM dd, yyyy');
    return '${startFormat.format(_weekStart)} - ${endFormat.format(_weekEnd)}';
  }

  double get _ownerShare => _companyRevenue - _totalDriverPayouts - _operatingCosts;

  bool get _isValid =>
      _companyRevenue > 0 &&
      _companyRevenue >= (_totalDriverPayouts + _operatingCosts) &&
      !_isSaved;

  @override
  void initState() {
    super.initState();
    _revenueController.addListener(() {
      setState(() {
        _companyRevenue = double.tryParse(_revenueController.text) ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _revenueController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<CompanyEarningsBloc>().add(LoadCompanyEarningsForWeek(weekStart: _weekStart));
  }

  void _previousWeek() {
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 7));
      _dataLoaded = false;
    });
    _loadData();
  }

  void _nextWeek() {
    setState(() {
      _currentDate = _currentDate.add(const Duration(days: 7));
      _dataLoaded = false;
    });
    _loadData();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _currentDate = picked;
        _dataLoaded = false;
      });
      _loadData();
    }
  }

  void _onSave() {
    final earning = CompanyEarningEntity(
      id: '',
      grossRevenue: _companyRevenue,
      totalDriverPayouts: _totalDriverPayouts,
      operatingCosts: _operatingCosts,
      ownerShare: _ownerShare,
      weekStart: _weekStart,
      weekEnd: _weekEnd,
    );

    context.read<CompanyEarningsBloc>().add(SaveCompanyEarnings(earning: earning));
  }

  void _populateData(CompanyEarningsLoaded state) {
    _totalDriverPayouts = state.totalDriverPayouts;
    _activeDrivers = state.activeDrivers;
    _completedTrips = state.completedTrips;
    _operatingCosts = state.operatingCosts;

    if (state.existingEarning != null) {
      _companyRevenue = state.existingEarning!.grossRevenue;
      _revenueController.text = _companyRevenue.toStringAsFixed(0);
      _isSaved = true;
    } else {
      _companyRevenue = 0.0;
      _revenueController.clear();
      _isSaved = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CompanyEarningsBloc, CompanyEarningsState>(
      listener: (context, state) {
        if (state is CompanyEarningsLoaded && !_dataLoaded) {
          _dataLoaded = true;
          _populateData(state);
        } else if (state is CompanyEarningsActionSuccess) {
          UIHelper.showSuccessSnackBar(context, state.message);
          _dataLoaded = false;
          _loadData();
        } else if (state is CompanyEarningsActionError) {
          UIHelper.showErrorSnackBar(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Company Earnings'),
          leading: Builder(
            builder: (context) => IconButton(
              icon: context.canPop() ? const Icon(Icons.arrow_back) : const Icon(Icons.menu),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  MainLayout.scaffoldKey.currentState?.openDrawer();
                }
              },
            ),
          ),
        ),
        body: BlocBuilder<CompanyEarningsBloc, CompanyEarningsState>(
          builder: (context, state) {
            if (state is CompanyEarningsLoading) {
              return _buildShimmerView();
            }

            if (state is CompanyEarningsError) {
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
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final isSaving = state is CompanyEarningsSaving;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildWeekSelector(),
                  const SizedBox(height: AppDimensions.lg),
                  Text('Driver Payouts Summary', style: AppTextStyles.heading2),
                  const SizedBox(height: AppDimensions.md),
                  _buildSummaryCard(),
                  const SizedBox(height: AppDimensions.xl),
                  Text(
                    'Enter the gross revenue generated by the entire fleet before any deductions or driver splits.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  _buildRevenueInput(),
                  const SizedBox(height: AppDimensions.xl),
                  if (_companyRevenue > 0) ...[
                    Text('Calculation Result', style: AppTextStyles.heading2),
                    const SizedBox(height: AppDimensions.md),
                    _buildCalculationCard(),
                    const SizedBox(height: AppDimensions.md),
                    Center(
                      child: Text(
                        '"Ensuring transparency and fair payouts for every mile driven."',
                        style: AppTextStyles.caption.copyWith(
                            fontStyle: FontStyle.italic, color: AppColors.primary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xl),
                  ],
                  ElevatedButton(
                    onPressed: _isValid && !isSaving ? _onSave : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                          )
                        : const Text('Save Earnings'),
                  ),
                  const SizedBox(height: AppDimensions.xl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWeekSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md, vertical: AppDimensions.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.primary),
            onPressed: _previousWeek,
          ),
          Column(
            children: [
              Text('Weekly Earnings Period',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              InkWell(
                onTap: _selectDate,
                child: Row(
                  children: [
                    Text(_weekPeriodStr, style: AppTextStyles.labelLarge),
                    const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.primary),
            onPressed: _nextWeek,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Payouts', style: AppTextStyles.labelLarge),
              Text(_currencyFormat.format(_totalDriverPayouts),
                  style: AppTextStyles.heading2.copyWith(color: AppColors.error)),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active Drivers', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              Text(_activeDrivers.toString(), style: AppTextStyles.labelLarge),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Completed Trips', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              Text(_completedTrips.toString(), style: AppTextStyles.labelLarge),
            ],
          ),
          const SizedBox(height: AppDimensions.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Estimated Operating Costs',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              Text(_currencyFormat.format(_operatingCosts),
                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.warning)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Based on active fleet logs', style: AppTextStyles.caption.copyWith(color: AppColors.grey400)),
        ],
      ),
    );
  }

  Widget _buildRevenueInput() {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gross Fleet Revenue', style: AppTextStyles.labelLarge),
          const SizedBox(height: AppDimensions.sm),
          TextField(
            controller: _revenueController,
            enabled: !_isSaved,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
            decoration: InputDecoration(
              prefixText: '₹ ',
              prefixStyle: AppTextStyles.heading2.copyWith(color: AppColors.primary),
              hintText: '0.00',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: BorderSide(color: AppColors.grey200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: BorderSide(color: AppColors.grey200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationCard() {
    final double share = _ownerShare;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('Owner\'s Net Share',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white.withOpacity(0.9))),
          const SizedBox(height: AppDimensions.sm),
          Text(
            _currencyFormat.format(share > 0 ? share : 0),
            style: AppTextStyles.heading1.copyWith(color: AppColors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerView() {
    return Shimmer.fromColors(
      baseColor: AppColors.grey200,
      highlightColor: AppColors.grey100,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          children: [
            Container(height: 60, color: AppColors.white),
            const SizedBox(height: AppDimensions.lg),
            Container(height: 180, color: AppColors.white),
            const SizedBox(height: AppDimensions.lg),
            Container(height: 80, color: AppColors.white),
          ],
        ),
      ),
    );
  }
}
