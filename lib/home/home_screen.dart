import 'dart:ui';

import 'package:auto_port/home/video_player_screen.dart';
import 'package:auto_port/models/operations_models.dart';
import 'package:auto_port/providers/theme_provider.dart';
import 'package:auto_port/services/auth_service.dart';
import 'package:auto_port/services/operations_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:auto_port/home/settings_notifications.dart';
import 'package:provider/provider.dart';

// ----------------------------------------------------------------------------
// 1. THEME & COLORS – Deep navy, electric teal, amber, rose, glassmorphism
// ----------------------------------------------------------------------------
class PortColors extends ThemeExtension<PortColors> {
  final Color background;
  final Color surfaceGlass;
  final Color accentTeal;
  final Color accentAmber;
  final Color accentRose;
  final Color textPrimary;
  final Color textSecondary;

  const PortColors({
    required this.background,
    required this.surfaceGlass,
    required this.accentTeal,
    required this.accentAmber,
    required this.accentRose,
    required this.textPrimary,
    required this.textSecondary,
  });

  static const light = PortColors(
    background: Color(0xFFF2F6FA),
    surfaceGlass: Color(0xCCFFFFFF),
    accentTeal: Color(0xFF2DD4BF),
    accentAmber: Color(0xFFF59E0B),
    accentRose: Color(0xFFEF4444),
    textPrimary: Color(0xFF0A1A2B),
    textSecondary: Color(0xFF52647A),
  );

  static const dark = PortColors(
    background: Color(0xFF0A1A2B),
    surfaceGlass: Color(0xAA1E3A5F),
    accentTeal: Color(0xFF2DD4BF),
    accentAmber: Color(0xFFF59E0B),
    accentRose: Color(0xFFEF4444),
    textPrimary: Colors.white,
    textSecondary: Color(0xFFB0C4DE),
  );

  @override
  PortColors copyWith({
    Color? background,
    Color? surfaceGlass,
    Color? accentTeal,
    Color? accentAmber,
    Color? accentRose,
    Color? textPrimary,
    Color? textSecondary,
  }) {
    return PortColors(
      background: background ?? this.background,
      surfaceGlass: surfaceGlass ?? this.surfaceGlass,
      accentTeal: accentTeal ?? this.accentTeal,
      accentAmber: accentAmber ?? this.accentAmber,
      accentRose: accentRose ?? this.accentRose,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }

  @override
  PortColors lerp(ThemeExtension<PortColors>? other, double t) {
    if (other is! PortColors) return this;
    return PortColors(
      background: Color.lerp(background, other.background, t)!,
      surfaceGlass: Color.lerp(surfaceGlass, other.surfaceGlass, t)!,
      accentTeal: Color.lerp(accentTeal, other.accentTeal, t)!,
      accentAmber: Color.lerp(accentAmber, other.accentAmber, t)!,
      accentRose: Color.lerp(accentRose, other.accentRose, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    );
  }
}

// ----------------------------------------------------------------------------
// 2. UTILITIES
// ----------------------------------------------------------------------------
final DateFormat _timeFormat = DateFormat('HH:mm:ss');
final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
final DateFormat _shortTime = DateFormat('HH:mm');

String formatTime(DateTime? time) =>
    time != null ? _timeFormat.format(time.toLocal()) : 'N/A';
String formatDate(DateTime? date) =>
    date != null ? _dateFormat.format(date.toLocal()) : 'N/A';
String formatShortTime(DateTime? time) =>
    time != null ? _shortTime.format(time.toLocal()) : 'N/A';

// ----------------------------------------------------------------------------
// 3. REALTIME STATE HANDLER (loading, error, empty) – kept for lists
// ----------------------------------------------------------------------------
class _RealtimeState<T> extends StatelessWidget {
  final AsyncSnapshot<List<T>> snapshot;
  final String emptyMessage;
  final Widget Function(List<T> data) builder;

  const _RealtimeState({
    required this.snapshot,
    required this.emptyMessage,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasError) {
      return _EmptyDataHint(
        icon: Icons.error_outline,
        message: 'Failed to load data: ${snapshot.error}',
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
    return builder(data);
  }
}

// ----------------------------------------------------------------------------
// 4. MAIN DASHBOARD WITH SIDEBAR, TOP/BOTTOM BARS
// ----------------------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _operationsRepository = OperationsRepository();
  int _selectedIndex = 0;
  bool _sidebarCollapsed = false;

  // Fixed logout method – no manual navigation, auth state listener handles it
  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed out successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = themeProvider.isDark ? PortColors.dark : PortColors.light;
    final baseTheme = themeProvider.isDark
        ? ThemeData.dark()
        : ThemeData.light();

    return Theme(
      data: baseTheme.copyWith(
        scaffoldBackgroundColor: colors.background,
        extensions: [colors],
        textTheme: baseTheme.textTheme.apply(fontFamily: 'Inter'),
        primaryTextTheme: baseTheme.primaryTextTheme.apply(fontFamily: 'Inter'),
      ),
      child: Scaffold(
        drawer: NotificationPanel(),
        body: Row(
          children: [
            _buildSidebar(colors),
            Expanded(
              child: Column(
                children: [
                  _buildTopBar(colors),
                  Expanded(child: _buildMainContent()),
                  _buildBottomBar(colors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SIDEBAR

  Widget _buildSidebar(PortColors colors) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _sidebarCollapsed ? 80 : 260,
      child: Material(
        color: colors.background.withOpacity(0.95),
        elevation: 10,
        child: Column(
          children: [
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (!_sidebarCollapsed)
                    const Expanded(
                      child: Text(
                        'AUTOPORT',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: Icon(
                      _sidebarCollapsed
                          ? Icons.chevron_right
                          : Icons.chevron_left,
                      color: colors.accentTeal,
                    ),
                    onPressed: () {
                      setState(() {
                        _sidebarCollapsed = !_sidebarCollapsed;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF2A4A6A)),
            Expanded(
              child: ListView(
                children: [
                  _SidebarItem(
                    icon: Icons.map_outlined,
                    label: 'AGV Fleet',
                    selected: _selectedIndex == 0,
                    collapsed: _sidebarCollapsed,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                  _SidebarItem(
                    icon: Icons.precision_manufacturing_outlined,
                    label: 'Cranes',
                    selected: _selectedIndex == 1,
                    collapsed: _sidebarCollapsed,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                  _SidebarItem(
                    icon: Icons.verified_user_outlined,
                    label: 'Deliveries',
                    selected: _selectedIndex == 2,
                    collapsed: _sidebarCollapsed,
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                  _SidebarItem(
                    icon: Icons.videocam_outlined,
                    label: 'Cameras',
                    selected: _selectedIndex == 3,
                    collapsed: _sidebarCollapsed,
                    onTap: () => setState(() => _selectedIndex = 3),
                  ),
                  _SidebarItem(
                    icon: Icons.sensors_outlined,
                    label: 'Sensors',
                    selected: _selectedIndex == 4,
                    collapsed: _sidebarCollapsed,
                    onTap: () => setState(() => _selectedIndex = 4),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.keyboard, color: colors.textSecondary, size: 16),
                  const SizedBox(width: 8),
                  if (!_sidebarCollapsed)
                    Text('⌘K', style: TextStyle(color: colors.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TOP BAR – clock, weather, alerts, user with logout popup

  Widget _buildTopBar(PortColors colors) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: colors.surfaceGlass,
        border: Border(
          bottom: BorderSide(color: colors.accentTeal.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          StreamBuilder<DateTime>(
            stream: Stream.periodic(
              const Duration(seconds: 1),
              (_) => DateTime.now(),
            ),
            builder: (context, snapshot) {
              final now = snapshot.data ?? DateTime.now();
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.accentTeal.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'LOC ${formatShortTime(now)}',
                      style: TextStyle(color: colors.accentTeal),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'UTC ${formatShortTime(now.toUtc())}',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ),
                ],
              );
            },
          ),
          const Spacer(),

          Row(
            children: [
              Icon(Icons.wb_sunny, color: colors.accentAmber, size: 18),
              const SizedBox(width: 6),
              Text('--°C', style: TextStyle(color: colors.textSecondary)),
            ],
          ),
          const SizedBox(width: 24),
          IconButton(
            icon: Icon(Icons.refresh, color: colors.textSecondary),
            onPressed: _refreshAllData,
            tooltip: 'Refresh data',
          ),
          IconButton(
            icon: Icon(Icons.settings, color: colors.textSecondary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SettingsPanel(userEmail: _authService.currentUser?.email),
                ),
              );
            },
            tooltip: 'Settings',
          ),
          // Notifications with badge and drawer trigger
          Builder(
            builder: (context) {
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_none,
                      color: colors.textPrimary,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                  Consumer<NotificationProvider>(
                    builder: (context, provider, _) {
                      if (provider.unreadCount == 0) {
                        return const SizedBox.shrink();
                      }
                      return Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${provider.unreadCount}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
          // Logout popup menu replacing the avatar
          PopupMenuButton<String>(
            offset: const Offset(0, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: colors.accentTeal,
              child: Text(
                _authService.currentUser?.email?[0].toUpperCase() ?? 'O',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onSelected: (value) async {
              if (value == 'logout') {
                await _signOut();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'email',
                enabled: false,
                child: Text(
                  _authService.currentUser?.email ?? 'User',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // setting and refresh functions
  Future<void> _refreshAllData() async {
    await _operationsRepository.refreshAll();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Data refreshed')));
  }

  void _showSettings() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final colors =
              Theme.of(context).extension<PortColors>() ??
              (themeProvider.isDark ? PortColors.dark : PortColors.light);
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surfaceGlass,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
                    color: colors.accentTeal,
                  ),
                  title: Text(
                    'Dark Mode',
                    style: TextStyle(color: colors.textPrimary),
                  ),
                  trailing: Switch(
                    value: themeProvider.isDark,
                    onChanged: (_) => themeProvider.toggleTheme(),
                    activeThumbColor: colors.accentTeal,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _playVideo(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => VideoPlayerScreen(url: url),
      ),
    );
  }

  // BOTTOM BAR – live KPIs (using delivery stream)

  Widget _buildBottomBar(PortColors colors) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: colors.surfaceGlass,
        border: Border(
          top: BorderSide(color: colors.accentTeal.withOpacity(0.3)),
        ),
      ),
      child: StreamBuilder<List<DeliveryRecord>>(
        stream: _operationsRepository.watchDeliveryRecords(),
        builder: (context, snapshot) {
          final deliveries = snapshot.data ?? const <DeliveryRecord>[];
          final movedToday = deliveries
              .where((d) => d.status.toLowerCase() == 'verified')
              .length;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _KpiWithSparkline(
                label: 'Containers Moved',
                value: '$movedToday',
                trend: const [],
                color: colors.accentTeal,
              ),
              _KpiWithSparkline(
                label: 'Avg Turnaround',
                value:
                    '2.4h', // placeholder – compute later after tumepata hardware data
                trend: const [],
                color: colors.accentAmber,
              ),
              _KpiWithSparkline(
                label: 'Energy (MWh)',
                value:
                    '184', // placeholder -– compute later after tumepata hardware data
                trend: const [],
                color: colors.accentRose,
              ),
            ],
          );
        },
      ),
    );
  }

  // MAIN CONTENT – switches between modules

  Widget _buildMainContent() {
    switch (_selectedIndex) {
      case 0:
        return _AgvTab(repository: _operationsRepository);
      case 1:
        return _CraneTab(repository: _operationsRepository);
      case 2:
        return _DeliveryTab(repository: _operationsRepository);
      case 3:
        return _CameraTab(
          repository: _operationsRepository,
          onPlayVideo: _playVideo,
        );
      case 4:
        return _SensorTab(repository: _operationsRepository);
      default:
        return const SizedBox.shrink();
    }
  }
}

// SIDEBAR ITEM

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PortColors>()!;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: selected
              ? colors.accentTeal.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: selected ? Border.all(color: colors.accentTeal) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? colors.accentTeal : colors.textSecondary,
            ),
            if (!collapsed) ...[
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: selected ? colors.accentTeal : colors.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// KPI WITH SPARKLINE

class _KpiWithSparkline extends StatelessWidget {
  final String label;
  final String value;
  final List<double> trend;
  final Color color;

  const _KpiWithSparkline({
    required this.label,
    required this.value,
    required this.trend,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        if (trend.isNotEmpty) ...[
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            height: 30,
            child: _SparklineChart(data: trend, color: color),
          ),
        ],
      ],
    );
  }
}

class _SparklineChart extends StatelessWidget {
  final List<double> data;
  final Color color;

  const _SparklineChart({required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data
                .asMap()
                .entries
                .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                .toList(),
            isCurved: true,
            color: color,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}

// GENERIC TAB CONTAINER (with grid layout)

class _DashboardTab extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _DashboardTab({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w300,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 600,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.4,
              ),
              itemCount: children.length,
              itemBuilder: (context, index) => children[index],
            ),
          ),
        ],
      ),
    );
  }
}

// GLASS CARD WRAPPER

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? height;
  final double? width;
  const GlassCard({super.key, required this.child, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PortColors>()!;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: colors.surfaceGlass,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.accentTeal.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );
  }
}

// 1. AGV TAB – 2.5D MAP + METRICS

class _AgvTab extends StatelessWidget {
  final OperationsRepository repository;
  const _AgvTab({required this.repository});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PortColors>()!;

    return _DashboardTab(
      title: 'AGV Fleet',
      children: [
        // 1. Interactive Yard Map
        GlassCard(
          height: 420,
          child: StreamBuilder<List<AgvTelemetry>>(
            stream: repository.watchAgvTelemetry(),
            builder: (context, snapshot) {
              return _RealtimeState<AgvTelemetry>(
                snapshot: snapshot,
                emptyMessage: 'No AGV telemetry available.',
                builder: (units) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Interactive Yard Map', style: _titleStyle),
                    const SizedBox(height: 8),
                    Expanded(
                      child: CustomPaint(
                        painter: _AgvMapPainter(units: units),
                        size: const Size(800, 500),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // 2. Online Units
        GlassCard(
          child: StreamBuilder<List<AgvTelemetry>>(
            stream: repository.watchAgvTelemetry(),
            builder: (context, snapshot) {
              final units = snapshot.data ?? const <AgvTelemetry>[];
              return _MetricWidget(
                label: 'Online',
                value: '${units.onlineCount}',
                color: colors.accentTeal,
              );
            },
          ),
        ),
        // 3. Avg Battery
        GlassCard(
          child: StreamBuilder<List<AgvTelemetry>>(
            stream: repository.watchAgvTelemetry(),
            builder: (context, snapshot) {
              final units = snapshot.data ?? const <AgvTelemetry>[];
              return _MetricWidget(
                label: 'Avg Battery',
                value: '${units.avgBattery.toStringAsFixed(1)}%',
                color: colors.accentAmber,
              );
            },
          ),
        ),
        // 4. Active Missions
        GlassCard(
          child: StreamBuilder<List<AgvTelemetry>>(
            stream: repository.watchAgvTelemetry(),
            builder: (context, snapshot) {
              final units = snapshot.data ?? const <AgvTelemetry>[];
              return _MetricWidget(
                label: 'Active Missions',
                value: '${units.activeCount}',
                color: colors.accentRose,
              );
            },
          ),
        ),
      ],
    );
  }

  TextStyle get _titleStyle =>
      const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
}

// AGV map painter – uses deterministic placement based on id
class _AgvMapPainter extends CustomPainter {
  final List<AgvTelemetry> units;
  _AgvMapPainter({required this.units});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 0.5;
    for (int i = 0; i <= 10; i++) {
      double x = i * size.width / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      double y = i * size.height / 10;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (var unit in units) {
      double x = (unit.id.hashCode % 100) / 100 * size.width;
      double y = (unit.id.hashCode ~/ 100 % 100) / 100 * size.height;

      final dotPaint = Paint()
        ..color = unit.online ? const Color(0xFF2DD4BF) : Colors.grey
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(x, y), 10, dotPaint);
      dotPaint.maskFilter = null;
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AgvMapPainter oldDelegate) =>
      oldDelegate.units != units;
}

// 2. CRANE TAB – GANTT TIMELINE + METRICS

class _CraneTab extends StatelessWidget {
  final OperationsRepository repository;
  const _CraneTab({required this.repository});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PortColors>()!;

    return _DashboardTab(
      title: 'Crane Operations',
      children: [
        // Timeline card
        GlassCard(
          height: 300,
          child: StreamBuilder<List<CraneTelemetry>>(
            stream: repository.watchCraneTelemetry(),
            builder: (context, snapshot) {
              return _RealtimeState<CraneTelemetry>(
                snapshot: snapshot,
                emptyMessage: 'No crane telemetry available.',
                builder: (cranes) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Timeline View', style: _titleStyle),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: cranes.length,
                        itemBuilder: (context, index) {
                          final crane = cranes[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    crane.id,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: crane.loadCycleProgress
                                          .clamp(0, 1),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: _statusColor(
                                            context,
                                            crane.status,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Online metric
        GlassCard(
          child: StreamBuilder<List<CraneTelemetry>>(
            stream: repository.watchCraneTelemetry(),
            builder: (context, snapshot) {
              final cranes = snapshot.data ?? const <CraneTelemetry>[];
              final online = cranes.where((c) => c.online).length;
              return _MetricWidget(
                label: 'Online',
                value: '$online/${cranes.length}',
                color: colors.accentTeal,
              );
            },
          ),
        ),
        // Avg Utilization
        GlassCard(
          child: StreamBuilder<List<CraneTelemetry>>(
            stream: repository.watchCraneTelemetry(),
            builder: (context, snapshot) {
              final cranes = snapshot.data ?? const <CraneTelemetry>[];
              final avgUtil = cranes.isEmpty
                  ? 0.0
                  : cranes
                            .map((c) => c.utilizationPercent)
                            .reduce((a, b) => a + b) /
                        cranes.length;
              return _MetricWidget(
                label: 'Avg Utilization',
                value: '${avgUtil.toStringAsFixed(1)}%',
                color: colors.accentAmber,
              );
            },
          ),
        ),
        // Moves/Hour
        GlassCard(
          child: StreamBuilder<List<CraneTelemetry>>(
            stream: repository.watchCraneTelemetry(),
            builder: (context, snapshot) {
              final cranes = snapshot.data ?? const <CraneTelemetry>[];
              final moves = cranes.fold(0, (sum, c) => sum + c.movesPerHour);
              return _MetricWidget(
                label: 'Moves/Hour',
                value: '$moves',
                color: colors.accentRose,
              );
            },
          ),
        ),
      ],
    );
  }

  TextStyle get _titleStyle =>
      const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
}

// 3. DELIVERY TAB – KANBAN BOARD + METRICS

class _DeliveryTab extends StatelessWidget {
  final OperationsRepository repository;
  const _DeliveryTab({required this.repository});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PortColors>()!;

    return _DashboardTab(
      title: 'Delivery Verification',
      children: [
        // Kanban board
        GlassCard(
          height: 400,
          child: StreamBuilder<List<DeliveryRecord>>(
            stream: repository.watchDeliveryRecords(),
            builder: (context, snapshot) {
              return _RealtimeState<DeliveryRecord>(
                snapshot: snapshot,
                emptyMessage: 'No delivery records available.',
                builder: (deliveries) {
                  final pending = deliveries
                      .where((d) => d.status.toLowerCase() == 'pending')
                      .toList();
                  final verified = deliveries
                      .where((d) => d.status.toLowerCase() == 'verified')
                      .toList();
                  final exceptions = deliveries
                      .where((d) => d.status.toLowerCase() == 'exception')
                      .toList();
                  return Row(
                    children: [
                      _KanbanColumn(
                        title: 'PENDING',
                        items: pending,
                        color: colors.accentAmber,
                      ),
                      _KanbanColumn(
                        title: 'VERIFIED',
                        items: verified,
                        color: colors.accentTeal,
                      ),
                      _KanbanColumn(
                        title: 'EXCEPTION',
                        items: exceptions,
                        color: colors.accentRose,
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        // Pending count
        GlassCard(
          child: StreamBuilder<List<DeliveryRecord>>(
            stream: repository.watchDeliveryRecords(),
            builder: (context, snapshot) {
              final deliveries = snapshot.data ?? const <DeliveryRecord>[];
              final pending = deliveries
                  .where((d) => d.status.toLowerCase() == 'pending')
                  .length;
              return _MetricWidget(
                label: 'Pending',
                value: '$pending',
                color: colors.accentAmber,
              );
            },
          ),
        ),
        // Verified today
        GlassCard(
          child: StreamBuilder<List<DeliveryRecord>>(
            stream: repository.watchDeliveryRecords(),
            builder: (context, snapshot) {
              final deliveries = snapshot.data ?? const <DeliveryRecord>[];
              final now = DateTime.now();
              final verifiedToday = deliveries.where((d) {
                final v = d.verifiedAt;
                return v != null &&
                    v.year == now.year &&
                    v.month == now.month &&
                    v.day == now.day;
              }).length;
              return _MetricWidget(
                label: 'Verified Today',
                value: '$verifiedToday',
                color: colors.accentTeal,
              );
            },
          ),
        ),
        // Exceptions
        GlassCard(
          child: StreamBuilder<List<DeliveryRecord>>(
            stream: repository.watchDeliveryRecords(),
            builder: (context, snapshot) {
              final deliveries = snapshot.data ?? const <DeliveryRecord>[];
              final exceptions = deliveries
                  .where((d) => d.status.toLowerCase() == 'exception')
                  .length;
              return _MetricWidget(
                label: 'Exceptions',
                value: '$exceptions',
                color: colors.accentRose,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final String title;
  final List<DeliveryRecord> items;
  final Color color;
  const _KanbanColumn({
    required this.title,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: color.withOpacity(0.2),
            child: Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.all(4),
                  child: ListTile(
                    title: Text(item.containerId),
                    subtitle: Text(
                      'ETA: ${formatShortTime(item.expectedGateOutAt)}',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 4. CAMERA TAB – LIVE THUMBNAILS + METRICS

class _CameraTab extends StatelessWidget {
  final OperationsRepository repository;
  final void Function(BuildContext context, String url) onPlayVideo;
  const _CameraTab({required this.repository, required this.onPlayVideo});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PortColors>()!;

    return _DashboardTab(
      title: 'Camera Feeds',
      children: [
        // Thumbnail grid
        GlassCard(
          height: 300,
          child: StreamBuilder<List<CameraFeed>>(
            stream: repository.watchCameraFeeds(),
            builder: (context, snapshot) {
              return _RealtimeState<CameraFeed>(
                snapshot: snapshot,
                emptyMessage: 'No camera feeds available.',
                builder: (feeds) => GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: feeds.length,
                  itemBuilder: (context, index) {
                    final feed = feeds[index];
                    return _CameraThumbnail(
                      feed: feed,
                      onPlayVideo: onPlayVideo,
                    );
                  },
                ),
              );
            },
          ),
        ),
        // Cameras online
        GlassCard(
          child: StreamBuilder<List<CameraFeed>>(
            stream: repository.watchCameraFeeds(),
            builder: (context, snapshot) {
              final feeds = snapshot.data ?? const <CameraFeed>[];
              final online = feeds.where((f) => f.online).length;
              return _MetricWidget(
                label: 'Online',
                value: '$online/${feeds.length}',
                color: colors.accentTeal,
              );
            },
          ),
        ),
        // AI Detections (if available)
        GlassCard(
          child: StreamBuilder<List<CameraFeed>>(
            stream: repository.watchCameraFeeds(),
            builder: (context, snapshot) {
              final feeds = snapshot.data ?? const <CameraFeed>[];
              final detections = feeds.fold(
                0,
                (sum, f) => sum + f.aiDetectionCount,
              );
              return _MetricWidget(
                label: 'AI Detections',
                value: '$detections',
                color: colors.accentAmber,
              );
            },
          ),
        ),
        // Stale feeds
        GlassCard(
          child: StreamBuilder<List<CameraFeed>>(
            stream: repository.watchCameraFeeds(),
            builder: (context, snapshot) {
              final feeds = snapshot.data ?? const <CameraFeed>[];
              final now = DateTime.now();
              final stale = feeds.where((f) {
                final last = f.lastSeen;
                return last == null || now.difference(last).inMinutes > 2;
              }).length;
              return _MetricWidget(
                label: 'Stale',
                value: '$stale',
                color: colors.accentRose,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CameraThumbnail extends StatelessWidget {
  final CameraFeed feed;
  final void Function(BuildContext context, String url) onPlayVideo;
  const _CameraThumbnail({required this.feed, required this.onPlayVideo});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PortColors>()!;
    final hasStream =
        feed.streamHttpsUrl != null && feed.streamHttpsUrl!.isNotEmpty;
    final imageProvider = hasStream
        ? NetworkImage(feed.streamHttpsUrl!) as ImageProvider
        : null;

    return GestureDetector(
      onTap: hasStream
          ? () => onPlayVideo(context, feed.streamHttpsUrl!)
          : null,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(8),
          image: imageProvider != null
              ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
              : null,
        ),
        child: Stack(
          children: [
            if (!hasStream)
              const Center(
                child: Icon(Icons.videocam, color: Colors.white24, size: 36),
              ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: feed.online ? colors.accentTeal : colors.accentRose,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  feed.online ? 'LIVE' : 'OFFLINE',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (feed.online && hasStream)
              const Positioned(
                left: 8,
                top: 8,
                child: Icon(
                  Icons.play_circle_filled,
                  color: Colors.white70,
                  size: 30,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// 5. SENSOR TAB – GRID + METRICS

class _SensorTab extends StatelessWidget {
  final OperationsRepository repository;
  const _SensorTab({required this.repository});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PortColors>()!;

    return _DashboardTab(
      title: 'Sensor Grid',
      children: [
        // Sensor tile grid
        GlassCard(
          height: 300,
          child: StreamBuilder<List<SensorReading>>(
            stream: repository.watchSensorReadings(),
            builder: (context, snapshot) {
              return _RealtimeState<SensorReading>(
                snapshot: snapshot,
                emptyMessage: 'No sensor readings available.',
                builder: (sensors) => GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: sensors.length,
                  itemBuilder: (context, index) {
                    final sensor = sensors[index];
                    return _SensorTile(sensor: sensor);
                  },
                ),
              );
            },
          ),
        ),
        // Sensors online
        GlassCard(
          child: StreamBuilder<List<SensorReading>>(
            stream: repository.watchSensorReadings(),
            builder: (context, snapshot) {
              final sensors = snapshot.data ?? const <SensorReading>[];
              final online = sensors.where((s) => s.online).length;
              return _MetricWidget(
                label: 'Online',
                value: '$online/${sensors.length}',
                color: colors.accentTeal,
              );
            },
          ),
        ),
        // Anomalies
        GlassCard(
          child: StreamBuilder<List<SensorReading>>(
            stream: repository.watchSensorReadings(),
            builder: (context, snapshot) {
              final sensors = snapshot.data ?? const <SensorReading>[];
              final anomalies = sensors.where((s) => s.anomaly).length;
              return _MetricWidget(
                label: 'Anomalies',
                value: '$anomalies',
                color: colors.accentRose,
              );
            },
          ),
        ),
        // Placeholder for third metric (e.g., avg value)
        GlassCard(
          child: StreamBuilder<List<SensorReading>>(
            stream: repository.watchSensorReadings(),
            builder: (context, snapshot) {
              final sensors = snapshot.data ?? const <SensorReading>[];
              // Dummy average of first sensor if exists
              final avg = sensors.isEmpty
                  ? 0.0
                  : sensors.map((s) => s.value).reduce((a, b) => a + b) /
                        sensors.length;
              return _MetricWidget(
                label: 'Avg Value',
                value: avg.toStringAsFixed(1),
                color: colors.accentAmber,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SensorTile extends StatelessWidget {
  final SensorReading sensor;
  const _SensorTile({required this.sensor});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<PortColors>()!;
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: sensor.anomaly ? colors.accentRose.withOpacity(0.2) : null,
        borderRadius: BorderRadius.circular(12),
        border: sensor.anomaly ? Border.all(color: colors.accentRose) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sensor.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('${sensor.value.toStringAsFixed(2)} ${sensor.unit}'),
          const SizedBox(height: 4),
          if (sensor.recentValues.isNotEmpty) ...[
            const SizedBox(height: 6),
            SizedBox(
              height: 32,
              child: _SparklineChart(
                data: sensor.recentValues,
                color: colors.accentTeal,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// HELPER WIDGETS

class _MetricWidget extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MetricWidget({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _EmptyDataHint extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyDataHint({required this.icon, required this.message});

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

// ----------------------------------------------------------------------------
// STATUS COLOR HELPER
// ----------------------------------------------------------------------------
Color _statusColor(BuildContext context, String status) {
  final colors = Theme.of(context).extension<PortColors>()!;
  switch (status.toLowerCase()) {
    case 'online':
    case 'active':
    case 'verified':
      return colors.accentTeal;
    case 'warning':
    case 'degraded':
    case 'pending':
      return colors.accentAmber;
    case 'offline':
    case 'error':
    case 'exception':
      return colors.accentRose;
    default:
      return colors.textSecondary;
  }
}

// EXTENSION METHODS FOR LIST METRICS

extension AgvListExt on List<AgvTelemetry> {
  int get onlineCount => where((unit) => unit.online).length;
  int get activeCount =>
      where((unit) => _isActiveMission(unit.missionStatus)).length;
  int get delayedCount => where((unit) => unit.etaMinutes > 15).length;
  double get avgBattery =>
      isEmpty ? 0 : map((u) => u.batteryLevel).reduce((a, b) => a + b) / length;
}

bool _isActiveMission(String status) {
  const activeStates = {
    'active',
    'loading',
    'unloading',
    'in_transit',
    'in-transit',
  };
  return activeStates.contains(status.trim().toLowerCase());
}
