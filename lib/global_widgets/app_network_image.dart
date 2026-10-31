import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// صورة من الشبكة مع حالة تحميل وبديل (Gradient + أيقونة) لو الرابط فاضي
/// أو فشل التحميل — عشان ما يظهر أبداً مربع أحمر/صورة مكسورة.
class AppNetworkImage extends StatelessWidget {
  final String? url;
  final IconData fallbackIcon;
  final Gradient? fallbackGradient;
  final BoxFit fit;
  final double? width;
  final double? height;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.fallbackIcon = Icons.image_outlined,
    this.fallbackGradient,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  Widget _fallback() {
    final gradient = fallbackGradient ?? AppColors.destinationGradients.first;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(gradient: gradient),
      alignment: Alignment.center,
      child: Icon(fallbackIcon,
          color: Colors.white.withValues(alpha: 0.55), size: 36),
    );
  }

  @override
  Widget build(BuildContext context) {
    final src = url?.trim();
    if (src == null || src.isEmpty || !src.startsWith('http')) {
      return _fallback();
    }
    return Image.network(
      src,
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurface
              : AppColors.primarySurface,
          alignment: Alignment.center,
          child: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }
}
