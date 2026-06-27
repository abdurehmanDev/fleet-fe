import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:rangrej_fleet/app/routes.dart';
import 'package:rangrej_fleet/core/di/injector.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/features/drivers/domain/entities/driver_entity.dart';
import 'package:rangrej_fleet/features/drivers/presentation/bloc/drivers_bloc.dart';
import 'package:rangrej_fleet/shared/helpers/ui_helper.dart';
import 'package:rangrej_fleet/shared/widgets/common_widgets.dart';
import 'package:rangrej_fleet/shared/views/main_layout.dart';
import 'package:shimmer/shimmer.dart';

class DriversListScreen extends StatelessWidget {
  const DriversListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DriversBloc>()..add(const LoadDrivers()),
      child: const _DriversListView(),
    );
  }
}

class _DriversListView extends StatefulWidget {
  const _DriversListView();

  @override
  State<_DriversListView> createState() => _DriversListViewState();
}

class _DriversListViewState extends State<_DriversListView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<DriversBloc>().add(const LoadMoreDrivers());
    }
  }

  void _onSearch(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<DriversBloc>().add(SearchDrivers(query));
    });
  }

  void _onDeleteDriver(String id, String name) {
    UIHelper.showConfirmDialog(
      context,
      title: 'Delete Driver',
      message: 'Are you sure you want to delete $name? This action cannot be undone.',
      isDangerous: true,
      confirmText: 'Delete',
    ).then((confirmed) {
      if (confirmed == true) {
        context.read<DriversBloc>().add(DeleteDriver(id));
      }
    });
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
    return BlocListener<DriversBloc, DriversState>(
      listener: (context, state) {
        if (state is DriverActionSuccess) {
          UIHelper.showSuccessSnackBar(context, state.message);
        } else if (state is DriverActionError) {
          UIHelper.showErrorSnackBar(context, state.message);
          // Re-fetch drivers after error
          context.read<DriversBloc>().add(const LoadDrivers());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Manage Drivers'),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => MainLayout.scaffoldKey.currentState?.openDrawer(),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add Driver',
              onPressed: () async {
                await context.push(AppRoutes.addDriver);
                if (mounted) {
                  context.read<DriversBloc>().add(const LoadDrivers());
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildStatsRow(),
            Expanded(child: _buildDriversList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      color: AppColors.white,
      child: TextField(
        controller: _searchController,
        onChanged: _onSearch,
        decoration: InputDecoration(
          hintText: 'Search by name or mobile',
          prefixIcon: const Icon(Icons.search, color: AppColors.grey400),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.grey400),
                  onPressed: () {
                    _searchController.clear();
                    context.read<DriversBloc>().add(const LoadDrivers());
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

  Widget _buildStatsRow() {
    return BlocBuilder<DriversBloc, DriversState>(
      builder: (context, state) {
        String total = '-';
        String filtered = '-';

        if (state is DriversLoaded) {
          total = state.meta?.total.toString() ?? state.drivers.length.toString();
          filtered = state.drivers.length.toString();
        }

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.lg,
            vertical: AppDimensions.sm,
          ),
          child: Row(
            children: [
              Expanded(child: _buildStatCard('Total Drivers', total, AppColors.primary)),
              const SizedBox(width: AppDimensions.sm),
              Expanded(child: _buildStatCard('Showing', filtered, AppColors.info)),
              const SizedBox(width: AppDimensions.sm),
              Expanded(child: _buildStatCard('Fleet Status', 'Active', AppColors.success)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: AppTextStyles.heading3.copyWith(color: color)),
          const SizedBox(height: 2),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDriversList() {
    return BlocBuilder<DriversBloc, DriversState>(
      builder: (context, state) {
        if (state is DriversLoading) {
          return _buildShimmerList();
        }

        if (state is DriversError) {
          return _buildErrorWidget(state.message);
        }

        if (state is DriversLoaded) {
          if (state.drivers.isEmpty) {
            return const AppEmptyWidget(
              message: 'No drivers found',
              icon: Icons.person_off_outlined,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DriversBloc>().add(const RefreshDrivers());
              // Wait for state change
              await context.read<DriversBloc>().stream.firstWhere(
                    (s) => s is DriversLoaded || s is DriversError,
                  );
            },
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.lg,
                vertical: AppDimensions.md,
              ),
              itemCount: state.drivers.length + (state.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.drivers.length) {
                  return const Padding(
                    padding: EdgeInsets.all(AppDimensions.lg),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _buildDriverCard(state.drivers[index]);
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDriverCard(DriverEntity driver) {
    final dateStr = driver.createdAt != null
        ? 'Added: ${DateFormat('MMM dd, yyyy').format(driver.createdAt!)}'
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.md),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.md),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      driver.name.isNotEmpty ? driver.name[0].toUpperCase() : 'D',
                      style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => context.push('/driver-earnings/${driver.id}'),
                          child: Text(
                            driver.name,
                            style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 14, color: AppColors.grey600),
                            const SizedBox(width: 4),
                            Text('+91 ${driver.mobile}', style: AppTextStyles.bodyMedium),
                          ],
                        ),
                        if (dateStr.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(dateStr, style: AppTextStyles.caption),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => context.push('/driver-earnings/${driver.id}'),
                    icon: const Icon(Icons.calculate, color: AppColors.success, size: 18),
                    label: Text('Calculate', style: AppTextStyles.button.copyWith(color: AppColors.success)),
                  ),
                ),
                Container(width: 1, height: 30, color: AppColors.grey200),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      await context.push('/edit-driver/${driver.id}');
                      if (mounted) {
                        context.read<DriversBloc>().add(const LoadDrivers());
                      }
                    },
                    icon: const Icon(Icons.edit, color: AppColors.info, size: 18),
                    label: Text('Edit', style: AppTextStyles.button.copyWith(color: AppColors.info)),
                  ),
                ),
                Container(width: 1, height: 30, color: AppColors.grey200),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _onDeleteDriver(driver.id, driver.name),
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
            height: 120,
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
              onPressed: () => context.read<DriversBloc>().add(const LoadDrivers()),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
