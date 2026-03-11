import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Splash / loading screen shown while the app initialises.
/// Design: half-clock / half-calendar logo with circuit-board traces,
/// "TIMELAPSE TOOLKIT" title, four-season photo strip,
/// and a three-dot pulsing loading animation.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _dotsController;

  static const _bgColor = Color(0xFF080C16);
  static const _cyanColor = Color(0xFF1CC9DC);

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) context.go('/');
    });
  }

  @override
  void dispose() {
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Logo ──────────────────────────────────────────────────────
            const Expanded(
              flex: 46,
              child: Center(
                child: _LogoWidget(cyanColor: _cyanColor, bgColor: _bgColor),
              ),
            ),
            // ── Title ─────────────────────────────────────────────────────
            const _TitleSection(cyanColor: _cyanColor),
            const SizedBox(height: 20),
            // ── Seasonal strip ────────────────────────────────────────────
            const Expanded(
              flex: 34,
              child: _SeasonalStrip(),
            ),
            const SizedBox(height: 20),
            // ── Loading indicator + caption ────────────────────────────────
            _BottomSection(
              cyanColor: _cyanColor,
              dotsController: _dotsController,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logo widget
// ─────────────────────────────────────────────────────────────────────────────

class _LogoWidget extends StatelessWidget {
  const _LogoWidget({required this.cyanColor, required this.bgColor});

  final Color cyanColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    const outerSize = 250.0;
    const innerSize = 160.0;
    return SizedBox(
      width: outerSize,
      height: outerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle dark glow behind the logo
          Container(
            width: outerSize,
            height: outerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  cyanColor.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Circuit-board traces
          CustomPaint(
            size: const Size(outerSize, outerSize),
            painter: _CircuitRaysPainter(cyanColor: cyanColor),
          ),
          // Half-clock / half-calendar disc
          SizedBox(
            width: innerSize,
            height: innerSize,
            child: CustomPaint(
              painter: _ClockCalendarPainter(
                cyanColor: cyanColor,
                bgColor: bgColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Circuit rays painter
// ─────────────────────────────────────────────────────────────────────────────

class _CircuitRaysPainter extends CustomPainter {
  const _CircuitRaysPainter({required this.cyanColor});

  final Color cyanColor;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final linePaint = Paint()
      ..color = cyanColor.withValues(alpha: 0.65)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = cyanColor
      ..style = PaintingStyle.fill;

    const rays = 16;
    const innerR = 86.0;
    const midR = 104.0;
    const farR = 118.0;

    for (int i = 0; i < rays; i++) {
      final angle = (i * math.pi * 2) / rays;
      final ca = math.cos(angle);
      final sa = math.sin(angle);

      final sx = cx + ca * innerR;
      final sy = cy + sa * innerR;
      final mx = cx + ca * midR;
      final my = cy + sa * midR;

      // Main radial segment
      canvas.drawLine(Offset(sx, sy), Offset(mx, my), linePaint);

      if (i.isEven) {
        // 90° branch + terminal dot
        final branchAngle = angle + math.pi / 2;
        final bx = mx + math.cos(branchAngle) * 12;
        final by = my + math.sin(branchAngle) * 12;
        canvas.drawLine(Offset(mx, my), Offset(bx, by), linePaint);
        canvas.drawCircle(Offset(bx, by), 2.8, dotPaint);
      } else {
        // Extended segment + terminal dot
        final ex = cx + ca * farR;
        final ey = cy + sa * farR;
        canvas.drawLine(Offset(mx, my), Offset(ex, ey), linePaint);
        canvas.drawCircle(Offset(ex, ey), 2.8, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Split clock / calendar painter
// ─────────────────────────────────────────────────────────────────────────────

class _ClockCalendarPainter extends CustomPainter {
  const _ClockCalendarPainter({
    required this.cyanColor,
    required this.bgColor,
  });

  final Color cyanColor;
  final Color bgColor;

  static const _numerals = [
    'XII',
    'I',
    'II',
    'III',
    'IV',
    'V',
    'VI',
    'VII',
    'VIII',
    'IX',
    'X',
    'XI',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy);

    // Clip everything to the outer circle
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
    );

    // ── LEFT HALF — vintage clock ──────────────────────────────────────

    // Brown gradient ring
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xFFCA8848), Color(0xFF7B4A1A)],
          stops: [0.75, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r)),
    );

    // Cream clock face
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.78,
      Paint()..color = const Color(0xFFF4EAD0),
    );

    // Subtle tick marks
    final tickPaint = Paint()
      ..color = const Color(0xFF2A1A0A).withValues(alpha: 0.5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (int t = 0; t < 60; t++) {
      final ta = t * math.pi * 2 / 60 - math.pi / 2;
      final isHour = t % 5 == 0;
      final tInner = r * 0.78 * (isHour ? 0.85 : 0.90);
      final tOuter = r * 0.78 * 0.96;
      canvas.drawLine(
        Offset(cx + math.cos(ta) * tInner, cy + math.sin(ta) * tInner),
        Offset(cx + math.cos(ta) * tOuter, cy + math.sin(ta) * tOuter),
        tickPaint,
      );
    }

    // Roman numerals
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi * 2 / 12) - math.pi / 2;
      final nr = r * 0.78 * 0.72;
      tp.text = TextSpan(
        text: _numerals[i],
        style: TextStyle(
          color: const Color(0xFF2A1A0A),
          fontSize: r * 0.115,
          fontWeight: FontWeight.w700,
        ),
      );
      tp.layout();
      tp.paint(
        canvas,
        Offset(
          cx + math.cos(angle) * nr - tp.width / 2,
          cy + math.sin(angle) * nr - tp.height / 2,
        ),
      );
    }

    // Clock hands (roughly 10:10)
    _drawHand(canvas, cx, cy, r * 0.44, -0.92, 4.0, const Color(0xFF1A0A00));
    _drawHand(canvas, cx, cy, r * 0.60, 0.62, 2.8, const Color(0xFF1A0A00));
    // Centre pin
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.045,
      Paint()..color = const Color(0xFF1A0A00),
    );

    // ── RIGHT HALF — teal calendar ─────────────────────────────────────

    // Clip to right half for the teal overlay
    canvas.clipRect(Rect.fromLTRB(cx, 0, size.width, size.height));

    // Teal fill
    canvas.drawRect(
      Rect.fromLTRB(cx, 0, size.width, size.height),
      Paint()..color = cyanColor,
    );

    // Calendar card body
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx + r * 0.28, cy),
        width: r * 0.92,
        height: r * 0.88,
      ),
      const Radius.circular(10),
    );
    canvas.drawRRect(cardRect, Paint()..color = const Color(0xFF0FB6CA));

    // Top header bar
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        cardRect.left,
        cardRect.top,
        cardRect.right,
        cardRect.top + r * 0.20,
        topLeft: const Radius.circular(10),
        topRight: const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFF0A9AAE),
    );

    // Binding clips (two rounded rectangles at top)
    for (int j = 0; j < 2; j++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx + r * (0.05 + j * 0.46), cardRect.top),
            width: 7,
            height: 13,
          ),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xFF087A8E),
      );
    }

    // 3×3 grid of rounded squares
    final cellPaint = Paint()
      ..color = const Color(0xFF08A8BE)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final cellSize = r * 0.175;
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        final gx = cx + r * (-0.02 + col * 0.24);
        final gy = cy + r * (-0.22 + row * 0.26);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(gx, gy),
              width: cellSize,
              height: cellSize,
            ),
            const Radius.circular(3),
          ),
          cellPaint,
        );
      }
    }

    canvas.restore();

    // Vertical white dividing line (drawn after restore so it's always on top)
    canvas.drawLine(
      Offset(cx, cy - r),
      Offset(cx, cy + r),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2.5,
    );
  }

  void _drawHand(
    Canvas canvas,
    double cx,
    double cy,
    double length,
    double angle,
    double width,
    Color color,
  ) {
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + math.cos(angle) * length, cy + math.sin(angle) * length),
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Title section
// ─────────────────────────────────────────────────────────────────────────────

class _TitleSection extends StatelessWidget {
  const _TitleSection({required this.cyanColor});

  final Color cyanColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'TIMELAPSE\nTOOLKIT',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 44,
            fontWeight: FontWeight.w900,
            height: 1.05,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 72,
          height: 2.5,
          decoration: BoxDecoration(
            color: cyanColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Four-season strip
// ─────────────────────────────────────────────────────────────────────────────

class _SeasonalStrip extends StatelessWidget {
  const _SeasonalStrip();

  static const _seasons = [
    _Season('Winter', Color(0xFFCFDDE8), Color(0xFFA8BEC9), Color(0xFF8CAFC2)),
    _Season('Spring', Color(0xFF8AC87E), Color(0xFFB5D98C), Color(0xFF5BA84E)),
    _Season('Summer', Color(0xFF2F8F58), Color(0xFF5AAE7A), Color(0xFF1A6B3C)),
    _Season('Autumn', Color(0xFFD4773A), Color(0xFFE8A060), Color(0xFF9C4A18)),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _seasons.map((s) => Expanded(child: _SeasonPanel(season: s))).toList(),
    );
  }
}

class _Season {
  const _Season(this.name, this.skyColor, this.midColor, this.groundColor);

  final String name;
  final Color skyColor;
  final Color midColor;
  final Color groundColor;
}

class _SeasonPanel extends StatelessWidget {
  const _SeasonPanel({required this.season});

  final _Season season;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [season.skyColor, season.midColor, season.groundColor],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: CustomPaint(painter: _TreePainter(season: season)),
    );
  }
}

class _TreePainter extends CustomPainter {
  const _TreePainter({required this.season});

  final _Season season;

  @override
  void paint(Canvas canvas, Size size) {
    final trunkX = size.width / 2;
    final trunkTop = size.height * 0.56;
    final trunkBottom = size.height * 0.95;
    final trunkW = size.width * 0.14;

    // Trunk
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          trunkX - trunkW / 2,
          trunkTop,
          trunkX + trunkW / 2,
          trunkBottom,
        ),
        Radius.circular(trunkW * 0.3),
      ),
      Paint()..color = const Color(0xFF5C3217),
    );

    // Foliage
    final foliageColor = switch (season.name) {
      'Winter' => const Color(0xFF8AAFC2),
      'Spring' => const Color(0xFF6EC242),
      'Summer' => const Color(0xFF1A7A3E),
      'Autumn' => const Color(0xFFD45A10),
      _ => Colors.green,
    };
    final fp = Paint()..color = foliageColor;

    final canopyY = size.height * 0.36;
    final cr = size.width * 0.46;

    canvas.drawCircle(Offset(trunkX, canopyY), cr, fp);
    canvas.drawCircle(Offset(trunkX - cr * 0.55, canopyY + cr * 0.22), cr * 0.68, fp);
    canvas.drawCircle(Offset(trunkX + cr * 0.55, canopyY + cr * 0.22), cr * 0.68, fp);

    // Winter: bare branches overlay
    if (season.name == 'Winter') {
      final branchPaint = Paint()
        ..color = const Color(0xFF5C3217).withValues(alpha: 0.7)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final angles = [-0.6, 0.0, 0.6, -1.1, 1.1];
      for (final a in angles) {
        canvas.drawLine(
          Offset(trunkX, trunkTop),
          Offset(trunkX + math.sin(a) * cr * 0.7, canopyY - cr * 0.3),
          branchPaint,
        );
      }
    }

    // Autumn: falling leaf dots
    if (season.name == 'Autumn') {
      final leafPaint = Paint()..color = const Color(0xFFE8600A).withValues(alpha: 0.75);
      final rng = math.Random(42);
      for (int i = 0; i < 6; i++) {
        canvas.drawCircle(
          Offset(
            trunkX + (rng.nextDouble() - 0.5) * size.width * 1.2,
            trunkTop + rng.nextDouble() * (trunkBottom - trunkTop) * 0.6,
          ),
          2.5 + rng.nextDouble() * 2,
          leafPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom section
// ─────────────────────────────────────────────────────────────────────────────

class _BottomSection extends StatelessWidget {
  const _BottomSection({
    required this.cyanColor,
    required this.dotsController,
  });

  final Color cyanColor;
  final AnimationController dotsController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          // "1 PHOTO / WEEK"
          Text(
            '1 PHOTO / WEEK',
            style: TextStyle(
              color: cyanColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 14),
          // Three-dot animation
          _ThreeDotsIndicator(cyanColor: cyanColor, controller: dotsController),
          const SizedBox(height: 14),
          // Caption
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Loading... Crafting journeys across time.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.70),
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.auto_awesome,
                color: Colors.white.withValues(alpha: 0.70),
                size: 15,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Three-dot loading indicator
// ─────────────────────────────────────────────────────────────────────────────

class _ThreeDotsIndicator extends StatelessWidget {
  const _ThreeDotsIndicator({
    required this.cyanColor,
    required this.controller,
  });

  final Color cyanColor;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            // Stagger each dot by 1/3 of the cycle
            var t = (controller.value - i / 3) % 1.0;
            if (t < 0) t += 1.0;
            // Smooth sine-based pulse
            final pulse = math.sin(t * math.pi);
            final alpha = 0.30 + 0.70 * pulse;
            final scale = 0.70 + 0.30 * pulse;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: cyanColor.withValues(alpha: alpha),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
