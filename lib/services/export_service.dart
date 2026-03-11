import 'dart:io';
import 'package:ffmpeg_kit_flutter_new_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min/return_code.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/photo_repository.dart';
import '../data/repositories/project_repository.dart';

enum ExportFormat { mp4, gif, webp }

enum ExportQuality { draft, premium }

class ExportJob {
  final int projectId;
  final ExportFormat format;
  final int fps;
  final ExportQuality quality;

  const ExportJob({
    required this.projectId,
    required this.format,
    this.fps = 24,
    this.quality = ExportQuality.draft,
  });
}

class ExportResult {
  final bool success;
  final String? outputPath;
  final String? error;

  const ExportResult({
    required this.success,
    this.outputPath,
    this.error,
  });
}

class ExportService {
  final PhotoRepository _photoRepo;
  final ProjectRepository _projectRepo;

  ExportService(this._photoRepo, this._projectRepo);

  Future<ExportResult> export(
    ExportJob job, {
    void Function(double progress)? onProgress,
  }) async {
    final photos = await _photoRepo.getForProject(job.projectId);
    if (photos.isEmpty) {
      return const ExportResult(success: false, error: 'No photos to export');
    }

    final exportDir = await _projectRepo.getExportsFolder();
    final tempDir = Directory(
        p.join(exportDir, 'tmp_${job.projectId}_${DateTime.now().millisecondsSinceEpoch}'));

    try {
      // Prepare sequential frames
      await _photoRepo.prepareForExport(job.projectId, tempDir.path);

      final outputFileName = _buildOutputName(job);
      final outputPath = p.join(exportDir, outputFileName);

      final ffmpegCmd = _buildCommand(
        inputPattern: p.join(tempDir.path, '%04d.jpg'),
        outputPath: outputPath,
        job: job,
      );

      onProgress?.call(0.1);

      final session = await FFmpegKit.execute(ffmpegCmd);
      final returnCode = await session.getReturnCode();

      // Clean up temp dir
      if (await tempDir.exists()) await tempDir.delete(recursive: true);

      if (ReturnCode.isSuccess(returnCode)) {
        onProgress?.call(1.0);
        return ExportResult(success: true, outputPath: outputPath);
      } else {
        final logs = await session.getLogsAsString();
        return ExportResult(
            success: false,
            error: 'FFmpeg failed: ${logs.substring(0, logs.length.clamp(0, 200))}');
      }
    } catch (e) {
      if (await tempDir.exists()) await tempDir.delete(recursive: true);
      return ExportResult(success: false, error: e.toString());
    }
  }

  String _buildOutputName(ExportJob job) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final ext = job.format.name;
    return 'timelapse_${job.projectId}_$ts.$ext';
  }

  String _buildCommand({
    required String inputPattern,
    required String outputPath,
    required ExportJob job,
  }) {
    switch (job.format) {
      case ExportFormat.mp4:
        return '-framerate ${job.fps} -i "$inputPattern" '
            '-vf "scale=1280:-2" '
            '-c:v libx264 -pix_fmt yuv420p '
            '-movflags +faststart '
            '"$outputPath" -y';

      case ExportFormat.gif:
        return '-framerate ${job.fps} -i "$inputPattern" '
            '-vf "scale=640:-2:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" '
            '"$outputPath" -y';

      case ExportFormat.webp:
        return '-framerate ${job.fps} -i "$inputPattern" '
            '-vf "scale=1280:-2" '
            '-c:v libwebp_anim -quality 80 '
            '"$outputPath" -y';
    }
  }
}

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(
    ref.read(photoRepositoryProvider),
    ref.read(projectRepositoryProvider),
  );
});
