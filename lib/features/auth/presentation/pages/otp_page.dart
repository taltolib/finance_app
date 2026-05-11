import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/colors/theme_custom.dart';
import '../../../../generated/fonts/app_fonts.dart';
import '../../../../shared/widgets/push_button.dart';
import '../../../../shared/widgets/top_snackbar.dart';
import '../providers/auth_provider.dart';
import '../providers/otp_provider.dart';

class OtpPage extends StatelessWidget {
  final String phone;
  final VoidCallback onOTPVerified;

  const OtpPage({
    super.key,
    required this.phone,
    required this.onOTPVerified,
  });

  Future _handleVerify(BuildContext context) async {
    final authProvider = context.read();
    final otpProvider = context.read();
    final code = otpProvider.code.trim();

    if (code.isEmpty) {
      TopSnackBar.show(context, 'Введите код');
      return;
    }

    if (code.length != 6) {
      TopSnackBar.show(context, 'Введите полный код из 6 цифр');
      return;
    }

    final success = await authProvider.verifyCode(code);

    if (!context.mounted) return;

    if (success) {
      TopSnackBar.show(context, 'Код подтверждён');
      onOTPVerified();
    } else {
      TopSnackBar.show(
        context,
        authProvider.error ?? 'Неверный код',
      );
    }
  }

  @override
  Widget  build(BuildContext context) {
    final colors = Theme.of(context).extension()!;
    final authProv = context.watch();
    final otpProv = context.watch();
    final isLoading = authProv.isVerifyingCode;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: colors.text,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/auth/phone');
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              'Введите код',
              style: AppFonts.mulish.s24w700(
                color: colors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              phone.isEmpty
                  ? 'Мы отправили код на ваш номер'
                  : 'Мы отправили код на $phone',
              style: AppFonts.mulish.s14w400(
                color: Colors.grey,
              ),
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
                  enabled: !isLoading,
                ),
              ),
            ),
            const SizedBox(height: 40),
            PushButton(
              height: 70,
              color: AppColors.blue,
              colorShadow: AppColors.blueDark,
              border: Border.all(
                width: 2,
                color: AppColors.blueDark,
              ),
              fontSize: 18,
              colorText: AppColors.textWhite,
              borderRadius: 15,
              language: 'Подтвердить',
              flagAsset: isLoading
                  ? const SizedBox(
                      height: 20,
                      child: CircularProgressIndicator(
                        backgroundColor: AppColors.textWhite,
                      ),
                    )
                  : const SizedBox.shrink(),
              isSelected: false,
              onTap: isLoading ? () {} : () => _handleVerify(context),
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
  final ValueChanged onChanged;
  final AppThemeColors colors;
  final bool enabled;

  const _OtpCell({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.colors,
    required this.enabled,
  });

  @overrideWidget
  build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: AppFonts.mulish.s24w700(
          color: colors.text,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: colors.backgroundAccepts,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.blue,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.blue,
              width: 2,
            ),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
