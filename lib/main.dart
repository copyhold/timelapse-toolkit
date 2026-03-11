import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'services/notification_service.dart';
import 'services/scheduler_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void callbackDispatcher() {
  SchedulerService.callbackDispatcher();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.initialize(flutterLocalNotificationsPlugin);
  try {
    await SchedulerService.initialize();
  } catch (_) {
    // WorkManager init failure should not prevent app launch
  }

  runApp(
    const ProviderScope(
      child: TimelapseApp(),
    ),
  );
}

class TimelapseApp extends ConsumerWidget {
  const TimelapseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Timelapse',
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
