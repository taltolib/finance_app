import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'dashboard_screen.dart';
import 'analytics_screen.dart';
import 'kanban_screen.dart';
import 'settings_screen.dart';
import '../providers/transaction_provider.dart';
import '../presentation/bloc/share_intent_bloc.dart';
import '../presentation/pages/share_preview_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    DashboardScreen(),
    AnalyticsScreen(),
    KanbanScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShareIntentBloc, ShareIntentState>(
      listener: (context, state) {
        // Если получили данные Share Intent, открыть preview страницу
        if (state is ShareIntentReceivedState) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SharePreviewPage(
                sharedContent: state.content,
              ),
            ),
          ).then((result) {
            if (result == true) {
              // Транзакция сохранена успешно, обновить Provider список
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
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          backgroundColor: Theme.of(context).cardColor,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}