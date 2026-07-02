import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:power_alert/core/config/app_environment.dart';
import 'package:power_alert/domain/models/complaint.dart';
import 'package:power_alert/domain/repositories/complaint_repository.dart';
import 'package:uuid/uuid.dart';

class FirebaseComplaintRepository implements ComplaintRepository {
  FirebaseComplaintRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseAppCheck? appCheck,
    http.Client? client,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _appCheck = appCheck ?? FirebaseAppCheck.instance,
       _client = client ?? http.Client();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseAppCheck _appCheck;
  final http.Client _client;

  @override
  Future<Complaint> create({
    required IssueType issueType,
    required String description,
    required String areaId,
    required String areaName,
    required double latitude,
    required double longitude,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Authentication required.');
    final idToken = await user.getIdToken();
    final appCheckToken = await _appCheck.getToken();
    final response = await _client.post(
      Uri.parse('${AppEnvironment.apiBaseUrl}/complaints'),
      headers: {
        'authorization': 'Bearer $idToken',
        'content-type': 'application/json',
        'idempotency-key': const Uuid().v4(),
        'x-firebase-appcheck': ?appCheckToken,
      },
      body: jsonEncode({
        'areaId': areaId,
        'issueType': issueType.name,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'attachmentPaths': <String>[],
      }),
    );
    if (response.statusCode != 201) {
      throw StateError('Complaint submission failed (${response.statusCode}).');
    }
    final result = jsonDecode(response.body) as Map<String, dynamic>;
    final now = DateTime.now();
    return Complaint(
      id: result['id'] as String,
      issueType: issueType,
      description: description,
      status: ComplaintStatus.submitted,
      createdAt: now,
      areaName: areaName,
    );
  }

  @override
  Stream<List<Complaint>> watchMyComplaints() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.error(StateError('Authentication required.'));
    }
    return _firestore
        .collection('complaints')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((document) {
            final data = document.data();
            return Complaint(
              id: document.id,
              issueType: IssueType.values.firstWhere(
                (value) => value.name == data['issueType'],
                orElse: () => IssueType.other,
              ),
              description: data['description'] as String? ?? '',
              status: ComplaintStatus.values.firstWhere(
                (value) => value.name == data['status'],
                orElse: () => ComplaintStatus.submitted,
              ),
              createdAt:
                  (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
              areaName: data['areaName'] as String? ?? 'Unknown area',
            );
          }).toList(),
        );
  }
}
