import 'package:cloud_firestore/cloud_firestore.dart';

class AgvTelemetry {
  const AgvTelemetry({
    required this.id,
    required this.online,
    required this.missionStatus,
    required this.currentZone,
    required this.destinationZone,
    required this.batteryLevel,
    required this.speedKph,
    required this.etaMinutes,
    this.containerId,
    this.streamHttpsUrl,
    this.streamUdpUrl,
    this.lastUpdated,
  });

  final String id;
  final bool online;
  final String missionStatus;
  final String currentZone;
  final String destinationZone;
  final double batteryLevel;
  final double speedKph;
  final int etaMinutes;
  final String? containerId;
  final String? streamHttpsUrl;
  final String? streamUdpUrl;
  final DateTime? lastUpdated;

  factory AgvTelemetry.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};

    return AgvTelemetry(
      id: document.id,
      online: _asBool(data['online'], fallback: false),
      missionStatus: _asString(data['missionStatus'], fallback: 'unknown'),
      currentZone: _asString(data['currentZone'], fallback: 'N/A'),
      destinationZone: _asString(data['destinationZone'], fallback: 'N/A'),
      batteryLevel: _asDouble(data['batteryLevel']),
      speedKph: _asDouble(data['speedKph']),
      etaMinutes: _asInt(data['etaMinutes']),
      containerId: _asNullableString(data['containerId']),
      streamHttpsUrl: _asNullableString(data['streamHttpsUrl']),
      streamUdpUrl: _asNullableString(data['streamUdpUrl']),
      lastUpdated: _asDateTime(data['lastUpdated'] ?? data['recordedAt']),
    );
  }
}

class CraneTelemetry {
  const CraneTelemetry({
    required this.id,
    required this.online,
    required this.status,
    required this.utilizationPercent,
    required this.movesPerHour,
    required this.loadCycleProgress,
    this.vesselName,
    this.streamHttpsUrl,
    this.streamUdpUrl,
    this.lastUpdated,
  });

  final String id;
  final bool online;
  final String status;
  final double utilizationPercent;
  final int movesPerHour;
  final double loadCycleProgress;
  final String? vesselName;
  final String? streamHttpsUrl;
  final String? streamUdpUrl;
  final DateTime? lastUpdated;

  factory CraneTelemetry.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};

    return CraneTelemetry(
      id: document.id,
      online: _asBool(data['online'], fallback: false),
      status: _asString(data['status'], fallback: 'unknown'),
      utilizationPercent: _asDouble(data['utilizationPercent']),
      movesPerHour: _asInt(data['movesPerHour']),
      loadCycleProgress: _asDouble(data['loadCycleProgress']),
      vesselName: _asNullableString(data['vesselName']),
      streamHttpsUrl: _asNullableString(data['streamHttpsUrl']),
      streamUdpUrl: _asNullableString(data['streamUdpUrl']),
      lastUpdated: _asDateTime(data['lastUpdated'] ?? data['recordedAt']),
    );
  }
}

class DeliveryRecord {
  const DeliveryRecord({
    required this.id,
    required this.containerId,
    required this.status,
    required this.ownerName,
    this.driverName,
    this.truckPlate,
    this.vesselName,
    this.originPort,
    this.destinationYard,
    this.sealNumber,
    this.customsStatus,
    this.arrivedAt,
    this.loadedAt,
    this.verifiedAt,
    this.expectedGateOutAt,
    this.actualGateOutAt,
    this.lastUpdated,
  });

  final String id;
  final String containerId;
  final String status;
  final String ownerName;
  final String? driverName;
  final String? truckPlate;
  final String? vesselName;
  final String? originPort;
  final String? destinationYard;
  final String? sealNumber;
  final String? customsStatus;
  final DateTime? arrivedAt;
  final DateTime? loadedAt;
  final DateTime? verifiedAt;
  final DateTime? expectedGateOutAt;
  final DateTime? actualGateOutAt;
  final DateTime? lastUpdated;

  factory DeliveryRecord.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};

    return DeliveryRecord(
      id: document.id,
      containerId: _asString(data['containerId'], fallback: document.id),
      status: _asString(data['status'], fallback: 'pending'),
      ownerName: _asString(data['ownerName'], fallback: 'N/A'),
      driverName: _asNullableString(data['driverName']),
      truckPlate: _asNullableString(data['truckPlate']),
      vesselName: _asNullableString(data['vesselName']),
      originPort: _asNullableString(data['originPort']),
      destinationYard: _asNullableString(data['destinationYard']),
      sealNumber: _asNullableString(data['sealNumber']),
      customsStatus: _asNullableString(data['customsStatus']),
      arrivedAt: _asDateTime(data['arrivedAt'] ?? data['arrivalAt']),
      loadedAt: _asDateTime(data['loadedAt']),
      verifiedAt: _asDateTime(data['verifiedAt']),
      expectedGateOutAt: _asDateTime(data['expectedGateOutAt']),
      actualGateOutAt: _asDateTime(data['actualGateOutAt']),
      lastUpdated: _asDateTime(data['lastUpdated'] ?? data['recordedAt']),
    );
  }
}

class CameraFeed {
  const CameraFeed({
    required this.id,
    required this.name,
    required this.zone,
    required this.status,
    required this.online,
    required this.aiDetectionCount,
    this.streamHttpsUrl,
    this.streamUdpUrl,
    this.protocol,
    this.lastSeen,
  });

  final String id;
  final String name;
  final String zone;
  final String status;
  final bool online;
  final int aiDetectionCount;
  final String? streamHttpsUrl;
  final String? streamUdpUrl;
  final String? protocol;
  final DateTime? lastSeen;

  factory CameraFeed.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};

    return CameraFeed(
      id: document.id,
      name: _asString(data['name'], fallback: document.id),
      zone: _asString(data['zone'], fallback: 'N/A'),
      status: _asString(data['status'], fallback: 'unknown'),
      online: _asBool(data['online'], fallback: false),
      aiDetectionCount: _asInt(data['aiDetectionCount']),
      streamHttpsUrl: _asNullableString(data['streamHttpsUrl']),
      streamUdpUrl: _asNullableString(data['streamUdpUrl']),
      protocol: _asNullableString(data['protocol']),
      lastSeen: _asDateTime(data['lastSeen'] ?? data['recordedAt']),
    );
  }
}

class SensorReading {
  const SensorReading({
    required this.id,
    required this.name,
    required this.kind,
    required this.location,
    required this.status,
    required this.online,
    required this.value,
    required this.unit,
    required this.anomaly,
    this.sourceProtocol,
    this.eventDescription,
    this.lastSeen,
  });

  final String id;
  final String name;
  final String kind;
  final String location;
  final String status;
  final bool online;
  final double value;
  final String unit;
  final bool anomaly;
  final String? sourceProtocol;
  final String? eventDescription;
  final DateTime? lastSeen;

  factory SensorReading.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};

    return SensorReading(
      id: document.id,
      name: _asString(data['name'], fallback: document.id),
      kind: _asString(data['kind'], fallback: 'sensor'),
      location: _asString(data['location'], fallback: 'N/A'),
      status: _asString(data['status'], fallback: 'unknown'),
      online: _asBool(data['online'], fallback: false),
      value: _asDouble(data['value']),
      unit: _asString(data['unit'], fallback: ''),
      anomaly: _asBool(data['anomaly'], fallback: false),
      sourceProtocol: _asNullableString(data['sourceProtocol']),
      eventDescription: _asNullableString(data['eventDescription']),
      lastSeen: _asDateTime(data['lastSeen'] ?? data['recordedAt']),
    );
  }
}

class SensorEvent {
  const SensorEvent({
    required this.id,
    required this.title,
    required this.status,
    this.description,
    this.assetId,
    this.createdAt,
  });

  final String id;
  final String title;
  final String status;
  final String? description;
  final String? assetId;
  final DateTime? createdAt;

  factory SensorEvent.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};

    return SensorEvent(
      id: document.id,
      title: _asString(data['title'], fallback: document.id),
      status: _asString(data['status'], fallback: 'open'),
      description: _asNullableString(data['description']),
      assetId: _asNullableString(data['assetId']),
      createdAt: _asDateTime(data['createdAt']),
    );
  }
}

DateTime? _asDateTime(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is Timestamp) {
    return value.toDate();
  }

  if (value is DateTime) {
    return value;
  }

  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }

  if (value is String) {
    return DateTime.tryParse(value);
  }

  return null;
}

double _asDouble(dynamic value, {double fallback = 0}) {
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value) ?? fallback;
  }

  return fallback;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }

  if (value is num) {
    return value.toInt();
  }

  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }

  return fallback;
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) {
    return value;
  }

  if (value is num) {
    return value > 0;
  }

  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'online') {
      return true;
    }

    if (normalized == 'false' || normalized == '0' || normalized == 'offline') {
      return false;
    }
  }

  return fallback;
}

String _asString(dynamic value, {String fallback = ''}) {
  final normalized = value?.toString().trim();
  if (normalized == null || normalized.isEmpty) {
    return fallback;
  }

  return normalized;
}

String? _asNullableString(dynamic value) {
  final normalized = value?.toString().trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }

  return normalized;
}
