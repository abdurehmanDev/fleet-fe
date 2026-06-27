import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rangrej_fleet/core/di/injector.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/core/utils/validators.dart';
import 'package:rangrej_fleet/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:rangrej_fleet/features/drivers/presentation/bloc/drivers_bloc.dart';
import 'package:rangrej_fleet/shared/helpers/ui_helper.dart';
import 'package:rangrej_fleet/shared/widgets/common_widgets.dart';

class AddDriverScreen extends StatelessWidget {
  const AddDriverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DriversBloc>(),
      child: const _AddDriverView(),
    );
  }
}

class _AddDriverView extends StatefulWidget {
  const _AddDriverView();

  @override
  State<_AddDriverView> createState() => _AddDriverViewState();
}

class _AddDriverViewState extends State<_AddDriverView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  bool _isValid = false;

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isValid = _nameController.text.trim().length >= 2 &&
          _mobileController.text.trim().length == 10;
    });
  }

  String? _validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) return 'Mobile number is required';
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
      return 'Enter a valid 10-digit Indian mobile number';
    }
    return null;
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<DriversBloc>().add(
            CreateDriver(
              name: _nameController.text.trim(),
              mobile: _mobileController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DriversBloc, DriversState>(
      listener: (context, state) {
        if (state is DriverActionSuccess) {
          UIHelper.showSuccessSnackBar(context, state.message);
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) context.pop();
          });
        } else if (state is DriverActionError) {
          UIHelper.showErrorSnackBar(context, state.message);
        }
      },
      child: Scaffold(
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
                      hint: 'Enter 10-digit mobile number',
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
                      Text('Preview',
                          style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                      const SizedBox(height: AppDimensions.sm),
                      Text(_nameController.text, style: AppTextStyles.heading3),
                      const SizedBox(height: 4),
                      Text('+91 ${_mobileController.text}', style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              const SizedBox(height: AppDimensions.xl),
              BlocBuilder<DriversBloc, DriversState>(
                builder: (context, state) {
                  final isLoading = state is DriverSaving;
                  return ElevatedButton(
                    onPressed: (_isValid && !isLoading) ? _onSubmit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.white,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.white),
                          )
                        : const Text('Add Driver'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
