import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/kanban_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';
import 'presentation/bloc/share_intent_bloc.dart';
import 'domain/usecases/share_intent_usecases.dart';
import 'data/repositories/share_intent_repository_impl.dart';
import 'data/datasources/share_intent_service.dart';
import 'services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru_RU', '');
  await ShareIntentService.initialize();

  // Инициализация зависимостей для BLoC
  final shareIntentService = ShareIntentService();
  final databaseHelper = DatabaseHelper.instance;
  final shareIntentRepository = ShareIntentRepositoryImpl(
    shareIntentService: shareIntentService,
    databaseHelper: databaseHelper,
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
            theme: themeProvider.isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
            home: const MainScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}