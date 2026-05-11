import 'package:finance_app/shared/database/database_helper.dart' show DatabaseHelper;
import 'package:finance_app/core/state/providers/theme_provider.dart';
import 'package:finance_app/features/transactions/presentation/providers/transaction_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/share_import/presentation/bloc/share_intent_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'features/kanban/presentation/providers/kanban_provider.dart';
import 'app/app_shell.dart';
import 'features/share_import/domain/usecases/share_intent_usecases.dart';
import 'features/share_import/data/repositories/share_intent_repository_impl.dart';
import 'features/share_import/data/datasources/share_intent_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/providers/otp_provider.dart';
import 'features/auth/presentation/pages/phone_auth_page.dart';
import 'features/auth/presentation/pages/otp_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru_RU', null);
  await ShareIntentService.initialize();

  final shareIntentService = ShareIntentService();
  final databaseHelper = DatabaseHelper.instance;
  final shareIntentRepository = ShareIntentRepositoryImpl(
    shareIntentService: shareIntentService,
    databaseHelper: databaseHelper ,
  );

  final getInitialSharedText = GetInitialSharedTextUseCase(shareIntentRepository);
  final listenShareIntent = ListenShareIntentUseCase(shareIntentRepository);
  final parseSharedContent = ParseSharedContentUseCase(shareIntentRepository);
  final saveTransaction = SaveTransactionUseCase(shareIntentRepository);

  runApp(
    HumoTrackerApp(
      getInitialSharedText: getInitialSharedText,
      listenShareIntent: listenShareIntent,
      parseSharedContent: parseSharedContent,
      saveTransaction: saveTransaction,
    ),
  );
}

final GoRouter _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: '/auth/phone',
      name: 'phone',
      builder: (context, state) {
        return ChangeNotifierProvider(
          create: (_) => AuthProvider(),
          child: PhoneAuthPage(
            onPhoneSubmitted: (phone) {
              context.go('/auth/otp', extra: phone);
            },
          ),
        );
      },
    ),
    GoRoute(
      path: '/auth/otp',
      name: 'otp',
      builder: (context, state) {
        final phone = state.extra as String? ?? '';

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => OtpProvider()),
          ],
          child: OtpPage(
            phone: phone,
            onOTPVerified: () {
              context.go('/auth/password');
            },
          ),
        );
      },
    ),
    GoRoute(
      path: '/auth/password',
      name: 'password',
      builder: (context, state) {
        // Placeholder for password page
        return Scaffold(
          body: Center(
            child: Text('Password Page Placeholder'),
          ),
        );
      },
    ),
  ],
);

class HumoTrackerApp extends StatelessWidget {
  final GetInitialSharedTextUseCase getInitialSharedText;
  final ListenShareIntentUseCase listenShareIntent;
  final ParseSharedContentUseCase parseSharedContent;
  final SaveTransactionUseCase saveTransaction;

  const HumoTrackerApp({
    super.key,
    required this.getInitialSharedText,
    required this.listenShareIntent,
    required this.parseSharedContent,
    required this.saveTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TransactionProvider>(create: (_) => TransactionProvider()),
        ChangeNotifierProvider<KanbanProvider>(create: (_) => KanbanProvider()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        BlocProvider(
          create: (_) => ShareIntentBloc(
            getInitialSharedText: getInitialSharedText,
            listenShareIntent: listenShareIntent,
            parseSharedContent: parseSharedContent,
            saveTransaction: saveTransaction,
          )..add(const ShareIntentStarted()),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'HUMO Finance Tracker',
            theme: themeProvider.isDark ? AppTheme.dark : AppTheme.light,
            routerConfig: _router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
