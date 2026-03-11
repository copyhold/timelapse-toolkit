import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import '../data/database/app_database.dart';
import 'notification_service.dart';

const _taskName = 'timelapse_notification_refresh';
const _taskTag = 'timelapse_refresh';

class SchedulerService {
  /// Called by WorkManager in the background (top-level, not a method).
  static void callbackDispatcher() {
    Workmanager().executeTask((taskName, inputData) async {
      if (taskName == _taskName) {
        try {
          final container = ProviderContainer();
          final db = container.read(databaseProvider);
          final projects = await db.getAllProjects();

          // Re-initialize notification plugin for background context
          final plugin = await _getNotificationPlugin();
          if (plugin != null) {
            await NotificationService.initialize(plugin);
          }
          await NotificationService.refreshAll(projects);
          container.dispose();
        } catch (_) {
          // Silently ignore in background
        }
      }
      return Future.value(true);
    });
  }

  static Future<dynamic> _getNotificationPlugin() async {
    // In a real background context, re-initialize the plugin
    // This is handled by the main isolate's static instance
    return null;
  }

  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
    );
  }

  /// Register a periodic 15-minute background refresh task.
  static Future<void> registerPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      _taskTag,
      _taskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }

  /// Reschedule notification for a single project.
  static Future<void> rescheduleForProject(Project project) async {
    if (!project.notificationsEnabled || !project.isActive) {
      await NotificationService.cancelForProject(project.id);
      return;
    }

    final lastPhoto = project.lastPhotoAt;
    final remaining = lastPhoto == null
        ? Duration.zero
        : () {
            final next =
                lastPhoto.add(Duration(seconds: project.intervalSeconds));
            final r = next.difference(DateTime.now());
            return r.isNegative ? Duration.zero : r;
          }();

    await NotificationService.showCountdownNotification(
      projectId: project.id,
      projectName: project.name,
      remaining: remaining,
    );
  }
}
