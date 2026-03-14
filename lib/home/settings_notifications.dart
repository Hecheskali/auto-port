import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // required for ChangeNotifier
import 'package:provider/provider.dart';
import 'package:auto_port/providers/theme_provider.dart';
import 'package:auto_port/home/home_screen.dart' show PortColors;

// ----------------------------------------------------------------------------
// 1. SETTINGS PROVIDER (unchanged – keep functionality)
// ----------------------------------------------------------------------------
class SettingsProvider extends ChangeNotifier {
  bool _enableAllNotifications = true;
  bool _criticalAlertsOnly = false;
  double _refreshInterval = 5.0;
  double _alertVolume = 70.0;
  double _lowBatteryWarning = 20.0;
  double _delayThreshold = 15.0;
  double _utilizationWarning = 80.0;
  double _staleFeedTimeout = 2.0;
  String _defaultEmail = 'user@example.com';
  String _appVersion = '1.0.0';

  // Getters
  bool get enableAllNotifications => _enableAllNotifications;
  bool get criticalAlertsOnly => _criticalAlertsOnly;
  double get refreshInterval => _refreshInterval;
  double get alertVolume => _alertVolume;
  double get lowBatteryWarning => _lowBatteryWarning;
  double get delayThreshold => _delayThreshold;
  double get utilizationWarning => _utilizationWarning;
  double get staleFeedTimeout => _staleFeedTimeout;
  String get appVersion => _appVersion;

  // Setters
  void setEnableAllNotifications(bool value) {
    _enableAllNotifications = value;
    notifyListeners();
  }

  void setCriticalAlertsOnly(bool value) {
    _criticalAlertsOnly = value;
    notifyListeners();
  }

  void setRefreshInterval(double value) {
    _refreshInterval = value;
    notifyListeners();
  }

  void setAlertVolume(double value) {
    _alertVolume = value;
    notifyListeners();
  }

  void setLowBatteryWarning(double value) {
    _lowBatteryWarning = value;
    notifyListeners();
  }

  void setDelayThreshold(double value) {
    _delayThreshold = value;
    notifyListeners();
  }

  void setUtilizationWarning(double value) {
    _utilizationWarning = value;
    notifyListeners();
  }

  void setStaleFeedTimeout(double value) {
    _staleFeedTimeout = value;
    notifyListeners();
  }
}

// ----------------------------------------------------------------------------
// 2. SETTINGS PANEL – with cute, advanced design
// ----------------------------------------------------------------------------
class SettingsPanel extends StatelessWidget {
  final String? userEmail;

  const SettingsPanel({super.key, this.userEmail});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final colors =
        Theme.of(context).extension<PortColors>() ??
        (themeProvider.isDark ? PortColors.dark : PortColors.light);

    return Scaffold(
      backgroundColor: const Color.fromARGB(0, 8, 155, 111),
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.surfaceGlass,
                colors.surfaceGlass.withOpacity(0.7),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Animated Header
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: colors.textPrimary,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w300,
                            color: colors.textPrimary,
                            shadows: [
                              Shadow(
                                color: colors.accentTeal.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      // Appearance
                      _buildSectionTitle('Appearance', colors),
                      _buildAnimatedSwitchTile(
                        icon: Icons.dark_mode_rounded,
                        title: 'Dark Mode',
                        value: themeProvider.isDark,
                        onChanged: (_) => themeProvider.toggleTheme(),
                        colors: colors,
                      ),
                      _buildAnimatedSliderTile(
                        icon: Icons.refresh_rounded,
                        title: 'Refresh interval (seconds)',
                        value: settingsProvider.refreshInterval,
                        min: 1,
                        max: 30,
                        onChanged: settingsProvider.setRefreshInterval,
                        colors: colors,
                      ),
                      const SizedBox(height: 24),

                      // Alerts
                      _buildSectionTitle('Alerts & Notifications', colors),
                      _buildAnimatedSwitchTile(
                        icon: Icons.notifications_active_rounded,
                        title: 'Enable all notifications',
                        value: settingsProvider.enableAllNotifications,
                        onChanged: settingsProvider.setEnableAllNotifications,
                        colors: colors,
                      ),
                      _buildAnimatedSwitchTile(
                        icon: Icons.warning_amber_rounded,
                        title: 'Critical alerts only',
                        value: settingsProvider.criticalAlertsOnly,
                        onChanged: settingsProvider.setCriticalAlertsOnly,
                        colors: colors,
                      ),
                      _buildAnimatedSliderTile(
                        icon: Icons.volume_up_rounded,
                        title: 'Alert volume',
                        value: settingsProvider.alertVolume,
                        min: 0,
                        max: 100,
                        onChanged: settingsProvider.setAlertVolume,
                        colors: colors,
                      ),
                      const SizedBox(height: 24),

                      // AGV thresholds
                      _buildSectionTitle('AGV Thresholds', colors),
                      _buildAnimatedSliderTile(
                        icon: Icons.battery_alert_rounded,
                        title: 'Low battery warning (%)',
                        value: settingsProvider.lowBatteryWarning,
                        min: 5,
                        max: 50,
                        onChanged: settingsProvider.setLowBatteryWarning,
                        colors: colors,
                      ),
                      _buildAnimatedSliderTile(
                        icon: Icons.timer_rounded,
                        title: 'Delay threshold (minutes)',
                        value: settingsProvider.delayThreshold,
                        min: 5,
                        max: 60,
                        onChanged: settingsProvider.setDelayThreshold,
                        colors: colors,
                      ),
                      const SizedBox(height: 24),

                      // Crane thresholds
                      _buildSectionTitle('Crane Thresholds', colors),
                      _buildAnimatedSliderTile(
                        icon: Icons.trending_up_rounded,
                        title: 'Utilization warning (%)',
                        value: settingsProvider.utilizationWarning,
                        min: 50,
                        max: 100,
                        onChanged: settingsProvider.setUtilizationWarning,
                        colors: colors,
                      ),
                      const SizedBox(height: 24),

                      // Camera thresholds
                      _buildSectionTitle('Camera Feeds', colors),
                      _buildAnimatedSliderTile(
                        icon: Icons.videocam_off_rounded,
                        title: 'Stale feed timeout (minutes)',
                        value: settingsProvider.staleFeedTimeout,
                        min: 1,
                        max: 10,
                        onChanged: settingsProvider.setStaleFeedTimeout,
                        colors: colors,
                      ),
                      const SizedBox(height: 24),

                      // Account section
                      _buildSectionTitle('Account', colors),
                      _buildAnimatedListTile(
                        icon: Icons.email_rounded,
                        title: 'Email notifications',
                        subtitle: userEmail ?? 'Not signed in',
                        onTap: () {},
                        colors: colors,
                      ),
                      _buildAnimatedListTile(
                        icon: Icons.lock_rounded,
                        title:
                            'To Change password or manage account settings, please contact  your administrator.',
                        onTap: () {},
                        colors: colors,
                      ),
                      _buildAnimatedListTile(
                        icon: Icons.info_rounded,
                        title: 'App version',
                        subtitle: settingsProvider.appVersion,
                        onTap: () {},
                        colors: colors,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, PortColors colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colors.accentTeal,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAnimatedSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required PortColors colors,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuad,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.surfaceGlass, colors.surfaceGlass.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.accentTeal.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => onChanged(!value),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.accentTeal.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: colors.accentTeal, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(color: colors.textPrimary, fontSize: 15),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Switch(
                      value: value,
                      onChanged: onChanged,
                      activeColor: colors.accentTeal,
                      activeTrackColor: colors.accentTeal.withOpacity(0.3),
                      inactiveThumbColor: colors.textSecondary,
                      inactiveTrackColor: colors.textSecondary.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSliderTile({
    required IconData icon,
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required PortColors colors,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuad,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.surfaceGlass, colors.surfaceGlass.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.accentTeal.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.accentTeal.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: colors.accentTeal, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(color: colors.textPrimary, fontSize: 14),
                  ),
                ),
                Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(
                    color: colors.accentTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: (max - min).toInt(),
                onChanged: onChanged,
                activeColor: colors.accentTeal,
                inactiveColor: colors.textSecondary.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required PortColors colors,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuad,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.surfaceGlass, colors.surfaceGlass.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.accentTeal.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.accentTeal.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: colors.accentTeal, size: 18),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// 3. NOTIFICATION PROVIDER (unchanged)
// ----------------------------------------------------------------------------
class NotificationProvider extends ChangeNotifier {
  final List<NotificationItem> _notifications = [];

  List<NotificationItem> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.read).length;

  void addNotification(NotificationItem notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index >= 0) {
      _notifications[index].read = true;
      notifyListeners();
    }
  }

  void markAllRead() {
    for (var n in _notifications) {
      n.read = true;
    }
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }
}

// ----------------------------------------------------------------------------
// 4. NOTIFICATION PANEL – enhanced design
// ----------------------------------------------------------------------------
class NotificationPanel extends StatelessWidget {
  const NotificationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors =
        Theme.of(context).extension<PortColors>() ??
        (themeProvider.isDark ? PortColors.dark : PortColors.light);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final notifications = notificationProvider.notifications;
    final unreadCount = notificationProvider.unreadCount;

    return Drawer(
      backgroundColor: Colors.transparent,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.surfaceGlass,
                colors.surfaceGlass.withOpacity(0.7),
              ],
            ),
          ),
          child: Column(
            children: [
              // Header with animation
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: colors.accentTeal.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          color: colors.textPrimary,
                          shadows: [
                            Shadow(
                              color: colors.accentTeal.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colors.accentRose,
                                colors.accentRose.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: colors.accentRose.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '$unreadCount new',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: colors.textPrimary,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
              // Action buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: notificationProvider.markAllRead,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.accentTeal,
                          side: BorderSide(color: colors.accentTeal),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Mark all read'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: notificationProvider.clearAll,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.accentRose,
                          side: BorderSide(color: colors.accentRose),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Clear all'),
                      ),
                    ),
                  ],
                ),
              ),
              // Notification list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    return TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 300 + (index * 50)),
                      curve: Curves.easeOutQuad,
                      builder: (context, scale, child) {
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: _NotificationTile(
                        notification: notif,
                        colors: colors,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem notification;
  final PortColors colors;

  const _NotificationTile({required this.notification, required this.colors});

  Color get _severityColor {
    switch (notification.severity) {
      case NotificationSeverity.critical:
        return colors.accentRose;
      case NotificationSeverity.warning:
        return colors.accentAmber;
      case NotificationSeverity.info:
        return colors.accentTeal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            notification.read
                ? colors.surfaceGlass.withOpacity(0.4)
                : colors.surfaceGlass,
            notification.read
                ? colors.surfaceGlass.withOpacity(0.2)
                : colors.surfaceGlass.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: notification.read
              ? Colors.transparent
              : _severityColor.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          if (!notification.read)
            BoxShadow(
              color: _severityColor.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.read<NotificationProvider>().markAsRead(notification.id);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _severityColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    notification.severity == NotificationSeverity.critical
                        ? Icons.error_rounded
                        : notification.severity == NotificationSeverity.warning
                        ? Icons.warning_rounded
                        : Icons.info_rounded,
                    color: _severityColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: notification.read
                              ? FontWeight.normal
                              : FontWeight.bold,
                          color: colors.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.description,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: colors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimeAgo(notification.timestamp),
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.textSecondary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              notification.module,
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!notification.read)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _severityColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';
    return '${diff.inDays} d ago';
  }
}

// ----------------------------------------------------------------------------
// 5. NOTIFICATION MODEL
// ----------------------------------------------------------------------------
enum NotificationSeverity { critical, warning, info }

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final NotificationSeverity severity;
  final String module;
  bool read;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.severity,
    required this.module,
    this.read = false,
  });
}
