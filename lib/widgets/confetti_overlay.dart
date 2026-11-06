import 'dart:math';
import 'package:flutter/material.dart';

class ConfettiOverlay extends StatefulWidget {
  final Widget child;

  const ConfettiOverlay({super.key, required this.child});

  static void show(BuildContext context) {
    // Helper if needed
  }

  @override
  State<ConfettiOverlay> createState() => ConfettiOverlayState();
}

class ConfettiOverlayState extends State<ConfettiOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..addListener(() {
        setState(() {
          for (var p in _particles) {
            p.update();
          }
        });
      });

    _spawnParticles();
    _controller.forward();
  }

  void _spawnParticles() {
    _particles.clear();
    const colors = [
      Color(0xFF6366F1),
      Color(0xFF10B981),
      Color(0xFFF43F5E),
      Color(0xFFF59E0B),
      Color(0xFF06B6D4),
      Color(0xFFEC4899),
    ];

    for (int i = 0; i < 70; i++) {
      _particles.add(
        _ConfettiParticle(
          x: _rnd.nextDouble() * 400,
          y: -20 - _rnd.nextDouble() * 100,
          vx: (_rnd.nextDouble() - 0.5) * 4,
          vy: 2 + _rnd.nextDouble() * 5,
          color: colors[_rnd.nextInt(colors.length)],
          size: 6 + _rnd.nextDouble() * 8,
          rotation: _rnd.nextDouble() * pi * 2,
          rotationSpeed: (_rnd.nextDouble() - 0.5) * 0.2,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_controller.isAnimating)
          IgnorePointer(
            child: CustomPaint(
              painter: _ConfettiPainter(_particles),
              size: Size.infinite,
            ),
          ),
      ],
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;
  double rotation;
  double rotationSpeed;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });

  void update() {
    x += vx;
    y += vy;
    rotation += rotationSpeed;
    vy += 0.05; // gravity
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;

  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final paint = Paint()..color = p.color;
      canvas.save();
      canvas.translate(p.x % size.width, p.y);
      canvas.rotate(p.rotation);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
