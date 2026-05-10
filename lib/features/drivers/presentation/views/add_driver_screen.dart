import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/core/utils/validators.dart';
import 'package:rangrej_fleet/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:rangrej_fleet/shared/helpers/ui_helper.dart';
import 'package:rangrej_fleet/shared/widgets/common_widgets.dart';

class AddDriverScreen extends StatefulWidget {
  const AddDriverScreen({super.key});

  @override
  State<AddDriverScreen> createState() => _AddDriverScreenState();
}

class _AddDriverScreenState extends State<AddDriverScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  
  bool _isLoading = false;
  bool _isValid = false;

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
      
      // Simulate API call and duplicate check
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _isLoading = false);
          
          if (_mobileController.text.contains('0000000000')) {
            UIHelper.showErrorSnackBar(context, 'A driver with this mobile number already exists');
            return;
          }
          
          UIHelper.showSuccessSnackBar(context, 'Driver added successfully!');
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
        title: const Text('Add New Driver'),
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
                    Text('Preview', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                    const SizedBox(height: AppDimensions.sm),
                    Text(_nameController.text, style: AppTextStyles.heading3),
                    const SizedBox(height: 4),
                    Text('+91 ${_mobileController.text}', style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              
            const SizedBox(height: AppDimensions.xl),
            
            ElevatedButton(
              onPressed: (_isValid && !_isLoading) ? _onSubmit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 22, width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                    )
                  : const Text('Add Driver'),
            ),
          ],
        ),
      ),
    );
  }
}
