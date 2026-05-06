
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/provider/transaction_provider.dart';
import '../core/theme/app_theme.dart';
import '../features/home/home_page.dart';

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
        home:  HomeScreen(),
      ),
    );
  }
}
