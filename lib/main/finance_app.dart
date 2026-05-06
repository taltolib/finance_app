
import 'package:finance_app/app/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/transactions/presentation/providers/transaction_provider.dart';
import '../shared/theme/app_theme.dart';


class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionProvider()..loadTransactions(),
      child: MaterialApp(
        title: 'HUMO Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home:  const MainScreen(),
      ),
    );
  }
}
