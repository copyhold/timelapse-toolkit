import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GpsProximityIndicator extends StatelessWidget {
  final double refLat;
  final double refLon;
  final double currentLat;
  final double currentLon;
  final double? currentHeading;

  const GpsProximityIndicator({
    super.key,
    required this.refLat,
    required this.refLon,
    required this.currentLat,
    required this.currentLon,
    this.currentHeading,
  });

  @override
  Widget build(BuildContext context) {
    final distance = Geolocator.distanceBetween(
        currentLat, currentLon, refLat, refLon);
    final bearing = Geolocator.bearingBetween(
        currentLat, currentLon, refLat, refLon);

    final double arrowAngle = currentHeading != null
        ? ((bearing - currentHeading!) % 360 + 360) % 360
        : bearing;
    final double arrowRad = arrowAngle * math.pi / 180.0;

    final String distLabel = distance < 1000
        ? '${distance.round()} m'
        : '${(distance / 1000).toStringAsFixed(1)} km';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.rotate(
            angle: arrowRad,
            child: const Icon(Icons.navigation, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            distLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
