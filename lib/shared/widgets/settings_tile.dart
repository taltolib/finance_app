import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final bool showArrow;
  final VoidCallback? onTap;
  final Color textPrimary;

  const SettingsTile({
    required this.title,
    required this.textPrimary,
    this.trailing,
    this.showArrow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 14, color: textPrimary),
              ),
            ),
            if (trailing != null) trailing!,
            if (showArrow)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(
                  CupertinoIcons.chevron_right,
                  size: 18,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }
}