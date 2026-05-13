import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:finance_app/core/api/api_exceptions.dart';
import 'package:finance_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_app/features/info/presentation/providers/humo_connection_provider.dart';
import 'package:finance_app/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:finance_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:finance_app/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:finance_app/features/kanban/presentation/providers/kanban_provider.dart';
import 'package:finance_app/core/theme/colors/theme_custom.dart';
import 'package:finance_app/generated/fonts/app_fonts.dart';

class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prepareApp();
    });
  }

  Future<void> _prepareApp() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final authProvider = context.read<AuthProvider>();
    final humoProvider = context.read<HumoConnectionProvider>();
    final profileProvider = context.read<UserProfileProvider>();
    final dashboardProvider = context.read<DashboardProvider>();
    final analyticsProvider = context.read<AnalyticsProvider>();
    final kanbanProvider = context.read<KanbanProvider>();

    try {
      await authProvider.restoreSession();

      if (!mounted) return;

      if (!authProvider.isAuthenticated || authProvider.sessionToken == null) {
        if (mounted) {
          context.go('/auth/phone');
        }
        return;
      }

      final isConnected = await humoProvider.checkBotStatus();

      if (!mounted) return;

      if (isConnected) {
        await profileProvider.loadProfile();
        await dashboardProvider.loadCurrentMonth();
        await analyticsProvider.restorePeriodAndLoad();
        await kanbanProvider.loadCurrentBoard();
        if (!mounted) return;
        context.go('/main');
      } else {
        if (!mounted) return;
        context.go('/info');
      }
    } catch (e) {
      if (e is UnauthorizedException) {
        authProvider.invalidateSession();
        if (mounted) {
          context.go('/auth/phone');
        }
        return;
      }

      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Подготовка приложения...',
                    style: AppFonts.mulish.s16w500(color: colors.text),
                  ),
                ],
              )
            : _error != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ошибка загрузки',
                          style: AppFonts.mulish.s18w700(color: colors.text),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _error ?? '',
                          style: AppFonts.mulish.s14w400(color: colors.text.withOpacity(0.72)),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _prepareApp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25B4C7),
                          ),
                          child: const Text('Повторить'),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
      ),
    );
  }
}
