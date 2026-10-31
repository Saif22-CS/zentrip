import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// شعار زنتريب — بوصلة + خط أفق + نقطة وجهة. يُرسم بـ CustomPainter.
class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;
  final bool showBackground;

  const AppLogo({super.key, this.size = 48, this.color, this.showBackground = false});

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? AppColors.primary;
    return Container(
      width: size * 1.5,
      height: size * 1.5,
      decoration: showBackground
          ? BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(size * 0.35),
            )
          : null,
      child: Center(
        child: CustomPaint(
          size: Size(size, size),
          painter: _ZentripLogoPainter(color: logoColor),
        ),
      ),
    );
  }
}

class _ZentripLogoPainter extends CustomPainter {
  final Color color;
  const _ZentripLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.07
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;

    // دائرة البوصلة
    canvas.drawCircle(Offset(cx, cy), r, paint);

    // خطوط البوصلة (N, S, E, W)
    for (int i = 0; i < 4; i++) {
      final angle = i * 3.14159 / 2;
      final x1 = cx + (r * 0.6) * _cos(angle);
      final y1 = cy + (r * 0.6) * _sin(angle);
      final x2 = cx + r * _cos(angle);
      final y2 = cy + r * _sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    // سهم الشمال (مثلث مملوء)
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final northPath = Path();
    northPath.moveTo(cx, cy - r * 0.55);
    northPath.lineTo(cx - r * 0.15, cy);
    northPath.lineTo(cx + r * 0.15, cy);
    northPath.close();
    canvas.drawPath(northPath, fillPaint);

    // نقطة المركز
    canvas.drawCircle(Offset(cx, cy), size.width * 0.05, fillPaint);
  }

  double _cos(double radians) => _trig(radians, true);
  double _sin(double radians) => _trig(radians, false);
  double _trig(double r, bool isCos) {
    // بسيط — نستخدم dart:math
    if (isCos) return _dartCos(r);
    return _dartSin(r);
  }

  double _dartCos(double r) {
    if (r == 0) return 1;
    if ((r - 1.5708).abs() < 0.001) return 0;
    if ((r - 3.14159).abs() < 0.001) return -1;
    if ((r - 4.71239).abs() < 0.001) return 0;
    return 1;
  }

  double _dartSin(double r) {
    if (r == 0) return 0;
    if ((r - 1.5708).abs() < 0.001) return 1;
    if ((r - 3.14159).abs() < 0.001) return 0;
    if ((r - 4.71239).abs() < 0.001) return -1;
    return 0;
  }

  @override
  bool shouldRepaint(_ZentripLogoPainter old) => old.color != color;
}
