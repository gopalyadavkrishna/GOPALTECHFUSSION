import 'package:power_alert/domain/models/outage.dart';

abstract interface class OutageRepository {
  Stream<List<Outage>> watchActiveOutages();

  Future<Outage?> getOutage(String id);

  Future<void> setFollowing(String outageId, {required bool following});
}
