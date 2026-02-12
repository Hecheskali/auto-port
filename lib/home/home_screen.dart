import 'package:auto_port/models/operations_models.dart';
import 'package:auto_port/services/auth_service.dart';
import 'package:auto_port/services/operations_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> _titles = [
    'AGV Status',
    'Crane Status',
    'Delivery Verification',
    'Camera Operations',
    'Sensor Operations',
  ];

  static const List<IconData> _icons = [
    Icons.local_shipping_outlined,
    Icons.precision_manufacturing_outlined,
    Icons.verified_user_outlined,
    Icons.videocam_outlined,
    Icons.sensors_outlined,
  ];

  final _authService = AuthService();
  final _operationsRepository = OperationsRepository();

  int _currentIndex = 0;

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Unable to sign out. Please try again.'),
            backgroundColor: Color(0xFFB00020),
          ),
        );
    }
  }

  Widget _buildCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return _AgvStatusView(repository: _operationsRepository);
      case 1:
        return _CraneStatusView(repository: _operationsRepository);
      case 2:
        return _DeliveryVerificationView(repository: _operationsRepository);
      case 3:
        return _CameraOperationsView(repository: _operationsRepository);
      case 4:
        return _SensorOperationsView(repository: _operationsRepository);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userLabel = _authService.currentUser?.email ?? 'Terminal Operator';

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AutoPort Dashboard',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
            ),
            Text(
              _titles[_currentIndex],
              style: const TextStyle(fontSize: 13, color: Color(0xFF9FBCD3)),
            ),
          ],
        ),
        actions: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Text(
                  userLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFD0DFED),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: _buildCurrentTab(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (value) {
          setState(() => _currentIndex = value);
        },
        destinations: List.generate(
          _titles.length,
          (index) => NavigationDestination(
            icon: Icon(_icons[index]),
            selectedIcon: Icon(_icons[index], color: const Color(0xFFBCEAF2)),
            label: _titles[index],
          ),
        ),
      ),
    );
  }
}

class _AgvStatusView extends StatelessWidget {
  const _AgvStatusView({required this.repository});

  final OperationsRepository repository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AgvTelemetry>>(
      stream: repository.watchAgvTelemetry(),
      builder: (context, snapshot) {
        final units = snapshot.data ?? const <AgvTelemetry>[];
        final onlineCount = units.where((unit) => unit.online).length;
        final activeCount = units
            .where((unit) => _isActiveMission(unit.missionStatus))
            .length;
        final delayedCount = units.where((unit) => unit.etaMinutes > 15).length;
        final avgBattery = units.isEmpty
            ? 0.0
            : units
                      .map((unit) => unit.batteryLevel)
                      .reduce((value, element) => value + element) /
                  units.length;

        return _DashboardScaffold(
          children: [
            const _SectionHeader(
              title: 'AGV Fleet Health',
              subtitle:
                  'Real AGV telemetry streamed from Firebase and fed by FastAPI ingest.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricCard(
                  label: 'Online Units',
                  value: '$onlineCount',
                  icon: Icons.local_shipping,
                  accent: const Color(0xFF62D2A2),
                ),
                _MetricCard(
                  label: 'Active Missions',
                  value: '$activeCount',
                  icon: Icons.route,
                  accent: const Color(0xFF72CCE0),
                ),
                _MetricCard(
                  label: 'Avg Battery',
                  value: '${avgBattery.toStringAsFixed(1)}%',
                  icon: Icons.battery_charging_full,
                  accent: const Color(0xFFF0C674),
                ),
                _MetricCard(
                  label: 'Delayed',
                  value: '$delayedCount',
                  icon: Icons.schedule,
                  accent: const Color(0xFFE39B86),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Panel(
              title: 'Live AGV Missions',
              subtitle:
                  'Container routing, ETA, battery level, and stream protocols.',
              child: _RealtimeState<AgvTelemetry>(
                snapshot: snapshot,
                emptyMessage: 'No AGV telemetry has been published yet.',
                child: Column(
                  children: [
                    for (var index = 0; index < units.length; index++) ...[
                      _OperationTile(
                        title:
                            '${units[index].id} · ${units[index].missionStatus}',
                        subtitle:
                            'Container: ${units[index].containerId ?? 'N/A'}\n'
                            'Route: ${units[index].currentZone} -> ${units[index].destinationZone}\n'
                            'ETA: ${units[index].etaMinutes} min · Speed: ${units[index].speedKph.toStringAsFixed(1)} km/h\n'
                            'Battery: ${units[index].batteryLevel.toStringAsFixed(1)}% · Updated: ${_formatDateTime(units[index].lastUpdated)}\n'
                            'HTTPS: ${units[index].streamHttpsUrl ?? '-'}\n'
                            'UDP: ${units[index].streamUdpUrl ?? '-'}',
                        statusLabel: units[index].online ? 'Online' : 'Offline',
                        statusColor: units[index].online
                            ? const Color(0xFF62D2A2)
                            : const Color(0xFFE39B86),
                      ),
                      if (index != units.length - 1)
                        const Divider(height: 1, color: Color(0xFF1A3C56)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CraneStatusView extends StatelessWidget {
  const _CraneStatusView({required this.repository});

  final OperationsRepository repository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CraneTelemetry>>(
      stream: repository.watchCraneTelemetry(),
      builder: (context, snapshot) {
        final cranes = snapshot.data ?? const <CraneTelemetry>[];
        final onlineCount = cranes.where((crane) => crane.online).length;
        final avgUtilization = cranes.isEmpty
            ? 0.0
            : cranes
                      .map((crane) => crane.utilizationPercent)
                      .reduce((value, element) => value + element) /
                  cranes.length;
        final movesPerHour = cranes.fold<int>(
          0,
          (total, crane) => total + crane.movesPerHour,
        );

        return _DashboardScaffold(
          children: [
            const _SectionHeader(
              title: 'Crane Operations',
              subtitle:
                  'Real crane status from camera analytics and sensor processing.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricCard(
                  label: 'Cranes Online',
                  value: '$onlineCount / ${cranes.length}',
                  icon: Icons.precision_manufacturing,
                  accent: const Color(0xFF62D2A2),
                ),
                _MetricCard(
                  label: 'Avg Utilization',
                  value: '${avgUtilization.toStringAsFixed(1)}%',
                  icon: Icons.trending_up,
                  accent: const Color(0xFF72CCE0),
                ),
                _MetricCard(
                  label: 'Moves / Hour',
                  value: '$movesPerHour',
                  icon: Icons.swap_horiz,
                  accent: const Color(0xFFF0C674),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Panel(
              title: 'Live Crane Feed',
              subtitle:
                  'Cycle progress, vessel assignment, HTTPS and UDP streams.',
              child: _RealtimeState<CraneTelemetry>(
                snapshot: snapshot,
                emptyMessage: 'No crane telemetry has been published yet.',
                child: Column(
                  children: [
                    for (var index = 0; index < cranes.length; index++) ...[
                      _ProgressRow(
                        label:
                            '${cranes[index].id} · ${cranes[index].vesselName ?? 'No vessel'}',
                        state: cranes[index].status,
                        progress: cranes[index].loadCycleProgress.clamp(0, 1),
                        accent: _statusColor(cranes[index].status),
                        subtitle:
                            'Utilization: ${cranes[index].utilizationPercent.toStringAsFixed(1)}% · '
                            'Moves/Hr: ${cranes[index].movesPerHour}\n'
                            'Updated: ${_formatDateTime(cranes[index].lastUpdated)}\n'
                            'HTTPS: ${cranes[index].streamHttpsUrl ?? '-'}\n'
                            'UDP: ${cranes[index].streamUdpUrl ?? '-'}',
                      ),
                      if (index != cranes.length - 1)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(height: 1, color: Color(0xFF1A3C56)),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DeliveryVerificationView extends StatelessWidget {
  const _DeliveryVerificationView({required this.repository});

  final OperationsRepository repository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DeliveryRecord>>(
      stream: repository.watchDeliveryRecords(),
      builder: (context, snapshot) {
        final deliveries = snapshot.data ?? const <DeliveryRecord>[];
        final pending = deliveries
            .where((record) => record.status.toLowerCase() == 'pending')
            .length;
        final verifiedToday = deliveries.where((record) {
          final verifiedAt = record.verifiedAt;
          if (verifiedAt == null) {
            return false;
          }

          final now = DateTime.now();
          return verifiedAt.year == now.year &&
              verifiedAt.month == now.month &&
              verifiedAt.day == now.day;
        }).length;
        final exceptions = deliveries
            .where((record) => record.status.toLowerCase() == 'exception')
            .length;

        return _DashboardScaffold(
          children: [
            const _SectionHeader(
              title: 'Delivery Verification',
              subtitle:
                  'Live container lifecycle from vessel arrival to gate-out execution.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricCard(
                  label: 'Pending Checks',
                  value: '$pending',
                  icon: Icons.pending_actions,
                  accent: const Color(0xFFF0C674),
                ),
                _MetricCard(
                  label: 'Verified Today',
                  value: '$verifiedToday',
                  icon: Icons.verified,
                  accent: const Color(0xFF62D2A2),
                ),
                _MetricCard(
                  label: 'Exceptions',
                  value: '$exceptions',
                  icon: Icons.report_gmailerrorred,
                  accent: const Color(0xFFE39B86),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Panel(
              title: 'Container Audit Trail',
              subtitle:
                  'Includes owner, driver, seal, timestamps, origin, destination, and status.',
              child: _RealtimeState<DeliveryRecord>(
                snapshot: snapshot,
                emptyMessage: 'No delivery records have been published yet.',
                child: Column(
                  children: [
                    for (var index = 0; index < deliveries.length; index++) ...[
                      _OperationTile(
                        title:
                            '${deliveries[index].containerId} · ${deliveries[index].status.toUpperCase()}',
                        subtitle:
                            'Owner: ${deliveries[index].ownerName} · Driver: ${deliveries[index].driverName ?? 'N/A'}\n'
                            'Truck: ${deliveries[index].truckPlate ?? 'N/A'} · Seal: ${deliveries[index].sealNumber ?? 'N/A'}\n'
                            'Vessel: ${deliveries[index].vesselName ?? 'N/A'} · Origin: ${deliveries[index].originPort ?? 'N/A'}\n'
                            'Destination Yard: ${deliveries[index].destinationYard ?? 'N/A'} · Customs: ${deliveries[index].customsStatus ?? 'N/A'}\n'
                            'Arrived: ${_formatDateTime(deliveries[index].arrivedAt)}\n'
                            'Loaded: ${_formatDateTime(deliveries[index].loadedAt)}\n'
                            'Verified: ${_formatDateTime(deliveries[index].verifiedAt)}\n'
                            'Expected Gate-out: ${_formatDateTime(deliveries[index].expectedGateOutAt)}\n'
                            'Actual Gate-out: ${_formatDateTime(deliveries[index].actualGateOutAt)}\n'
                            'Updated: ${_formatDateTime(deliveries[index].lastUpdated)}',
                        statusLabel: deliveries[index].status,
                        statusColor: _statusColor(deliveries[index].status),
                      ),
                      if (index != deliveries.length - 1)
                        const Divider(height: 1, color: Color(0xFF1A3C56)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CameraOperationsView extends StatelessWidget {
  const _CameraOperationsView({required this.repository});

  final OperationsRepository repository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CameraFeed>>(
      stream: repository.watchCameraFeeds(),
      builder: (context, snapshot) {
        final feeds = snapshot.data ?? const <CameraFeed>[];
        final online = feeds.where((feed) => feed.online).length;
        final detections = feeds.fold<int>(
          0,
          (total, feed) => total + feed.aiDetectionCount,
        );
        final staleFeeds = feeds.where((feed) {
          final lastSeen = feed.lastSeen;
          if (lastSeen == null) {
            return true;
          }

          return DateTime.now().difference(lastSeen).inMinutes > 2;
        }).length;

        return _DashboardScaffold(
          children: [
            const _SectionHeader(
              title: 'Camera Operations',
              subtitle:
                  'Real camera statuses and stream endpoints over HTTPS/UDP.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricCard(
                  label: 'Cameras Online',
                  value: '$online / ${feeds.length}',
                  icon: Icons.videocam,
                  accent: const Color(0xFF72CCE0),
                ),
                _MetricCard(
                  label: 'AI Detections',
                  value: '$detections',
                  icon: Icons.center_focus_strong,
                  accent: const Color(0xFFF0C674),
                ),
                _MetricCard(
                  label: 'Stale Feeds',
                  value: '$staleFeeds',
                  icon: Icons.warning_amber_rounded,
                  accent: const Color(0xFFE39B86),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Panel(
              title: 'Live Stream Registry',
              subtitle:
                  'Use HTTPS playback links in app viewers and UDP source for edge gateways.',
              child: _RealtimeState<CameraFeed>(
                snapshot: snapshot,
                emptyMessage: 'No camera feeds have been published yet.',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final feed in feeds)
                      _CameraFeedTile(
                        cameraName: feed.name,
                        location: feed.zone,
                        status: feed.status,
                        statusColor: _statusColor(feed.status),
                        subtitle:
                            'Last seen: ${_formatDateTime(feed.lastSeen)}\n'
                            'Protocol: ${feed.protocol ?? 'N/A'}\n'
                            'HTTPS: ${feed.streamHttpsUrl ?? '-'}\n'
                            'UDP: ${feed.streamUdpUrl ?? '-'}',
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SensorOperationsView extends StatelessWidget {
  const _SensorOperationsView({required this.repository});

  final OperationsRepository repository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SensorReading>>(
      stream: repository.watchSensorReadings(),
      builder: (context, sensorSnapshot) {
        final sensors = sensorSnapshot.data ?? const <SensorReading>[];
        final onlineCount = sensors.where((sensor) => sensor.online).length;
        final anomalies = sensors.where((sensor) => sensor.anomaly).length;

        return _DashboardScaffold(
          children: [
            const _SectionHeader(
              title: 'Sensor Operations',
              subtitle:
                  'Real machine and environmental sensor telemetry from Firebase.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricCard(
                  label: 'Sensors Online',
                  value: '$onlineCount / ${sensors.length}',
                  icon: Icons.sensors,
                  accent: const Color(0xFF62D2A2),
                ),
                _MetricCard(
                  label: 'Anomaly Alerts',
                  value: '$anomalies',
                  icon: Icons.notification_important_outlined,
                  accent: const Color(0xFFE39B86),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Panel(
              title: 'Live Sensor Matrix',
              subtitle:
                  'Per-sensor current value, source protocol, and event detail.',
              child: _RealtimeState<SensorReading>(
                snapshot: sensorSnapshot,
                emptyMessage: 'No sensor readings have been published yet.',
                child: Column(
                  children: [
                    for (var index = 0; index < sensors.length; index++) ...[
                      _OperationTile(
                        title:
                            '${sensors[index].name} · ${sensors[index].kind}',
                        subtitle:
                            'Location: ${sensors[index].location}\n'
                            'Status: ${sensors[index].status}\n'
                            'Value: ${sensors[index].value.toStringAsFixed(3)} ${sensors[index].unit}\n'
                            'Protocol: ${sensors[index].sourceProtocol ?? 'N/A'}\n'
                            'Last seen: ${_formatDateTime(sensors[index].lastSeen)}\n'
                            'Event: ${sensors[index].eventDescription ?? 'No active event'}',
                        statusLabel: sensors[index].anomaly
                            ? 'Anomaly'
                            : 'Normal',
                        statusColor: sensors[index].anomaly
                            ? const Color(0xFFE39B86)
                            : const Color(0xFF62D2A2),
                      ),
                      if (index != sensors.length - 1)
                        const Divider(height: 1, color: Color(0xFF1A3C56)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<SensorEvent>>(
              stream: repository.watchSensorEvents(),
              builder: (context, eventSnapshot) {
                final events = eventSnapshot.data ?? const <SensorEvent>[];

                return _Panel(
                  title: 'Recent Sensor Events',
                  subtitle:
                      'Events raised by FastAPI ingestion and automation logic.',
                  child: _RealtimeState<SensorEvent>(
                    snapshot: eventSnapshot,
                    emptyMessage: 'No sensor events have been published yet.',
                    child: Column(
                      children: [
                        for (var index = 0; index < events.length; index++) ...[
                          _OperationTile(
                            title: events[index].title,
                            subtitle:
                                'Asset: ${events[index].assetId ?? 'N/A'}\n'
                                'Created: ${_formatDateTime(events[index].createdAt)}\n'
                                '${events[index].description ?? 'No description'}',
                            statusLabel: events[index].status,
                            statusColor: _statusColor(events[index].status),
                          ),
                          if (index != events.length - 1)
                            const Divider(height: 1, color: Color(0xFF1A3C56)),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _RealtimeState<T> extends StatelessWidget {
  const _RealtimeState({
    required this.snapshot,
    required this.emptyMessage,
    required this.child,
  });

  final AsyncSnapshot<List<T>> snapshot;
  final String emptyMessage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasError) {
      return _EmptyDataHint(
        icon: Icons.error_outline,
        message: 'Failed to load live data: ${snapshot.error}',
      );
    }

    if (snapshot.connectionState == ConnectionState.waiting &&
        !snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = snapshot.data;
    if (data == null || data.isEmpty) {
      return _EmptyDataHint(
        icon: Icons.cloud_off_outlined,
        message: emptyMessage,
      );
    }

    return child;
  }
}

class _DashboardScaffold extends StatelessWidget {
  const _DashboardScaffold({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth > 900 ? 24.0 : 16.0;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            16,
            horizontalPadding,
            24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: Color(0xFF9FB1C2))),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: Color(0xFF9FB1C2)),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF10263A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1A3C56)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(label, style: const TextStyle(color: Color(0xFF9FB1C2))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OperationTile extends StatelessWidget {
  const _OperationTile({
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.statusColor,
  });

  final String title;
  final String subtitle;
  final String statusLabel;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF9FB1C2),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _TagBadge(label: statusLabel, color: statusColor),
        ],
      ),
    );
  }
}

class _TagBadge extends StatelessWidget {
  const _TagBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.17),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.state,
    required this.progress,
    required this.accent,
    required this.subtitle,
  });

  final String label;
  final String state;
  final double progress;
  final Color accent;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            _TagBadge(label: state, color: accent),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: const Color(0xFF1A3C56),
            color: accent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$percentage% cycle completion',
          style: const TextStyle(color: Color(0xFF9FB1C2)),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF9FB1C2), fontSize: 13),
        ),
      ],
    );
  }
}

class _CameraFeedTile extends StatelessWidget {
  const _CameraFeedTile({
    required this.cameraName,
    required this.location,
    required this.status,
    required this.statusColor,
    required this.subtitle,
  });

  final String cameraName;
  final String location;
  final String status;
  final Color statusColor;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0E2437),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1A3C56)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(13),
                ),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF274E6D),
                    statusColor.withValues(alpha: 0.45),
                  ],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.videocam_rounded,
                  size: 44,
                  color: Color(0xFFD6F0F5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cameraName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _TagBadge(label: status, color: statusColor),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    location,
                    style: const TextStyle(
                      color: Color(0xFF9FB1C2),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF9FB1C2),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDataHint extends StatelessWidget {
  const _EmptyDataHint({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D344D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E4F6D)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF86D5E5)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFCEEAF0), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

bool _isActiveMission(String status) {
  final normalized = status.trim().toLowerCase();
  return normalized == 'active' ||
      normalized == 'loading' ||
      normalized == 'unloading' ||
      normalized == 'in_transit' ||
      normalized == 'in-transit';
}

Color _statusColor(String status) {
  final normalized = status.trim().toLowerCase();

  if (normalized == 'online' ||
      normalized == 'verified' ||
      normalized == 'normal' ||
      normalized == 'completed' ||
      normalized == 'mitigated') {
    return const Color(0xFF62D2A2);
  }

  if (normalized == 'pending' ||
      normalized == 'review' ||
      normalized == 'degraded' ||
      normalized == 'congestion') {
    return const Color(0xFFF0C674);
  }

  if (normalized == 'offline' ||
      normalized == 'exception' ||
      normalized == 'alert' ||
      normalized == 'error') {
    return const Color(0xFFE39B86);
  }

  return const Color(0xFF72CCE0);
}

final DateFormat _timestampFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

String _formatDateTime(DateTime? value) {
  if (value == null) {
    return 'N/A';
  }

  return _timestampFormat.format(value.toLocal());
}
