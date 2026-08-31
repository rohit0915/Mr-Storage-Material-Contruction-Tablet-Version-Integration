import 'package:get/get.dart';

import '../../../app/constants/api_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/utils/app_logger.dart';

class AuthService extends GetxService {
  AuthService({ApiClient? apiClient})
      : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  static AuthService get to => Get.find<AuthService>();

  bool get isLoggedIn => _apiClient.token != null && _apiClient.token!.isNotEmpty;

  String get userName {
    final user = _apiClient.getUserData();
    return user?['name']?.toString() ?? 'Construction User';
  }

  String get userEmail {
    final user = _apiClient.getUserData();
    return user?['email']?.toString() ?? 'construction1@example.com';
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();
    AppLogger.i('Attempting login for email: $cleanEmail', tag: 'AUTH');

    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        body: {
          'email': cleanEmail,
          'password': cleanPassword,
        },
      );

      AppLogger.i('Login API Raw Response: $response', tag: 'AUTH');

      if (response is Map) {
        final data = response['data'] ?? response;
        if (data is Map) {
          final token = data['accessToken'] ?? data['token'] ?? response['accessToken'] ?? response['token'];
          final refreshToken = data['refreshToken'] ?? data['refresh_token'] ?? response['refreshToken'];
          if (token != null && token.toString().isNotEmpty) {
            await _apiClient.saveToken(token.toString());
            if (refreshToken != null && refreshToken.toString().isNotEmpty) {
              await _apiClient.saveRefreshToken(refreshToken.toString());
            }

            if (data['user'] is Map) {
              await _apiClient.saveUserData(Map<String, dynamic>.from(data['user'] as Map));
            } else if (response['user'] is Map) {
              await _apiClient.saveUserData(Map<String, dynamic>.from(response['user'] as Map));
            }
            AppLogger.i('Login successful for $cleanEmail', tag: 'AUTH');
            return null;
          }
        }
      }

      AppLogger.w('Login response missing token: $response', tag: 'AUTH');
      return 'Invalid email or password';
    } on ApiException catch (e) {
      AppLogger.e('Login ApiException: ${e.message} [Code: ${e.statusCode}]', error: e, tag: 'AUTH');
      return e.message;
    } catch (e, stackTrace) {
      AppLogger.e('Login General Exception', error: e, stackTrace: stackTrace, tag: 'AUTH');
      return 'Network connection error. Please check your internet connection.';
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } catch (e) {
      AppLogger.e('Logout API error', error: e, tag: 'AUTH');
    } finally {
      await _apiClient.clearAuthData();
    }
  }
}

