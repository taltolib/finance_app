import 'package:finance_app/core/state/providers/theme_provider.dart';
import 'package:finance_app/core/theme/colors/app_colors.dart';
import 'package:finance_app/core/theme/colors/theme_custom.dart';
import 'package:finance_app/generated/fonts/app_fonts.dart';
import 'package:finance_app/shared/widgets/custom_show_dialog.dart';
import 'package:finance_app/shared/widgets/push_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widget/settings_switch_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              themeProvider.authBackgroundAsset,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.15),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileHeader(colors: colors, nameUser: '',),
                const SizedBox(height: 36),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Настройки',
                    style: AppFonts.mulish.s24w700(
                      color: colors.text,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _SettingsCard(
                    colors: colors,
                    children: [
                       const SettingsSwitchTile(),
                      Divider(
                        height: 0.5,
                        thickness: 1,
                        color: colors.text.withOpacity(0.08),
                      ),
                      _LogoutTile(
                        colors: colors,
                        onTap: () => customShowBottomSheetDialog(
                            context,
                            0.4,
                            heightRadius: const Radius.circular(25),
                            Container(),
                            Text('Вы точно хотите выйти из аккаунта?', style: AppFonts.mulish.s16w400()),
                            PushButton(
                                language: 'Выйти',
                                flagAsset: const SizedBox.shrink(),
                                onTap: () {},
                                isSelected: false,
                              color: AppColors.red,
                              colorShadow: AppColors.redDark,
                              border: Border.all(color:AppColors.redDark,width: 1 ),
                              height: 50,
                            )
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String nameUser;
  final String? nikeName;
  final String? photoUrl;
  final AppThemeColors colors;

  const _ProfileHeader({
    required this.colors,
    this.nikeName,
    required this.nameUser,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.text.withOpacity(0.75),
                width: 1,
              ),
            ),
            child: photoUrl != null
                ? Image.asset(photoUrl!)
                : Icon(
                    Icons.person_outline,
                    color: colors.text.withOpacity(0.75),
                    size: 24,
                  ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nameUser,
                  style: AppFonts.mulish.s16w700(
                    color: colors.text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  nikeName != null ? "@$nikeName" : '',
                  style: AppFonts.mulish.s12w400(
                    color: colors.text.withOpacity(0.45),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final AppThemeColors colors;
  final List<Widget> children;

  const _SettingsCard({
    required this.colors,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.backgroundLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.shadow.withOpacity(0.70),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}

// class _ThemeSwitchTile extends StatelessWidget {
//   final AppThemeColors colors;
//
//   const _ThemeSwitchTile({
//     required this.colors,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = context.watch<ThemeProvider>();
//     final isDark = themeProvider.isDark;
//
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 15,
//         vertical: 15,
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Text(
//               'Тема',
//               style: AppFonts.mulish.s16w500(
//                 color: colors.text.withOpacity(0.70),
//               ),
//             ),
//           ),
//
//         ],
//       ),
//     );
//   }
// }

class _LogoutTile extends StatelessWidget {
  final AppThemeColors colors;
  final VoidCallback onTap;

  const _LogoutTile({
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColors.red.withOpacity(0.08),
      highlightColor: AppColors.red.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Выйти из аккаунта',
                style: AppFonts.mulish.s16w500(
                  color: AppColors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



