import 'package:power_alert/domain/models/complaint.dart';

abstract interface class ComplaintRepository {
  Stream<List<Complaint>> watchMyComplaints();

  Future<Complaint> create({
    required IssueType issueType,
    required String description,
    required String areaId,
    required String areaName,
    required double latitude,
    required double longitude,
  });
}
