import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../data/database/app_database.dart';

class NotificationService {
  static FlutterLocalNotificationsPlugin? _plugin;

  static const String _channelId = 'timelapse_reminder';
  static const String _channelName = 'Timelapse Reminders';
  static const String _channelDescription =
      'Persistent countdown to next photo capture';

  static Future<void> initialize(
      FlutterLocalNotificationsPlugin plugin) async {
    _plugin = plugin;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create the notification channel
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
      showBadge: false,
    );

    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Deep link is handled via the notification payload in the router
    // The payload is the project ID
  }

  /// Show/update persistent countdown notification for a project.
  static Future<void> showCountdownNotification({
    required int projectId,
    required String projectName,
    required Duration remaining,
  }) async {
    if (_plugin == null) return;

    final body = remaining.inSeconds <= 0
        ? 'Time to take your photo!'
        : 'Next photo in: ${_formatDuration(remaining)}';

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      playSound: false,
      enableVibration: false,
      icon: '@mipmap/ic_launcher',
      category: AndroidNotificationCategory.status,
      // Deep-link payload = projectId
    );

    final details = NotificationDetails(android: androidDetails);

    await _plugin!.show(
      projectId, // Use projectId as notification ID so one per project
      projectName,
      body,
      details,
      payload: projectId.toString(),
    );
  }

  /// Cancel notification for a specific project.
  static Future<void> cancelForProject(int projectId) async {
    await _plugin?.cancel(projectId);
  }

  /// Update all active project notifications.
  static Future<void> refreshAll(List<Project> projects) async {
    for (final project in projects) {
      if (!project.isActive || !project.notificationsEnabled) {
        await cancelForProject(project.id);
        continue;
      }

      final remaining = _computeRemaining(project);
      await showCountdownNotification(
        projectId: project.id,
        projectName: project.name,
        remaining: remaining,
      );
    }
  }

  static Duration _computeRemaining(Project project) {
    final lastPhoto = project.lastPhotoAt;
    if (lastPhoto == null) return Duration.zero;
    final next =
        lastPhoto.add(Duration(seconds: project.intervalSeconds));
    final remaining = next.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  static String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }
}
