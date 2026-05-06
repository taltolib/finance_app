import 'package:finance_app/features/share_import/domain/entities/transaction.dart' hide TransactionType;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../shared/errors/failure.dart';
import '../../../../shared/theme/app_theme.dart';
import '../bloc/share_intent_bloc.dart';

class SharePreviewPage extends StatelessWidget {
  final String sharedContent;

  const SharePreviewPage({
    super.key,
    required this.sharedContent,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShareIntentBloc, ShareIntentState>(
      listener: (context, state) {
        if (state is ShareIntentSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Транзакция сохранена!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            // ignore: use_build_context_synchronously
            Navigator.pop(context, true); // Возврат с флагом успеха
          });
        } else if (state is ShareIntentFailure) {
          _showErrorDialog(context, state.failure);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Подтверждение транзакции'),
          centerTitle: true,
          elevation: 0,
        ),
        body: BlocBuilder<ShareIntentBloc, ShareIntentState>(
          builder: (context, state) {
            // Экран загрузки при парсинге
            if (state is ShareIntentLoading || state is ShareIntentSaving) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Ошибка при парсинге
            if (state is ShareIntentFailure) {
              return _buildErrorView(context, state.failure);
            }

            // Показ полученного текста
            if (state is ShareIntentReceivedState) {
              return _buildReceivedView(context, state.content);
            }

            // Показ парсед транзакции с preview
            if (state is ShareIntentParsedState) {
              return _buildParsedView(context, state.transaction);
            }

            return const Center(
              child: Text('Неизвестное состояние'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReceivedView(BuildContext context, String content) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Полученный текст:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              content,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<ShareIntentBloc>().add(
                      ShareIntentParseRequested(content),
                    );
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('Распознать транзакцию'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded),
              label: const Text('Отменить'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParsedView(BuildContext context, Transaction transaction) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final isIncome = transaction.type.name == 'income';
    final color = isIncome ? colors.income : colors.expense;
    final bgColor = isIncome ? colors.incomeLight : colors.expenseLight;
    final sign = isIncome ? '+' : '-';
    final f = NumberFormat('#,##0.00', 'ru_RU');
    final timeF = DateFormat('HH:mm');
    final dateF = DateFormat('dd.MM.yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Результат распознавания:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          // Карточка с основной информацией
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      transaction.place,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$sign${f.format(transaction.amount)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      isIncome
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: color,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isIncome ? 'Пополнение' : 'Списание',
                      style: TextStyle(fontSize: 12, color: color),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Детали
          _buildDetailRow('Карта', transaction.cardNumber),
          const SizedBox(height: 12),
          _buildDetailRow('Дата', dateF.format(transaction.dateTime)),
          const SizedBox(height: 12),
          _buildDetailRow('Время', timeF.format(transaction.dateTime)),
          const SizedBox(height: 12),
          _buildDetailRow('Баланс после', '${f.format(transaction.balance)} UZS'),
          const SizedBox(height: 32),
          // Кнопки действия
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<ShareIntentBloc>().add(
                      ShareIntentSaveRequested(transaction),
                    );
              },
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Сохранить транзакцию'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<ShareIntentBloc>().add(
                      const ShareIntentCleared(),
                    );
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close_rounded),
              label: const Text('Отменить'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, Failure failure) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Ошибка',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              failure.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded),
              label: const Text('Закрыть'),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, Failure failure) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(failure.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ОК'),
          ),
        ],
      ),
    );
  }
}

// Ответственность: Предварительный просмотр и сохранение транзакций из общего контента.
