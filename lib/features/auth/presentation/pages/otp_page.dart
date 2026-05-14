import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/colors/theme_custom.dart';
import '../../../../generated/fonts/app_fonts.dart';
import '../../../../shared/widgets/push_button.dart';
import '../../../../shared/widgets/top_snackbar.dart';
import '../../../info/presentation/providers/humo_connection_provider.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../analytics/presentation/providers/analytics_provider.dart';
import '../../../kanban/presentation/providers/kanban_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/otp_provider.dart';

class OtpPage extends StatefulWidget {
  final String phone;
  final VoidCallback onOTPVerified;

  const OtpPage({
    super.key,
    required this.phone,
    required this.onOTPVerified,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isCheckingBot = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final otpProvider = context.read<OtpProvider>();
    final code = otpProvider.code.trim();
    final password = _passwordController.text.trim();

    if (code.isEmpty) {
      TopSnackBar.show(context, 'Введите код');
      return;
    }

    if (code.length != OtpProvider.codeLength) {
      TopSnackBar.show(
          context, 'Введите полный код из ${OtpProvider.codeLength} цифр');
      return;
    }

    // 1. Проверяем OTP-код
    final success = await authProvider.verifyCode(
      code,
      password: password.isEmpty ? null : password,
    );

    if (!context.mounted) return;

    if (!success) {
      TopSnackBar.show(context, authProvider.error ?? 'Неверный код');
      return;
    }

    TopSnackBar.show(context, 'Код подтверждён');

    // 2. Если backend вернул данные пользователя прямо в verifyCode — сразу
    //    заполняем профиль. Это позволяет Settings показать имя/фото мгновенно,
    //    ещё до загрузки /auth/me.
    final userInfo = authProvider.user;
    if (userInfo != null) {
      context.read<UserProfileProvider>().updateFromAuthUser(
        id: userInfo.id,
        phone: userInfo.phoneNumber,
        name: userInfo.name,
        firstName: userInfo.firstName,
        lastName: userInfo.lastName,
        username: userInfo.username,
        photoBase64: userInfo.photoBase64,
      );
    }

    // 3. Показываем загрузку пока проверяем бота
    setState(() => _isCheckingBot = true);

    try {
      final humoProvider = context.read<HumoConnectionProvider>();
      final isConnected = await humoProvider.checkBotStatus();

      if (!context.mounted) return;

      if (isConnected) {
        // 4a. Бот подключён — загружаем данные и идём на главную
        final profileProvider = context.read<UserProfileProvider>();
        final dashboardProvider = context.read<DashboardProvider>();
        final analyticsProvider = context.read<AnalyticsProvider>();
        final kanbanProvider = context.read<KanbanProvider>();

        // loadProfile перезапишет pre-fill из verifyCode полными данными /auth/me
        await profileProvider.loadProfile();
        await dashboardProvider.loadCurrentMonth();
        await analyticsProvider.restorePeriodAndLoad();
        await kanbanProvider.loadCurrentBoard();

        if (!context.mounted) return;
        context.go('/main');
      } else {
        // 4b. Бот не подключён — показываем инструкцию
        if (!context.mounted) return;
        context.go('/info');
      }
    } catch (e) {
      if (!context.mounted) return;
      // При ошибке проверки бота всё равно идём на /info
      context.go('/info');
    } finally {
      if (mounted) {
        setState(() => _isCheckingBot = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final authProv = context.watch<AuthProvider>();
    final otpProv = context.watch<OtpProvider>();
    final isLoading = authProv.isVerifyingCode || _isCheckingBot;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colors.text),
          onPressed: isLoading
              ? null
              : () {
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
              style: AppFonts.mulish.s24w700(color: colors.text),
            ),
            const SizedBox(height: 8),
            Text(
              widget.phone.isEmpty
                  ? 'Мы отправили код на ваш номер'
                  : 'Мы отправили код на ${widget.phone}',
              style: AppFonts.mulish.s14w400(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                otpProv.controllers.length,
                    (i) => _OtpCell(
                  controller: otpProv.controllers[i],
                  focusNode: otpProv.focusNodes[i],
                  onChanged: (v) => otpProv.onChanged(i, v),
                  colors: colors,
                  enabled: !isLoading,
                ),
              ),
            ),
            if (authProv.passwordRequired) ...[
              const SizedBox(height: 40),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  controller: _passwordController,
                  enabled: !isLoading,
                  style: TextStyle(color: colors.text),
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Пароль',
                    hintStyle: AppFonts.mulish.s14w400(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 40),
            if (_isCheckingBot) ...[
              const SizedBox(height: 12),
              Text(
                'Проверяем подключение бота...',
                style: AppFonts.mulish.s14w400(color: Colors.grey),
              ),
              const SizedBox(height: 12),
            ],
            PushButton(
              height: 80,
              color: AppColors.blue,
              colorShadow: AppColors.blueDark,
              border: Border.all(width: 2, color: AppColors.blueDark),
              fontSize: 18,
              colorText: AppColors.textWhite,
              borderRadius: 15,
              language: _isCheckingBot ? 'Проверка...' : 'Подтвердить',
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

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
        style: AppFonts.mulish.s24w700(color: colors.text),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: colors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.blue),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.text.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.blue, width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}