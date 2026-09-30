import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/bundle_scan_models.dart';
import '../services/bundle_scan_service.dart';

class BundleScanController extends GetxController {
  BundleScanController({BundleScanService? service})
    : _service = service ?? BundleScanService();

  final BundleScanService _service;
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final isLoading = false.obs;

  final _allBundles = <BundleScanItem>[].obs;

  final pageIndex = 0.obs;
  final pageSize = 10.obs;

  final apiScanned = 0.obs;
  final apiRemaining = 0.obs;
  final apiLoaded = 0.obs;
  final apiTotal = 0.obs;
  final hasApiStats = false.obs;

  String scopedLeadId = '';
  String scopedProject = '';
  String scopedJobId = '';
  bool isProjectScoped = false;

  int get bundlesScanned =>
      isProjectScoped ? filteredBundles.length : apiScanned.value;
  int get bundlesRemaining => isProjectScoped
      ? filteredBundles.where((b) => b.status != BundleScanStatus.ready).length
      : apiRemaining.value;
  int get bundlesLoaded => isProjectScoped
      ? filteredBundles
            .where(
              (b) =>
                  b.status == BundleScanStatus.ready ||
                  b.status == BundleScanStatus.assigned,
            )
            .length
      : apiLoaded.value;
  int get totalCount =>
      isProjectScoped ? filteredBundles.length : apiTotal.value;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      scopedLeadId = (args['leadId'] ?? '').toString();
      scopedProject = (args['project'] ?? '').toString();
      scopedJobId = (args['jobId'] ?? '').toString();
      isProjectScoped =
          args['fromProject'] == true ||
          scopedLeadId.isNotEmpty ||
          scopedJobId.isNotEmpty;
    }
    fetchBundlesFromApi();
  }

  Future<void> fetchBundlesFromApi({int? targetPage, int? targetLimit}) async {
    if (targetLimit != null) pageSize.value = targetLimit;
    final pageToFetch = targetPage ?? (pageIndex.value + 1);
    pageIndex.value = pageToFetch - 1;
    isLoading.value = true;
    try {
      final resMap = await _service.fetchBundleScansData(
        page: pageToFetch,
        limit: pageSize.value,
      );
      final List<BundleScanItem> list = resMap['items'] ?? [];
      final Map<String, dynamic> stats = resMap['stats'] ?? {};
      final int count = resMap['total'] ?? 0;

      hasApiStats.value = true;
      final scannedFromStat =
          (stats['scanned'] as num?)?.toInt() ??
          (stats['bundlesScanned'] as num?)?.toInt();
      apiScanned.value = scannedFromStat ?? 0;
      apiRemaining.value =
          (stats['remaining'] as num?)?.toInt() ??
          (stats['bundlesRemaining'] as num?)?.toInt() ??
          0;
      apiLoaded.value =
          (stats['loaded'] as num?)?.toInt() ??
          (stats['bundlesLoaded'] as num?)?.toInt() ??
          0;
      apiTotal.value = count;

      if (list.isNotEmpty) {
        _allBundles.assignAll(list);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitScan(String code) async {
    final success = await _service.scanBundle(code);
    if (success) {
      await fetchBundlesFromApi();
    }
    return success;
  }

  Future<bool> markBundleStaged(String bundleId) async {
    final success = await _service.markStaged(bundleId);
    if (success) {
      final idx = _allBundles.indexWhere(
        (b) => b.bundleId == bundleId || b.id == bundleId,
      );
      if (idx >= 0) {
        _allBundles[idx] = _allBundles[idx].copyWith(
          status: BundleScanStatus.staging,
          statusText: 'STAGING',
        );
      }
    }
    return success;
  }

  final selectedStatus = 'All Statuses'.obs;
  final selectedSort = 'Latest'.obs;

  List<BundleScanItem> get filteredBundles {
    var list = List<BundleScanItem>.from(_allBundles);

    // If scoped to a specific project from Project Details:
    if (isProjectScoped &&
        (scopedJobId.isNotEmpty ||
            scopedProject.isNotEmpty ||
            scopedLeadId.isNotEmpty)) {
      list = list.where((b) {
        if (scopedJobId.isNotEmpty &&
            b.jobId.toLowerCase() == scopedJobId.toLowerCase()) {
          return true;
        }
        if (scopedProject.isNotEmpty &&
            b.project.toLowerCase().contains(scopedProject.toLowerCase())) {
          return true;
        }
        if (scopedLeadId.isNotEmpty &&
            (b.realMongoId == scopedLeadId || b.id == scopedLeadId)) {
          return true;
        }
        return false;
      }).toList();
    }

    if (selectedStatus.value != 'All Statuses') {
      final filterText = selectedStatus.value.toUpperCase();
      list = list.where((b) {
        return b.statusText.toUpperCase().contains(filterText) ||
            b.status.name.toUpperCase().contains(filterText);
      }).toList();
    }

    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (b) =>
                b.bundleId.toLowerCase().contains(q) ||
                b.project.toLowerCase().contains(q) ||
                b.jobId.toLowerCase().contains(q) ||
                b.parts.toLowerCase().contains(q) ||
                b.site.toLowerCase().contains(q) ||
                b.totalWeight.toLowerCase().contains(q) ||
                b.statusText.toLowerCase().contains(q),
          )
          .toList();
    }

    if (selectedSort.value == 'Weight High to Low') {
      list.sort(
        (a, b) =>
            _parseWeight(b.totalWeight).compareTo(_parseWeight(a.totalWeight)),
      );
    } else if (selectedSort.value == 'Weight Low to High') {
      list.sort(
        (a, b) =>
            _parseWeight(a.totalWeight).compareTo(_parseWeight(b.totalWeight)),
      );
    } else if (selectedSort.value == 'Oldest') {
      list = list.reversed.toList();
    }

    return list;
  }

  double _parseWeight(String w) {
    final clean = w.replaceAll('LBS', '').replaceAll(',', '').trim();
    return double.tryParse(clean) ?? 0.0;
  }

  void setStatusFilter(String status) {
    selectedStatus.value = status;
    pageIndex.value = 0;
  }

  void setSort(String sort) {
    selectedSort.value = sort;
  }

  int get totalPages {
    final t = totalCount;
    if (t == 0) return 1;
    final pSize = pageSize.value > 0 ? pageSize.value : 10;
    return (t / pSize).ceil().clamp(1, 999);
  }

  List<BundleScanItem> get pageBundles => filteredBundles;

  void nextPage() {
    if (pageIndex.value < totalPages - 1) {
      fetchBundlesFromApi(targetPage: pageIndex.value + 2);
    }
  }

  void prevPage() {
    if (pageIndex.value > 0) {
      fetchBundlesFromApi(targetPage: pageIndex.value);
    }
  }

  void goToPage(int p) {
    if (p >= 0 && p < totalPages) {
      fetchBundlesFromApi(targetPage: p + 1);
    }
  }

  void changePage(int pageNumber) {
    if (pageNumber >= 1 && pageNumber <= totalPages) {
      fetchBundlesFromApi(targetPage: pageNumber);
    }
  }

  void changeLimit(int newLimit) {
    if (newLimit != pageSize.value) {
      fetchBundlesFromApi(targetPage: 1, targetLimit: newLimit);
    }
  }

  void onSearch(String v) {
    searchQuery.value = v;
    pageIndex.value = 0;
    fetchBundlesFromApi(targetPage: 1);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
