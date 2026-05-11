/// Loading State Widget
/// Отображение состояния загрузки

import 'package:flutter/material.dart';

class LoadingStateWidget extends StatelessWidget {
  final String? message;
  final bool fullScreen;

  const LoadingStateWidget({
    super.key,
    this.message,
    this.fullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );

    if (fullScreen) {
      return content;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: content,
    );
  }
}
