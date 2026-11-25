import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import '../utils/app_toast.dart';
import '../../features/dispatch_verification/controllers/dispatch_verification_controller.dart';

class AppShellController extends GetxController {
  TextEditingController _searchController = TextEditingController();
  TextEditingController get searchController {
    try {
      final _ = _searchController.text;
    } catch (_) {
      _searchController = TextEditingController();
    }
    return _searchController;
  }
  final selectedMenu = 'Dashboard'.obs;

  void selectMenu(String title) {
    selectedMenu.value = title;

    switch (title) {
      case 'Dashboard':
        Get.offAllNamed(AppRoutes.dashboard);
        break;
      case 'Project & Calendar':
        Get.offAllNamed(AppRoutes.projectCalendar);
        break;
      case 'Drawings & Attachments':
        Get.offAllNamed(AppRoutes.drawings);
        break;
      case 'Tasks':
        Get.offAllNamed(AppRoutes.tasks);
        break;
      case 'Daily Work Logs':
        Get.offAllNamed(AppRoutes.dailyWorkLogs);
        break;
      case 'Material Request':
        Get.offAllNamed(AppRoutes.materialRequests);
        break;
      case 'Label Printing':
        Get.offAllNamed(AppRoutes.labelPrinting);
        break;
      case 'Delivery Tracking':
        Get.offAllNamed(AppRoutes.deliveryTracking);
        break;
      case 'Bundle Scan':
        Get.offAllNamed(AppRoutes.bundleScan);
        break;
      case 'Packing List':
        Get.offAllNamed(AppRoutes.packingList);
        break;
      case 'Dispatch Verification':
        if (Get.isRegistered<DispatchVerificationController>()) {
          Get.find<DispatchVerificationController>().resetToStep1();
        }
        Get.offAllNamed(AppRoutes.dispatchVerification);
        break;
      case 'Communication':
      case 'Chat / Messaging':
        Get.offAllNamed(AppRoutes.chat);
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
    super.onClose();
  }
}
