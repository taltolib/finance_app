import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/share_import/presentation/bloc/share_intent_bloc.dart';
import '../features/share_import/presentation/pages/share_preview_page.dart';
import '../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../features/analytics/presentation/pages/analytics_screen.dart';
import '../features/kanban/presentation/pages/kanban_screen.dart';
import '../features/settings/presentation/pages/settings_screen.dart';
import 'package:finance_app/features/transactions/presentation/providers/transaction_provider.dart';

import '../shared/theme/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = [
    const DashboardScreen(),
    const AnalyticsScreen(),
    const KanbanScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final colors = Theme.of(context).extension<AppColors>()!;
    return BlocListener<ShareIntentBloc, ShareIntentState>(
      listener: (context, state) {
        if (state is ShareIntentReceivedState) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SharePreviewPage(
                sharedContent: state.content,
              ),
            ),
          ).then((result) {
            if (result == true && mounted) {
              context.read<TransactionProvider>().loadTransactions();
            }
          });
        }
      },
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Статистика',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Аналитика',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.view_kanban),
              label: 'Канбан',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Настройки',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          backgroundColor: Theme.of(context).cardColor,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}