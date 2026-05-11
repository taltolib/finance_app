import 'package:flutter/material.dart';

class PushButton extends StatelessWidget {
  final String language;
  final Widget flagAsset;
  final bool isSelected;
  final BoxBorder? border;

  final double height;
  final double? width;

  final Color color;
  final Color colorShadow;
  final Color colorText;

  final double borderRadius;
  final double fontSize;

  final VoidCallback onTap;

  const PushButton({
    super.key,
    required this.language,
    required this.flagAsset,
    required this.onTap,
    required this.isSelected,

    this.height = 140,
    this.width,

    this.color = Colors.white,
    this.colorShadow = Colors.grey,
    this.colorText = Colors.black,

    this.borderRadius = 25,
    this.fontSize = 14,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: height,
        width: width,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: height * 0.5,
                decoration: BoxDecoration(
                  color: colorShadow,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              bottom: isSelected ? 0 : 5,
              left: 0,
              right: 0,
              child: Container(
                height: height - 20,
                width: width,
                decoration: BoxDecoration(
                  color: color,
                  border: border,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    flagAsset,
                    const SizedBox(width: 12),
                    Flexible(
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          language,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: colorText,
                            overflow: TextOverflow.ellipsis,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
