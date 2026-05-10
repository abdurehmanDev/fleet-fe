import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rangrej_fleet/app/routes.dart';
import 'package:rangrej_fleet/core/themes/app_theme.dart';
import 'package:rangrej_fleet/shared/helpers/ui_helper.dart';
import 'package:rangrej_fleet/shared/widgets/common_widgets.dart';
import 'package:rangrej_fleet/shared/views/main_layout.dart';

class DriversListScreen extends StatefulWidget {
  const DriversListScreen({super.key});

  @override
  State<DriversListScreen> createState() => _DriversListScreenState();
}

class _DriversListScreenState extends State<DriversListScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Static mock data
  final List<Map<String, dynamic>> _allDrivers = [
    {'id': '1', 'name': 'Rahul Sharma', 'mobile': '+91 98765 43210', 'date': 'Added: May 02, 2025'},
    {'id': '2', 'name': 'Amit Kumar', 'mobile': '+91 87654 32109', 'date': 'Added: Apr 15, 2025'},
    {'id': '3', 'name': 'Suresh Patel', 'mobile': '+91 76543 21098', 'date': 'Added: Apr 10, 2025'},
  ];
  
  List<Map<String, dynamic>> _filteredDrivers = [];

  @override
  void initState() {
    super.initState();
    _filteredDrivers = _allDrivers;
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDrivers = _allDrivers;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredDrivers = _allDrivers.where((driver) {
          return driver['name'].toLowerCase().contains(lowerQuery) ||
                 driver['mobile'].toLowerCase().contains(lowerQuery);
        }).toList();
      }
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
        setState(() {
          _allDrivers.removeWhere((d) => d['id'] == id);
          _onSearch(_searchController.text);
        });
        UIHelper.showSuccessSnackBar(context, 'Driver deleted successfully');
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
            onPressed: () => context.push(AppRoutes.addDriver),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatsRow(),
          Expanded(
            child: _filteredDrivers.isEmpty
                ? const AppEmptyWidget(
                    message: 'No drivers found',
                    icon: Icons.person_off_outlined,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.md),
                    itemCount: _filteredDrivers.length,
                    itemBuilder: (context, index) {
                      final driver = _filteredDrivers[index];
                      return _buildDriverCard(driver);
                    },
                  ),
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.sm),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Total Drivers', _allDrivers.length.toString(), AppColors.primary)),
          const SizedBox(width: AppDimensions.sm),
          Expanded(child: _buildStatCard('Filtered', _filteredDrivers.length.toString(), AppColors.info)),
          const SizedBox(width: AppDimensions.sm),
          Expanded(child: _buildStatCard('Fleet Status', 'Active', AppColors.success)),
        ],
      ),
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

  Widget _buildDriverCard(Map<String, dynamic> driver) {
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
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => context.push('/driver-earnings/${driver['id']}'),
                          child: Text(
                            driver['name'],
                            style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 14, color: AppColors.grey600),
                            const SizedBox(width: 4),
                            Text(driver['mobile'], style: AppTextStyles.bodyMedium),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(driver['date'], style: AppTextStyles.caption),
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
                    onPressed: () => context.push('/driver-earnings/${driver['id']}'),
                    icon: const Icon(Icons.calculate, color: AppColors.success, size: 18),
                    label: Text('Calculate', style: AppTextStyles.button.copyWith(color: AppColors.success)),
                  ),
                ),
                Container(width: 1, height: 30, color: AppColors.grey200),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => context.push('/edit-driver/${driver['id']}'),
                    icon: const Icon(Icons.edit, color: AppColors.info, size: 18),
                    label: Text('Edit', style: AppTextStyles.button.copyWith(color: AppColors.info)),
                  ),
                ),
                Container(width: 1, height: 30, color: AppColors.grey200),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _onDeleteDriver(driver['id'], driver['name']),
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
}
