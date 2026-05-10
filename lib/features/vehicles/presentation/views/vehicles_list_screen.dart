import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rangrej_fleet/app/routes.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/shared/helpers/ui_helper.dart';
import 'package:rangrej_fleet/shared/widgets/common_widgets.dart';
import 'package:rangrej_fleet/shared/views/main_layout.dart';

class VehiclesListScreen extends StatefulWidget {
  const VehiclesListScreen({super.key});

  @override
  State<VehiclesListScreen> createState() => _VehiclesListScreenState();
}

class _VehiclesListScreenState extends State<VehiclesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Static mock data
  final List<Map<String, dynamic>> _allVehicles = [
    {'id': '1', 'number': 'MH 01 AB 1234', 'status': 'Active', 'date': 'Added: May 01, 2025'},
    {'id': '2', 'number': 'MH 12 CD 5678', 'status': 'Maintenance', 'date': 'Added: Apr 20, 2025'},
    {'id': '3', 'number': 'MH 14 EF 9012', 'status': 'Inactive', 'date': 'Added: Mar 15, 2025'},
  ];
  
  List<Map<String, dynamic>> _filteredVehicles = [];

  @override
  void initState() {
    super.initState();
    _filteredVehicles = _allVehicles;
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredVehicles = _allVehicles;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredVehicles = _allVehicles.where((v) {
          return v['number'].toLowerCase().contains(lowerQuery);
        }).toList();
      }
    });
  }

  void _onDelete(String id, String number) {
    UIHelper.showConfirmDialog(
      context,
      title: 'Delete Vehicle',
      message: 'Are you sure you want to delete vehicle $number? This action cannot be undone.',
      isDangerous: true,
      confirmText: 'Delete',
    ).then((confirmed) {
      if (confirmed == true) {
        setState(() {
          _allVehicles.removeWhere((v) => v['id'] == id);
          _onSearch(_searchController.text);
        });
        UIHelper.showSuccessSnackBar(context, 'Vehicle deleted successfully');
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => MainLayout.scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text('Manage Vehicles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Vehicle',
            onPressed: () => context.push(AppRoutes.addVehicle),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildAdminProfileBanner(),
          _buildStatsRow(),
          const SizedBox(height: AppDimensions.sm),
          Expanded(
            child: _filteredVehicles.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_car_filled_outlined, size: 64, color: AppColors.grey400),
                          const SizedBox(height: AppDimensions.md),
                          Text('No vehicles found', style: AppTextStyles.heading3),
                          const SizedBox(height: AppDimensions.sm),
                          Text(
                            'We couldn\'t find any vehicles matching your search or filters. Try adjusting your search.',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.md),
                    itemCount: _filteredVehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = _filteredVehicles[index];
                      return _buildVehicleCard(vehicle);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminProfileBanner() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.md),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(Icons.person, color: AppColors.primary),
          ),
          const SizedBox(width: AppDimensions.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Admin Profile', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              Text('Fleet Manager', style: AppTextStyles.labelLarge),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.md),
      color: AppColors.primary.withOpacity(0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Total Fleet', '124', AppColors.primary),
          _buildStatItem('Active', '108', AppColors.success),
          _buildStatItem('Maintenance', '16', AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.heading2.copyWith(color: color)),
      ],
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    // Mocking Stitch Design values based on the sample index
    String number = vehicle['number'];
    String model = 'Toyota Camry (2022)';
    String odometer = '42,500 km';
    String driver = 'Arjun Sharma';
    
    if (number.contains('12 CD')) {
      model = 'Honda Accord (2021)';
      odometer = '68,210 km';
      driver = 'Priya Patel';
    } else if (number.contains('14 EF')) {
      model = 'Suzuki Swift (2019)';
      odometer = '112,005 km';
      driver = 'Unassigned';
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.md),
      child: AppCard(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(number, style: AppTextStyles.heading3.copyWith(color: AppColors.primary)),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: AppColors.grey400),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(model, style: AppTextStyles.bodyMedium),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppDimensions.sm),
              child: Divider(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Odometer', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(odometer, style: AppTextStyles.labelLarge),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Driver', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Text(driver, style: AppTextStyles.labelLarge.copyWith(
                      color: driver == 'Unassigned' ? AppColors.error : AppColors.textPrimary
                    )),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
