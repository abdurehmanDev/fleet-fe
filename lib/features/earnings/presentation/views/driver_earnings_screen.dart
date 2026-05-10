import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rangrej_fleet/app/routes.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/features/earnings/utils/bill_generator.dart';
import 'package:rangrej_fleet/shared/helpers/ui_helper.dart';
import 'package:rangrej_fleet/shared/widgets/common_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverEarningsScreen extends StatefulWidget {
  final String id;
  const DriverEarningsScreen({super.key, required this.id});

  @override
  State<DriverEarningsScreen> createState() => _DriverEarningsScreenState();
}

class _DriverEarningsScreenState extends State<DriverEarningsScreen> {
  DateTime _currentDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  // Driver details (mock)
  final String _driverName = 'Rahul Sharma';
  final String _driverMobile = '9876543210';

  // Controllers
  final _earningCtrl = TextEditingController();
  final _cashCtrl = TextEditingController();
  final _taxCtrl = TextEditingController();
  final _tollCtrl = TextEditingController();
  final _rentCtrl = TextEditingController();
  final _uberSubCtrl = TextEditingController();
  final _adjustmentCtrl = TextEditingController();
  final _otherCtrl = TextEditingController();

  bool _isEditing = false;
  bool _existingEarning = false;
  bool _isLoading = false;
  double _netAmount = 0.0;

  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  DateTime get _weekStart {
    int daysToSubtract = _currentDate.weekday - 1;
    return _currentDate.subtract(Duration(days: daysToSubtract));
  }

  DateTime get _weekEnd => _weekStart.add(const Duration(days: 6));

  String get _weekPeriodStr {
    final startFormat = DateFormat('MMM dd');
    final endFormat = DateFormat('MMM dd, yyyy');
    return '${startFormat.format(_weekStart)} - ${endFormat.format(_weekEnd)}';
  }

  @override
  void initState() {
    super.initState();
    _setupListeners();
    _loadDataForWeek();
  }

  void _setupListeners() {
    final controllers = [
      _earningCtrl, _cashCtrl, _taxCtrl, _tollCtrl, _rentCtrl,
      _uberSubCtrl, _adjustmentCtrl, _otherCtrl
    ];
    for (var ctrl in controllers) {
      ctrl.addListener(_calculateNet);
    }
  }

  @override
  void dispose() {
    _earningCtrl.dispose();
    _cashCtrl.dispose();
    _taxCtrl.dispose();
    _tollCtrl.dispose();
    _rentCtrl.dispose();
    _uberSubCtrl.dispose();
    _adjustmentCtrl.dispose();
    _otherCtrl.dispose();
    super.dispose();
  }

  void _loadDataForWeek() {
    // Mock logic based on week
    setState(() {
      _existingEarning = _currentDate.isBefore(DateTime.now().subtract(const Duration(days: 7)));
      if (_existingEarning) {
        _earningCtrl.text = '15000';
        _cashCtrl.text = '2000';
        _taxCtrl.text = '500';
        _tollCtrl.text = '200';
        _rentCtrl.text = '3000';
        _uberSubCtrl.text = '1000';
        _adjustmentCtrl.text = '0';
        _otherCtrl.text = '0';
        _isEditing = false;
      } else {
        _clearForm();
        _isEditing = true;
      }
      _calculateNet();
    });
  }

  void _clearForm() {
    _earningCtrl.clear();
    _cashCtrl.clear();
    _taxCtrl.clear();
    _tollCtrl.clear();
    _rentCtrl.clear();
    _uberSubCtrl.clear();
    _adjustmentCtrl.clear();
    _otherCtrl.clear();
  }

  void _calculateNet() {
    final earning = double.tryParse(_earningCtrl.text) ?? 0;
    final cash = double.tryParse(_cashCtrl.text) ?? 0;
    final tax = double.tryParse(_taxCtrl.text) ?? 0;
    final toll = double.tryParse(_tollCtrl.text) ?? 0;
    final rent = double.tryParse(_rentCtrl.text) ?? 0;
    final uber = double.tryParse(_uberSubCtrl.text) ?? 0;
    final adj = double.tryParse(_adjustmentCtrl.text) ?? 0;
    final other = double.tryParse(_otherCtrl.text) ?? 0;

    setState(() {
      _netAmount = earning - cash - tax + toll - rent - uber + adj - other;
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _currentDate = picked;
        _loadDataForWeek();
      });
    }
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _existingEarning = true;
            _isEditing = false;
          });
          UIHelper.showSuccessSnackBar(context, 'Earnings saved successfully');
        }
      });
    }
  }

  Future<void> _generateBill() async {
    UIHelper.showInfoSnackBar(context, 'Generating bill...');
    final path = await BillGenerator.generateBillPng(
      driverName: _driverName,
      mobile: '+91 $_driverMobile',
      weekPeriod: _weekPeriodStr,
      weeklyEarning: double.tryParse(_earningCtrl.text) ?? 0,
      cash: double.tryParse(_cashCtrl.text) ?? 0,
      tax: double.tryParse(_taxCtrl.text) ?? 0,
      toll: double.tryParse(_tollCtrl.text) ?? 0,
      rent: double.tryParse(_rentCtrl.text) ?? 0,
      uberSubscription: double.tryParse(_uberSubCtrl.text) ?? 0,
      adjustment: double.tryParse(_adjustmentCtrl.text) ?? 0,
      other: double.tryParse(_otherCtrl.text) ?? 0,
      netAmount: _netAmount,
    );

    if (path != null && mounted) {
      UIHelper.showSuccessSnackBar(context, 'Bill saved to: $path');
    }
  }

  Future<void> _shareOnWhatsApp() async {
    final message = '''
🚗 *Rangrej Fleet - Weekly Earnings Statement*
👤 Driver: $_driverName
📅 Week: $_weekPeriodStr

💰 *Earnings Breakdown:*
✅ Weekly Earning: ₹${_earningCtrl.text}
➖ Cash: ₹${_cashCtrl.text}
➖ Tax: ₹${_taxCtrl.text}
➕ Toll: ₹${_tollCtrl.text}
➖ Rent: ₹${_rentCtrl.text}
➖ Uber Subscription: ₹${_uberSubCtrl.text}
${_adjustmentCtrl.text.isNotEmpty && _adjustmentCtrl.text != '0' ? '➕ Adjustment: ₹${_adjustmentCtrl.text}\n' : ''}${_otherCtrl.text.isNotEmpty && _otherCtrl.text != '0' ? '➖ Other: ₹${_otherCtrl.text}\n' : ''}
💵 *Net Amount: ${_currencyFormat.format(_netAmount)}*
''';

    final url = Uri.parse('https://wa.me/91$_driverMobile?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) UIHelper.showErrorSnackBar(context, 'Could not launch WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Driver Earnings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDriverInfoCard(),
            const SizedBox(height: AppDimensions.lg),
            
            _buildWeekSelector(),
            const SizedBox(height: AppDimensions.lg),

            if (_existingEarning && !_isEditing)
              _buildExistingAlert(),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Calculated Net Amount', style: AppTextStyles.heading3),
                  const SizedBox(height: AppDimensions.md),
                  
                  AppCard(
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      leading: const Icon(Icons.add_circle, color: AppColors.success),
                      title: Text('Additions', style: AppTextStyles.heading3.copyWith(color: AppColors.success)),
                      childrenPadding: const EdgeInsets.all(AppDimensions.md),
                      children: [
                        _buildFieldRow(
                          label: 'Weekly Earning',
                          ctrl: _earningCtrl,
                          isAddition: true,
                          isRequired: true,
                        ),
                        _buildFieldRow(
                          label: 'Toll',
                          ctrl: _tollCtrl,
                          isAddition: true,
                          isRequired: true,
                        ),
                        _buildFieldRow(
                          label: 'Adjustment',
                          ctrl: _adjustmentCtrl,
                          isAddition: true,
                          isRequired: false,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppDimensions.md),
                  
                  AppCard(
                    child: ExpansionTile(
                      initiallyExpanded: true,
                      leading: const Icon(Icons.remove_circle, color: AppColors.error),
                      title: Text('Deductions', style: AppTextStyles.heading3.copyWith(color: AppColors.error)),
                      childrenPadding: const EdgeInsets.all(AppDimensions.md),
                      children: [
                        _buildFieldRow(
                          label: 'Cash',
                          ctrl: _cashCtrl,
                          isAddition: false,
                          isRequired: true,
                        ),
                        _buildFieldRow(
                          label: 'Tax',
                          ctrl: _taxCtrl,
                          isAddition: false,
                          isRequired: true,
                        ),
                        _buildFieldRow(
                          label: 'Rent',
                          ctrl: _rentCtrl,
                          isAddition: false,
                          isRequired: true,
                        ),
                        _buildFieldRow(
                          label: 'Uber Subscription',
                          ctrl: _uberSubCtrl,
                          isAddition: false,
                          isRequired: true,
                        ),
                        _buildFieldRow(
                          label: 'Other',
                          ctrl: _otherCtrl,
                          isAddition: false,
                          isRequired: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.lg),
            _buildTotalAmountCard(),
            const SizedBox(height: AppDimensions.xl),

            _buildActionButtons(),
            const SizedBox(height: AppDimensions.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverInfoCard() {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_driverName, style: AppTextStyles.heading2),
                Text('+91 $_driverMobile', style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push(AppRoutes.drivers),
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Earnings Period', style: AppTextStyles.heading3),
        const SizedBox(height: AppDimensions.sm),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.sm, vertical: AppDimensions.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() => _currentDate = _currentDate.subtract(const Duration(days: 7)));
                  _loadDataForWeek();
                },
                color: AppColors.primary,
              ),
              InkWell(
                onTap: _selectDate,
                child: Column(
                  children: [
                    Text('Week Period', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                    const SizedBox(height: 2),
                    Text(_weekPeriodStr, style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() => _currentDate = _currentDate.add(const Duration(days: 7)));
                  _loadDataForWeek();
                },
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExistingAlert() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.lg),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.md),
        decoration: BoxDecoration(
          color: AppColors.info.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.info.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.info),
            const SizedBox(width: AppDimensions.sm),
            Expanded(
              child: Text('Earnings already calculated for this week', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.info)),
            ),
            TextButton(
              onPressed: () => setState(() => _isEditing = true),
              child: const Text('Edit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldRow({
    required String label,
    required TextEditingController ctrl,
    required bool isAddition,
    required bool isRequired,
  }) {
    final color = isAddition ? AppColors.success : AppColors.error;
    final sign = isAddition ? '(+)' : '(-)';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.md),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(label, style: AppTextStyles.bodyMedium),
                const SizedBox(width: 4),
                Text(sign, style: AppTextStyles.labelLarge.copyWith(color: color)),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: ctrl,
              enabled: _isEditing,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixText: '₹ ',
                filled: true,
                fillColor: _isEditing ? AppColors.white : AppColors.grey100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              validator: isRequired 
                ? (v) => v == null || v.isEmpty ? 'Required' : null
                : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalAmountCard() {
    final color = _netAmount >= 0 ? AppColors.success : AppColors.error;
    
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Center(
        child: Text(
          'Net Amount: ${_currencyFormat.format(_netAmount)}',
          style: AppTextStyles.heading1.copyWith(color: AppColors.white),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isEditing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: _isLoading ? null : _onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: _existingEarning ? AppColors.info : AppColors.success,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_existingEarning ? 'Update Earnings' : 'Calculate Earnings'),
          ),
          if (_existingEarning) ...[
            const SizedBox(height: AppDimensions.md),
            TextButton(
              onPressed: () => setState(() => _isEditing = false),
              child: const Text('Cancel Edit'),
            ),
          ]
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _generateBill,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8E2DE2), // Purple pink gradient color representation
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          icon: const Icon(Icons.receipt_long),
          label: const Text('Generate Bill (PNG)'),
        ),
        const SizedBox(height: AppDimensions.md),
        OutlinedButton.icon(
          onPressed: _shareOnWhatsApp,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.success,
            side: const BorderSide(color: AppColors.success),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          icon: const Icon(Icons.share),
          label: const Text('Share on WhatsApp'),
        ),
      ],
    );
  }
}
