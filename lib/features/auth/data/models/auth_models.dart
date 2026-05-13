library;

class SendCodeResponse {
  final bool success;
  final String? message;
  final String? phoneCodeHash;

  const SendCodeResponse({
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
}

class VerifyCodeResponse {
  final bool success;
  final String? message;
  final String? sessionToken;
  final bool passwordRequired;
  final UserInfo? user;

  const VerifyCodeResponse({
    required this.success,
    this.message,
    this.sessionToken,
    this.passwordRequired = false,
    this.user,
  });

  factory VerifyCodeResponse.fromJson(Map<String, dynamic> json) {
    return VerifyCodeResponse(
      success: json['success'] == true,
      message: json['message']?.toString(),
      sessionToken: json['session_token']?.toString(),
      passwordRequired: json['requires_password'] == true ||
          json['password_required'] == true ||
          (json['message']?.toString().toLowerCase().contains('пароль') ?? false),
      user: json['user'] is Map<String, dynamic>
          ? UserInfo.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
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

  const UserInfo({
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phoneNumber,
        'name': name,
        'first_name': firstName,
        'last_name': lastName,
        'username': username,
        'photo_base64': photoBase64,
      };

  String get fullName {
    if (name != null && name!.trim().isNotEmpty) return name!.trim();
    return '${firstName ?? ''} ${lastName ?? ''}'.trim();
  }

  String get displayName {
    if (username != null && username!.isNotEmpty) return '@$username';
    if (fullName.isNotEmpty) return fullName;
    return phoneNumber;
  }
}
