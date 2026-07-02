import 'package:flutter/material.dart';
import 'package:power_alert/core/theme/app_theme.dart';

enum OutageStatus {
  reported,
  investigating,
  identified,
  repairing,
  restoring,
  restored,
  scheduled,
  emergency,
  cancelled;

  String get label => switch (this) {
    reported => 'Reported',
    investigating => 'Investigating',
    identified => 'Cause identified',
    repairing => 'Repairing',
    restoring => 'Restoring',
    restored => 'Power available',
    scheduled => 'Maintenance',
    emergency => 'Emergency',
    cancelled => 'Cancelled',
  };

  Color get color => switch (this) {
    restored => AppColors.success,
    scheduled => AppColors.primary,
    emergency => AppColors.warning,
    cancelled => Colors.blueGrey,
    _ => AppColors.error,
  };
}

enum OutageSeverity { low, medium, high, critical }

class Outage {
  const Outage({
    required this.id,
    required this.areaName,
    required this.providerName,
    required this.reason,
    required this.status,
    required this.severity,
    required this.startTime,
    required this.estimatedRestoreTime,
    required this.affectedPopulation,
    required this.latitude,
    required this.longitude,
    required this.progress,
  });

  final String id;
  final String areaName;
  final String providerName;
  final String reason;
  final OutageStatus status;
  final OutageSeverity severity;
  final DateTime startTime;
  final DateTime? estimatedRestoreTime;
  final int affectedPopulation;
  final double latitude;
  final double longitude;
  final double progress;

  bool get isActive =>
      status != OutageStatus.restored && status != OutageStatus.cancelled;
}
