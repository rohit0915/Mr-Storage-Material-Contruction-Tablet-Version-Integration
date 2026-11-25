import 'package:get/get.dart';

import '../../../app/constants/api_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/utils/app_logger.dart';

class AuthService extends GetxService {
  AuthService({ApiClient? apiClient})
    : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  static AuthService get to => Get.find<AuthService>();

  bool get isLoggedIn =>
      _apiClient.token != null && _apiClient.token!.isNotEmpty;

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
    final cleanPassword = password
        .replaceAll(RegExp(r'[\u200B-\u200D\uFEFF\u2028\u2029]'), '')
        .trim();
    AppLogger.i('Attempting login for email: $cleanEmail', tag: 'AUTH');

    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        body: {'email': cleanEmail, 'password': cleanPassword},
      );

      if (response is Map) {
        final data = response['data'] ?? response;
        if (data is Map) {
          final userMap = (data['user'] is Map)
              ? (data['user'] as Map)
              : (response['user'] is Map ? (response['user'] as Map) : null);
          final userRole =
              (data['role'] ?? userMap?['role'])?.toString().toLowerCase() ?? '';

          // Strict Role-Based Check: Reject non-construction accounts (plant, customer, etc.)
          if (userRole == 'plant' ||
              userRole == 'customer' ||
              (!userRole.contains('construction') && userRole != 'admin')) {
            AppLogger.w(
              'Login rejected for non-construction role: $userRole',
              tag: 'AUTH',
            );
            return 'Access denied. Only Construction accounts can sign in to this app.';
          }

          final token =
              data['accessToken'] ??
              data['token'] ??
              response['accessToken'] ??
              response['token'];
          final refreshToken =
              data['refreshToken'] ??
              data['refresh_token'] ??
              response['refreshToken'];
          if (token != null && token.toString().isNotEmpty) {
            await _apiClient.saveToken(token.toString());
            if (refreshToken != null && refreshToken.toString().isNotEmpty) {
              await _apiClient.saveRefreshToken(refreshToken.toString());
            }

            if (userMap != null) {
              await _apiClient.saveUserData(
                Map<String, dynamic>.from(userMap),
              );
            }
            AppLogger.i('Login successful for $cleanEmail ($userRole)', tag: 'AUTH');
            return null;
          }
        }
      }

      AppLogger.w('Login response missing token', tag: 'AUTH');
      return 'Invalid email or password';
    } on ApiException catch (e) {
      AppLogger.e(
        'Login ApiException: ${e.message} [Code: ${e.statusCode}]',
        error: e,
        tag: 'AUTH',
      );
      return e.message;
    } catch (e, stackTrace) {
      AppLogger.e(
        'Login General Exception',
        error: e,
        stackTrace: stackTrace,
        tag: 'AUTH',
      );
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

  /// Send forgot password request (sends 6-digit OTP to user's email)
  Future<String?> forgotPassword(String email) async {
    final cleanEmail = email.trim();
    AppLogger.i('Sending forgot password request for: $cleanEmail', tag: 'AUTH');
    try {
      final response = await _apiClient.post(
        ApiConstants.forgotPassword,
        body: {'email': cleanEmail},
      );
      if (response is Map) {
        if (response['success'] == true) {
          return null;
        }
        return response['message']?.toString() ?? 'Failed to send OTP';
      }
      return null;
    } on ApiException catch (e) {
      AppLogger.e('forgotPassword ApiException: ${e.message}', tag: 'AUTH');
      return e.message;
    } catch (e) {
      return 'Network connection error. Please try again.';
    }
  }

  /// Verify 6-digit OTP sent to email; returns resetToken on success
  Future<({String? resetToken, String? error})> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final cleanEmail = email.trim();
    final cleanOtp = otp.trim();
    AppLogger.i('Verifying OTP for: $cleanEmail', tag: 'AUTH');
    try {
      final response = await _apiClient.post(
        ApiConstants.verifyOtp,
        body: {'email': cleanEmail, 'otp': cleanOtp},
      );
      if (response is Map) {
        if (response['success'] == true) {
          final data = response['data'] ?? response;
          final token =
              data['resetToken'] ?? data['token'] ?? data['reset_token'];
          return (resetToken: token?.toString() ?? '', error: null);
        }
        return (
          resetToken: null,
          error: response['message']?.toString() ?? 'Invalid OTP',
        );
      }
      return (resetToken: null, error: 'Failed to verify OTP');
    } on ApiException catch (e) {
      AppLogger.e('verifyOtp ApiException: ${e.message}', tag: 'AUTH');
      return (resetToken: null, error: e.message);
    } catch (e) {
      return (resetToken: null, error: 'Network error. Please try again.');
    }
  }

  /// Reset password using resetToken and newPassword
  Future<String?> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    AppLogger.i('Submitting reset password request', tag: 'AUTH');
    try {
      final response = await _apiClient.post(
        ApiConstants.resetPassword,
        body: {
          'resetToken': resetToken.trim(),
          'newPassword': newPassword,
        },
      );
      if (response is Map) {
        if (response['success'] == true) {
          return null;
        }
        return response['message']?.toString() ?? 'Failed to reset password';
      }
      return null;
    } on ApiException catch (e) {
      AppLogger.e('resetPassword ApiException: ${e.message}', tag: 'AUTH');
      return e.message;
    } catch (e) {
      return 'Network error. Please try again.';
    }
  }

  /// Change password for logged-in user
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    AppLogger.i('Changing password for authenticated user', tag: 'AUTH');
    try {
      final response = await _apiClient.put(
        ApiConstants.changePassword,
        body: {
          'currentPassword': currentPassword,
          'oldPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      if (response is Map) {
        if (response['success'] == true) {
          return null;
        }
        return response['message']?.toString() ?? 'Failed to change password';
      }
      return null;
    } on ApiException catch (e) {
      AppLogger.e('changePassword ApiException: ${e.message}', tag: 'AUTH');
      return e.message;
    } catch (e) {
      return 'Network error. Please try again.';
    }
  }
}
