// ─── Company Earning Entity ──────────────────────────────────────────────────
import 'package:equatable/equatable.dart';

class CompanyEarningEntity extends Equatable {
  final String id;
  final double grossRevenue;
  final double totalDriverPayouts;
  final double operatingCosts;
  final double ownerShare;
  final DateTime weekStart;
  final DateTime weekEnd;
  final bool isSaved;

  const CompanyEarningEntity({
    required this.id,
    required this.grossRevenue,
    required this.totalDriverPayouts,
    required this.operatingCosts,
    required this.ownerShare,
    required this.weekStart,
    required this.weekEnd,
    this.isSaved = false,
  });

  @override
  List<Object?> get props => [
        id,
        grossRevenue,
        totalDriverPayouts,
        operatingCosts,
        ownerShare,
        weekStart,
        weekEnd,
        isSaved,
      ];
}
