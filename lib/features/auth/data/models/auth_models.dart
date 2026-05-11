/// Модели для аутентификации

class SendCodeResponse {
  final bool success;
  final String? message;
  final String? phoneCodeHash;

  SendCodeResponse({
    required this.success,
    this.message,
    this.phoneCodeHash,
  });

  factory SendCodeResponse.fromJson(Map<String, dynamic> json) {
    return SendCodeResponse(
      success: json['success'] == true,
      message: json['message']?.toString(),
      phoneCodeHash: json['phone_code_hash']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'phone_code_hash': phoneCodeHash,
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
      success: json['success'] == true,
      message: json['message']?.toString(),
      sessionToken: json['session_token']?.toString(),
      user: json['user'] is Map<String, dynamic>
          ? UserInfo.fromJson(json['user'] as Map<String, dynamic>)
          : null,
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
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? photoBase64;

  UserInfo({
    required this.id,
    required this.phoneNumber,
    this.name,
    this.firstName,
    this.lastName,
    this.username,
    this.photoBase64,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id']?.toString() ?? '',
      phoneNumber: (json['phone'] ?? json['phone_number'] ?? '').toString(),
      name: json['name']?.toString(),
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      username: json['username']?.toString(),
      photoBase64: json['photo_base64']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phoneNumber,
      'name': name,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'photo_base64': photoBase64,
    };
  }

  String get fullName {
    if (name != null && name!.trim().isNotEmpty) {
      return name!.trim();
    }

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
