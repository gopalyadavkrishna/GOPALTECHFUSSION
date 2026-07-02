import 'package:flutter_test/flutter_test.dart';
import 'package:power_alert/domain/models/outage.dart';

void main() {
  test('restored and cancelled outages are not active', () {
    Outage create(OutageStatus status) => Outage(
      id: 'id',
      areaName: 'Area',
      providerName: 'Provider',
      reason: 'Reason',
      status: status,
      severity: OutageSeverity.low,
      startTime: DateTime(2026),
      estimatedRestoreTime: null,
      affectedPopulation: 0,
      latitude: 0,
      longitude: 0,
      progress: 0,
    );

    expect(create(OutageStatus.reported).isActive, isTrue);
    expect(create(OutageStatus.restored).isActive, isFalse);
    expect(create(OutageStatus.cancelled).isActive, isFalse);
  });
}
