enum IssueType {
  noPower,
  lowVoltage,
  transformerFault,
  poleDamage,
  wireDamage,
  streetLight,
  meterIssue,
  other;

  String get label => switch (this) {
    noPower => 'No power',
    lowVoltage => 'Low voltage',
    transformerFault => 'Transformer fault',
    poleDamage => 'Pole damage',
    wireDamage => 'Wire damage',
    streetLight => 'Street light issue',
    meterIssue => 'Meter issue',
    other => 'Other',
  };
}

enum ComplaintStatus {
  submitted,
  verified,
  assigned,
  repairStarted,
  restoring,
  resolved;

  String get label => switch (this) {
    submitted => 'Submitted',
    verified => 'Verified',
    assigned => 'Assigned',
    repairStarted => 'Repair started',
    restoring => 'Restoring',
    resolved => 'Resolved',
  };
}

class Complaint {
  const Complaint({
    required this.id,
    required this.issueType,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.areaName,
  });

  final String id;
  final IssueType issueType;
  final String description;
  final ComplaintStatus status;
  final DateTime createdAt;
  final String areaName;
}
