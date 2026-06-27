// ─── Weekly Earning Entity ───────────────────────────────────────────────────
import 'package:equatable/equatable.dart';

class WeeklyEarningEntity extends Equatable {
  final String id;
  final String driverId;
  final String driverName;
  final double amount; // Net amount
  final DateTime weekStart;
  final DateTime weekEnd;
  final int trips;
  final String status;
  final String notes;

  // Calculation breakdown fields
  final double weeklyEarning;
  final double cash;
  final double tax;
  final double toll;
  final double rent;
  final double uberSubscription;
  final double adjustment;
  final double other;

  const WeeklyEarningEntity({
    required this.id,
    required this.driverId,
    this.driverName = '',
    required this.amount,
    required this.weekStart,
    required this.weekEnd,
    this.trips = 0,
    this.status = 'PENDING',
    this.notes = '',
    this.weeklyEarning = 0.0,
    this.cash = 0.0,
    this.tax = 0.0,
    this.toll = 0.0,
    this.rent = 0.0,
    this.uberSubscription = 0.0,
    this.adjustment = 0.0,
    this.other = 0.0,
  });

  @override
  List<Object?> get props => [
        id,
        driverId,
        driverName,
        amount,
        weekStart,
        weekEnd,
        trips,
        status,
        weeklyEarning,
        cash,
        tax,
        toll,
        rent,
        uberSubscription,
        adjustment,
        other,
      ];
}
