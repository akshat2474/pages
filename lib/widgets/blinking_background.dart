import 'dart:math';
import 'package:flutter/material.dart';

class BlinkingDotsBackground extends StatefulWidget {
  const BlinkingDotsBackground({super.key});

  @override
  State<BlinkingDotsBackground> createState() => _BlinkingDotsBackgroundState();
}

class _BlinkingDotsBackgroundState extends State<BlinkingDotsBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Dot> _dots = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..addListener(() {
            _updateDots();
          });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeDots(context.size ?? const Size(400, 800));
        _controller.repeat();
      }
    });
  }

  void _initializeDots(Size size) {
    if (!mounted || size.isEmpty) return;
    _dots.clear();
    const double spacing = 50.0;

    final cols = (size.width / spacing).ceil();
    final rows = (size.height / spacing).ceil();

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        _dots.add(
          _Dot(
            position: Offset(x * spacing, y * spacing),
            opacity: _random.nextDouble() * 0.5,
            targetOpacity: _random.nextDouble() * 0.7,
          ),
        );
      }
    }
    setState(() {});
  }

  void _updateDots() {
    if (!mounted) return;
    setState(() {
      for (var dot in _dots) {
        dot.opacity += (dot.targetOpacity - dot.opacity) * 0.05;

        if (_random.nextDouble() < 0.01) {
          dot.targetOpacity = _random.nextDouble() * 0.7;
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DotsPainter(dots: _dots),
      child: Container(),
    );
  }
}

class _Dot {
  Offset position;
  double opacity;
  double targetOpacity;

  _Dot({required this.position, this.opacity = 0.0, this.targetOpacity = 0.5});
}

class _DotsPainter extends CustomPainter {
  final List<_Dot> dots;

  _DotsPainter({required this.dots});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var dot in dots) {
      paint.color = Colors.white.withValues(alpha:dot.opacity);
      canvas.drawCircle(dot.position, 1.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
