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
import 'package:shimmer/shimmer.dart';

class EditDriverScreen extends StatelessWidget {
  final String id;
  const EditDriverScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DriversBloc>()..add(LoadDriverDetail(id)),
      child: _EditDriverView(id: id),
    );
  }
}

class _EditDriverView extends StatefulWidget {
  final String id;
  const _EditDriverView({required this.id});

  @override
  State<_EditDriverView> createState() => _EditDriverViewState();
}

class _EditDriverViewState extends State<_EditDriverView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  bool _isValid = true;
  bool _dataLoaded = false;

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
            UpdateDriver(
              id: widget.id,
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
        if (state is DriverDetailLoaded && !_dataLoaded) {
          _dataLoaded = true;
          _nameController.text = state.driver.name;
          _mobileController.text = state.driver.mobile;
        } else if (state is DriverActionSuccess) {
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
          title: const Text('Edit Driver Profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocBuilder<DriversBloc, DriversState>(
          builder: (context, state) {
            if (state is DriverDetailLoading) {
              return _buildShimmerForm();
            }

            if (state is DriversError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: AppDimensions.md),
                    Text(state.message, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppDimensions.lg),
                    ElevatedButton(
                      onPressed: () => context.read<DriversBloc>().add(LoadDriverDetail(widget.id)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
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
                          Text('Preview Changes',
                              style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                          const SizedBox(height: AppDimensions.md),
                          Text(
                            _nameController.text.isEmpty ? 'Driver Name' : _nameController.text,
                            style: AppTextStyles.heading2,
                          ),
                          const SizedBox(height: AppDimensions.sm),
                          Row(
                            children: [
                              const Icon(Icons.call, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                '+91 ${_mobileController.text}',
                                style: AppTextStyles.bodyLarge,
                              ),
                            ],
                          ),
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
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.white),
                              )
                            : const Text('Update Driver Profile'),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildShimmerForm() {
    return Shimmer.fromColors(
      baseColor: AppColors.grey200,
      highlightColor: AppColors.grey100,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 16, width: 250, color: AppColors.white),
            const SizedBox(height: AppDimensions.lg),
            Container(height: 56, color: AppColors.white),
            const SizedBox(height: AppDimensions.md),
            Container(height: 56, color: AppColors.white),
            const SizedBox(height: AppDimensions.xl),
            Container(height: 120, color: AppColors.white),
          ],
        ),
      ),
    );
  }
}
