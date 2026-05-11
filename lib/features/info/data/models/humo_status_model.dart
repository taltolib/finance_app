/// HUMO Status Models

class HumoCheckResponse {
  final bool success;
  final bool authorized;
  final bool hasBot;
  final bool hasMessages;
  final BotInfo? bot;
  final HumoStatus? humo;

  HumoCheckResponse({
    required this.success,
    required this.authorized,
    required this.hasBot,
    required this.hasMessages,
    this.bot,
    this.humo,
  });

  factory HumoCheckResponse.fromJson(Map<String, dynamic> json) {
    return HumoCheckResponse(
      success: json['success'] ?? false,
      authorized: json['authorized'] ?? false,
      hasBot: json['has_bot'] ?? false,
      hasMessages: json['has_messages'] ?? false,
      bot: json['bot'] != null ? BotInfo.fromJson(json['bot']) : null,
      humo: json['humo'] != null ? HumoStatus.fromJson(json['humo']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'authorized': authorized,
      'has_bot': hasBot,
      'has_messages': hasMessages,
      'bot': bot?.toJson(),
      'humo': humo?.toJson(),
    };
  }

  /// Проверить, успешно ли подключен HUMO
  bool get isHumoConnected {
    return authorized &&
        (humo?.isCardConnected ?? false) &&
        (humo?.canReadTransactions ?? false);
  }
}

class BotInfo {
  final int id;
  final String username;
  final String title;

  BotInfo({
    required this.id,
    required this.username,
    required this.title,
  });

  factory BotInfo.fromJson(Map<String, dynamic> json) {
    return BotInfo(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      title: json['title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'title': title,
    };
  }
}

class HumoStatus {
  final bool hasBotStarted;
  final bool isHumoRegistered;
  final bool isRegistered;
  final bool isCardConnected;
  final bool hasHumoAccountForPhone;
  final bool canReadTransactions;
  final String status;
  final String reason;
  final List<String> matchedSignals;

  HumoStatus({
    required this.hasBotStarted,
    required this.isHumoRegistered,
    required this.isRegistered,
    required this.isCardConnected,
    required this.hasHumoAccountForPhone,
    required this.canReadTransactions,
    required this.status,
    required this.reason,
    required this.matchedSignals,
  });

  factory HumoStatus.fromJson(Map<String, dynamic> json) {
    return HumoStatus(
      hasBotStarted: json['has_bot_started'] ?? false,
      isHumoRegistered: json['is_humo_registered'] ?? false,
      isRegistered: json['is_registered'] ?? false,
      isCardConnected: json['is_card_connected'] ?? false,
      hasHumoAccountForPhone: json['has_humo_account_for_phone'] ?? false,
      canReadTransactions: json['can_read_transactions'] ?? false,
      status: json['status'] ?? '',
      reason: json['reason'] ?? '',
      matchedSignals: List<String>.from(json['matched_signals'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_bot_started': hasBotStarted,
      'is_humo_registered': isHumoRegistered,
      'is_registered': isRegistered,
      'is_card_connected': isCardConnected,
      'has_humo_account_for_phone': hasHumoAccountForPhone,
      'can_read_transactions': canReadTransactions,
      'status': status,
      'reason': reason,
      'matched_signals': matchedSignals,
    };
  }

  /// Получить статус на русском
  String getStatusText() {
    switch (status) {
      case 'card_connected':
        return 'Карта подключена';
      case 'card_not_connected':
        return 'Карта не подключена';
      case 'bot_not_found':
        return 'Бот не найден';
      case 'no_messages':
        return 'Нет сообщений от бота';
      default:
        return reason.isNotEmpty ? reason : 'Неизвестный статус';
    }
  }
}
