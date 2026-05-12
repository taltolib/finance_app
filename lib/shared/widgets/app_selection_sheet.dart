import 'package:flutter/material.dart';

import '../../core/theme/colors/theme_custom.dart';

class AppSelectionSheet extends StatelessWidget {
  final Widget? header;
  final Widget body;
  final Widget? bottom;
  final Radius? heightRadius;


  const AppSelectionSheet({
    super.key,
    this.header,
    required this.body,
    this.bottom, this.heightRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius:  BorderRadius.vertical(
            top:heightRadius ?? Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            if (header != null) ...[
              header!,
              const SizedBox(height: 12),
            ],
            Expanded(child: body),
            if (bottom != null) ...[
              const SizedBox(height: 12),
              bottom!,
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}