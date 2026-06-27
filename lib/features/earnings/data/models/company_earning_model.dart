// ─── Company Earning Model ───────────────────────────────────────────────────
import 'package:rangrej_fleet/features/earnings/domain/entities/company_earning_entity.dart';

class CompanyEarningModel {
  final String id;
  final double grossRevenue;
  final double totalDriverPayouts;
  final double operatingCosts;
  final double ownerShare;
  final DateTime weekStart;
  final DateTime weekEnd;

  const CompanyEarningModel({
    required this.id,
    required this.grossRevenue,
    required this.totalDriverPayouts,
    required this.operatingCosts,
    required this.ownerShare,
    required this.weekStart,
    required this.weekEnd,
  });

  factory CompanyEarningModel.fromJson(Map<String, dynamic> json) {
    return CompanyEarningModel(
      id: json['id']?.toString() ?? '',
      grossRevenue: double.tryParse(json['grossRevenue']?.toString() ?? json['revenue']?.toString() ?? '') ?? 0.0,
      totalDriverPayouts: double.tryParse(json['totalDriverPayouts']?.toString() ?? json['driver_payouts']?.toString() ?? '') ?? 0.0,
      operatingCosts: double.tryParse(json['operatingCosts']?.toString() ?? json['operating_costs']?.toString() ?? '') ?? 0.0,
      ownerShare: double.tryParse(json['ownerShare']?.toString() ?? json['owner_share']?.toString() ?? '') ?? 0.0,
      weekStart: DateTime.tryParse(json['weekStart']?.toString() ?? json['week_start']?.toString() ?? '') ?? DateTime.now(),
      weekEnd: DateTime.tryParse(json['weekEnd']?.toString() ?? json['week_end']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'revenue': grossRevenue,
      'date': weekStart.toIso8601String().substring(0, 10),
    };
  }

  CompanyEarningEntity toEntity() {
    return CompanyEarningEntity(
      id: id,
      grossRevenue: grossRevenue,
      totalDriverPayouts: totalDriverPayouts,
      operatingCosts: operatingCosts,
      ownerShare: ownerShare,
      weekStart: weekStart,
      weekEnd: weekEnd,
      isSaved: true,
    );
  }
}
