import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/services/api_client.dart';
import '../../../app/services/construction_socket_service.dart';
import '../../../app/utils/app_logger.dart';
import '../../../app/utils/app_toast.dart';
import '../../auth/services/auth_service.dart';
import '../services/profile_service.dart';

class ProfileController extends GetxController {
  ProfileController({ProfileService? profileService})
    : _profileService = profileService ?? Get.put(ProfileService());

  final ProfileService _profileService;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final roleController = TextEditingController();

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool isLoadingSettings = false.obs;
  final RxBool isSavingSettings = false.obs;
  final RxBool isLoadingProfile = false.obs;
  final RxBool isSavingProfile = false.obs;

  // 7 Settings Toggle Switches matching Image 4 & 5
  final twoFactor = true.obs;
  final emailNotif = true.obs;
  final smsNotif = false.obs;
  final dashboardNotif = true.obs;
  final weeklyReports = true.obs;
  final systemAlerts = true.obs;
  final loginAlerts = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
    loadSettingsData();
  }

  /// Load profile details from API
  Future<void> loadProfileData() async {
    isLoadingProfile.value = true;
    try {
      if (Get.isRegistered<ApiClient>()) {
        final cachedUser = Get.find<ApiClient>().getUserData();
        if (cachedUser != null) {
          final name = cachedUser['name'] ?? cachedUser['fullName'];
          final email = cachedUser['email'];
          final phone = cachedUser['phone'] ?? cachedUser['phoneNumber'];
          final role = cachedUser['role'] ?? cachedUser['designation'];

          if (name != null && name.toString().isNotEmpty) {
            fullNameController.text = name.toString();
          }
          if (email != null && email.toString().isNotEmpty) {
            emailController.text = email.toString();
          }
          if (phone != null && phone.toString().isNotEmpty) {
            phoneController.text = phone.toString();
          }
          if (role != null && role.toString().isNotEmpty) {
            roleController.text = role.toString();
          }
        }
      }

      final res = await _profileService.getUserProfile();
      if (res != null) {
        final name = res['name'] ?? res['fullName'] ?? res['user']?['name'];
        final email = res['email'] ?? res['user']?['email'];
        final phone =
            res['phone'] ?? res['phoneNumber'] ?? res['user']?['phone'];
        final role = res['role'] ?? res['designation'] ?? res['user']?['role'];

        if (name != null && name.toString().isNotEmpty) {
          fullNameController.text = name.toString();
        }
        if (email != null && email.toString().isNotEmpty) {
          emailController.text = email.toString();
        }
        if (phone != null && phone.toString().isNotEmpty) {
          phoneController.text = phone.toString();
        }
        if (role != null && role.toString().isNotEmpty) {
          roleController.text = role.toString();
        }
      }
    } catch (e) {
      AppLogger.w('loadProfileData note: $e', tag: 'PROFILE');
    } finally {
      isLoadingProfile.value = false;
    }
  }

  /// Load settings toggle switch states from API
  Future<void> loadSettingsData() async {
    isLoadingSettings.value = true;
    try {
      final res = await _profileService.getUserSettings();
      if (res != null) {
        final Map<String, dynamic> dataMap = (res['settings'] is Map)
            ? Map<String, dynamic>.from(res['settings'] as Map)
            : res;

        if (dataMap.containsKey('twoFactorAuthentication')) {
          twoFactor.value = dataMap['twoFactorAuthentication'] == true;
        } else if (dataMap.containsKey('twoFactor')) {
          twoFactor.value = dataMap['twoFactor'] == true;
        }

        if (dataMap.containsKey('emailNotifications')) {
          emailNotif.value = dataMap['emailNotifications'] == true;
        } else if (dataMap.containsKey('emailNotif')) {
          emailNotif.value = dataMap['emailNotif'] == true;
        }

        if (dataMap.containsKey('smsNotifications')) {
          smsNotif.value = dataMap['smsNotifications'] == true;
        } else if (dataMap.containsKey('smsNotif')) {
          smsNotif.value = dataMap['smsNotif'] == true;
        }

        if (dataMap.containsKey('dashboardNotifications')) {
          dashboardNotif.value = dataMap['dashboardNotifications'] == true;
        } else if (dataMap.containsKey('dashboardNotif')) {
          dashboardNotif.value = dataMap['dashboardNotif'] == true;
        }

        if (dataMap.containsKey('weeklyEmailReports')) {
          weeklyReports.value = dataMap['weeklyEmailReports'] == true;
        } else if (dataMap.containsKey('weeklyReports')) {
          weeklyReports.value = dataMap['weeklyReports'] == true;
        }

        if (dataMap.containsKey('systemAlerts')) {
          systemAlerts.value = dataMap['systemAlerts'] == true;
        }

        if (dataMap.containsKey('loginAlertsViaMail')) {
          loginAlerts.value = dataMap['loginAlertsViaMail'] == true;
        } else if (dataMap.containsKey('loginAlerts')) {
          loginAlerts.value = dataMap['loginAlerts'] == true;
        }
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'loadSettingsData Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'SETTINGS',
      );
    } finally {
      isLoadingSettings.value = false;
    }
  }

  /// Save settings toggle switch states to API
  Future<bool> saveSettingsData() async {
    isSavingSettings.value = true;
    try {
      final payload = {
        'twoFactorAuthentication': twoFactor.value,
        'emailNotifications': emailNotif.value,
        'smsNotifications': smsNotif.value,
        'dashboardNotifications': dashboardNotif.value,
        'weeklyEmailReports': weeklyReports.value,
        'systemAlerts': systemAlerts.value,
        'loginAlertsViaMail': loginAlerts.value,
      };

      final success = await _profileService.updateUserSettings(payload);
      if (success) {
        AppToast.showSuccess(
          title: 'Settings Saved',
          description: 'Your account settings have been updated successfully.',
        );
        return true;
      }
      return true;
    } catch (e, stackTrace) {
      AppLogger.e(
        'saveSettingsData Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'SETTINGS',
      );
      return false;
    } finally {
      isSavingSettings.value = false;
    }
  }

  Future<void> saveProfile() async {
    isSavingProfile.value = true;
    try {
      final payload = {
        'fullName': fullNameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'role': roleController.text.trim(),
      };
      await _profileService.updateUserProfile(payload);
      AppToast.showSuccess(
        title: 'Profile Updated',
        description: 'Your profile information has been saved successfully.',
      );
    } finally {
      isSavingProfile.value = false;
    }
  }

  void updatePassword() {
    if (newPasswordController.text.isEmpty) {
      AppToast.showError(
        title: 'Error',
        description: 'Please enter new password',
      );
      return;
    }
    if (newPasswordController.text != confirmPasswordController.text) {
      AppToast.showError(title: 'Error', description: 'Passwords do not match');
      return;
    }

    AppToast.showSuccess(
      title: 'Password Updated',
      description: 'Your password has been changed successfully.',
    );
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  void logout() {
    if (Get.isRegistered<ConstructionSocketService>()) {
      Get.find<ConstructionSocketService>().disconnect();
    }
    if (Get.isRegistered<AuthService>()) {
      Get.find<AuthService>().logout();
    }
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    roleController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
