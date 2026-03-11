import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/projects/projects_screen.dart';
import '../features/settings/project_settings_screen.dart';
import '../features/camera/camera_screen.dart';
import '../features/gallery/gallery_screen.dart';
import '../features/export/export_screen.dart';
import '../features/premium/premium_screen.dart';
import '../features/splash/splash_screen.dart';

// Route names
class AppRoutes {
  static const splash = '/splash';
  static const projects = '/';
  static const projectSettings = '/projects/:projectId/settings';
  static const camera = '/projects/:projectId/camera';
  static const gallery = '/projects/:projectId/gallery';
  static const export = '/projects/:projectId/export';
  static const premium = '/premium';

  static String projectSettingsPath(String projectId) =>
      '/projects/$projectId/settings';
  static String cameraPath(String projectId) => '/projects/$projectId/camera';
  static String galleryPath(String projectId) => '/projects/$projectId/gallery';
  static String exportPath(String projectId) => '/projects/$projectId/export';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.projects,
        name: 'projects',
        builder: (context, state) => const ProjectsScreen(),
      ),
      GoRoute(
        path: AppRoutes.projectSettings,
        name: 'project-settings',
        builder: (context, state) {
          final projectId = int.parse(state.pathParameters['projectId']!);
          return ProjectSettingsScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: AppRoutes.camera,
        name: 'camera',
        builder: (context, state) {
          final projectId = int.parse(state.pathParameters['projectId']!);
          return CameraScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: AppRoutes.gallery,
        name: 'gallery',
        builder: (context, state) {
          final projectId = int.parse(state.pathParameters['projectId']!);
          return GalleryScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: AppRoutes.export,
        name: 'export',
        builder: (context, state) {
          final projectId = int.parse(state.pathParameters['projectId']!);
          return ExportScreen(projectId: projectId);
        },
      ),
      GoRoute(
        path: AppRoutes.premium,
        name: 'premium',
        builder: (context, state) => const PremiumScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});
