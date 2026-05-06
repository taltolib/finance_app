import 'package:finance_app/services/database_helper.dart' show DatabaseHelper;

import 'features/share_import/presentation/bloc/share_intent_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'shared/providers/theme_provider.dart';
import 'features/transactions/presentation/providers/transaction_provider.dart';
import 'features/kanban/presentation/providers/kanban_provider.dart';
import 'app/app_shell.dart';
import 'shared/theme/app_theme.dart';
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
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => KanbanProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
          return MaterialApp(
            title: 'HUMO Finance Tracker',
            theme: themeProvider.isDark ? AppTheme.dark : AppTheme.light,
            home: const MainScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
