import 'package:auto_port/models/operations_models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OperationsRepository {
  OperationsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<AgvTelemetry>> watchAgvTelemetry() {
    return _firestore
        .collection('agv_units')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(AgvTelemetry.fromFirestore).toList()
            ..sort((a, b) => _compareByLatest(a.lastUpdated, b.lastUpdated)),
        );
  }

  Stream<List<CraneTelemetry>> watchCraneTelemetry() {
    return _firestore
        .collection('cranes')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(CraneTelemetry.fromFirestore).toList()
            ..sort((a, b) => _compareByLatest(a.lastUpdated, b.lastUpdated)),
        );
  }

  Stream<List<DeliveryRecord>> watchDeliveryRecords() {
    return _firestore
        .collection('deliveries')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(DeliveryRecord.fromFirestore).toList()
            ..sort((a, b) => _compareByLatest(a.lastUpdated, b.lastUpdated)),
        );
  }

  Stream<List<CameraFeed>> watchCameraFeeds() {
    return _firestore
        .collection('camera_feeds')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(CameraFeed.fromFirestore).toList()
                ..sort((a, b) => _compareByLatest(a.lastSeen, b.lastSeen)),
        );
  }

  Stream<List<SensorReading>> watchSensorReadings() {
    return _firestore
        .collection('sensor_readings')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(SensorReading.fromFirestore).toList()
                ..sort((a, b) => _compareByLatest(a.lastSeen, b.lastSeen)),
        );
  }

  Stream<List<SensorEvent>> watchSensorEvents({int limit = 20}) {
    return _firestore
        .collection('sensor_events')
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(SensorEvent.fromFirestore).toList()
                ..sort((a, b) => _compareByLatest(a.createdAt, b.createdAt)),
        );
  }

  Future<void> refreshAll() async {
    await Future.wait([
      _firestore.collection('agv_units').get(),
      _firestore.collection('cranes').get(),
      _firestore.collection('deliveries').get(),
      _firestore.collection('camera_feeds').get(),
      _firestore.collection('sensor_readings').get(),
      _firestore.collection('sensor_events').limit(20).get(),
    ]);
  }
}

int _compareByLatest(DateTime? left, DateTime? right) {
  if (left == null && right == null) {
    return 0;
  }
  if (left == null) {
    return 1;
  }
  if (right == null) {
    return -1;
  }
  return right.compareTo(left);
}
