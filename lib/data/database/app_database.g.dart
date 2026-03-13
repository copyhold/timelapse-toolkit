// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _intervalSecondsMeta =
      const VerificationMeta('intervalSeconds');
  @override
  late final GeneratedColumn<int> intervalSeconds = GeneratedColumn<int>(
      'interval_seconds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(86400));
  static const VerificationMeta _gpsEnabledMeta =
      const VerificationMeta('gpsEnabled');
  @override
  late final GeneratedColumn<bool> gpsEnabled = GeneratedColumn<bool>(
      'gps_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("gps_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _referencePhotoIdMeta =
      const VerificationMeta('referencePhotoId');
  @override
  late final GeneratedColumn<int> referencePhotoId = GeneratedColumn<int>(
      'reference_photo_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _folderPathMeta =
      const VerificationMeta('folderPath');
  @override
  late final GeneratedColumn<String> folderPath = GeneratedColumn<String>(
      'folder_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
      'notifications_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notifications_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _lastPhotoAtMeta =
      const VerificationMeta('lastPhotoAt');
  @override
  late final GeneratedColumn<DateTime> lastPhotoAt = GeneratedColumn<DateTime>(
      'last_photo_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        createdAt,
        intervalSeconds,
        gpsEnabled,
        referencePhotoId,
        folderPath,
        isActive,
        notificationsEnabled,
        lastPhotoAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(Insertable<Project> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('interval_seconds')) {
      context.handle(
          _intervalSecondsMeta,
          intervalSeconds.isAcceptableOrUnknown(
              data['interval_seconds']!, _intervalSecondsMeta));
    }
    if (data.containsKey('gps_enabled')) {
      context.handle(
          _gpsEnabledMeta,
          gpsEnabled.isAcceptableOrUnknown(
              data['gps_enabled']!, _gpsEnabledMeta));
    }
    if (data.containsKey('reference_photo_id')) {
      context.handle(
          _referencePhotoIdMeta,
          referencePhotoId.isAcceptableOrUnknown(
              data['reference_photo_id']!, _referencePhotoIdMeta));
    }
    if (data.containsKey('folder_path')) {
      context.handle(
          _folderPathMeta,
          folderPath.isAcceptableOrUnknown(
              data['folder_path']!, _folderPathMeta));
    } else if (isInserting) {
      context.missing(_folderPathMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
          _notificationsEnabledMeta,
          notificationsEnabled.isAcceptableOrUnknown(
              data['notifications_enabled']!, _notificationsEnabledMeta));
    }
    if (data.containsKey('last_photo_at')) {
      context.handle(
          _lastPhotoAtMeta,
          lastPhotoAt.isAcceptableOrUnknown(
              data['last_photo_at']!, _lastPhotoAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      intervalSeconds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}interval_seconds'])!,
      gpsEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}gps_enabled'])!,
      referencePhotoId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reference_photo_id']),
      folderPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}folder_path'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      notificationsEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}notifications_enabled'])!,
      lastPhotoAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_photo_at']),
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final int id;
  final String name;
  final DateTime createdAt;
  final int intervalSeconds;
  final bool gpsEnabled;
  final int? referencePhotoId;
  final String folderPath;
  final bool isActive;
  final bool notificationsEnabled;
  final DateTime? lastPhotoAt;
  const Project(
      {required this.id,
      required this.name,
      required this.createdAt,
      required this.intervalSeconds,
      required this.gpsEnabled,
      this.referencePhotoId,
      required this.folderPath,
      required this.isActive,
      required this.notificationsEnabled,
      this.lastPhotoAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['interval_seconds'] = Variable<int>(intervalSeconds);
    map['gps_enabled'] = Variable<bool>(gpsEnabled);
    if (!nullToAbsent || referencePhotoId != null) {
      map['reference_photo_id'] = Variable<int>(referencePhotoId);
    }
    map['folder_path'] = Variable<String>(folderPath);
    map['is_active'] = Variable<bool>(isActive);
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    if (!nullToAbsent || lastPhotoAt != null) {
      map['last_photo_at'] = Variable<DateTime>(lastPhotoAt);
    }
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      intervalSeconds: Value(intervalSeconds),
      gpsEnabled: Value(gpsEnabled),
      referencePhotoId: referencePhotoId == null && nullToAbsent
          ? const Value.absent()
          : Value(referencePhotoId),
      folderPath: Value(folderPath),
      isActive: Value(isActive),
      notificationsEnabled: Value(notificationsEnabled),
      lastPhotoAt: lastPhotoAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPhotoAt),
    );
  }

  factory Project.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      intervalSeconds: serializer.fromJson<int>(json['intervalSeconds']),
      gpsEnabled: serializer.fromJson<bool>(json['gpsEnabled']),
      referencePhotoId: serializer.fromJson<int?>(json['referencePhotoId']),
      folderPath: serializer.fromJson<String>(json['folderPath']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      notificationsEnabled:
          serializer.fromJson<bool>(json['notificationsEnabled']),
      lastPhotoAt: serializer.fromJson<DateTime?>(json['lastPhotoAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'intervalSeconds': serializer.toJson<int>(intervalSeconds),
      'gpsEnabled': serializer.toJson<bool>(gpsEnabled),
      'referencePhotoId': serializer.toJson<int?>(referencePhotoId),
      'folderPath': serializer.toJson<String>(folderPath),
      'isActive': serializer.toJson<bool>(isActive),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'lastPhotoAt': serializer.toJson<DateTime?>(lastPhotoAt),
    };
  }

  Project copyWith(
          {int? id,
          String? name,
          DateTime? createdAt,
          int? intervalSeconds,
          bool? gpsEnabled,
          Value<int?> referencePhotoId = const Value.absent(),
          String? folderPath,
          bool? isActive,
          bool? notificationsEnabled,
          Value<DateTime?> lastPhotoAt = const Value.absent()}) =>
      Project(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        intervalSeconds: intervalSeconds ?? this.intervalSeconds,
        gpsEnabled: gpsEnabled ?? this.gpsEnabled,
        referencePhotoId: referencePhotoId.present
            ? referencePhotoId.value
            : this.referencePhotoId,
        folderPath: folderPath ?? this.folderPath,
        isActive: isActive ?? this.isActive,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        lastPhotoAt: lastPhotoAt.present ? lastPhotoAt.value : this.lastPhotoAt,
      );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      intervalSeconds: data.intervalSeconds.present
          ? data.intervalSeconds.value
          : this.intervalSeconds,
      gpsEnabled:
          data.gpsEnabled.present ? data.gpsEnabled.value : this.gpsEnabled,
      referencePhotoId: data.referencePhotoId.present
          ? data.referencePhotoId.value
          : this.referencePhotoId,
      folderPath:
          data.folderPath.present ? data.folderPath.value : this.folderPath,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      lastPhotoAt:
          data.lastPhotoAt.present ? data.lastPhotoAt.value : this.lastPhotoAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('intervalSeconds: $intervalSeconds, ')
          ..write('gpsEnabled: $gpsEnabled, ')
          ..write('referencePhotoId: $referencePhotoId, ')
          ..write('folderPath: $folderPath, ')
          ..write('isActive: $isActive, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('lastPhotoAt: $lastPhotoAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      createdAt,
      intervalSeconds,
      gpsEnabled,
      referencePhotoId,
      folderPath,
      isActive,
      notificationsEnabled,
      lastPhotoAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.intervalSeconds == this.intervalSeconds &&
          other.gpsEnabled == this.gpsEnabled &&
          other.referencePhotoId == this.referencePhotoId &&
          other.folderPath == this.folderPath &&
          other.isActive == this.isActive &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.lastPhotoAt == this.lastPhotoAt);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> intervalSeconds;
  final Value<bool> gpsEnabled;
  final Value<int?> referencePhotoId;
  final Value<String> folderPath;
  final Value<bool> isActive;
  final Value<bool> notificationsEnabled;
  final Value<DateTime?> lastPhotoAt;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.intervalSeconds = const Value.absent(),
    this.gpsEnabled = const Value.absent(),
    this.referencePhotoId = const Value.absent(),
    this.folderPath = const Value.absent(),
    this.isActive = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.lastPhotoAt = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.createdAt = const Value.absent(),
    this.intervalSeconds = const Value.absent(),
    this.gpsEnabled = const Value.absent(),
    this.referencePhotoId = const Value.absent(),
    required String folderPath,
    this.isActive = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.lastPhotoAt = const Value.absent(),
  })  : name = Value(name),
        folderPath = Value(folderPath);
  static Insertable<Project> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<int>? intervalSeconds,
    Expression<bool>? gpsEnabled,
    Expression<int>? referencePhotoId,
    Expression<String>? folderPath,
    Expression<bool>? isActive,
    Expression<bool>? notificationsEnabled,
    Expression<DateTime>? lastPhotoAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (intervalSeconds != null) 'interval_seconds': intervalSeconds,
      if (gpsEnabled != null) 'gps_enabled': gpsEnabled,
      if (referencePhotoId != null) 'reference_photo_id': referencePhotoId,
      if (folderPath != null) 'folder_path': folderPath,
      if (isActive != null) 'is_active': isActive,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (lastPhotoAt != null) 'last_photo_at': lastPhotoAt,
    });
  }

  ProjectsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<DateTime>? createdAt,
      Value<int>? intervalSeconds,
      Value<bool>? gpsEnabled,
      Value<int?>? referencePhotoId,
      Value<String>? folderPath,
      Value<bool>? isActive,
      Value<bool>? notificationsEnabled,
      Value<DateTime?>? lastPhotoAt}) {
    return ProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      intervalSeconds: intervalSeconds ?? this.intervalSeconds,
      gpsEnabled: gpsEnabled ?? this.gpsEnabled,
      referencePhotoId: referencePhotoId ?? this.referencePhotoId,
      folderPath: folderPath ?? this.folderPath,
      isActive: isActive ?? this.isActive,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      lastPhotoAt: lastPhotoAt ?? this.lastPhotoAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (intervalSeconds.present) {
      map['interval_seconds'] = Variable<int>(intervalSeconds.value);
    }
    if (gpsEnabled.present) {
      map['gps_enabled'] = Variable<bool>(gpsEnabled.value);
    }
    if (referencePhotoId.present) {
      map['reference_photo_id'] = Variable<int>(referencePhotoId.value);
    }
    if (folderPath.present) {
      map['folder_path'] = Variable<String>(folderPath.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (lastPhotoAt.present) {
      map['last_photo_at'] = Variable<DateTime>(lastPhotoAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('intervalSeconds: $intervalSeconds, ')
          ..write('gpsEnabled: $gpsEnabled, ')
          ..write('referencePhotoId: $referencePhotoId, ')
          ..write('folderPath: $folderPath, ')
          ..write('isActive: $isActive, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('lastPhotoAt: $lastPhotoAt')
          ..write(')'))
        .toString();
  }
}

class $PhotosTable extends Photos with TableInfo<$PhotosTable, Photo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _projectIdMeta =
      const VerificationMeta('projectId');
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
      'project_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES projects (id)'));
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _takenAtMeta =
      const VerificationMeta('takenAt');
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
      'taken_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _headingMeta =
      const VerificationMeta('heading');
  @override
  late final GeneratedColumn<double> heading = GeneratedColumn<double>(
      'heading', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, projectId, filePath, takenAt, latitude, longitude, heading];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photos';
  @override
  VerificationContext validateIntegrity(Insertable<Photo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(_projectIdMeta,
          projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta));
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(_takenAtMeta,
          takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('heading')) {
      context.handle(_headingMeta,
          heading.isAcceptableOrUnknown(data['heading']!, _headingMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Photo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Photo(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      projectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}project_id'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      takenAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}taken_at'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      heading: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}heading']),
    );
  }

  @override
  $PhotosTable createAlias(String alias) {
    return $PhotosTable(attachedDatabase, alias);
  }
}

class Photo extends DataClass implements Insertable<Photo> {
  final int id;
  final int projectId;
  final String filePath;
  final DateTime takenAt;
  final double? latitude;
  final double? longitude;
  final double? heading;
  const Photo(
      {required this.id,
      required this.projectId,
      required this.filePath,
      required this.takenAt,
      this.latitude,
      this.longitude,
      this.heading});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['project_id'] = Variable<int>(projectId);
    map['file_path'] = Variable<String>(filePath);
    map['taken_at'] = Variable<DateTime>(takenAt);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || heading != null) {
      map['heading'] = Variable<double>(heading);
    }
    return map;
  }

  PhotosCompanion toCompanion(bool nullToAbsent) {
    return PhotosCompanion(
      id: Value(id),
      projectId: Value(projectId),
      filePath: Value(filePath),
      takenAt: Value(takenAt),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      heading: heading == null && nullToAbsent
          ? const Value.absent()
          : Value(heading),
    );
  }

  factory Photo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Photo(
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<int>(json['projectId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      heading: serializer.fromJson<double?>(json['heading']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'projectId': serializer.toJson<int>(projectId),
      'filePath': serializer.toJson<String>(filePath),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'heading': serializer.toJson<double?>(heading),
    };
  }

  Photo copyWith(
          {int? id,
          int? projectId,
          String? filePath,
          DateTime? takenAt,
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          Value<double?> heading = const Value.absent()}) =>
      Photo(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        filePath: filePath ?? this.filePath,
        takenAt: takenAt ?? this.takenAt,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        heading: heading.present ? heading.value : this.heading,
      );
  Photo copyWithCompanion(PhotosCompanion data) {
    return Photo(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      heading: data.heading.present ? data.heading.value : this.heading,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Photo(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('filePath: $filePath, ')
          ..write('takenAt: $takenAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('heading: $heading')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, projectId, filePath, takenAt, latitude, longitude, heading);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Photo &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.filePath == this.filePath &&
          other.takenAt == this.takenAt &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.heading == this.heading);
}

class PhotosCompanion extends UpdateCompanion<Photo> {
  final Value<int> id;
  final Value<int> projectId;
  final Value<String> filePath;
  final Value<DateTime> takenAt;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<double?> heading;
  const PhotosCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.heading = const Value.absent(),
  });
  PhotosCompanion.insert({
    this.id = const Value.absent(),
    required int projectId,
    required String filePath,
    this.takenAt = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.heading = const Value.absent(),
  })  : projectId = Value(projectId),
        filePath = Value(filePath);
  static Insertable<Photo> custom({
    Expression<int>? id,
    Expression<int>? projectId,
    Expression<String>? filePath,
    Expression<DateTime>? takenAt,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? heading,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (filePath != null) 'file_path': filePath,
      if (takenAt != null) 'taken_at': takenAt,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (heading != null) 'heading': heading,
    });
  }

  PhotosCompanion copyWith(
      {Value<int>? id,
      Value<int>? projectId,
      Value<String>? filePath,
      Value<DateTime>? takenAt,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<double?>? heading}) {
    return PhotosCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      filePath: filePath ?? this.filePath,
      takenAt: takenAt ?? this.takenAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heading: heading ?? this.heading,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (heading.present) {
      map['heading'] = Variable<double>(heading.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotosCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('filePath: $filePath, ')
          ..write('takenAt: $takenAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('heading: $heading')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $PhotosTable photos = $PhotosTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [projects, photos];
}

typedef $$ProjectsTableCreateCompanionBuilder = ProjectsCompanion Function({
  Value<int> id,
  required String name,
  Value<DateTime> createdAt,
  Value<int> intervalSeconds,
  Value<bool> gpsEnabled,
  Value<int?> referencePhotoId,
  required String folderPath,
  Value<bool> isActive,
  Value<bool> notificationsEnabled,
  Value<DateTime?> lastPhotoAt,
});
typedef $$ProjectsTableUpdateCompanionBuilder = ProjectsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<DateTime> createdAt,
  Value<int> intervalSeconds,
  Value<bool> gpsEnabled,
  Value<int?> referencePhotoId,
  Value<String> folderPath,
  Value<bool> isActive,
  Value<bool> notificationsEnabled,
  Value<DateTime?> lastPhotoAt,
});

class $$ProjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProjectsTable,
    Project,
    $$ProjectsTableFilterComposer,
    $$ProjectsTableOrderingComposer,
    $$ProjectsTableCreateCompanionBuilder,
    $$ProjectsTableUpdateCompanionBuilder> {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ProjectsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ProjectsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> intervalSeconds = const Value.absent(),
            Value<bool> gpsEnabled = const Value.absent(),
            Value<int?> referencePhotoId = const Value.absent(),
            Value<String> folderPath = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<bool> notificationsEnabled = const Value.absent(),
            Value<DateTime?> lastPhotoAt = const Value.absent(),
          }) =>
              ProjectsCompanion(
            id: id,
            name: name,
            createdAt: createdAt,
            intervalSeconds: intervalSeconds,
            gpsEnabled: gpsEnabled,
            referencePhotoId: referencePhotoId,
            folderPath: folderPath,
            isActive: isActive,
            notificationsEnabled: notificationsEnabled,
            lastPhotoAt: lastPhotoAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> intervalSeconds = const Value.absent(),
            Value<bool> gpsEnabled = const Value.absent(),
            Value<int?> referencePhotoId = const Value.absent(),
            required String folderPath,
            Value<bool> isActive = const Value.absent(),
            Value<bool> notificationsEnabled = const Value.absent(),
            Value<DateTime?> lastPhotoAt = const Value.absent(),
          }) =>
              ProjectsCompanion.insert(
            id: id,
            name: name,
            createdAt: createdAt,
            intervalSeconds: intervalSeconds,
            gpsEnabled: gpsEnabled,
            referencePhotoId: referencePhotoId,
            folderPath: folderPath,
            isActive: isActive,
            notificationsEnabled: notificationsEnabled,
            lastPhotoAt: lastPhotoAt,
          ),
        ));
}

class $$ProjectsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get intervalSeconds => $state.composableBuilder(
      column: $state.table.intervalSeconds,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get gpsEnabled => $state.composableBuilder(
      column: $state.table.gpsEnabled,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get referencePhotoId => $state.composableBuilder(
      column: $state.table.referencePhotoId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get folderPath => $state.composableBuilder(
      column: $state.table.folderPath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isActive => $state.composableBuilder(
      column: $state.table.isActive,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get notificationsEnabled => $state.composableBuilder(
      column: $state.table.notificationsEnabled,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get lastPhotoAt => $state.composableBuilder(
      column: $state.table.lastPhotoAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter photosRefs(
      ComposableFilter Function($$PhotosTableFilterComposer f) f) {
    final $$PhotosTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.photos,
        getReferencedColumn: (t) => t.projectId,
        builder: (joinBuilder, parentComposers) => $$PhotosTableFilterComposer(
            ComposerState(
                $state.db, $state.db.photos, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$ProjectsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get intervalSeconds => $state.composableBuilder(
      column: $state.table.intervalSeconds,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get gpsEnabled => $state.composableBuilder(
      column: $state.table.gpsEnabled,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get referencePhotoId => $state.composableBuilder(
      column: $state.table.referencePhotoId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get folderPath => $state.composableBuilder(
      column: $state.table.folderPath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isActive => $state.composableBuilder(
      column: $state.table.isActive,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get notificationsEnabled => $state.composableBuilder(
      column: $state.table.notificationsEnabled,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get lastPhotoAt => $state.composableBuilder(
      column: $state.table.lastPhotoAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$PhotosTableCreateCompanionBuilder = PhotosCompanion Function({
  Value<int> id,
  required int projectId,
  required String filePath,
  Value<DateTime> takenAt,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<double?> heading,
});
typedef $$PhotosTableUpdateCompanionBuilder = PhotosCompanion Function({
  Value<int> id,
  Value<int> projectId,
  Value<String> filePath,
  Value<DateTime> takenAt,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<double?> heading,
});

class $$PhotosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PhotosTable,
    Photo,
    $$PhotosTableFilterComposer,
    $$PhotosTableOrderingComposer,
    $$PhotosTableCreateCompanionBuilder,
    $$PhotosTableUpdateCompanionBuilder> {
  $$PhotosTableTableManager(_$AppDatabase db, $PhotosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$PhotosTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$PhotosTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> projectId = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<DateTime> takenAt = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<double?> heading = const Value.absent(),
          }) =>
              PhotosCompanion(
            id: id,
            projectId: projectId,
            filePath: filePath,
            takenAt: takenAt,
            latitude: latitude,
            longitude: longitude,
            heading: heading,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int projectId,
            required String filePath,
            Value<DateTime> takenAt = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<double?> heading = const Value.absent(),
          }) =>
              PhotosCompanion.insert(
            id: id,
            projectId: projectId,
            filePath: filePath,
            takenAt: takenAt,
            latitude: latitude,
            longitude: longitude,
            heading: heading,
          ),
        ));
}

class $$PhotosTableFilterComposer
    extends FilterComposer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get filePath => $state.composableBuilder(
      column: $state.table.filePath,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get takenAt => $state.composableBuilder(
      column: $state.table.takenAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get latitude => $state.composableBuilder(
      column: $state.table.latitude,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get longitude => $state.composableBuilder(
      column: $state.table.longitude,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get heading => $state.composableBuilder(
      column: $state.table.heading,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $state.db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ProjectsTableFilterComposer(ComposerState(
                $state.db, $state.db.projects, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$PhotosTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get filePath => $state.composableBuilder(
      column: $state.table.filePath,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get takenAt => $state.composableBuilder(
      column: $state.table.takenAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get latitude => $state.composableBuilder(
      column: $state.table.latitude,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get longitude => $state.composableBuilder(
      column: $state.table.longitude,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get heading => $state.composableBuilder(
      column: $state.table.heading,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.projectId,
        referencedTable: $state.db.projects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$ProjectsTableOrderingComposer(ComposerState(
                $state.db, $state.db.projects, joinBuilder, parentComposers)));
    return composer;
  }
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$PhotosTableTableManager get photos =>
      $$PhotosTableTableManager(_db, _db.photos);
}
