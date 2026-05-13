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

    final body = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : response;
    return UserProfileModel.fromJson(body);
  }
}
