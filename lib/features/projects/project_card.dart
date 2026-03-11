import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/photo_repository.dart';

class ProjectCard extends ConsumerStatefulWidget {
  final Project project;
  final VoidCallback onTap;
  final VoidCallback onSettings;
  final VoidCallback onGallery;
  final VoidCallback onExport;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.onSettings,
    required this.onGallery,
    required this.onExport,
    required this.onDelete,
    required this.onRename,
  });

  @override
  ConsumerState<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends ConsumerState<ProjectCard> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    final lastPhoto = widget.project.lastPhotoAt;
    if (lastPhoto == null) {
      setState(() => _remaining = Duration.zero);
      return;
    }
    final next = lastPhoto.add(Duration(seconds: widget.project.intervalSeconds));
    final now = DateTime.now();
    final remaining = next.difference(now);
    setState(() => _remaining = remaining.isNegative ? Duration.zero : remaining);
  }

  String _formatDuration(Duration d) {
    if (d == Duration.zero) return 'Time to shoot!';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final photoCount = ref.watch(photosCountProvider(widget.project.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: widget.onTap,
        onLongPress: () => _showContextMenu(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.project.name,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (widget.project.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Active',
                        style: tt.labelSmall?.copyWith(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showContextMenu(context),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Stats row
              Row(
                children: [
                  _StatChip(
                    icon: Icons.photo_library_outlined,
                    label: photoCount.when(
                      data: (c) => '$c photos',
                      loading: () => '... photos',
                      error: (_, __) => '? photos',
                    ),
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.timer_outlined,
                    label: _intervalLabel(widget.project.intervalSeconds),
                  ),
                  if (widget.project.gpsEnabled) ...[
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: Icons.location_on_outlined,
                      label: 'GPS',
                    ),
                  ],
                ],
              ),
              if (widget.project.notificationsEnabled) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      _remaining == Duration.zero
                          ? Icons.camera_alt
                          : Icons.schedule,
                      size: 16,
                      color: _remaining == Duration.zero
                          ? cs.primary
                          : cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _remaining == Duration.zero
                          ? 'Time to take a photo!'
                          : 'Next photo in: ${_formatDuration(_remaining)}',
                      style: tt.bodySmall?.copyWith(
                        color: _remaining == Duration.zero
                            ? cs.primary
                            : cs.onSurfaceVariant,
                        fontWeight: _remaining == Duration.zero
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onGallery,
                      icon: const Icon(Icons.grid_view, size: 18),
                      label: const Text('Gallery'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onExport,
                      icon: const Icon(Icons.movie_creation_outlined, size: 18),
                      label: const Text('Export'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    onPressed: widget.onSettings,
                    icon: const Icon(Icons.settings_outlined, size: 20),
                    tooltip: 'Settings',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _intervalLabel(int seconds) {
    if (seconds < 60) return '${seconds}s';
    if (seconds < 3600) return '${seconds ~/ 60}m';
    if (seconds < 86400) return '${seconds ~/ 3600}h';
    return '${seconds ~/ 86400}d';
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(ctx);
                widget.onRename();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(ctx);
                widget.onSettings();
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline,
                  color: Theme.of(ctx).colorScheme.error),
              title: Text(
                'Delete',
                style:
                    TextStyle(color: Theme.of(ctx).colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(ctx);
                widget.onDelete();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
