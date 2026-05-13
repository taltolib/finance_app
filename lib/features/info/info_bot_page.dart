import 'package:finance_app/features/info/presentation/providers/humo_connection_provider.dart';
import 'package:finance_app/generated/fonts/app_fonts.dart';
import 'package:finance_app/core/theme/colors/theme_custom.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class InfoBotPage extends StatelessWidget {
  const InfoBotPage({super.key});

  @override
  Widget build(BuildContext context) {
    final humoProvider = context.watch<HumoConnectionProvider>();
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    final statusTitle = humoProvider.isConnected ? 'HUMO подключен' : 'Проблема с подключением HUMO';
    final statusMessage = humoProvider.error ?? humoProvider.getErrorMessage();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'HUMO Bot',
          style: AppFonts.mulish.s18w700(color: colors.text),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: colors.text),
          onPressed: () => context.go('/main'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.backgroundLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(statusTitle, style: AppFonts.mulish.s20w700(color: colors.text)),
                    const SizedBox(height: 12),
                    Text(statusMessage, style: AppFonts.mulish.s14w400(color: colors.text.withOpacity(0.72))),
                    const SizedBox(height: 16),
                    Text(
                      'Проверьте подключение HUMO bot в Telegram и повторите попытку.',
                      style: AppFonts.mulish.s14w400(color: colors.text.withOpacity(0.72)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _InstructionStep(
                number: 1,
                title: 'Откройте @HUMOcardbot',
                description: 'Найдите бот в Telegram и начните чат с ним.',
              ),
              const SizedBox(height: 12),
              _InstructionStep(
                number: 2,
                title: 'Отправьте команду /start',
                description: 'Если бот запросит доступ, подтвердите его.',
              ),
              const SizedBox(height: 12),
              _InstructionStep(
                number: 3,
                title: 'Подключите карту HUMO',
                description: 'Следуйте инструкциям в боте для подключения карты.',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: humoProvider.isChecking
                    ? null
                    : () async {
                        final router = GoRouter.of(context);
                        final connected = await humoProvider.checkBotStatus();
                        if (connected) {
                          router.go('/main');
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25B4C7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: humoProvider.isChecking
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Проверить снова'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final int number;
  final String title;
  final String description;

  const _InstructionStep({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.backgroundLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF25B4C7),
            child: Text(
              number.toString(),
              style: AppFonts.mulish.s14w700(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppFonts.mulish.s16w700(color: colors.text)),
                const SizedBox(height: 6),
                Text(description, style: AppFonts.mulish.s14w400(color: colors.text.withOpacity(0.72))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
