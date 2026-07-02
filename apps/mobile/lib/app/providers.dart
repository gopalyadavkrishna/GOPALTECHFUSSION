import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:power_alert/core/config/app_environment.dart';
import 'package:power_alert/data/demo/demo_repositories.dart';
import 'package:power_alert/data/firebase/firebase_complaint_repository.dart';
import 'package:power_alert/data/firebase/firebase_outage_repository.dart';
import 'package:power_alert/domain/models/complaint.dart';
import 'package:power_alert/domain/models/outage.dart';
import 'package:power_alert/domain/repositories/complaint_repository.dart';
import 'package:power_alert/domain/repositories/outage_repository.dart';

final outageRepositoryProvider = Provider<OutageRepository>(
  (ref) => AppEnvironment.useDemoData
      ? DemoOutageRepository()
      : FirebaseOutageRepository(),
);

final complaintRepositoryProvider = Provider<ComplaintRepository>(
  (ref) => AppEnvironment.useDemoData
      ? DemoComplaintRepository()
      : FirebaseComplaintRepository(),
);

final activeOutagesProvider = StreamProvider<List<Outage>>(
  (ref) => ref.watch(outageRepositoryProvider).watchActiveOutages(),
);

final outageProvider = FutureProvider.family<Outage?, String>(
  (ref, id) => ref.watch(outageRepositoryProvider).getOutage(id),
);

final myComplaintsProvider = StreamProvider<List<Complaint>>(
  (ref) => ref.watch(complaintRepositoryProvider).watchMyComplaints(),
);
