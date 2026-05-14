import 'dart:convert';

import 'package:finance_app/core/state/providers/theme_provider.dart';
import 'package:finance_app/core/theme/colors/app_colors.dart';
import 'package:finance_app/core/theme/colors/theme_custom.dart';
import 'package:finance_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_app/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:finance_app/generated/fonts/app_fonts.dart';
import 'package:finance_app/shared/widgets/custom_show_dialog.dart';
import 'package:finance_app/shared/widgets/push_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../widget/settings_switch_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final profileProvider = context.watch<UserProfileProvider>();
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    final profile = profileProvider.user;

    // displayName: fullName → username → phone → 'Пользователь'
    final displayName = profile?.displayName ?? 'Пользователь';
    // displayUsername: @username → phone → ''
    final displayUsername =
    profile != null ? profile.displayUsername : null;
    final photoBase64 = profile?.photoBase64;

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
                _ProfileHeader(
                  colors: colors,
                  nameUser: displayName,
                  nikeName: displayUsername,
                  photoUrl: photoBase64,
                  isLoading: profileProvider.isLoading,
                ),
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
                          0.2,
                          heightRadius: const Radius.circular(25),
                          Container(),
                          Text(
                            'Вы точно хотите выйти из аккаунта?',
                            style: AppFonts.mulish.s16w400(color: colors.text),
                          ),
                          PushButton(
                            language: 'Выйти',
                            colorText: colors.text,
                            flagAsset: const SizedBox.shrink(),
                            onTap: () async {
                              // Закрываем диалог
                              Navigator.of(context, rootNavigator: true).pop();

                              final authProvider = context.read<AuthProvider>();
                              final profileProv =
                              context.read<UserProfileProvider>();

                              await authProvider.logout();
                              // Очищаем профиль после logout
                              profileProv.clear();

                              if (context.mounted) {
                                context.go('/auth/phone');
                              }
                            },
                            isSelected: false,
                            color: AppColors.red,
                            colorShadow: AppColors.redDark,
                            border: Border.all(
                                color: AppColors.redDark, width: 1),
                            borderRadius: 15,
                            height: 80,
                          ),
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
  final bool isLoading;

  const _ProfileHeader({
    required this.colors,
    required this.nameUser,
    this.nikeName,
    this.photoUrl,
    this.isLoading = false,
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
          // Аватар
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.text.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: ClipOval(
              child: isLoading
                  ? _buildAvatarPlaceholder(colors)
                  : photoUrl != null && photoUrl!.isNotEmpty
                  ? Image.memory(
                base64Decode(photoUrl!),
                fit: BoxFit.cover,
                width: 54,
                height: 54,
                errorBuilder: (context, error, stackTrace) =>
                    _buildAvatarPlaceholder(colors),
              )
                  : _buildAvatarPlaceholder(colors),
            ),
          ),
          const SizedBox(width: 18),
          // Имя и username / телефон
          Expanded(
            child: isLoading
                ? _buildTextSkeleton(colors)
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nameUser,
                  style: AppFonts.mulish.s16w700(color: colors.text),
                  overflow: TextOverflow.ellipsis,
                ),
                if (nikeName != null && nikeName!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    nikeName!,
                    style: AppFonts.mulish.s12w400(
                      color: colors.text.withOpacity(0.45),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder(AppThemeColors colors) {
    return Icon(
      Icons.person_outline,
      color: colors.text.withOpacity(0.75),
      size: 24,
    );
  }

  Widget _buildTextSkeleton(AppThemeColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 14,
          width: 120,
          decoration: BoxDecoration(
            color: colors.text.withOpacity(0.10),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 11,
          width: 80,
          decoration: BoxDecoration(
            color: colors.text.withOpacity(0.06),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
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