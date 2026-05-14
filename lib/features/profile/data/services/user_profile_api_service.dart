import 'package:finance_app/core/api/api_service.dart';
import 'package:finance_app/core/api/api_endpoints.dart';
import '../models/user_profile_model.dart';

class UserProfileApiService {
  final ApiService _apiService = ApiService();

  Future<UserProfileModel> getProfile() async {
    final response = await _apiService.get(
      ApiEndpoints.authMe,
      needsAuth: true,
    );

    // Backend может вернуть данные в разных обёртках:
    // { "data": {...} }  /  { "user": {...} }  /  { ...напрямую... }
    final Map<String, dynamic> body;
    if (response['data'] is Map<String, dynamic>) {
      body = response['data'] as Map<String, dynamic>;
    } else if (response['user'] is Map<String, dynamic>) {
      body = response['user'] as Map<String, dynamic>;
    } else {
      body = response;
    }

    return UserProfileModel.fromJson(body);
  }
}