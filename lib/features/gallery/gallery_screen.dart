import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/photo_repository.dart';
import '../../data/repositories/project_repository.dart';
import '../../app/router.dart';

class GalleryScreen extends ConsumerWidget {
  final int projectId;

  const GalleryScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(photosStreamProvider(projectId));
    final projectAsync = ref.watch(projectProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: projectAsync.when(
          data: (p) => Text(p?.name ?? 'Gallery'),
          loading: () => const Text('Gallery'),
          error: (_, __) => const Text('Gallery'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.movie_creation_outlined),
            tooltip: 'Export',
            onPressed: () => context.push(AppRoutes.exportPath(projectId.toString())),
          ),
        ],
      ),
      body: photosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (photos) {
          if (photos.isEmpty) {
            return _EmptyGallery(onCapture: () {
              context.push(AppRoutes.cameraPath(projectId.toString()));
            });
          }

          return Column(
            children: [
              _GalleryHeader(photos: photos),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (ctx, i) => _PhotoTile(
                    photo: photos[i],
                    index: i,
                    onTap: () => _showPhotoDetail(context, ref, photos, i),
                    onLongPress: () =>
                        _showPhotoOptions(context, ref, photos[i]),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPhotoDetail(BuildContext context, WidgetRef ref,
      List<Photo> photos, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PhotoDetailView(
          photos: photos,
          initialIndex: initialIndex,
          projectId: projectId,
        ),
      ),
    );
  }

  void _showPhotoOptions(
      BuildContext context, WidgetRef ref, Photo photo) {
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
              leading: const Icon(Icons.star_outline),
              title: const Text('Set as Reference Photo'),
              onTap: () async {
                Navigator.pop(ctx);
                await ref
                    .read(projectRepositoryProvider)
                    .setReferencePhoto(projectId, photo.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reference photo updated')),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline,
                  color: Theme.of(ctx).colorScheme.error),
              title: Text('Delete',
                  style: TextStyle(
                      color: Theme.of(ctx).colorScheme.error)),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(photoRepositoryProvider).delete(photo.id);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _GalleryHeader extends StatelessWidget {
  final List<Photo> photos;

  const _GalleryHeader({required this.photos});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final count = photos.length;

    // Estimate animation duration at 24fps
    final seconds24 = count / 24.0;
    final durationLabel = seconds24 < 1
        ? '< 1s at 24fps'
        : '${seconds24.toStringAsFixed(1)}s at 24fps';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: cs.surfaceContainerLow,
      child: Row(
        children: [
          Icon(Icons.photo_library_outlined,
              size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            '$count photos',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
          const Spacer(),
          Icon(Icons.movie_outlined, size: 18, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            durationLabel,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final Photo photo;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _PhotoTile({
    required this.photo,
    required this.index,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(photo.filePath),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Icon(Icons.broken_image_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          // Timestamp overlay on bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              color: Colors.black45,
              child: Text(
                DateFormat('MMM d\nHH:mm').format(photo.takenAt),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  height: 1.2,
                ),
                maxLines: 2,
              ),
            ),
          ),
          if (photo.latitude != null)
            const Positioned(
              top: 4,
              right: 4,
              child: Icon(Icons.location_on, color: Colors.white70, size: 14),
            ),
        ],
      ),
    );
  }
}

class _PhotoDetailView extends StatefulWidget {
  final List<Photo> photos;
  final int initialIndex;
  final int projectId;

  const _PhotoDetailView({
    required this.photos,
    required this.initialIndex,
    required this.projectId,
  });

  @override
  State<_PhotoDetailView> createState() => _PhotoDetailViewState();
}

class _PhotoDetailViewState extends State<_PhotoDetailView> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photos[_currentIndex];
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${_currentIndex + 1} / ${widget.photos.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.photos.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (_, i) => InteractiveViewer(
                child: Image.file(
                  File(widget.photos[i].filePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          // Metadata
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('EEEE, MMM d, y — HH:mm:ss')
                          .format(photo.takenAt),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                if (photo.latitude != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${photo.latitude!.toStringAsFixed(6)}, '
                        '${photo.longitude!.toStringAsFixed(6)}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  final VoidCallback onCapture;

  const _EmptyGallery({required this.onCapture});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_library_outlined, size: 80,
                color: cs.primary.withValues(alpha: 0.6)),
            const SizedBox(height: 24),
            Text(
              'No photos yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Take your first photo to start building your timelapse.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCapture,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take First Photo'),
            ),
          ],
        ),
      ),
    );
  }
}
