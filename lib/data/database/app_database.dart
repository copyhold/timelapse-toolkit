import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';

// ── Tables ──────────────────────────────────────────────────────────────────

class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get intervalSeconds => integer().withDefault(const Constant(86400))(); // 24h default
  BoolColumn get gpsEnabled => boolean().withDefault(const Constant(false))();
  IntColumn get referencePhotoId => integer().nullable()(); // no FK to avoid circular ref
  TextColumn get folderPath => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get notificationsEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastPhotoAt => dateTime().nullable()();
}

class Photos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId => integer().references(Projects, #id)();
  TextColumn get filePath => text()();
  DateTimeColumn get takenAt => dateTime().withDefault(currentDateAndTime)();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  RealColumn get heading => real().nullable()();
}

// ── Database ─────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [Projects, Photos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(photos, photos.heading);
          }
        },
      );

  // ── Project queries ───────────────────────────────────────────────────────

  Stream<List<Project>> watchAllProjects() =>
      (select(projects)..orderBy([(p) => OrderingTerm.desc(p.createdAt)]))
          .watch();

  Future<List<Project>> getAllProjects() =>
      (select(projects)..orderBy([(p) => OrderingTerm.desc(p.createdAt)]))
          .get();

  Future<Project?> getProjectById(int id) =>
      (select(projects)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<int> insertProject(ProjectsCompanion project) =>
      into(projects).insert(project);

  Future<bool> updateProject(ProjectsCompanion project) =>
      update(projects).replace(project);

  Future<int> deleteProject(int id) =>
      (delete(projects)..where((p) => p.id.equals(id))).go();

  Future<int> countProjects() async {
    final count = await (select(projects)
          ..where((p) => p.isActive.equals(true)))
        .get();
    return count.length;
  }

  // ── Photo queries ─────────────────────────────────────────────────────────

  Stream<List<Photo>> watchPhotosForProject(int projectId) =>
      (select(photos)
            ..where((p) => p.projectId.equals(projectId))
            ..orderBy([(p) => OrderingTerm.asc(p.takenAt)]))
          .watch();

  Future<List<Photo>> getPhotosForProject(int projectId) =>
      (select(photos)
            ..where((p) => p.projectId.equals(projectId))
            ..orderBy([(p) => OrderingTerm.asc(p.takenAt)]))
          .get();

  Future<Photo?> getPhotoById(int id) =>
      (select(photos)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<Photo?> getLatestPhotoForProject(int projectId) async {
    final result = await (select(photos)
          ..where((p) => p.projectId.equals(projectId))
          ..orderBy([(p) => OrderingTerm.desc(p.takenAt)])
          ..limit(1))
        .getSingleOrNull();
    return result;
  }

  Future<int> insertPhoto(PhotosCompanion photo) =>
      into(photos).insert(photo);

  Future<int> deletePhoto(int id) =>
      (delete(photos)..where((p) => p.id.equals(id))).go();

  Future<int> deletePhotosForProject(int projectId) =>
      (delete(photos)..where((p) => p.projectId.equals(projectId))).go();

  Future<int> countPhotosForProject(int projectId) async {
    final result = await (select(photos)
          ..where((p) => p.projectId.equals(projectId)))
        .get();
    return result.length;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'timelapse.db'));
    return NativeDatabase.createInBackground(file);
  });
}

// ── Riverpod provider ────────────────────────────────────────────────────────

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
