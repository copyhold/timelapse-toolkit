import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart' as p;

import '../../data/database/app_database.dart';
import '../../data/repositories/project_repository.dart';
import '../../data/repositories/photo_repository.dart';
import '../../services/notification_service.dart';
import 'ghost_overlay.dart';

class CameraScreen extends ConsumerStatefulWidget {
  final int projectId;

  const CameraScreen({super.key, required this.projectId});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCapturing = false;
  double _overlayOpacity = 0.4;
  String? _ghostImagePath;
  List<Photo> _projectPhotos = [];
  int _ghostIndex = -1; // -1 = latest
  Project? _project;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    _project = await ref.read(projectRepositoryProvider).getById(widget.projectId);
    _projectPhotos =
        await ref.read(photoRepositoryProvider).getForProject(widget.projectId);
    _updateGhostImage();

    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      await _initCamera(_cameras.first);
    }
  }

  Future<void> _initCamera(CameraDescription camera) async {
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _controller = controller;
    try {
      await controller.initialize();
      if (mounted) setState(() => _initialized = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Camera error: $e')));
      }
    }
  }

  void _updateGhostImage() {
    if (_projectPhotos.isEmpty) {
      _ghostImagePath = null;
      return;
    }

    if (_ghostIndex == -1) {
      // Use reference photo if set, else latest
      if (_project?.referencePhotoId != null) {
        final ref = _projectPhotos
            .where((p) => p.id == _project!.referencePhotoId)
            .firstOrNull;
        _ghostImagePath = ref?.filePath ?? _projectPhotos.last.filePath;
      } else {
        _ghostImagePath = _projectPhotos.last.filePath;
      }
    } else {
      final idx = _ghostIndex.clamp(0, _projectPhotos.length - 1);
      _ghostImagePath = _projectPhotos[idx].filePath;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed && _cameras.isNotEmpty) {
      _initCamera(_cameras.first);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_isCapturing || _controller == null || !_controller!.value.isInitialized) {
      return;
    }

    setState(() => _isCapturing = true);

    try {
      final XFile imageFile = await _controller!.takePicture();

      // Save to project folder
      final folderPath =
          await ref.read(projectRepositoryProvider).getPhotosFolder(widget.projectId);
      await Directory(folderPath).create(recursive: true);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final destPath = p.join(folderPath, '$timestamp.jpg');
      await File(imageFile.path).copy(destPath);

      // Get GPS if enabled
      double? lat, lon;
      if (_project?.gpsEnabled == true) {
        try {
          final pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 5),
          );
          lat = pos.latitude;
          lon = pos.longitude;
        } catch (_) {
          // GPS failed silently
        }
      }

      // Save to DB
      final photo = await ref.read(photoRepositoryProvider).save(
            projectId: widget.projectId,
            filePath: destPath,
            latitude: lat,
            longitude: lon,
          );

      // Update project's last photo time
      await ref
          .read(projectRepositoryProvider)
          .updateLastPhotoAt(widget.projectId, photo.takenAt);

      // Update notification
      if (_project != null) {
        final updatedProject =
            await ref.read(projectRepositoryProvider).getById(widget.projectId);
        if (updatedProject != null) {
          final interval = Duration(seconds: updatedProject.intervalSeconds);
          await NotificationService.showCountdownNotification(
            projectId: widget.projectId,
            projectName: updatedProject.name,
            remaining: interval,
          );
        }
      }

      // Refresh photo list for ghost
      _projectPhotos =
          await ref.read(photoRepositoryProvider).getForProject(widget.projectId);
      if (mounted) {
        setState(() {
          _ghostIndex = -1;
          _updateGhostImage();
          _isCapturing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo saved!'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCapturing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  void _cycleGhostPhoto() {
    if (_projectPhotos.isEmpty) return;
    setState(() {
      if (_ghostIndex == -1) {
        _ghostIndex = _projectPhotos.length - 1;
      } else {
        _ghostIndex = (_ghostIndex - 1 + _projectPhotos.length) %
            _projectPhotos.length;
        if (_ghostIndex == _projectPhotos.length - 1) _ghostIndex = -1;
      }
      _updateGhostImage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          if (_initialized && _controller != null)
            CameraPreview(_controller!)
          else
            const Center(
                child: CircularProgressIndicator(color: Colors.white)),

          // Ghost overlay
          if (_initialized)
            Positioned.fill(
              child: GhostOverlay(
                imagePath: _ghostImagePath,
                opacity: _overlayOpacity,
              ),
            ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: _TopBar(
                projectName: _project?.name ?? '',
                onBack: () => Navigator.of(context).pop(),
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: _BottomControls(
                opacity: _overlayOpacity,
                onOpacityChanged: (v) => setState(() => _overlayOpacity = v),
                onCapture: _isCapturing ? null : _capture,
                isCapturing: _isCapturing,
                hasPhotos: _projectPhotos.isNotEmpty,
                onCycleGhost: _cycleGhostPhoto,
                ghostLabel: _ghostIndex == -1
                    ? 'Latest'
                    : 'Photo ${_ghostIndex + 1}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String projectName;
  final VoidCallback onBack;

  const _TopBar({required this.projectName, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: onBack,
          ),
          Expanded(
            child: Text(
              projectName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  final double opacity;
  final ValueChanged<double> onOpacityChanged;
  final VoidCallback? onCapture;
  final bool isCapturing;
  final bool hasPhotos;
  final VoidCallback onCycleGhost;
  final String ghostLabel;

  const _BottomControls({
    required this.opacity,
    required this.onOpacityChanged,
    required this.onCapture,
    required this.isCapturing,
    required this.hasPhotos,
    required this.onCycleGhost,
    required this.ghostLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Opacity slider
          if (hasPhotos) ...[
            Row(
              children: [
                const Icon(Icons.photo_outlined, color: Colors.white54, size: 18),
                Expanded(
                  child: Slider(
                    value: opacity,
                    onChanged: onOpacityChanged,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                  ),
                ),
                const Icon(Icons.photo, color: Colors.white, size: 18),
              ],
            ),
            const SizedBox(height: 4),
          ],

          // Controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Cycle ghost
              if (hasPhotos)
                _CircleButton(
                  icon: Icons.swap_horiz,
                  label: ghostLabel,
                  onTap: onCycleGhost,
                )
              else
                const SizedBox(width: 60),

              // Shutter
              GestureDetector(
                onTap: onCapture,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: isCapturing
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.15),
                  ),
                  child: isCapturing
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(Icons.camera_alt,
                          color: Colors.white, size: 36),
                ),
              ),

              const SizedBox(width: 60),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CircleButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.5),
              border: Border.all(color: Colors.white54),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
