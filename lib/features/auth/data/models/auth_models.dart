/// Модели для аутентификации
class SendCodeResponse {
  final bool success;
  final String? message;
  final String? requestId;

  SendCodeResponse({
    required this.success,
    this.message,
    this.requestId,
  });

  factory SendCodeResponse.fromJson(Map<String, dynamic> json) {
    return SendCodeResponse(
      success: json['success'] ?? false,
      message: json['message'],
      requestId: json['request_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'request_id': requestId,
    };
  }
}

class VerifyCodeResponse {
  final bool success;
  final String? message;
  final String? sessionToken;
  final UserInfo? user;

  VerifyCodeResponse({
    required this.success,
    this.message,
    this.sessionToken,
    this.user,
  });

  factory VerifyCodeResponse.fromJson(Map<String, dynamic> json) {
    return VerifyCodeResponse(
      success: json['success'] ?? false,
      message: json['message'],
      sessionToken: json['session_token'],
      user: json['user'] != null ? UserInfo.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'session_token': sessionToken,
      'user': user?.toJson(),
    };
  }
}

class UserInfo {
  final String id;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? username;

  UserInfo({
    required this.id,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.username,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
    };
  }

  String get fullName {
    final first = firstName ?? '';
    final last = lastName ?? '';
    return '$first $last'.trim();
  }

  String get displayName {
    if (username != null && username!.isNotEmpty) return '@$username';
    if (fullName.isNotEmpty) return fullName;
    return phoneNumber;
  }
}
