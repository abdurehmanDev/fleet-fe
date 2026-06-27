import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rangrej_fleet/core/di/injector.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/core/utils/validators.dart';
import 'package:rangrej_fleet/features/auth/domain/repositories/auth_repository.dart';
import 'package:rangrej_fleet/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:rangrej_fleet/shared/helpers/ui_helper.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final repository = sl<AuthRepository>();
      final (success, failure) = await repository.forgotPassword(_emailController.text.trim());

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (failure != null) {
        UIHelper.showErrorSnackBar(context, failure.message);
      } else if (success) {
        UIHelper.showSuccessSnackBar(
          context,
          'Password reset link sent to your registered email!',
        );
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) context.pop();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reset Password'),
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
            const SizedBox(height: AppDimensions.xl),
            const Icon(Icons.lock_reset, size: 80, color: AppColors.primary),
            const SizedBox(height: AppDimensions.xl),
            Text('Forgot Your Password?', style: AppTextStyles.heading1, textAlign: TextAlign.center),
            const SizedBox(height: AppDimensions.sm),
            Text(
              "Enter your registered email address below, and we'll send you instructions to reset your password.",
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.xl),
            Form(
              key: _formKey,
              child: AuthTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'e.g., owner@rangrejfleet.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                textInputAction: TextInputAction.done,
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            ElevatedButton(
              onPressed: _isLoading ? null : _onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                    )
                  : const Text('Send Reset Instructions'),
            ),
          ],
        ),
      ),
    );
  }
}
