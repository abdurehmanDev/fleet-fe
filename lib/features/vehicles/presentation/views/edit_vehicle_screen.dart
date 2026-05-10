import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:rangrej_fleet/shared/helpers/ui_helper.dart';
import 'package:rangrej_fleet/shared/widgets/common_widgets.dart';

class EditVehicleScreen extends StatefulWidget {
  final String id;
  const EditVehicleScreen({super.key, required this.id});

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _numberController;
  
  String _selectedStatus = 'Active';
  bool _isLoading = false;
  bool _isValid = true;

  final List<String> _statuses = ['Active', 'Maintenance', 'Inactive'];

  @override
  void initState() {
    super.initState();
    // Mock fetching data based on ID
    _numberController = TextEditingController(text: 'MH 01 AB 1234');
    _selectedStatus = 'Maintenance';
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isValid = _numberController.text.trim().length >= 3;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active': return AppColors.success;
      case 'Maintenance': return AppColors.warning;
      case 'Inactive': return AppColors.error;
      default: return AppColors.grey600;
    }
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _isLoading = false);
          UIHelper.showSuccessSnackBar(context, 'Vehicle updated successfully!');
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) context.pop();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Vehicle'),
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
            Text('Edit Vehicle Details', style: AppTextStyles.heading2),
            const SizedBox(height: 4),
            Text(
              'Update the registration and operational status for your fleet asset.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.xl),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('12 Oct 2023', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                Text('K. Deshmukh', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: AppDimensions.sm),
            
            AppCard(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Toyota Corolla Altis', style: AppTextStyles.heading3),
                  const SizedBox(height: 4),
                  Text(_numberController.text, style: AppTextStyles.heading2.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            
            Form(
              key: _formKey,
              onChanged: _validateForm,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuthTextField(
                    controller: _numberController,
                    label: 'Registration Number',
                    hint: 'e.g., MH 01 AB 1234',
                    prefixIcon: Icons.pin_outlined,
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) => v == null || v.trim().length < 3 
                        ? 'Registration number must be at least 3 characters' 
                        : null,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  Text('Operational Status', style: AppTextStyles.labelLarge),
                  const SizedBox(height: AppDimensions.sm),
                  _buildStatusDropdown(),
                ],
              ),
            ),
            
            const SizedBox(height: AppDimensions.xl),
            
            if (_selectedStatus == 'Maintenance')
              Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.build, color: AppColors.warning, size: 20),
                        const SizedBox(width: AppDimensions.sm),
                        Text('Maintenance Scheduling', style: AppTextStyles.labelLarge.copyWith(color: AppColors.warning)),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      'Changing status to \'Maintenance\' will automatically notify the assigned driver and block any future bookings in the calendar for this vehicle.',
                      style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                    ),
                  ],
                ),
              ),
              
            const SizedBox(height: AppDimensions.xl),
            
            ElevatedButton(
              onPressed: (_isValid && !_isLoading) ? _onSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 22, width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                    )
                  : const Text('Update Vehicle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.grey200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.grey600),
          items: _statuses.map((status) {
            return DropdownMenuItem<String>(
              value: status,
              child: Row(
                children: [
                  Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(color: _getStatusColor(status), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Text(status, style: AppTextStyles.bodyMedium),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedStatus = value;
              });
            }
          },
        ),
      ),
    );
  }
}
