class UserProfileModel {
  final String id;
  final String? name;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? photoBase64;

  UserProfileModel({
    required this.id,
    this.name,
    this.firstName,
    this.lastName,
    this.username,
    this.photoBase64,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString() ?? '',
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
    if (username != null && username!.isNotEmpty) {
      return '@$username';
    }
    if (fullName.isNotEmpty) {
      return fullName;
    }
    return id;
  }
}
