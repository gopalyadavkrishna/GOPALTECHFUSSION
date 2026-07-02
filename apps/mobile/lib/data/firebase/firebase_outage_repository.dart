import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:power_alert/domain/models/outage.dart';
import 'package:power_alert/domain/repositories/outage_repository.dart';

class FirebaseOutageRepository implements OutageRepository {
  FirebaseOutageRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<Outage?> getOutage(String id) async {
    final snapshot = await _firestore.collection('outages').doc(id).get();
    return snapshot.exists ? _fromSnapshot(snapshot) : null;
  }

  @override
  Future<void> setFollowing(String outageId, {required bool following}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Authentication required.');
    final follower = _firestore
        .collection('outages')
        .doc(outageId)
        .collection('followers')
        .doc(uid);
    if (following) {
      await follower.set({'createdAt': FieldValue.serverTimestamp()});
    } else {
      await follower.delete();
    }
  }

  @override
  Stream<List<Outage>> watchActiveOutages() => _firestore
      .collection('outages')
      .orderBy('startTime', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(_fromSnapshot).toList());

  Outage _fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    final location = data['location'] as GeoPoint?;
    final statusName = data['status'] as String? ?? 'reported';
    final severityName = data['severity'] as String? ?? 'medium';
    return Outage(
      id: snapshot.id,
      areaName: data['areaName'] as String? ?? 'Unknown area',
      providerName: data['providerName'] as String? ?? 'Utility provider',
      reason: data['reason'] as String? ?? 'Under investigation',
      status: OutageStatus.values.firstWhere(
        (value) => value.name == statusName,
        orElse: () => OutageStatus.reported,
      ),
      severity: OutageSeverity.values.firstWhere(
        (value) => value.name == severityName,
        orElse: () => OutageSeverity.medium,
      ),
      startTime: (data['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      estimatedRestoreTime: (data['estimatedRestoreTime'] as Timestamp?)
          ?.toDate(),
      affectedPopulation: (data['affectedPopulation'] as num?)?.toInt() ?? 0,
      latitude: location?.latitude ?? 0,
      longitude: location?.longitude ?? 0,
      progress: ((data['progress'] as num?)?.toDouble() ?? 0).clamp(0, 1),
    );
  }
}
