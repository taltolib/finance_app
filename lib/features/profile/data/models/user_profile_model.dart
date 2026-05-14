class UserProfileModel {
  final String id;
  final String? phone;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? photoBase64;

  UserProfileModel({
    required this.id,
    this.phone,
    this.name,
    this.firstName,
    this.lastName,
    this.username,
    this.photoBase64,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      // Поддерживаем разные ключи телефона от backend
      phone: (json['phone'] ?? json['phone_number'])?.toString(),
      name: json['name']?.toString(),
      firstName: json['first_name']?.toString() ?? json['firstName']?.toString(),
      lastName: json['last_name']?.toString() ?? json['lastName']?.toString(),
      username: json['username']?.toString(),
      // Поддерживаем разные ключи фото от backend
      photoBase64: (json['photo_base64'] ??
          json['photo'] ??
          json['photo_url'] ??
          json['avatar'] ??
          json['avatar_url'])
          ?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'photo_base64': photoBase64,
    };
  }

  /// Полное имя: name → firstName + lastName → username → phone → id
  String get fullName {
    if (name != null && name!.trim().isNotEmpty) {
      return name!.trim();
    }
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';
    final combined = [first, last].where((s) => s.isNotEmpty).join(' ');
    if (combined.isNotEmpty) return combined;
    return '';
  }

  /// Отображаемое имя с fallback на телефон
  String get displayName {
    if (fullName.isNotEmpty) return fullName;
    if (username != null && username!.trim().isNotEmpty) return username!.trim();
    if (phone != null && phone!.trim().isNotEmpty) return phone!.trim();
    return 'Пользователь';
  }

  /// Username с @ или телефон
  String get displayUsername {
    if (username != null && username!.trim().isNotEmpty) {
      return '@${username!.trim()}';
    }
    if (phone != null && phone!.trim().isNotEmpty) return phone!.trim();
    return '';
  }
}