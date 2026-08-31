import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/utils/app_toast.dart';

class ProfileController extends GetxController {
  final fullNameController = TextEditingController(text: 'John Anderson');
  final emailController = TextEditingController(text: 'john@gmail.com');
  final phoneController = TextEditingController(text: '+1234567890');
  final roleController = TextEditingController(text: 'Construction Manager');

  final currentPasswordController = TextEditingController(text: '••••••••••••');
  final newPasswordController = TextEditingController(text: '••••••••••••');
  final confirmPasswordController = TextEditingController(text: '••••••••••••');

  // 7 Settings Toggle Switches matching Image 4
  final twoFactor = true.obs;
  final emailNotif = true.obs;
  final smsNotif = true.obs;
  final dashboardNotif = true.obs;
  final weeklyReports = true.obs;
  final systemAlerts = true.obs;
  final loginAlerts = true.obs;

  void saveProfile() {
    AppToast.showSuccess(
      title: 'Profile Updated',
      description: 'Your profile information has been saved successfully.',
    );
  }

  void updatePassword() {
    AppToast.showSuccess(
      title: 'Password Updated',
      description: 'Your password has been changed successfully.',
    );
  }

  void logout() {
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
