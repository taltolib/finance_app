import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:progress/core/providers/auth_provider.dart';
import 'package:progress/core/providers/otp_provider.dart';
import 'package:progress/core/theme/colors/app_colors.dart';
import 'package:progress/core/theme/colors/theme_custom.dart';
import 'package:progress/domain/enums/auth_status.dart';
import 'package:progress/generated/fonts/app_fonts.dart';
import 'package:progress/generated/tr/locale_keys.dart';
import 'package:progress/shared/widget/%20top_snackbar.dart';
import 'package:progress/shared/widget/push_button.dart';
import 'package:provider/provider.dart';

/////  здесть тоже измени цвета на нажи фирмениые которые я укзал темы и цвета
class OtpPage extends StatelessWidget {
  final String phone;
  // isLogin убран — определяем автоматически по наличию профиля в Firestore
  const OtpPage({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    // созадй нужные провайдеры  и поклучи сюда
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final authProv = context.watch<AuthProvider>();
    final otpProv = context.watch<OtpProvider>();

    return Scaffold(
      backgroundColor: colors.backgroundWhiteOrDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colors.text),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              LocaleKeys.codeEnter.tr(),
              style: AppFonts.mulish.s24w700(color: colors.text),
            ),
            const SizedBox(height: 8),
            Text(
              'Отправили SMS на +998$phone',
              style: AppFonts.mulish.s14w400(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                    (i) => _OtpCell(
                  controller: otpProv.controllers[i],
                  focusNode: otpProv.focusNodes[i],
                  onChanged: (v) => otpProv.onChanged(i, v),
                  colors: colors,
                ),
              ),
            ),
            const SizedBox(height: 40),
            PushButton(
              height: 70,
              color: AppColors.green,
              colorShadow: AppColors.blackGreen,
              border: Border.all(width: 2, color: AppColors.blackGreen),
              fontSize: 18,
              colorText: AppColors.whiteForLight,
              borderRadius: 15,
              language: authProv.status == AuthStatus.loading
                  ? LocaleKeys.loading.tr()
                  : LocaleKeys.confirm.tr(),
              flagAsset: const SizedBox.shrink(),
              isSelected: false,
              onTap: authProv.status == AuthStatus.loading
                  ? () {}
                  : () async {
                final code = otpProv.otpCode;
                final success = await authProv.verifyOtp(code);
                if (!context.mounted) return;

                if (success) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    TopSnackBar.show(context, LocaleKeys.errorAuth.tr());
                    return;
                  }
                  // Профиль есть → /main, нет → /create_profile
                  final doc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .get();
                  if (!context.mounted) return;
                  context.go(doc.exists ? '/main' : '/create_profile');
                } else {
                  TopSnackBar.show(
                      context, authProv.errorMessage ?? LocaleKeys.errorPasswordNoCorrect.tr());
                  otpProv.clear();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpCell extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final AppThemeColors colors;

  const _OtpCell({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: AppFonts.mulish.s24w700(color: colors.text),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: colors.backgroundAcceptsWhiteOrDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.green),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.green, width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

////то что лишнее удали чтоыб есм острпвлается на телеграм пуст в блоке или в провайдере будет эти веши то что нужно