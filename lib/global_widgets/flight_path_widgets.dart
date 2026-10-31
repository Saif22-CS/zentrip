import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants/app_colors.dart';

/// طائرة تُقلع من أسفل الشاشة بمسار منحنٍ — تُستخدم في شاشة الـ Splash.
class TakeoffPlaneAnimation extends StatefulWidget {
  const TakeoffPlaneAnimation({super.key});

  @override
  State<TakeoffPlaneAnimation> createState() => _TakeoffPlaneAnimationState();
}

class _TakeoffPlaneAnimationState extends State<TakeoffPlaneAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.repeat(reverse: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (_, __) {
        final t = _progress.value;
        final size = MediaQuery.of(context).size;
        final x = size.width * 0.1 + (size.width * 0.8) * t;
        final y = size.height * 0.75 - (size.height * 0.5) * (t * t);
        final opacity = t < 0.85 ? 1.0 : (1.0 - (t - 0.85) / 0.15);
        return Positioned(
          left: x,
          top: y,
          child: Opacity(
            opacity: opacity.clamp(0, 1),
            child: Transform.rotate(
              angle: -0.35 * (1 - t),
              child: const Icon(Icons.flight, color: Colors.white24, size: 28),
            ),
          ),
        );
      },
    );
  }
}

/// طائرة أفقية مستقيمة — تُستخدم في شاشة الـ Auth.
class StraightFlightPlane extends StatelessWidget {
  final double height;
  final Color color;

  const StraightFlightPlane({super.key, this.height = 40, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(child: Container(height: 1.5, color: color.withValues(alpha: 0.15))),
          Icon(Icons.flight, color: color, size: height * 0.7),
          Expanded(child: Container(height: 1.5, color: color.withValues(alpha: 0.15))),
        ],
      ),
    ).animate().fade(duration: 600.ms).slideX(begin: -0.05, end: 0, curve: Curves.easeOut);
  }
}

/// خط المسار بين مدينتين — يُستخدم في بطاقة تفاصيل الرحلة.
class FlightPathLine extends StatelessWidget {
  final String origin;
  final String destination;
  final bool isDirect;

  const FlightPathLine({
    super.key,
    required this.origin,
    required this.destination,
    this.isDirect = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(origin, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        Expanded(
          child: Column(
            children: [
              const Icon(Icons.flight, color: AppColors.primary, size: 18),
              Container(height: 1.5, color: AppColors.border),
              Text(
                isDirect ? 'Direct' : '1 Stop',
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        Text(destination, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      ],
    );
  }
}
