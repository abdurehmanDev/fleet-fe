import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rangrej_fleet/core/di/injector.dart';
import 'package:rangrej_fleet/core/storage/secure_storage_service.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/features/auth/domain/repositories/auth_repository.dart';
import 'package:rangrej_fleet/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:rangrej_fleet/shared/helpers/ui_helper.dart';
import 'package:rangrej_fleet/shared/widgets/common_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  String _name = '';
  String _email = '';
  String _role = '';
  bool _isLoading = false;
  bool _isPasswordLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    final storage = sl<SecureStorageService>();
    final dataStr = await storage.getUserData();
    if (dataStr != null) {
      try {
        final decoded = jsonDecode(dataStr);
        setState(() {
          _name = decoded['name']?.toString() ?? 'Fleet Manager';
          _email = decoded['email']?.toString() ?? 'admin@rangrejfleet.com';
          _role = decoded['role']?.toString() ?? 'OWNER';
        });
      } catch (_) {}
    }

    // Attempt to load from API for latest details
    final repository = sl<AuthRepository>();
    final (entity, failure) = await repository.getMe();
    if (entity != null) {
      setState(() {
        _name = entity.name;
        _email = entity.email;
        _role = entity.role;
      });
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _onChangePassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) {
        UIHelper.showErrorSnackBar(context, 'Passwords do not match');
        return;
      }

      setState(() => _isPasswordLoading = true);
      final repository = sl<AuthRepository>();
      final (success, failure) = await repository.changePassword(
        currentPassword: _currentPasswordCtrl.text,
        newPassword: _newPasswordCtrl.text,
      );

      if (!mounted) return;
      setState(() => _isPasswordLoading = false);

      if (failure != null) {
        UIHelper.showErrorSnackBar(context, failure.message);
      } else if (success) {
        UIHelper.showSuccessSnackBar(context, 'Password changed successfully!');
        _currentPasswordCtrl.clear();
        _newPasswordCtrl.clear();
        _confirmPasswordCtrl.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: AppDimensions.xl),
                  Text('Change Password', style: AppTextStyles.heading2),
                  const SizedBox(height: AppDimensions.md),
                  _buildPasswordForm(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileCard() {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              _name.isNotEmpty ? _name[0].toUpperCase() : 'A',
              style: AppTextStyles.heading1.copyWith(color: AppColors.primary, fontSize: 32),
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Text(_name, style: AppTextStyles.heading2),
          const SizedBox(height: 4),
          StatusBadge(label: _role.toUpperCase(), color: AppColors.primary),
          const Divider(height: 32),
          _buildInfoRow(Icons.email_outlined, 'Email', _email),
          const SizedBox(height: AppDimensions.sm),
          _buildInfoRow(Icons.security, 'Account Access', 'Active'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.grey600, size: 20),
        const SizedBox(width: AppDimensions.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            Text(value, style: AppTextStyles.labelLarge),
          ],
        )
      ],
    );
  }

  Widget _buildPasswordForm() {
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.md),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthTextField(
              controller: _currentPasswordCtrl,
              label: 'Current Password',
              hint: 'Enter your current password',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              validator: (v) => v == null || v.isEmpty ? 'Current password is required' : null,
            ),
            const SizedBox(height: AppDimensions.md),
            AuthTextField(
              controller: _newPasswordCtrl,
              label: 'New Password',
              hint: 'Enter new password (min 8 chars)',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              validator: (v) => v == null || v.length < 8 ? 'Password must be at least 8 characters' : null,
            ),
            const SizedBox(height: AppDimensions.md),
            AuthTextField(
              controller: _confirmPasswordCtrl,
              label: 'Confirm New Password',
              hint: 'Re-enter your new password',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              validator: (v) => v == null || v.isEmpty ? 'Confirm password is required' : null,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AppDimensions.lg),
            ElevatedButton(
              onPressed: _isPasswordLoading ? null : _onChangePassword,
              child: _isPasswordLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                    )
                  : const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}
