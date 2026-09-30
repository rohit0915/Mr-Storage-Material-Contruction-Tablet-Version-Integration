import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

class AppToast {
  AppToast._();

  static void _safeShow(VoidCallback action) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.context != null) {
        action();
      }
    });
  }

  static void showSuccess({
    required String title,
    String? description,
    Duration duration = const Duration(seconds: 4),
  }) {
    _safeShow(() {
      toastification.show(
        context: Get.context,
        type: ToastificationType.success,
        style: ToastificationStyle.flatColored,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        description: description != null ? Text(description) : null,
        alignment: Alignment.bottomRight,
        autoCloseDuration: duration,
        borderRadius: BorderRadius.circular(10),
        boxShadow: highModeShadow,
        showProgressBar: true,
      );
    });
  }

  static void showError({
    required String title,
    String? description,
    Duration duration = const Duration(seconds: 4),
  }) {
    _safeShow(() {
      toastification.show(
        context: Get.context,
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        description: description != null ? Text(description) : null,
        alignment: Alignment.bottomRight,
        autoCloseDuration: duration,
        borderRadius: BorderRadius.circular(10),
        boxShadow: highModeShadow,
        showProgressBar: true,
      );
    });
  }

  static void showInfo({
    required String title,
    String? description,
    Duration duration = const Duration(seconds: 4),
  }) {
    _safeShow(() {
      toastification.show(
        context: Get.context,
        type: ToastificationType.info,
        style: ToastificationStyle.flatColored,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        description: description != null ? Text(description) : null,
        alignment: Alignment.bottomRight,
        autoCloseDuration: duration,
        borderRadius: BorderRadius.circular(10),
        boxShadow: highModeShadow,
        showProgressBar: true,
      );
    });
  }

  static void showWarning({
    required String title,
    String? description,
    Duration duration = const Duration(seconds: 4),
  }) {
    _safeShow(() {
      toastification.show(
        context: Get.context,
        type: ToastificationType.warning,
        style: ToastificationStyle.flatColored,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        description: description != null ? Text(description) : null,
        alignment: Alignment.bottomRight,
        autoCloseDuration: duration,
        borderRadius: BorderRadius.circular(10),
        boxShadow: highModeShadow,
        showProgressBar: true,
      );
    });
  }
}
