// ─── Weekly Earning Model ────────────────────────────────────────────────────
import 'package:rangrej_fleet/features/earnings/domain/entities/weekly_earning_entity.dart';

class WeeklyEarningModel {
  final String id;
  final String driverId;
  final String driverName;
  final double amount;
  final DateTime weekStart;
  final DateTime weekEnd;
  final int trips;
  final String status;
  final String notes;

  // Breakdown details
  final double weeklyEarning;
  final double cash;
  final double tax;
  final double toll;
  final double rent;
  final double uberSubscription;
  final double adjustment;
  final double other;

  const WeeklyEarningModel({
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

  factory WeeklyEarningModel.fromJson(Map<String, dynamic> json) {
    final driverJson = json['driver'] as Map<String, dynamic>?;
    final driverName = driverJson?['name']?.toString() ?? json['driverName']?.toString() ?? '';

    return WeeklyEarningModel(
      id: json['id']?.toString() ?? '',
      driverId: json['driverId']?.toString() ?? json['driver_id']?.toString() ?? '',
      driverName: driverName,
      amount: double.tryParse(json['amount']?.toString() ?? json['totalAmount']?.toString() ?? '') ?? 0.0,
      weekStart: DateTime.tryParse(json['weekStart']?.toString() ?? json['week_start']?.toString() ?? json['weekStartDate']?.toString() ?? '') ?? DateTime.now(),
      weekEnd: DateTime.tryParse(json['weekEnd']?.toString() ?? json['week_end']?.toString() ?? json['weekEndDate']?.toString() ?? '') ?? DateTime.now(),
      trips: json['trips'] as int? ?? 0,
      status: json['status']?.toString() ?? 'PENDING',
      notes: json['notes']?.toString() ?? '',
      weeklyEarning: double.tryParse(json['weeklyEarning']?.toString() ?? json['weekly_earning']?.toString() ?? '') ?? 0.0,
      cash: double.tryParse(json['cash']?.toString() ?? '') ?? 0.0,
      tax: double.tryParse(json['tax']?.toString() ?? '') ?? 0.0,
      toll: double.tryParse(json['toll']?.toString() ?? '') ?? 0.0,
      rent: double.tryParse(json['rent']?.toString() ?? '') ?? 0.0,
      uberSubscription: double.tryParse(json['uberSubscription']?.toString() ?? json['uber_subscription']?.toString() ?? '') ?? 0.0,
      adjustment: double.tryParse(json['adjustment']?.toString() ?? '') ?? 0.0,
      other: double.tryParse(json['other']?.toString() ?? '') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driver_id': driverId,
      'total_amount': amount,
      'week_start_date': weekStart.toIso8601String().substring(0, 10),
      'week_end_date': weekEnd.toIso8601String().substring(0, 10),
      'trips': trips,
      'status': status,
      'notes': notes,
      'weekly_earning': weeklyEarning,
      'cash': cash,
      'tax': tax,
      'toll': toll,
      'rent': rent,
      'uber_subscription': uberSubscription,
      'adjustment': adjustment,
      'other': other,
    };
  }

  WeeklyEarningEntity toEntity() {
    return WeeklyEarningEntity(
      id: id,
      driverId: driverId,
      driverName: driverName,
      amount: amount,
      weekStart: weekStart,
      weekEnd: weekEnd,
      trips: trips,
      status: status,
      notes: notes,
      weeklyEarning: weeklyEarning,
      cash: cash,
      tax: tax,
      toll: toll,
      rent: rent,
      uberSubscription: uberSubscription,
      adjustment: adjustment,
      other: other,
    );
  }
}
