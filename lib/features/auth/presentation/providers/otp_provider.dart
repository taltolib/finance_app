import 'package:flutter/material.dart';

class OtpProvider extends ChangeNotifier {
  final List<TextEditingController> controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final List<FocusNode> focusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );

  String get code {
    return controllers.map((controller) => controller.text).join();
  }

  bool get isComplete {
    return code.length == 6 && controllers.every((c) => c.text.isNotEmpty);
  }

  void onChanged(int index, String value) {
    if (value.length > 1) {
      final lastChar = value.substring(value.length - 1);
      controllers[index].text = lastChar;
      controllers[index].selection = TextSelection.fromPosition(
        TextPosition(offset: controllers[index].text.length),
      );
    }

    if (value.isNotEmpty && index < focusNodes.length - 1) {
      focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }

    notifyListeners();
  }

  void clear() {
    for (final controller in controllers) {
      controller.clear();
    }

    focusNodes.first.requestFocus();
    notifyListeners();
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }

    for (final focusNode in focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }
}
