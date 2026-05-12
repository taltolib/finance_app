import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/providers/theme_provider.dart';
import '../../../../core/theme/colors/theme_custom.dart';
import '../../../../generated/fonts/app_fonts.dart';

class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({super.key, });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final isDark = themeProvider.isDark;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      child: Row(
        children: [
           Expanded(
            child: Text(
              "Тема",
              style: AppFonts.mulish.s16w500(color:colors.text ),
            ),
          ),
          GestureDetector(
            onTap: () {
              themeProvider.toggleTheme();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 70,
              height: 36,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: isDark
                    ? const LinearGradient(
                  colors: [
                    Color(0xFF0D1B2A),
                    Color(0xFF1B263B),
                  ],
                )
                    : const LinearGradient(
                  colors: [
                    Color(0xFF87CEEB),
                    Color(0xFFFFD54F),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  if (isDark)
                    const Positioned(
                      left: 8,
                      top: 8,
                      child: Icon(
                        Icons.star,
                        size: 6,
                        color: Colors.white70,
                      ),
                    ),
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: isDark
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? const Color(0xFFF4E3C1)
                            : const Color(0xFFFFB300),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isDark
                            ? Icons.nightlight_round
                            : Icons.wb_sunny,
                        size: 16,
                        color: isDark
                            ? Colors.brown
                            : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}