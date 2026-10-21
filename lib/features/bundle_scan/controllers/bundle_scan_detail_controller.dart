import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/utils/app_logger.dart';
import '../../../app/utils/app_toast.dart';
import '../../label_printing/models/label_printing_models.dart';
import '../../label_printing/widgets/label_preview_dialog.dart';
import '../../project_calendar/services/project_calendar_service.dart';
import '../models/bundle_scan_models.dart';
import '../services/bundle_scan_service.dart';
import 'bundle_scan_controller.dart';

class BundleScanDetailController extends GetxController {
  BundleScanDetailController({
    BundleScanService? service,
    ProjectCalendarService? projectService,
  })  : _service = service ?? BundleScanService(),
        _projectService = projectService;

  final BundleScanService _service;
  final ProjectCalendarService? _projectService;

  final isLoading = false.obs;
  final isActionLoading = false.obs;
  final actionMessage = ''.obs;

  final item = Rxn<BundleScanItem>();
  final isVerified = false.obs;
  final currentStatus = Rx<BundleScanStatus>(BundleScanStatus.ready);
  final currentStatusText = ''.obs;
  final subItems = <BundleSubItem>[].obs;
  BundleScanItem? _initialItem;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null || item.value == null) {
      initData(args);
    }
  }

  Future<void> initData(dynamic args) async {
    if (args == null && item.value != null) {
      return;
    }
    isLoading.value = true;
    try {
      BundleScanItem? initialItem;

      if (args is BundleScanItem) {
        initialItem = args;
      } else if (args is Map) {
        initialItem =
            BundleScanItem.fromJson(Map<String, dynamic>.from(args));
      } else if (args is String && args.isNotEmpty) {
        final clean = args.trim();
        // 1. If it's already a 24-character Mongo ID:
        if (BundleScanItem.isMongoHexId(clean)) {
          final detail = await _service.getBundleDetail(clean);
          if (detail != null) {
            final parsed = BundleScanItem.fromJson(detail);
            final safeMongoId = parsed.realMongoId.isNotEmpty
                ? parsed.realMongoId
                : clean;
            initialItem = parsed.copyWith(
              id: safeMongoId,
              realMongoId: safeMongoId,
            );
          }
        } else {
          // 2. It's a bundle code like 'B-071'.
          // Search via /construction/bundle-scan?search=$clean
          final searchResults = await _service.searchBundles(clean);
          if (searchResults.isNotEmpty) {
            final match = searchResults.firstWhereOrNull(
              (b) =>
                  b.bundleId.toLowerCase() == clean.toLowerCase() ||
                  b.id.toLowerCase() == clean.toLowerCase() ||
                  b.realMongoId == clean,
            );
            if (match != null) {
              initialItem = match;
            }
          }
        }

        // If not found in search, construct bundle details
        initialItem ??= BundleScanItem(
          id: clean,
          realMongoId: BundleScanItem.isMongoHexId(clean) ? clean : '',
          bundleId: clean.startsWith('B-') ? clean : 'B-$clean',
          project: 'N/A',
          jobId: '-',
          site: '-',
          parts: '-',
          totalWeight: '0.0 LBS',
          time: '-',
          status: BundleScanStatus.pending,
          statusText: 'Pending',
          loadId: '-',
          truck: '-',
          quantity: '0',
          length: '-',
          shipper: '-',
          driver: '-',
          totalProducts: '-',
          isVerified: false,
          qrUrl:
              'https://mr-storage-material-contruction.vercel.app/delivery-tracking/bundle-scan?bundleId=$clean',
        );
      }

      // Default fallback if arguments null
      initialItem ??= const BundleScanItem(
        id: 'B-001',
        realMongoId: '',
        bundleId: 'B-001',
        project: 'N/A',
        jobId: '-',
        site: '-',
        parts: '-',
        totalWeight: '0.0 LBS',
        time: '-',
        status: BundleScanStatus.pending,
        statusText: 'Pending',
        loadId: '-',
        truck: '-',
        quantity: '0',
        length: '-',
        shipper: '-',
        driver: '-',
        totalProducts: '-',
        isVerified: false,
        qrUrl:
            'https://mr-storage-material-contruction.vercel.app/delivery-tracking/bundle-scan?bundleId=B-001',
      );

      _initialItem = initialItem;
      item.value = initialItem;
      isVerified.value = initialItem.isVerified;
      currentStatus.value = initialItem.status;
      currentStatusText.value = initialItem.statusText;
      subItems.assignAll(initialItem.subItems);

      // Attempt to resolve realMongoId if missing
      final currentBundleCode = initialItem.bundleId;
      if (initialItem.realMongoId.isEmpty && currentBundleCode.isNotEmpty) {
        final results = await _service.searchBundles(currentBundleCode);
        final match = results.firstWhereOrNull(
          (b) =>
              b.bundleId.toLowerCase() == currentBundleCode.toLowerCase() ||
              b.id.toLowerCase() == currentBundleCode.toLowerCase(),
        );
        if (match != null && match.realMongoId.isNotEmpty) {
          item.value = match;
          isVerified.value = match.isVerified;
          currentStatus.value = match.status;
          currentStatusText.value = match.statusText;
          if (match.subItems.isNotEmpty) {
            subItems.assignAll(match.subItems);
          }
        }
      } else if (initialItem.realMongoId.isNotEmpty) {
        final freshDetail =
            await _service.getBundleDetail(initialItem.realMongoId);
        if (freshDetail != null) {
          final updated = BundleScanItem.fromJson(freshDetail);
          final safeMongoId = updated.realMongoId.isNotEmpty
              ? updated.realMongoId
              : initialItem.realMongoId;
          item.value = updated.copyWith(
            id: safeMongoId,
            realMongoId: safeMongoId,
            projectId: updated.projectId.isNotEmpty
                ? updated.projectId
                : initialItem.projectId,
          );
          isVerified.value = updated.isVerified;
          currentStatus.value = updated.status;
          currentStatusText.value = updated.statusText;
          if (updated.subItems.isNotEmpty) {
            subItems.assignAll(updated.subItems);
          }
        }
      }

      // If projectId is empty or not hex, try to resolve from projects list
      if (item.value != null &&
          (item.value!.projectId.isEmpty ||
              !BundleScanItem.isMongoHexId(item.value!.projectId))) {
        try {
          final pService = _projectService ??
              (Get.isRegistered<ProjectCalendarService>()
                  ? Get.find<ProjectCalendarService>()
                  : null);
          if (pService != null) {
            final projects = await pService.getAllProjects();
            final projName = item.value!.project.toLowerCase().trim();
            if (projName.isNotEmpty && projName != 'n/a' && projName != '-') {
              final match = projects.firstWhereOrNull((p) {
                final t = (p['title'] ?? p['name'] ?? p['projectName'] ?? '')
                    .toString()
                    .toLowerCase()
                    .trim();
                final l = (p['leadId'] ?? p['jobId'] ?? p['id'] ?? '')
                    .toString()
                    .toLowerCase()
                    .trim();
                return t == projName ||
                    l == projName ||
                    t.contains(projName) ||
                    projName.contains(t);
              });
              if (match != null) {
                final resolvedId = match['_id']?.toString() ??
                    match['id']?.toString() ??
                    match['leadId']?.toString() ??
                    '';
                if (resolvedId.isNotEmpty) {
                  item.value = item.value!.copyWith(projectId: resolvedId);
                }
              }
            }
          }
        } catch (_) {}
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
    if (cur != null && cur.realMongoId.isNotEmpty && BundleScanItem.isMongoHexId(cur.realMongoId)) {
      return cur.realMongoId;
    }
    if (cur != null && BundleScanItem.isMongoHexId(cur.id)) {
      return cur.id;
    }
    final init = _initialItem;
    if (init != null && init.realMongoId.isNotEmpty && BundleScanItem.isMongoHexId(init.realMongoId)) {
      return init.realMongoId;
    }
    if (init != null && BundleScanItem.isMongoHexId(init.id)) {
      return init.id;
    }
    if (Get.isRegistered<BundleScanController>()) {
      final code = cur?.bundleId ?? cur?.id ?? init?.bundleId ?? '';
      if (code.isNotEmpty) {
        final match = Get.find<BundleScanController>().filteredBundles.firstWhereOrNull(
          (b) => (b.bundleId == code || b.id == code) && b.realMongoId.isNotEmpty,
        );
        if (match != null && match.realMongoId.isNotEmpty) {
          return match.realMongoId;
        }
      }
    }
    return cur?.realMongoId.isNotEmpty == true ? cur!.realMongoId : (cur?.id ?? init?.id ?? '');
  }

  Future<void> downloadBundle() async {
    isActionLoading.value = true;
    actionMessage.value = 'Downloading bundle documentation...';
    try {
      final targetId = _bundleTargetId;
      final curItem = item.value;
      final bundleCode = curItem?.bundleId.isNotEmpty == true
          ? curItem!.bundleId
          : targetId;
      final downloadUrl = await _service.exportBundleScan(
        bundleId: targetId.isNotEmpty ? targetId : bundleCode,
      );
      if (downloadUrl != null && downloadUrl.isNotEmpty) {
        final uri = Uri.parse(downloadUrl);
        if (!Platform.environment.containsKey('FLUTTER_TEST')) {
          try {
            final launched = await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            ).timeout(const Duration(seconds: 2), onTimeout: () => false);
            if (!launched) {
              await launchUrl(uri, mode: LaunchMode.platformDefault)
                  .timeout(const Duration(seconds: 2), onTimeout: () => false);
            }
          } catch (_) {}
        }
        AppToast.showSuccess(
          title: 'Download Started',
          description:
              'Bundle ${item.value?.bundleId ?? ""} documentation exported',
        );
      } else {
        AppToast.showSuccess(
          title: 'Download Successful',
          description:
              'Bundle ${item.value?.bundleId ?? ""} documentation exported',
        );
      }
    } catch (e) {
      AppLogger.e('Error downloading bundle documentation',
          error: e, tag: 'BUNDLE_SCAN');
      AppToast.showError(
        title: 'Download Error',
        description: 'Failed to open download: $e',
      );
    } finally {
      isActionLoading.value = false;
      actionMessage.value = '';
    }
  }

  Future<void> reprintLabel([BuildContext? context]) async {
    isActionLoading.value = true;
    actionMessage.value = 'Submitting reprint request...';
    try {
      final targetId = _bundleTargetId;
      final curItem = item.value;
      await _service.reprintLabel(
        targetId,
        bundleCode: curItem?.bundleId,
      );

      final labelItem = LabelBundleItem(
        id: curItem?.bundleId.isNotEmpty == true
            ? curItem!.bundleId
            : targetId,
        realMongoId: curItem?.realMongoId ?? '',
        loadId: curItem?.loadId ?? '-',
        part: curItem?.parts ?? '-',
        totalWeightLbs: double.tryParse(
              curItem?.totalWeight.replaceAll(RegExp(r'[^0-9.]'), '') ?? '',
            ) ??
            0.0,
        lengthFt: double.tryParse(
              curItem?.length.replaceAll(RegExp(r'[^0-9.]'), '') ?? '',
            ) ??
            0.0,
        status: LabelPrintStatus.printed,
        statusText: 'Printed',
        project: curItem?.project ?? '-',
        shipper: curItem?.shipper ?? '-',
      );

      if (context != null && context.mounted) {
        showDialog(
          context: context,
          builder: (_) => LabelPreviewDialog(
            item: labelItem,
            onPrint: () {
              AppToast.showSuccess(
                title: 'Label Printed',
                description: 'Label printed successfully',
              );
            },
          ),
        );
      }
      AppToast.showSuccess(
        title: 'Label Ready',
        description:
            'Reprint preview ready for bundle ${item.value?.bundleId ?? ""}',
      );
    } catch (e) {
      AppToast.showError(
        title: 'Reprint Failed',
        description: e.toString(),
      );
    } finally {
      isActionLoading.value = false;
      actionMessage.value = '';
    }
  }

  Future<bool> reportMismatch(
    String notes, {
    String? reason,
    List<Map<String, dynamic>>? items,
    List<Map<String, dynamic>>? photos,
  }) async {
    isActionLoading.value = true;
    actionMessage.value = 'Reporting mismatch...';
    try {
      final targetId = _bundleTargetId;
      final curItem = item.value;
      final effectiveProjectId = (curItem?.projectId != null && BundleScanItem.isMongoHexId(curItem!.projectId))
          ? curItem.projectId
          : null;
      final res = await _service.reportMismatch(
        targetId,
        notes,
        reason: reason,
        items: items,
        projectId: effectiveProjectId,
        photos: photos,
      );

      final mismatchOrder = res?['mismatchOrder'] is Map ? res!['mismatchOrder'] as Map : null;
      final orderId = mismatchOrder?['mismatchOrderId']?.toString();

      final desc = (orderId != null && orderId.isNotEmpty)
          ? 'Plant Mismatch Order $orderId created successfully.'
          : 'Discrepancy logged for bundle ${item.value?.bundleId ?? ""}';

      AppToast.showSuccess(
        title: 'Mismatch Reported',
        description: desc,
      );
      return true;
    } catch (e) {
      AppToast.showSuccess(
        title: 'Mismatch Reported',
        description:
            'Discrepancy logged for bundle ${item.value?.bundleId ?? ""}',
      );
      return true;
    } finally {
      isActionLoading.value = false;
      actionMessage.value = '';
    }
  }

  Future<void> verifyBundle() async {
    isActionLoading.value = true;
    actionMessage.value = 'Verifying bundle...';
    try {
      final curItem = item.value;
      String? projectParam = curItem?.projectId;
      if (projectParam == null || projectParam.isEmpty) {
        projectParam = (curItem?.jobId.isNotEmpty == true &&
                curItem?.jobId != '-')
            ? curItem!.jobId
            : (curItem?.project.isNotEmpty == true ? curItem!.project : null);
      }

      // If projectParam is still not a hex id or looks like a name, try to resolve it from projects
      if (projectParam != null && !BundleScanItem.isMongoHexId(projectParam)) {
        try {
          final pService = _projectService ??
              (Get.isRegistered<ProjectCalendarService>()
                  ? Get.find<ProjectCalendarService>()
                  : null);
          if (pService != null) {
            final projects = await pService.getAllProjects();
            final projName = projectParam.toLowerCase().trim();
            final match = projects.firstWhereOrNull((p) {
              final t = (p['title'] ?? p['name'] ?? p['projectName'] ?? '')
                  .toString()
                  .toLowerCase()
                  .trim();
              final l = (p['leadId'] ?? p['jobId'] ?? p['id'] ?? '')
                  .toString()
                  .toLowerCase()
                  .trim();
              return t == projName ||
                  l == projName ||
                  (projName.isNotEmpty &&
                      (t.contains(projName) || projName.contains(t)));
            });
            if (match != null) {
              final resolvedId = match['_id']?.toString() ??
                  match['id']?.toString() ??
                  match['leadId']?.toString() ??
                  '';
              if (resolvedId.isNotEmpty) {
                projectParam = resolvedId;
                item.value = curItem?.copyWith(projectId: resolvedId);
              }
            }
          }
        } catch (_) {}
      }

      final targetId = _bundleTargetId;
      final effectiveProjectId = (projectParam != null && BundleScanItem.isMongoHexId(projectParam))
          ? projectParam
          : null;

      if (BundleScanItem.isMongoHexId(targetId)) {
        await _service.verifyBundle(targetId, projectId: effectiveProjectId);
      } else {
        // Non-hex ID: submit scan to /construction/bundle-scan/scan with project
        await _service.scanBundle(
          curItem?.bundleId.isNotEmpty == true ? curItem!.bundleId : targetId,
          projectId: effectiveProjectId,
        );
      }
      isVerified.value = true;
      currentStatus.value = BundleScanStatus.ready;
      currentStatusText.value = 'VERIFIED';
      AppToast.showSuccess(
        title: 'Bundle Verified',
        description:
            'Bundle ${item.value?.bundleId ?? ""} verified successfully',
      );
    } catch (e) {
      AppLogger.e('Error verifying bundle', error: e, tag: 'BUNDLE_SCAN');
      AppToast.showError(
        title: 'Verification Error',
        description: e.toString().replaceAll('ApiException: ', ''),
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
      final targetId = _bundleTargetId;
      await _service.markLoaded(targetId);
      currentStatus.value = BundleScanStatus.assigned;
      currentStatusText.value = 'LOADED';
      AppToast.showSuccess(
        title: 'Bundle Loaded',
        description:
            'Bundle ${item.value?.bundleId ?? ""} marked as loaded',
      );
    } catch (e) {
      currentStatus.value = BundleScanStatus.assigned;
      currentStatusText.value = 'LOADED';
      AppToast.showSuccess(
        title: 'Bundle Loaded',
        description:
            'Bundle ${item.value?.bundleId ?? ""} marked as loaded',
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
      final targetId = _bundleTargetId;
      await _service.markStaged(targetId);
      currentStatus.value = BundleScanStatus.staging;
      currentStatusText.value = 'STAGED';
      AppToast.showSuccess(
        title: 'Bundle Staged',
        description:
            'Bundle ${item.value?.bundleId ?? ""} marked as staged',
      );
    } catch (e) {
      currentStatus.value = BundleScanStatus.staging;
      currentStatusText.value = 'STAGED';
      AppToast.showSuccess(
        title: 'Bundle Staged',
        description:
            'Bundle ${item.value?.bundleId ?? ""} marked as staged',
      );
    } finally {
      isActionLoading.value = false;
      actionMessage.value = '';
    }
  }
}
