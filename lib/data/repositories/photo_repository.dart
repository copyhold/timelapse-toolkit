import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../database/app_database.dart';

class PhotoRepository {
  final AppDatabase _db;

  PhotoRepository(this._db);

  Stream<List<Photo>> watchForProject(int projectId) =>
      _db.watchPhotosForProject(projectId);

  Future<List<Photo>> getForProject(int projectId) =>
      _db.getPhotosForProject(projectId);

  Future<Photo?> getById(int id) => _db.getPhotoById(id);

  Future<Photo?> getLatestForProject(int projectId) =>
      _db.getLatestPhotoForProject(projectId);

  Future<Photo> save({
    required int projectId,
    required String filePath,
    double? latitude,
    double? longitude,
    double? heading,
  }) async {
    final id = await _db.insertPhoto(
      PhotosCompanion.insert(
        projectId: projectId,
        filePath: filePath,
        takenAt: Value(DateTime.now()),
        latitude: Value(latitude),
        longitude: Value(longitude),
        heading: Value(heading),
      ),
    );
    return (await _db.getPhotoById(id))!;
  }

  Future<void> delete(int photoId) async {
    final photo = await _db.getPhotoById(photoId);
    if (photo != null) {
      // Remove file from disk
      final file = File(photo.filePath);
      if (await file.exists()) await file.delete();
    }
    await _db.deletePhoto(photoId);
  }

  Future<int> countForProject(int projectId) =>
      _db.countPhotosForProject(projectId);

  /// Returns ordered file paths for FFmpeg input
  Future<List<String>> getOrderedFilePaths(int projectId) async {
    final photos = await _db.getPhotosForProject(projectId);
    return photos.map((ph) => ph.filePath).toList();
  }

  /// Rename files to sequential 4-digit names for FFmpeg %04d pattern
  Future<String> prepareForExport(int projectId, String exportTempDir) async {
    final photos = await _db.getPhotosForProject(projectId);
    await Directory(exportTempDir).create(recursive: true);

    for (int i = 0; i < photos.length; i++) {
      final src = File(photos[i].filePath);
      if (!await src.exists()) continue;
      final dest = File(p.join(exportTempDir, '${(i + 1).toString().padLeft(4, '0')}.jpg'));
      await src.copy(dest.path);
    }

    return exportTempDir;
  }
}

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  return PhotoRepository(ref.read(databaseProvider));
});

final photosStreamProvider =
    StreamProvider.family<List<Photo>, int>((ref, projectId) {
  return ref.read(photoRepositoryProvider).watchForProject(projectId);
});

final photosCountProvider = FutureProvider.family<int, int>((ref, projectId) {
  return ref.read(photoRepositoryProvider).countForProject(projectId);
});
