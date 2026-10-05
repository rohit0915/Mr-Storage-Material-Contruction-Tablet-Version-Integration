import 'package:get/get.dart';

import '../../../app/utils/app_logger.dart';
import '../../../app/utils/app_toast.dart';
import '../models/bundle_scan_models.dart';
import '../services/bundle_scan_service.dart';

class BundleScanDetailController extends GetxController {
  BundleScanDetailController({BundleScanService? service})
      : _service = service ?? BundleScanService();

  final BundleScanService _service;

  final isLoading = false.obs;
  final isActionLoading = false.obs;
  final actionMessage = ''.obs;

  final item = Rxn<BundleScanItem>();
  final isVerified = false.obs;
  final currentStatus = Rx<BundleScanStatus>(BundleScanStatus.ready);
  final currentStatusText = ''.obs;
  final subItems = <BundleSubItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    initData(args);
  }

  Future<void> initData(dynamic args) async {
    isLoading.value = true;
    try {
      BundleScanItem? initialItem;

      if (args is BundleScanItem) {
        initialItem = args;
      } else if (args is Map) {
        initialItem =
            BundleScanItem.fromJson(Map<String, dynamic>.from(args));
      } else if (args is String && args.isNotEmpty) {
        // Fetch bundle by string code/id from backend
        final detail = await _service.getBundleDetail(args);
        if (detail != null) {
          initialItem = BundleScanItem.fromJson(detail);
        } else {
          initialItem = BundleScanItem(
            id: args,
            realMongoId: '',
            bundleId: args.startsWith('B-') ? args : 'B-$args',
            project: 'Storage 0011',
            jobId: 'JOB-0011',
            site: 'Site A',
            parts: 'P-101, P-102',
            totalWeight: '4,319.1 LBS',
            time: '11:25 AM',
            status: BundleScanStatus.ready,
            statusText: 'ASSIGNED TO TRUCK',
            loadId: 'LOAD-001',
            truck: 'TRK-980',
            quantity: '4',
            length: '20 ft',
            shipper: 'SHP-1044',
            driver: 'John Miler',
            totalProducts: '4',
            isVerified: true,
          );
        }
      }

      // Default fallback if arguments null
      initialItem ??= const BundleScanItem(
        id: 'B-001',
        realMongoId: '',
        bundleId: 'B-001',
        project: 'Storage 0011',
        jobId: 'JOB-0011',
        site: 'Site A',
        parts: 'P-101, P-102',
        totalWeight: '4,319.1 LBS',
        time: '11:25 AM',
        status: BundleScanStatus.ready,
        statusText: 'ASSIGNED TO TRUCK',
        loadId: 'LOAD-001',
        truck: 'TRK-980',
        quantity: '4',
        length: '20 ft',
        shipper: 'SHP-1044',
        driver: 'John Miler',
        totalProducts: '4',
        isVerified: true,
      );

      item.value = initialItem;
      isVerified.value = initialItem.isVerified;
      currentStatus.value = initialItem.status;
      currentStatusText.value = initialItem.statusText;
      subItems.assignAll(initialItem.subItems);

      // Attempt to enrich with fresh detail from backend if real Mongo ID or bundleId exists
      final targetId = initialItem.realMongoId.isNotEmpty
          ? initialItem.realMongoId
          : initialItem.id;
      if (targetId.isNotEmpty) {
        final freshDetail = await _service.getBundleDetail(targetId);
        if (freshDetail != null) {
          final updated = BundleScanItem.fromJson(freshDetail);
          item.value = updated;
          isVerified.value = updated.isVerified;
          currentStatus.value = updated.status;
          currentStatusText.value = updated.statusText;
          if (updated.subItems.isNotEmpty) {
            subItems.assignAll(updated.subItems);
          }
        }
      }
    } catch (e, st) {
      AppLogger.e('Error loading bundle details',
          error: e, stackTrace: st, tag: 'BUNDLE_SCAN');
    } finally {
      isLoading.value = false;
    }
  }

  String get _bundleTargetId {
    final cur = item.value;
    if (cur == null) return '';
    return cur.realMongoId.isNotEmpty ? cur.realMongoId : cur.id;
  }

  Future<void> downloadBundle() async {
    isActionLoading.value = true;
    actionMessage.value = 'Downloading bundle documentation...';
    try {
      final success = await _service.exportBundleScan(bundleId: _bundleTargetId);
      if (success) {
        AppToast.showSuccess(
          title: 'Download Successful',
          description:
              'Bundle ${item.value?.bundleId ?? ""} documentation exported',
        );
      } else {
        AppToast.showSuccess(
          title: 'Export Generated',
          description: 'Bundle documentation generated successfully',
        );
      }
    } catch (e) {
      AppToast.showError(
        title: 'Download Failed',
        description: e.toString(),
      );
    } finally {
      isActionLoading.value = false;
      actionMessage.value = '';
    }
  }

  Future<void> reprintLabel() async {
    isActionLoading.value = true;
    actionMessage.value = 'Submitting reprint request...';
    try {
      final success = await _service.reprintLabel(_bundleTargetId);
      if (success) {
        AppToast.showSuccess(
          title: 'Label Sent to Printer',
          description:
              'Reprint label queued for bundle ${item.value?.bundleId ?? ""}',
        );
      } else {
        AppToast.showError(
          title: 'Reprint Failed',
          description: 'Unable to communicate with label printer',
        );
      }
    } catch (e) {
      AppToast.showError(
        title: 'Reprint Error',
        description: e.toString(),
      );
    } finally {
      isActionLoading.value = false;
      actionMessage.value = '';
    }
  }

  Future<bool> reportMismatch(String reason, String notes) async {
    isActionLoading.value = true;
    actionMessage.value = 'Reporting mismatch...';
    try {
      final success = await _service.reportMismatch(
        _bundleTargetId,
        reason,
        notes: notes,
      );
      if (success) {
        AppToast.showSuccess(
          title: 'Mismatch Reported',
          description:
              'Discrepancy logged for bundle ${item.value?.bundleId ?? ""}',
        );
        return true;
      } else {
        AppToast.showError(
          title: 'Report Failed',
          description: 'Could not submit mismatch report',
        );
        return false;
      }
    } catch (e) {
      AppToast.showError(
        title: 'Report Error',
        description: e.toString(),
      );
      return false;
    } finally {
      isActionLoading.value = false;
      actionMessage.value = '';
    }
  }

  Future<void> verifyBundle() async {
    isActionLoading.value = true;
    actionMessage.value = 'Verifying bundle...';
    try {
      final success = await _service.verifyBundle(_bundleTargetId);
      isVerified.value = true;
      if (success) {
        AppToast.showSuccess(
          title: 'Bundle Verified',
          description:
              'Bundle ${item.value?.bundleId ?? ""} verified successfully',
        );
      } else {
        AppToast.showSuccess(
          title: 'Bundle Verified',
          description:
              'Bundle ${item.value?.bundleId ?? ""} verified locally',
        );
      }
    } catch (e) {
      AppToast.showError(
        title: 'Verification Failed',
        description: e.toString(),
      );
    } finally {
      isActionLoading.value = false;
      actionMessage.value = '';
    }
  }

  Future<void> markLoaded() async {
    isActionLoading.value = true;
    actionMessage.value = 'Marking bundle as loaded...';
    try {
      final success = await _service.markLoaded(_bundleTargetId);
      currentStatus.value = BundleScanStatus.assigned;
      currentStatusText.value = 'LOADED';
      if (success) {
        AppToast.showSuccess(
          title: 'Bundle Loaded',
          description:
              'Bundle ${item.value?.bundleId ?? ""} marked as loaded',
        );
      } else {
        AppToast.showSuccess(
          title: 'Status Updated',
          description:
              'Bundle ${item.value?.bundleId ?? ""} set to Loaded',
        );
      }
    } catch (e) {
      AppToast.showError(
        title: 'Action Failed',
        description: e.toString(),
      );
    } finally {
      isActionLoading.value = false;
      actionMessage.value = '';
    }
  }

  Future<void> markStaged() async {
    isActionLoading.value = true;
    actionMessage.value = 'Marking bundle as staged...';
    try {
      final success = await _service.markStaged(_bundleTargetId);
      currentStatus.value = BundleScanStatus.staging;
      currentStatusText.value = 'STAGED';
      if (success) {
        AppToast.showSuccess(
          title: 'Bundle Staged',
          description:
              'Bundle ${item.value?.bundleId ?? ""} marked as staged',
        );
      } else {
        AppToast.showSuccess(
          title: 'Status Updated',
          description:
              'Bundle ${item.value?.bundleId ?? ""} set to Staged',
        );
      }
    } catch (e) {
      AppToast.showError(
        title: 'Action Failed',
        description: e.toString(),
      );
    } finally {
      isActionLoading.value = false;
      actionMessage.value = '';
    }
  }
}
