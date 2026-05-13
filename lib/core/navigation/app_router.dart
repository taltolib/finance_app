import 'package:finance_app/features/auth/presentation/pages/otp_page.dart';
import 'package:finance_app/features/auth/presentation/pages/phone_auth_page.dart';
import 'package:finance_app/features/info/info_bot_page.dart';
import 'package:finance_app/features/kanban/presentation/pages/kanban_boards_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_shell.dart';
import '../../core/navigation/startup_gate.dart';
import '../../features/analytics/presentation/pages/analytics_screen.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/kanban/presentation/widgets/archived_boards_view.dart';
import '../../features/settings/presentation/pages/settings_screen.dart';

/// Централизованный роутер приложения
final GoRouter appRouter = GoRouter(
  initialLocation: '/start',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/start',
      name: 'startup',
      builder: (context, state) => const StartupGate(),
    ),

    GoRoute(
      path: '/main',
      name: 'main',
      builder: (context, state) => const MainScreen(),
    ),

    // ─── Auth ─────────────────────────────────────────────────────────────
    GoRoute(
      path: '/auth/phone',
      name: 'phone',
      builder: (context, state) => PhoneAuthPage(
        onPhoneSubmitted: (phone) {
          context.go('/auth/otp', extra: phone);
        },
      ),
    ),

    GoRoute(
      path: '/auth/otp',
      name: 'otp',
      builder: (context, state) {
        final phone = state.extra as String? ?? '';
        return OtpPage(
          phone: phone,
          onOTPVerified: () {
            context.go('/main');
          },
        );
      },
    ),

    // ─── Kanban Boards ────────────────────────────────────────────────────
    GoRoute(
      path: '/kanban',
      name: 'kanban',
      builder: (context, state) => const KanbanBoardsScreen(),
    ),

    // ─── Archived Boards (отдельная страница) ─────────────────────────────
    GoRoute(
      path: '/kanban/archived',
      name: 'kanban-archived',
      builder: (context, state) => Scaffold(
        backgroundColor: Colors.transparent,
        body: ArchivedBoardsView(
          onBack: () => context.go('/kanban'),
        ),
      ),
    ),

    // ─── Analytics ────────────────────────────────────────────────────────
    GoRoute(
      path: '/analytics',
      name: 'analytics',
      builder: (context, state) => const AnalyticsScreen(),
    ),

    // ─── Dashboard ────────────────────────────────────────────────────────
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),

    GoRoute(
      path: '/info',
      name: 'info',
      builder: (context, state) => const InfoBotPage(),
    ),

    // ─── Settings ─────────────────────────────────────────────────────────
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],

  // ─── Error page ───────────────────────────────────────────────────────────
  errorBuilder: (context, state) => Scaffold(
    backgroundColor: const Color(0xFF1D2125),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF4B4B), size: 48),
          const SizedBox(height: 16),
          const Text(
            'Страница не найдена',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Mulish',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.error?.toString() ?? 'Неизвестная ошибка',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 13,
              fontFamily: 'Mulish',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25B4C7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => context.go('/'),
            child: const Text('На главную'),
          ),
        ],
      ),
    ),
  ),
);
