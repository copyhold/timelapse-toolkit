import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/repositories/photo_repository.dart';
import '../../services/export_service.dart';

class ExportScreen extends ConsumerStatefulWidget {
  final int projectId;

  const ExportScreen({super.key, required this.projectId});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  ExportFormat _format = ExportFormat.mp4;
  int _fps = 24;
  bool _exporting = false;
  double _progress = 0;
  String? _outputPath;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final photosAsync = ref.watch(photosStreamProvider(widget.projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Timelapse'),
      ),
      body: photosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (photos) {
          if (photos.isEmpty) {
            return _EmptyExport();
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Photo count info
              _InfoCard(
                icon: Icons.photo_library_outlined,
                title: '${photos.length} photos',
                subtitle: _estimateDuration(photos.length, _fps),
              ),
              const SizedBox(height: 16),

              // Draft mode section
              _SectionLabel('Draft Export (On-Device)'),
              const SizedBox(height: 8),

              // Format picker
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Format',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: ExportFormat.values.map((f) {
                          final selected = f == _format;
                          return ChoiceChip(
                            label: Text(f.name.toUpperCase()),
                            selected: selected,
                            onSelected: (_) =>
                                setState(() => _format = f),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // FPS picker
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frame Rate',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [12, 24, 30].map((fps) {
                          final selected = fps == _fps;
                          return ChoiceChip(
                            label: Text('$fps fps'),
                            selected: selected,
                            onSelected: (_) {
                              setState(() {
                                _fps = fps;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _estimateDuration(photos.length, _fps),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Export button / progress
              if (_exporting) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Exporting...'),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(value: _progress),
                        const SizedBox(height: 8),
                        Text(
                          '${(_progress * 100).toInt()}%',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (_outputPath != null) ...[
                _SuccessCard(
                  outputPath: _outputPath!,
                  onShare: _shareOutput,
                  onExportAgain: _resetExport,
                ),
              ] else if (_errorMessage != null) ...[
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export failed',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onErrorContainer,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _resetExport,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                FilledButton.icon(
                  onPressed: () => _startExport(photos.length),
                  icon: const Icon(Icons.movie_creation),
                  label: const Text('Create Timelapse'),
                ),
              ],

              const SizedBox(height: 24),

              // Premium placeholder
              _PremiumSection(),
            ],
          );
        },
      ),
    );
  }

  String _estimateDuration(int photoCount, int fps) {
    final seconds = photoCount / fps;
    if (seconds < 1) return '< 1 second animation';
    return '${seconds.toStringAsFixed(1)} second animation';
  }

  Future<void> _startExport(int photoCount) async {
    setState(() {
      _exporting = true;
      _progress = 0;
      _outputPath = null;
      _errorMessage = null;
    });

    final job = ExportJob(
      projectId: widget.projectId,
      format: _format,
      fps: _fps,
      quality: ExportQuality.draft,
    );

    final result = await ref.read(exportServiceProvider).export(
      job,
      onProgress: (p) {
        if (mounted) setState(() => _progress = p);
      },
    );

    if (mounted) {
      setState(() {
        _exporting = false;
        if (result.success) {
          _outputPath = result.outputPath;
        } else {
          _errorMessage = result.error;
        }
      });
    }
  }

  void _shareOutput() {
    if (_outputPath != null) {
      Share.shareXFiles([XFile(_outputPath!)]);
    }
  }

  void _resetExport() {
    setState(() {
      _outputPath = null;
      _errorMessage = null;
      _progress = 0;
    });
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoCard(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: cs.onPrimaryContainer),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessCard extends StatelessWidget {
  final String outputPath;
  final VoidCallback onShare;
  final VoidCallback onExportAgain;

  const _SuccessCard({
    required this.outputPath,
    required this.onShare,
    required this.onExportAgain,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: cs.onSecondaryContainer),
                const SizedBox(width: 8),
                Text(
                  'Export complete!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cs.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              outputPath.split('/').last,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSecondaryContainer.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                FilledButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: onExportAgain,
                  child: const Text('Export Again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Premium Export',
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PremiumFeatureRow(
                  icon: Icons.hd,
                  label: '4K Export',
                  locked: true,
                ),
                const Divider(height: 16),
                _PremiumFeatureRow(
                  icon: Icons.palette_outlined,
                  label: 'Color Grading Presets',
                  locked: true,
                ),
                const Divider(height: 16),
                _PremiumFeatureRow(
                  icon: Icons.cloud_outlined,
                  label: 'Cloud HQ Render',
                  locked: true,
                  badge: 'Coming Soon',
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.workspace_premium_outlined),
                  label: const Text('Unlock Premium'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PremiumFeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool locked;
  final String? badge;

  const _PremiumFeatureRow({
    required this.icon,
    required this.label,
    required this.locked,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: cs.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: cs.onSurfaceVariant)),
        const Spacer(),
        if (badge != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: cs.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge!,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: cs.onTertiaryContainer),
            ),
          )
        else if (locked)
          Icon(Icons.lock_outline, size: 16, color: cs.onSurfaceVariant),
      ],
    );
  }
}

class _EmptyExport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.movie_creation_outlined, size: 80,
                color: cs.primary.withValues(alpha: 0.6)),
            const SizedBox(height: 24),
            Text(
              'No photos to export',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Take at least a few photos before creating your timelapse.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
