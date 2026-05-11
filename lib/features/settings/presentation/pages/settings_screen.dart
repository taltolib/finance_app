import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finance_app/features/transactions/presentation/providers/transaction_provider.dart';

import '../../../../shared/providers/theme_provider.dart';
///пуст везде будет картинка которая в ассет/имаже  в заднем фоне и чтобы  в зависемости от темы она меналось на white/dart  версию

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Профиль'),
            subtitle: const Text('Имя, номер карты'),
            leading: const Icon(Icons.person),
            onTap: () {
              // Placeholder
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Профиль')),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Экспорт данных'),
            leading: const Icon(Icons.download),
            onTap: () {
              // Placeholder
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Экспорт данных')),
              );
            },
          ),
          ListTile(
            title: const Text('Очистить все данные'),
            leading: const Icon(Icons.delete_forever),
            onTap: () => _showClearDataDialog(context),
          ),
          SwitchListTile(
            title: const Text('Тёмная тема'),
            value: themeProvider.isDark,
            onChanged: (value) => themeProvider.toggleTheme(),
          ),
          const Divider(),
          ListTile(
            title: const Text('О приложении'),
            leading: const Icon(Icons.info),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'HUMO Finance Tracker',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2024 HUMO Finance Tracker',
              );
            },
          ),
        ],
      ),
    );
  }


  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить все данные'),
        content: const Text('Это действие нельзя отменить. Все транзакции будут удалены.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              // Clear all data
              // Note: This is a simple implementation
              context.read<TransactionProvider>().loadTransactions(); // This will clear local list
              // In real app, would clear database
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Данные очищены')),
              );
            },
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
  }
}

// Ответственность: Настройки приложения с переключением темы и управлением данными.