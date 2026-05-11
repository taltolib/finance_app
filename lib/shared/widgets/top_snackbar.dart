import 'package:finance_app/shared/widgets/push_button.dart';
import 'package:flutter/material.dart';

import '../../core/theme/colors/app_colors.dart';


class TopSnackBar {
  static void show(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _TopSnackBarWidget(message: message),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}

class _TopSnackBarWidget extends StatefulWidget {
  final String message;

  const _TopSnackBarWidget({required this.message});

  @override
  State<_TopSnackBarWidget> createState() => _TopSnackBarWidgetState();
}

class _TopSnackBarWidgetState extends State<_TopSnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 25,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _animation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: PushButton(
            language: widget.message,
            flagAsset: const Icon(Icons.error, color: AppColors.textWhite, ),
            onTap: () {},
            isSelected: false,
            height: 70,
            borderRadius: 10,
            color: AppColors.red,
            colorShadow: AppColors.redDark,
            colorText: AppColors.textWhite,
            border: Border.all(width: 1, color: AppColors.redDark),
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
