import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/state/providers/theme_provider.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/colors/theme_custom.dart';
import '../../../../generated/fonts/app_fonts.dart';
import '../../../../shared/widgets/push_button.dart';
import '../../../../shared/widgets/top_snackbar.dart';
import '../providers/auth_provider.dart';

class PhoneAuthPage extends StatefulWidget {
  final ValueChanged<String> onPhoneSubmitted;

  const PhoneAuthPage({
    super.key,
    required this.onPhoneSubmitted,
  });

  @override
  State createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State {
  final TextEditingController _phoneController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future _handleSubmit() async {
    final rawPhone = _phoneController.text.trim();

    if (rawPhone.isEmpty) {
      TopSnackBar.show(context, 'Введите номер телефона');
      return;
    }

    if (rawPhone.length != 9) {
      TopSnackBar.show(context, 'Введите номер в формате 901234567');
      return;
    }

    final fullPhone = '+998$rawPhone';

    setState(() {
      isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.sendCode(fullPhone);

      if (!mounted) return;

      if (success) {
        TopSnackBar.show(context, 'Код отправлен в Telegram');
        (widget as PhoneAuthPage).onPhoneSubmitted(fullPhone);
      } else {
        TopSnackBar.show(
          context,
          authProvider.error ?? 'Не удалось отправить код',
        );
      }
    } catch (e) {
      if (!mounted) return;
      TopSnackBar.show(context, 'Ошибка: \n $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    final isDark = context.read<ThemeProvider>().isDark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              isDark
                  ? 'assets/images/kanban_bg_dark.png'
                  : 'assets/images/kanban_bg.png',
              key: ValueKey(isDark),
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: colors.background.withOpacity(0.15),
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: size.height * 0.42,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(40),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.blue.withOpacity(0.85),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(40),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Text(
                              'Авторизация',
                              style: AppFonts.mulish.s24w700(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -40),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: colors.shadow.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: colors.background,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: colors.text.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                '🇺🇿 +998',
                                style: AppFonts.mulish.s14w600(
                                  color: colors.text,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.background,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: colors.text.withOpacity(0.2),
                                  ),
                                ),
                                child: TextField(
                                  controller: _phoneController,
                                  enabled: !isLoading,
                                  style: TextStyle(color: colors.text),
                                  keyboardType: TextInputType.phone,
                                  maxLength: 9,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(9),
                                  ],
                                  decoration: const InputDecoration(
                                    counterText: '',
                                    hintText: '901234567',
                                    hintStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
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
                          language:
                              isLoading ? 'Отправляем...' : 'Отправить код',
                          flagAsset: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const SizedBox.shrink(),
                          onTap: isLoading ? () {} : _handleSubmit,
                          isSelected: isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
