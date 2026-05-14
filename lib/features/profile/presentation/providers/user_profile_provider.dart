import 'package:flutter/material.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/services/user_profile_api_service.dart';

class UserProfileProvider extends ChangeNotifier {
  final UserProfileApiService _apiService = UserProfileApiService();

  bool _isLoading = false;
  UserProfileModel? _user;
  String? _error;

  bool get isLoading => _isLoading;
  UserProfileModel? get user => _user;
  String? get error => _error;

  /// Загрузить профиль с backend /auth/me
  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _apiService.getProfile();
    } catch (e) {
      _error = 'Ошибка загрузки профиля: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Обновить профиль из данных UserInfo, полученных при авторизации (verifyCode).
  /// Используется как мгновенный pre-fill до загрузки /auth/me.
  void updateFromAuthUser({
    required String id,
    String? phone,
    String? name,
    String? firstName,
    String? lastName,
    String? username,
    String? photoBase64,
  }) {
    _user = UserProfileModel(
      id: id,
      phone: phone,
      name: name,
      firstName: firstName,
      lastName: lastName,
      username: username,
      photoBase64: photoBase64,
    );
    notifyListeners();
  }

  /// Очистить профиль при logout
  void clear() {
    _user = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}