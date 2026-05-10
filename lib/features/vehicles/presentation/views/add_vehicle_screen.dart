import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:rangrej_fleet/shared/helpers/ui_helper.dart';
import 'package:rangrej_fleet/shared/widgets/common_widgets.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  
  bool _isLoading = false;
  bool _isValid = false;

  final _typeController = TextEditingController(text: 'Premium Sedan');
  final _modelController = TextEditingController(text: '2024 Series');

  @override
  void dispose() {
    _numberController.dispose();
    _typeController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isValid = _numberController.text.trim().length >= 3;
    });
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _isLoading = false);
          UIHelper.showSuccessSnackBar(context, 'Vehicle registered successfully!');
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
        title: const Text('Add Vehicle'),
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
            Text('Register New Vehicle', style: AppTextStyles.heading2),
            const SizedBox(height: 4),
            Text(
              'Expand your fleet by adding a new vehicle to the registry.\nUse standard regional format for automatic recognition.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
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
                    label: 'Registration',
                    hint: 'MH 12 AB 1234',
                    prefixIcon: Icons.pin_outlined,
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) => v == null || v.trim().length < 3 
                        ? 'Registration must be at least 3 characters' 
                        : null,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppDimensions.md),
                  AuthTextField(
                    controller: _typeController,
                    label: 'Type',
                    hint: 'Premium Sedan',
                    prefixIcon: Icons.directions_car_outlined,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppDimensions.md),
                  AuthTextField(
                    controller: _modelController,
                    label: 'Model',
                    hint: '2024 Series',
                    prefixIcon: Icons.calendar_today_outlined,
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppDimensions.xl),
            
            Text('Live Preview', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
            const SizedBox(height: AppDimensions.sm),
            _buildPreviewCard(),
            
            const SizedBox(height: AppDimensions.lg),
            
            Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.warning),
                  const SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: Text(
                      'This vehicle will be automatically assigned to the default garage "Central Terminal" after successful registration.',
                      style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                    ),
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
                  : const Text('Register Vehicle'),
            ),
            const SizedBox(height: AppDimensions.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Registration', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text(
                    _numberController.text.isNotEmpty ? _numberController.text.toUpperCase() : 'MH 12 AB 1234',
                    style: AppTextStyles.heading3,
                  ),
                ],
              ),
              Icon(Icons.directions_car, color: AppColors.primary.withOpacity(0.5), size: 32),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppDimensions.md),
            child: Divider(),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Type', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      _typeController.text.isNotEmpty ? _typeController.text : 'Premium Sedan',
                      style: AppTextStyles.labelLarge,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Model', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(
                      _modelController.text.isNotEmpty ? _modelController.text : '2024 Series',
                      style: AppTextStyles.labelLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
