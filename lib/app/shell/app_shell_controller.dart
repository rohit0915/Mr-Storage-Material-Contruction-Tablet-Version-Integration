import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';

class AppShellController extends GetxController {
  final searchController = TextEditingController();
  final selectedMenu = 'Dashboard'.obs;

  void selectMenu(String title) {
    selectedMenu.value = title;

    switch (title) {
      case 'Dashboard':
        Get.offNamed(AppRoutes.dashboard);
        break;
      case 'Project & Calendar':
        Get.offNamed(AppRoutes.projectCalendar);
        break;
      case 'Drawings & Attachments':
        Get.offNamed(AppRoutes.drawings);
        break;
      default:
        Get.snackbar(
          title,
          'This screen will be available soon.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
