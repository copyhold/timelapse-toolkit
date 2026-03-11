import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/repositories/photo_repository.dart';
import '../../services/notification_service.dart';
import '../../services/scheduler_service.dart';

class ProjectSettingsScreen extends ConsumerStatefulWidget {
  final int projectId;

  const ProjectSettingsScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectSettingsScreen> createState() =>
      _ProjectSettingsScreenState();
}

class _ProjectSettingsScreenState
    extends ConsumerState<ProjectSettingsScreen> {
  late TextEditingController _nameController;
  int _intervalSeconds = 86400;
  bool _gpsEnabled = false;
  bool _notificationsEnabled = true;
  bool _loading = true;
  Project? _project;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadProject();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProject() async {
    final project =
        await ref.read(projectRepositoryProvider).getById(widget.projectId);
    if (project != null && mounted) {
      setState(() {
        _project = project;
        _nameController.text = project.name;
        _intervalSeconds = project.intervalSeconds;
        _gpsEnabled = project.gpsEnabled;
        _notificationsEnabled = project.notificationsEnabled;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (_project == null) return;
    final updated = _project!.copyWith(
      name: _nameController.text.trim(),
      intervalSeconds: _intervalSeconds,
      gpsEnabled: _gpsEnabled,
      notificationsEnabled: _notificationsEnabled,
    );
    await ref.read(projectRepositoryProvider).update(updated);

    // Reschedule notification
    if (_notificationsEnabled) {
      await SchedulerService.rescheduleForProject(updated);
    } else {
      await NotificationService.cancelForProject(updated.id);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  Future<void> _onGpsToggle(bool value) async {
    if (value) {
      // Request permission before enabling
      final status = await Permission.location.request();
      if (status.isGranted) {
        setState(() => _gpsEnabled = true);
      } else if (status.isPermanentlyDenied && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Location permission is required for GPS tagging.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: openAppSettings,
            ),
          ),
        );
      }
    } else {
      setState(() => _gpsEnabled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Settings'),
        actions: [
          FilledButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Name
          _SectionLabel('General'),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Project Name',
              prefixIcon: Icon(Icons.label_outline),
            ),
          ),
          const SizedBox(height: 24),

          // Interval
          _SectionLabel('Capture Interval'),
          const SizedBox(height: 8),
          _IntervalPicker(
            value: _intervalSeconds,
            onChanged: (v) => setState(() => _intervalSeconds = v),
          ),
          const SizedBox(height: 24),

          // Notifications
          _SectionLabel('Notifications'),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
              title: const Text('Persistent Reminder'),
              subtitle: const Text(
                  'Shows an ongoing notification counting down to the next photo'),
              secondary: const Icon(Icons.notifications_outlined),
            ),
          ),
          const SizedBox(height: 24),

          // GPS
          _SectionLabel('Location'),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              value: _gpsEnabled,
              onChanged: _onGpsToggle,
              title: const Text('GPS Tagging'),
              subtitle: const Text(
                  'Tag each photo with GPS coordinates at capture time'),
              secondary: const Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 24),

          // Reference photo
          _SectionLabel('Ghost Overlay'),
          const SizedBox(height: 8),
          _ReferencePhotoSelector(
            project: _project!,
            onSelected: (photoId) async {
              await ref
                  .read(projectRepositoryProvider)
                  .setReferencePhoto(widget.projectId, photoId);
              await _loadProject();
            },
          ),
          const SizedBox(height: 32),

          // Danger zone
          _DangerZone(
            projectId: widget.projectId,
            onDeletePhotos: () async {
              final confirmed = await _confirmDangerAction(
                context,
                'Delete All Photos?',
                'This will permanently remove all photos from this project.',
              );
              if (confirmed == true && mounted) {
                await ref
                    .read(photoRepositoryProvider)
                    .getForProject(widget.projectId)
                    .then((photos) async {
                  for (final p in photos) {
                    await ref.read(photoRepositoryProvider).delete(p.id);
                  }
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All photos deleted')),
                  );
                }
              }
            },
            onDeleteProject: () async {
              final confirmed = await _confirmDangerAction(
                context,
                'Delete Project?',
                'This will permanently delete this project and all its photos.',
              );
              if (confirmed == true && context.mounted) {
                await ref
                    .read(projectRepositoryProvider)
                    .delete(widget.projectId);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDangerAction(
      BuildContext context, String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}

class _IntervalPicker extends StatefulWidget {
  final int value; // in seconds
  final ValueChanged<int> onChanged;

  const _IntervalPicker({required this.value, required this.onChanged});

  @override
  State<_IntervalPicker> createState() => _IntervalPickerState();
}

class _IntervalPickerState extends State<_IntervalPicker> {
  late _IntervalUnit _unit;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _unit = _unitFromSeconds(widget.value);
    _controller = TextEditingController(
        text: _valueInUnit(widget.value, _unit).toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _IntervalUnit _unitFromSeconds(int s) {
    if (s % 86400 == 0) return _IntervalUnit.days;
    if (s % 3600 == 0) return _IntervalUnit.hours;
    if (s % 60 == 0) return _IntervalUnit.minutes;
    return _IntervalUnit.seconds;
  }

  int _valueInUnit(int s, _IntervalUnit u) {
    switch (u) {
      case _IntervalUnit.days:
        return s ~/ 86400;
      case _IntervalUnit.hours:
        return s ~/ 3600;
      case _IntervalUnit.minutes:
        return s ~/ 60;
      case _IntervalUnit.seconds:
        return s;
    }
  }

  int _toSeconds(int v, _IntervalUnit u) {
    switch (u) {
      case _IntervalUnit.days:
        return v * 86400;
      case _IntervalUnit.hours:
        return v * 3600;
      case _IntervalUnit.minutes:
        return v * 60;
      case _IntervalUnit.seconds:
        return v;
    }
  }

  void _notify() {
    final v = int.tryParse(_controller.text) ?? 1;
    widget.onChanged(_toSeconds(v, _unit));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How often should you take a photo?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Interval',
                    ),
                    onChanged: (_) => _notify(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<_IntervalUnit>(
                    initialValue: _unit,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                    ),
                    items: _IntervalUnit.values
                        .map((u) => DropdownMenuItem(
                              value: u,
                              child: Text(u.label),
                            ))
                        .toList(),
                    onChanged: (u) {
                      if (u != null) {
                        setState(() {
                          _unit = u;
                          _controller.text =
                              _valueInUnit(widget.value, _unit).toString();
                        });
                        _notify();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Quick presets
            Wrap(
              spacing: 8,
              children: [
                _PresetChip(
                    label: '30m',
                    onTap: () {
                      setState(() {
                        _unit = _IntervalUnit.minutes;
                        _controller.text = '30';
                      });
                      widget.onChanged(1800);
                    }),
                _PresetChip(
                    label: '1h',
                    onTap: () {
                      setState(() {
                        _unit = _IntervalUnit.hours;
                        _controller.text = '1';
                      });
                      widget.onChanged(3600);
                    }),
                _PresetChip(
                    label: '4h',
                    onTap: () {
                      setState(() {
                        _unit = _IntervalUnit.hours;
                        _controller.text = '4';
                      });
                      widget.onChanged(14400);
                    }),
                _PresetChip(
                    label: '1d',
                    onTap: () {
                      setState(() {
                        _unit = _IntervalUnit.days;
                        _controller.text = '1';
                      });
                      widget.onChanged(86400);
                    }),
                _PresetChip(
                    label: '1 week',
                    onTap: () {
                      setState(() {
                        _unit = _IntervalUnit.days;
                        _controller.text = '7';
                      });
                      widget.onChanged(604800);
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _IntervalUnit {
  seconds('seconds'),
  minutes('minutes'),
  hours('hours'),
  days('days');

  final String label;
  const _IntervalUnit(this.label);
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ReferencePhotoSelector extends ConsumerWidget {
  final Project project;
  final ValueChanged<int?> onSelected;

  const _ReferencePhotoSelector(
      {required this.project, required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(photosStreamProvider(project.id));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reference Photo for Ghost Overlay',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'This photo will be shown semi-transparent when taking new shots',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            photosAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text('Failed to load photos'),
              data: (photos) {
                if (photos.isEmpty) {
                  return Text(
                    'No photos yet — take your first photo first',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  );
                }

                return DropdownButtonFormField<int?>(
                  initialValue: project.referencePhotoId,
                  decoration: const InputDecoration(
                    labelText: 'Reference photo',
                  ),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Latest photo (automatic)'),
                    ),
                    ...photos.map((p) => DropdownMenuItem<int?>(
                          value: p.id,
                          child: Text(
                              'Photo ${photos.indexOf(p) + 1} — ${_formatDate(p.takenAt)}'),
                        )),
                  ],
                  onChanged: onSelected,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _DangerZone extends StatelessWidget {
  final int projectId;
  final VoidCallback onDeletePhotos;
  final VoidCallback onDeleteProject;

  const _DangerZone({
    required this.projectId,
    required this.onDeletePhotos,
    required this.onDeleteProject,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danger Zone',
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: cs.error),
        ),
        const SizedBox(height: 8),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: cs.errorContainer),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.delete_sweep_outlined, color: cs.error),
                title: const Text('Delete All Photos'),
                subtitle: const Text('Removes all photos from this project'),
                trailing: TextButton(
                  onPressed: onDeletePhotos,
                  style: TextButton.styleFrom(foregroundColor: cs.error),
                  child: const Text('Delete'),
                ),
              ),
              Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: Icon(Icons.delete_forever_outlined, color: cs.error),
                title: const Text('Delete Project'),
                subtitle: const Text('Permanently removes project and all photos'),
                trailing: TextButton(
                  onPressed: onDeleteProject,
                  style: TextButton.styleFrom(foregroundColor: cs.error),
                  child: const Text('Delete'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
