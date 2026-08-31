import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import '../utils/app_toast.dart';

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
      case 'Tasks':
        Get.offNamed(AppRoutes.tasks);
        break;
      case 'Material Request':
        Get.offNamed(AppRoutes.materialRequests);
        break;
      case 'Label Printing':
        Get.offNamed(AppRoutes.labelPrinting);
        break;
      case 'Delivery Tracking':
        Get.offNamed(AppRoutes.deliveryTracking);
        break;
      case 'Bundle Scan':
        Get.offNamed(AppRoutes.bundleScan);
        break;
      case 'Packing List':
        Get.offNamed(AppRoutes.packingList);
        break;
      case 'Dispatch Verification':
        Get.offNamed(AppRoutes.dispatchVerification);
        break;
      case 'Chat / Messaging':
        Get.offNamed(AppRoutes.chat);
        break;

      default:
        AppToast.showInfo(
          title: title,
          description: 'This screen will be available soon.',
        );
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
