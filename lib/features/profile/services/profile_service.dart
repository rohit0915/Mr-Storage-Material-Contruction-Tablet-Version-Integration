import 'package:get/get.dart';
import '../../../app/constants/api_constants.dart';
import '../../../app/services/api_client.dart';
import '../../../app/utils/app_logger.dart';

class ProfileService extends GetxService {
  ProfileService({ApiClient? apiClient})
    : _apiClient = apiClient ?? Get.find<ApiClient>();

  final ApiClient _apiClient;

  /// Fetch user notification and account settings from API
  Future<Map<String, dynamic>?> getUserSettings() async {
    try {
      final response = await _apiClient.get(ApiConstants.userSettings);
      AppLogger.i('Get User Settings Response: $response', tag: 'SETTINGS');
      if (response is Map) {
        if (response['data'] is Map) {
          return Map<String, dynamic>.from(response['data'] as Map);
        }
        return Map<String, dynamic>.from(response);
      }
      return null;
    } catch (e) {
      AppLogger.w(
        'getUserSettings note (optional endpoint): $e',
        tag: 'SETTINGS',
      );
      return null;
    }
  }

  /// Update user notification and account settings on API
  Future<bool> updateUserSettings(Map<String, dynamic> settingsData) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.userSettings,
        body: settingsData,
      );
      AppLogger.i('Update User Settings Response: $response', tag: 'SETTINGS');
      return response is Map &&
          (response['success'] == true || response.containsKey('data'));
    } catch (e) {
      AppLogger.w('updateUserSettings note: $e', tag: 'SETTINGS');
      return false;
    }
  }

  /// Fetch user profile details from API
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.userProfile);
      AppLogger.i('Get User Profile Response: $response', tag: 'PROFILE');
      if (response is Map) {
        if (response['data'] is Map) {
          return Map<String, dynamic>.from(response['data'] as Map);
        }
        return Map<String, dynamic>.from(response);
      }
      return null;
    } catch (e) {
      AppLogger.w(
        'getUserProfile note (optional endpoint): $e',
        tag: 'PROFILE',
      );
      return null;
    }
  }

  /// Update user profile details on API
  Future<bool> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.userProfile,
        body: profileData,
      );
      AppLogger.i('Update User Profile Response: $response', tag: 'PROFILE');
      return true;
    } catch (e, stackTrace) {
      AppLogger.e(
        'updateUserProfile Exception',
        error: e,
        stackTrace: stackTrace,
        tag: 'PROFILE',
      );
      return false;
    }
  }
}
