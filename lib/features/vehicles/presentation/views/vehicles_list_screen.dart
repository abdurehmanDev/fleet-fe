import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rangrej_fleet/app/routes.dart';
import 'package:rangrej_fleet/core/di/injector.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:rangrej_fleet/features/vehicles/presentation/bloc/vehicles_bloc.dart';
import 'package:rangrej_fleet/shared/helpers/ui_helper.dart';
import 'package:rangrej_fleet/shared/widgets/common_widgets.dart';
import 'package:rangrej_fleet/shared/views/main_layout.dart';
import 'package:shimmer/shimmer.dart';

class VehiclesListScreen extends StatelessWidget {
  const VehiclesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<VehiclesBloc>()..add(const LoadVehicles()),
      child: const _VehiclesListView(),
    );
  }
}

class _VehiclesListView extends StatefulWidget {
  const _VehiclesListView();

  @override
  State<_VehiclesListView> createState() => _VehiclesListViewState();
}

class _VehiclesListViewState extends State<_VehiclesListView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  String _activeFilter = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<VehiclesBloc>().add(const LoadMoreVehicles());
    }
  }

  void _onSearch(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<VehiclesBloc>().add(SearchVehicles(query));
    });
  }

  void _onDeleteVehicle(String id, String number) {
    final bloc = context.read<VehiclesBloc>();
    UIHelper.showConfirmDialog(
      context,
      title: 'Delete Vehicle',
      message: 'Are you sure you want to delete vehicle $number? This action cannot be undone.',
      isDangerous: true,
      confirmText: 'Delete',
    ).then((confirmed) {
      if (confirmed == true) {
        bloc.add(DeleteVehicle(id));
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return AppColors.success;
      case 'MAINTENANCE':
        return AppColors.warning;
      case 'INACTIVE':
        return AppColors.error;
      default:
        return AppColors.grey600;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehiclesBloc, VehiclesState>(
      listener: (context, state) {
        if (state is VehicleActionSuccess) {
          UIHelper.showSuccessSnackBar(context, state.message);
        } else if (state is VehicleActionError) {
          UIHelper.showErrorSnackBar(context, state.message);
          context.read<VehiclesBloc>().add(const LoadVehicles());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Manage Vehicles'),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => MainLayout.scaffoldKey.currentState?.openDrawer(),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Vehicle',
              onPressed: () async {
                final bloc = context.read<VehiclesBloc>();
                await context.push(AppRoutes.addVehicle);
                bloc.add(const LoadVehicles());
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildFilterTabs(),
            Expanded(child: _buildVehiclesList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.lg,
        vertical: AppDimensions.md,
      ),
      color: AppColors.white,
      child: TextField(
        controller: _searchController,
        onChanged: _onSearch,
        decoration: InputDecoration(
          hintText: 'Search by vehicle number',
          prefixIcon: const Icon(Icons.search, color: AppColors.grey400),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.grey400),
                  onPressed: () {
                    _searchController.clear();
                    context.read<VehiclesBloc>().add(const LoadVehicles());
                  },
                )
              : null,
          fillColor: AppColors.grey100,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = [
      {'label': 'All', 'value': ''},
      {'label': 'Active', 'value': 'ACTIVE'},
      {'label': 'Maintenance', 'value': 'MAINTENANCE'},
      {'label': 'Inactive', 'value': 'INACTIVE'},
    ];

    return Container(
      height: 48,
      color: AppColors.white,
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _activeFilter == filter['value'];
          return Padding(
            padding: const EdgeInsets.only(right: AppDimensions.sm),
            child: ChoiceChip(
              label: Text(filter['label']!),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _activeFilter = filter['value']!;
                  });
                  context
                      .read<VehiclesBloc>()
                      .add(FilterVehiclesByStatus(filter['value']!));
                }
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.grey100,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVehiclesList() {
    return BlocBuilder<VehiclesBloc, VehiclesState>(
      builder: (context, state) {
        if (state is VehiclesLoading) {
          return _buildShimmerList();
        }

        if (state is VehiclesError) {
          return _buildErrorWidget(state.message);
        }

        if (state is VehiclesLoaded) {
          if (state.vehicles.isEmpty) {
            return const AppEmptyWidget(
              message: 'No vehicles found',
              icon: Icons.directions_car_filled_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<VehiclesBloc>().add(const RefreshVehicles());
              await context.read<VehiclesBloc>().stream.firstWhere(
                    (s) => s is VehiclesLoaded || s is VehiclesError,
                  );
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppDimensions.lg),
              itemCount: state.vehicles.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.vehicles.length) {
                  return const Padding(
                    padding: EdgeInsets.all(AppDimensions.lg),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _buildVehicleCard(state.vehicles[index]);
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildVehicleCard(VehicleEntity vehicle) {
    final statusColor = _getStatusColor(vehicle.status);
    final dateStr = vehicle.createdAt != null
        ? 'Added: ${DateFormat('MMM dd, yyyy').format(vehicle.createdAt!)}'
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.md),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.number.toUpperCase(),
                            style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
                          ),
                          if (dateStr.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(dateStr, style: AppTextStyles.caption),
                          ],
                        ],
                      ),
                    ],
                  ),
                  StatusBadge(
                    label: vehicle.status.toUpperCase(),
                    color: statusColor,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      await context.push('/edit-vehicle/${vehicle.id}');
                      if (mounted) {
                        context.read<VehiclesBloc>().add(const LoadVehicles());
                      }
                    },
                    icon: const Icon(Icons.edit, color: AppColors.info, size: 18),
                    label: Text('Edit', style: AppTextStyles.button.copyWith(color: AppColors.info)),
                  ),
                ),
                Container(width: 1, height: 30, color: AppColors.grey200),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _onDeleteVehicle(vehicle.id, vehicle.number),
                    icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                    label: Text('Delete', style: AppTextStyles.button.copyWith(color: AppColors.error)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return Shimmer.fromColors(
      baseColor: AppColors.grey200,
      highlightColor: AppColors.grey100,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.lg),
        itemCount: 5,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.md),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: AppDimensions.md),
            Text('Something went wrong', style: AppTextStyles.heading3),
            const SizedBox(height: AppDimensions.sm),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.lg),
            ElevatedButton.icon(
              onPressed: () => context.read<VehiclesBloc>().add(const LoadVehicles()),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
