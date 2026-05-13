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

  void clear() {
    _user = null;
    _error = null;
    notifyListeners();
  }
}
