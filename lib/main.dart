import 'package:finance_app/features/auth/presentation/providers/otp_provider.dart';
import 'package:finance_app/shared/database/database_helper.dart' show DatabaseHelper;
import 'package:finance_app/core/state/providers/theme_provider.dart';
import 'package:finance_app/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:finance_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:finance_app/features/info/presentation/providers/humo_connection_provider.dart';
import 'package:finance_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:finance_app/features/analytics/presentation/providers/analytics_provider.dart';
import 'package:finance_app/features/profile/presentation/providers/user_profile_provider.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/share_import/presentation/bloc/share_intent_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'features/kanban/presentation/providers/kanban_provider.dart';
import 'features/share_import/domain/usecases/share_intent_usecases.dart';
import 'features/share_import/data/repositories/share_intent_repository_impl.dart';
import 'features/share_import/data/datasources/share_intent_service.dart';

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
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()..restoreSession()),
        ChangeNotifierProvider<HumoConnectionProvider>(create: (_) => HumoConnectionProvider()),
        ChangeNotifierProvider<DashboardProvider>(create: (_) => DashboardProvider()),
        ChangeNotifierProvider<AnalyticsProvider>(create: (_) => AnalyticsProvider()..restorePeriodAndLoad()),
        ChangeNotifierProvider<UserProfileProvider>(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider<TransactionProvider>(create: (_) => TransactionProvider()),
        ChangeNotifierProvider<KanbanProvider>(create: (_) => KanbanProvider()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<OtpProvider>(create: (_) => OtpProvider()),
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
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
