import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/core/utils/validators.dart';
import 'package:rangrej_fleet/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:rangrej_fleet/shared/helpers/ui_helper.dart';
import 'package:rangrej_fleet/shared/widgets/common_widgets.dart';

class EditDriverScreen extends StatefulWidget {
  final String id;
  const EditDriverScreen({super.key, required this.id});

  @override
  State<EditDriverScreen> createState() => _EditDriverScreenState();
}

class _EditDriverScreenState extends State<EditDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _mobileController;
  
  bool _isLoading = false;
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    // Mock fetching data based on ID
    _nameController = TextEditingController(text: 'Rahul Sharma');
    _mobileController = TextEditingController(text: '9876543210');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isValid = _nameController.text.isNotEmpty && 
                 _mobileController.text.length >= 10;
    });
  }

  String? _validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) return 'Mobile number is required';
    final regex = RegExp(r'^[+]?[1-9]?[0-9]{7,15}$');
    if (!regex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Enter a valid mobile number';
    }
    return null;
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _isLoading = false);
          UIHelper.showSuccessSnackBar(context, 'Driver updated successfully!');
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
        title: const Text('Edit Driver Profile'),
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
            Text(
              'Update the personal details and contact information for your fleet staff.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimensions.sm),
            Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                  const SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: Text(
                      'Please provide the name as it appears on official identification.',
                      style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            Form(
              key: _formKey,
              onChanged: _validateForm,
              child: Column(
                children: [
                  AuthTextField(
                    controller: _nameController,
                    label: 'Driver Name',
                    hint: "Enter driver's full name",
                    prefixIcon: Icons.person_outline,
                    validator: (v) => Validators.validateName(v, fieldName: 'Driver Name'),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  AuthTextField(
                    controller: _mobileController,
                    label: 'Mobile Number',
                    hint: 'Enter mobile number',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_android,
                    validator: _validateMobile,
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppDimensions.xl),
            
            if (_isValid)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Preview Changes', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                    const SizedBox(height: AppDimensions.md),
                    Text(_nameController.text.isEmpty ? 'Arjun Singh' : _nameController.text, style: AppTextStyles.heading2),
                    const SizedBox(height: AppDimensions.sm),
                    Row(
                      children: [
                        const Icon(Icons.call, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '+91 ${_mobileController.text.isEmpty ? '9876543210' : _mobileController.text.replaceAll('+91 ', '')}',
                          style: AppTextStyles.bodyLarge,
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: AppDimensions.md), child: Divider()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID Number', style: AppTextStyles.caption),
                            const SizedBox(height: 4),
                            Text('RF-DRV-2024-08', style: AppTextStyles.bodyMedium),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Vehicle Type', style: AppTextStyles.caption),
                            const SizedBox(height: 4),
                            Text('Sedan (EV)', style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
            const SizedBox(height: AppDimensions.xl),

            Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.sync, color: AppColors.info, size: 20),
                  const SizedBox(width: AppDimensions.sm),
                  Expanded(
                    child: Text(
                      "Changes to the driver's name or contact number may take up to 15 minutes to sync across all fleet dispatch devices.",
                      style: AppTextStyles.caption.copyWith(color: AppColors.info),
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
                  : const Text('Update Driver Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
