/// Stat Card Widget
/// Карточка для отображения статистики

import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String sum;
  final String? subtitle;
  final Color accentColor;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? sumColor;
  final VoidCallback? onTap;
  final bool isLoading;

  const StatCard({
    super.key,
    required this.title,
    required this.sum,
    this.subtitle,
    required this.accentColor,
    this.backgroundColor,
    this.titleColor,
    this.sumColor,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentColor.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left accent bar
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: titleColor ?? theme.textTheme.bodySmall?.color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            // Sum
            if (isLoading)
              const SizedBox(
                height: 28,
                child: ShimmerLoader(
                  width: 100,
                  height: 24,
                ),
              )
            else
              Text(
                sum,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: sumColor ?? accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shimmer loading effect
class ShimmerLoader extends StatefulWidget {
  final double width;
  final double height;

  const ShimmerLoader({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.brightness == Brightness.dark
        ? Colors.grey[800]!
        : Colors.grey[300]!;
    final highlightColor = theme.brightness == Brightness.dark
        ? Colors.grey[700]!
        : Colors.grey[100]!;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: const  [
              0.0,
              0.5,
              1.0,
            ],
            colors: [
              baseColor,
              highlightColor,
              baseColor,
            ],
            transform: _SlidingGradientTransform(
              slidePercent: _controller.value,
            ),
          ).createShader(bounds);
        },
        child: Container(
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.identity()
      ..translate(slidePercent * bounds.width * 2, 0.0);
  }
}
