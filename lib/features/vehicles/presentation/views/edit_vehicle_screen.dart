import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rangrej_fleet/core/di/injector.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:rangrej_fleet/features/vehicles/presentation/bloc/vehicles_bloc.dart';
import 'package:rangrej_fleet/shared/helpers/ui_helper.dart';
import 'package:shimmer/shimmer.dart';

class EditVehicleScreen extends StatelessWidget {
  final String id;
  const EditVehicleScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VehiclesBloc>()..add(LoadVehicleDetail(id)),
      child: _EditVehicleView(id: id),
    );
  }
}

class _EditVehicleView extends StatefulWidget {
  final String id;
  const _EditVehicleView({required this.id});

  @override
  State<_EditVehicleView> createState() => _EditVehicleViewState();
}

class _EditVehicleViewState extends State<_EditVehicleView> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  String _selectedStatus = 'ACTIVE';
  bool _isValid = true;
  bool _dataLoaded = false;

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
            UpdateVehicle(
              id: widget.id,
              number: _numberController.text.trim().toUpperCase(),
              status: _selectedStatus,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehiclesBloc, VehiclesState>(
      listener: (context, state) {
        if (state is VehicleDetailLoaded && !_dataLoaded) {
          _dataLoaded = true;
          _numberController.text = state.vehicle.number;
          _selectedStatus = state.vehicle.status;
        } else if (state is VehicleActionSuccess) {
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
          title: const Text('Edit Vehicle'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocBuilder<VehiclesBloc, VehiclesState>(
          builder: (context, state) {
            if (state is VehicleDetailLoading) {
              return _buildShimmerForm();
            }

            if (state is VehiclesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: AppDimensions.md),
                    Text(state.message, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: AppDimensions.lg),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<VehiclesBloc>().add(LoadVehicleDetail(widget.id)),
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
                  Text('Edit Vehicle Details', style: AppTextStyles.heading2),
                  const SizedBox(height: 4),
                  Text(
                    'Update the registration and operational status for your fleet asset.',
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
                          hint: 'MH 01 AB 1234',
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
                  if (_selectedStatus == 'MAINTENANCE')
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
                              Text('Maintenance Mode',
                                  style: AppTextStyles.labelLarge.copyWith(color: AppColors.warning)),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.sm),
                          Text(
                            "This vehicle is marked as in Maintenance. Please verify before assigning active drivers.",
                            style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                          ),
                        ],
                      ),
                    ),
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
                            : const Text('Update Vehicle'),
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
          value: _selectedStatus,
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
                _selectedStatus = value;
              });
            }
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
            Container(height: 24, width: 200, color: AppColors.white),
            const SizedBox(height: AppDimensions.lg),
            Container(height: 56, color: AppColors.white),
            const SizedBox(height: AppDimensions.md),
            Container(height: 56, color: AppColors.white),
            const SizedBox(height: AppDimensions.xl),
            Container(height: 52, color: AppColors.white),
          ],
        ),
      ),
    );
  }
}
