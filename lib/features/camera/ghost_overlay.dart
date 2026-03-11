import 'dart:io';
import 'package:flutter/material.dart';

class GhostOverlay extends StatelessWidget {
  final String? imagePath;
  final double opacity;

  const GhostOverlay({
    super.key,
    required this.imagePath,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || opacity == 0) return const SizedBox.shrink();

    final file = File(imagePath!);

    return Opacity(
      opacity: opacity,
      child: Image.file(
        file,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}
