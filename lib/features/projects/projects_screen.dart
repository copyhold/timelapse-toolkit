import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/project_repository.dart';
import '../../app/router.dart';
import 'project_card.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timelapse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.workspace_premium_outlined),
            tooltip: 'Premium',
            onPressed: () => context.push(AppRoutes.premium),
          ),
        ],
      ),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (projects) => _ProjectsList(projects: projects),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateProjectDialog(context, ref),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('New Project'),
      ),
    );
  }

  Future<void> _showCreateProjectDialog(
      BuildContext context, WidgetRef ref) async {
    final canCreate =
        await ref.read(projectRepositoryProvider).canCreateProject();

    if (!context.mounted) return;

    if (!canCreate) {
      context.push(AppRoutes.premium);
      return;
    }

    final nameController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Project'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Project name',
            hintText: 'e.g. Backyard Garden',
          ),
          onSubmitted: (_) => Navigator.pop(ctx, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (confirmed == true && nameController.text.trim().isNotEmpty) {
      if (!context.mounted) return;
      try {
        final project = await ref.read(projectRepositoryProvider).create(
              name: nameController.text.trim(),
            );
        if (context.mounted) {
          context.push(AppRoutes.projectSettingsPath(project.id.toString()));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create project: $e')),
          );
        }
      }
    }
  }
}

class _ProjectsList extends ConsumerWidget {
  final List<Project> projects;

  const _ProjectsList({required this.projects});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (projects.isEmpty) {
      return _EmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: projects.length,
      itemBuilder: (ctx, i) => ProjectCard(
        project: projects[i],
        onTap: () =>
            context.push(AppRoutes.cameraPath(projects[i].id.toString())),
        onSettings: () => context
            .push(AppRoutes.projectSettingsPath(projects[i].id.toString())),
        onGallery: () =>
            context.push(AppRoutes.galleryPath(projects[i].id.toString())),
        onExport: () =>
            context.push(AppRoutes.exportPath(projects[i].id.toString())),
        onDelete: () => _confirmDelete(context, ref, projects[i]),
        onRename: () => _showRenameDialog(context, ref, projects[i]),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Project project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Project?'),
        content: Text(
            'This will permanently delete "${project.name}" and all its photos. This cannot be undone.'),
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

    if (confirmed == true && context.mounted) {
      await ref.read(projectRepositoryProvider).delete(project.id);
    }
  }

  Future<void> _showRenameDialog(
      BuildContext context, WidgetRef ref, Project project) async {
    final controller = TextEditingController(text: project.name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Project'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Project name'),
          onSubmitted: (_) => Navigator.pop(ctx, true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (confirmed == true &&
        controller.text.trim().isNotEmpty &&
        context.mounted) {
      await ref.read(projectRepositoryProvider).update(
            project.copyWith(name: controller.text.trim()),
          );
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_camera_outlined,
              size: 80,
              color: cs.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 24),
            Text(
              'No projects yet',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first timelapse project\nto start capturing moments over time.',
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
