import 'dart:async';

import 'package:power_alert/domain/models/complaint.dart';
import 'package:power_alert/domain/models/outage.dart';
import 'package:power_alert/domain/repositories/complaint_repository.dart';
import 'package:power_alert/domain/repositories/outage_repository.dart';
import 'package:uuid/uuid.dart';

class DemoOutageRepository implements OutageRepository {
  static final _outages = [
    Outage(
      id: 'OUT-2026-1048',
      areaName: 'Indiranagar, Bengaluru',
      providerName: 'BESCOM',
      reason: 'Feeder protection trip after heavy rain',
      status: OutageStatus.repairing,
      severity: OutageSeverity.high,
      startTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 42)),
      estimatedRestoreTime: DateTime.now().add(const Duration(minutes: 48)),
      affectedPopulation: 12840,
      latitude: 12.9784,
      longitude: 77.6408,
      progress: 0.68,
    ),
    Outage(
      id: 'OUT-2026-1051',
      areaName: 'Koramangala 5th Block',
      providerName: 'BESCOM',
      reason: 'Planned transformer maintenance',
      status: OutageStatus.scheduled,
      severity: OutageSeverity.medium,
      startTime: DateTime.now().add(const Duration(hours: 3)),
      estimatedRestoreTime: DateTime.now().add(const Duration(hours: 5)),
      affectedPopulation: 4380,
      latitude: 12.9346,
      longitude: 77.6206,
      progress: 0,
    ),
    Outage(
      id: 'OUT-2026-1037',
      areaName: 'Shivaji Nagar',
      providerName: 'BESCOM',
      reason: 'Supply restored after cable repair',
      status: OutageStatus.restored,
      severity: OutageSeverity.low,
      startTime: DateTime.now().subtract(const Duration(hours: 4)),
      estimatedRestoreTime: DateTime.now().subtract(
        const Duration(minutes: 22),
      ),
      affectedPopulation: 6200,
      latitude: 12.9857,
      longitude: 77.6057,
      progress: 1,
    ),
  ];

  @override
  Future<Outage?> getOutage(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _outages.where((item) => item.id == id).firstOrNull;
  }

  @override
  Future<void> setFollowing(String outageId, {required bool following}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  @override
  Stream<List<Outage>> watchActiveOutages() async* {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    yield List.unmodifiable(_outages);
  }
}

class DemoComplaintRepository implements ComplaintRepository {
  final _controller = StreamController<List<Complaint>>.broadcast();
  final _complaints = <Complaint>[
    Complaint(
      id: 'PA-72841',
      issueType: IssueType.lowVoltage,
      description: 'Voltage fluctuates every evening.',
      status: ComplaintStatus.assigned,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      areaName: 'Indiranagar, Bengaluru',
    ),
  ];

  @override
  Future<Complaint> create({
    required IssueType issueType,
    required String description,
    required String areaId,
    required String areaName,
    required double latitude,
    required double longitude,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final complaint = Complaint(
      id: 'PA-${const Uuid().v4().substring(0, 6).toUpperCase()}',
      issueType: issueType,
      description: description,
      status: ComplaintStatus.submitted,
      createdAt: DateTime.now(),
      areaName: areaName,
    );
    _complaints.insert(0, complaint);
    _controller.add(List.unmodifiable(_complaints));
    return complaint;
  }

  @override
  Stream<List<Complaint>> watchMyComplaints() async* {
    yield List.unmodifiable(_complaints);
    yield* _controller.stream;
  }
}
