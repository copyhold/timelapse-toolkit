import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../database/app_database.dart';

const int kFreeProjectLimit = 3;

class ProjectRepository {
  final AppDatabase _db;

  ProjectRepository(this._db);

  Stream<List<Project>> watchAll() => _db.watchAllProjects();

  Future<List<Project>> getAll() => _db.getAllProjects();

  Future<Project?> getById(int id) => _db.getProjectById(id);

  Future<int> count() => _db.countProjects();

  Future<bool> canCreateProject() async {
    // Premium check always false in Phase 1
    final count = await _db.countProjects();
    return count < kFreeProjectLimit;
  }

  Future<Project> create({
    required String name,
    int intervalSeconds = 86400,
    bool gpsEnabled = false,
    bool notificationsEnabled = true,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final projectsDir = p.join(appDir.path, 'projects');

    // Generate a temp folder name — will be renamed after insert
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    final folderPath = p.join(projectsDir, tempId, 'photos');

    final id = await _db.insertProject(
      ProjectsCompanion.insert(
        name: name,
        intervalSeconds: Value(intervalSeconds),
        gpsEnabled: Value(gpsEnabled),
        notificationsEnabled: Value(notificationsEnabled),
        folderPath: folderPath,
        isActive: const Value(true),
      ),
    );

    // Update folder path with real ID
    final realFolderPath = p.join(projectsDir, id.toString(), 'photos');
    await _db.updateProject(
      ProjectsCompanion(
        id: Value(id),
        name: Value(name),
        intervalSeconds: Value(intervalSeconds),
        gpsEnabled: Value(gpsEnabled),
        notificationsEnabled: Value(notificationsEnabled),
        folderPath: Value(realFolderPath),
        isActive: const Value(true),
      ),
    );

    // Create directory on disk
    await Directory(realFolderPath).create(recursive: true);

    return (await _db.getProjectById(id))!;
  }

  Future<void> update(Project project) async {
    await _db.updateProject(
      ProjectsCompanion(
        id: Value(project.id),
        name: Value(project.name),
        intervalSeconds: Value(project.intervalSeconds),
        gpsEnabled: Value(project.gpsEnabled),
        referencePhotoId: Value(project.referencePhotoId),
        folderPath: Value(project.folderPath),
        isActive: Value(project.isActive),
        notificationsEnabled: Value(project.notificationsEnabled),
        lastPhotoAt: Value(project.lastPhotoAt),
      ),
    );
  }

  Future<void> updateLastPhotoAt(int projectId, DateTime time) async {
    final project = await _db.getProjectById(projectId);
    if (project == null) return;
    await update(project.copyWith(lastPhotoAt: Value(time)));
  }

  Future<void> setReferencePhoto(int projectId, int? photoId) async {
    final project = await _db.getProjectById(projectId);
    if (project == null) return;
    await update(project.copyWith(referencePhotoId: Value(photoId)));
  }

  Future<void> delete(int projectId) async {
    final project = await _db.getProjectById(projectId);
    if (project == null) return;

    // Delete photos from DB
    await _db.deletePhotosForProject(projectId);

    // Delete project folder from disk
    final folder = Directory(p.dirname(project.folderPath));
    if (await folder.exists()) {
      await folder.delete(recursive: true);
    }

    await _db.deleteProject(projectId);
  }

  Future<String> getPhotosFolder(int projectId) async {
    final project = await _db.getProjectById(projectId);
    if (project != null) return project.folderPath;

    // Fallback
    final appDir = await getApplicationDocumentsDirectory();
    return p.join(appDir.path, 'projects', projectId.toString(), 'photos');
  }

  Future<String> getExportsFolder() async {
    final appDir = await getApplicationDocumentsDirectory();
    final exportsDir = Directory(p.join(appDir.path, 'exports'));
    await exportsDir.create(recursive: true);
    return exportsDir.path;
  }
}

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(ref.read(databaseProvider));
});

final projectsStreamProvider = StreamProvider<List<Project>>((ref) {
  return ref.read(projectRepositoryProvider).watchAll();
});

final projectProvider = FutureProvider.family<Project?, int>((ref, id) async {
  return ref.read(projectRepositoryProvider).getById(id);
});
