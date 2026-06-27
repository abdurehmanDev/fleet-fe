import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rangrej_fleet/core/di/injector.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:rangrej_fleet/features/vehicles/presentation/bloc/vehicles_bloc.dart';
import 'package:rangrej_fleet/shared/helpers/ui_helper.dart';
import 'package:rangrej_fleet/shared/widgets/common_widgets.dart';

class AddVehicleScreen extends StatelessWidget {
  const AddVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VehiclesBloc>(),
      child: const _AddVehicleView(),
    );
  }
}

class _AddVehicleView extends StatefulWidget {
  const _AddVehicleView();

  @override
  State<_AddVehicleView> createState() => _AddVehicleViewState();
}

class _AddVehicleViewState extends State<_AddVehicleView> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  String _status = 'ACTIVE';
  bool _isValid = false;

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

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<VehiclesBloc>().add(
            CreateVehicle(
              number: _numberController.text.trim().toUpperCase(),
              status: _status,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehiclesBloc, VehiclesState>(
      listener: (context, state) {
        if (state is VehicleActionSuccess) {
          UIHelper.showSuccessSnackBar(context, state.message);
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) context.pop();
          });
        } else if (state is VehicleActionError) {
          UIHelper.showErrorSnackBar(context, state.message);
        }
      },
      child: Scaffold(
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
                'Expand your fleet by adding a new vehicle to the registry. Use standard regional format.',
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
                      label: 'Registration Number',
                      hint: 'MH 12 AB 1234',
                      prefixIcon: Icons.pin_outlined,
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) => v == null || v.trim().length < 3
                          ? 'Registration must be at least 3 characters'
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
              if (_isValid) ...[
                Text('Live Preview', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                const SizedBox(height: AppDimensions.sm),
                _buildPreviewCard(),
              ],
              const SizedBox(height: AppDimensions.xl),
              BlocBuilder<VehiclesBloc, VehiclesState>(
                builder: (context, state) {
                  final isLoading = state is VehicleSaving;
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
                        : const Text('Register Vehicle'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    final statuses = [
      {'label': 'Active', 'value': 'ACTIVE', 'color': AppColors.success},
      {'label': 'Maintenance', 'value': 'MAINTENANCE', 'color': AppColors.warning},
      {'label': 'Inactive', 'value': 'INACTIVE', 'color': AppColors.error},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.grey200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _status,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.grey600),
          items: statuses.map((status) {
            return DropdownMenuItem<String>(
              value: status['value'] as String,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: status['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Text(status['label'] as String, style: AppTextStyles.bodyMedium),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _status = value;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    Color getStatusColor(String val) {
      if (val == 'ACTIVE') return AppColors.success;
      if (val == 'MAINTENANCE') return AppColors.warning;
      return AppColors.error;
    }

    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: const Icon(Icons.directions_car, color: AppColors.primary),
              ),
              const SizedBox(width: AppDimensions.md),
              Text(
                _numberController.text.toUpperCase(),
                style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          StatusBadge(
            label: _status,
            color: getStatusColor(_status),
          ),
        ],
      ),
    );
  }
}
