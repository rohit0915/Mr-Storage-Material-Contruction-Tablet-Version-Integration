
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/bundle_scan_models.dart';
import '../services/bundle_scan_service.dart';

class BundleScanController extends GetxController {
  BundleScanController({BundleScanService? service})
    : _service = service ?? BundleScanService();

  final BundleScanService _service;
  TextEditingController _searchController = TextEditingController();
  TextEditingController get searchController {
    try {
      final _ = _searchController.text;
    } catch (_) {
      _searchController = TextEditingController(text: searchQuery.value);
    }
    return _searchController;
  }
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
    searchController.addListener(() {
      searchQuery.value = searchController.text.trim();
      pageIndex.value = 0;
    });
    fetchBundlesFromApi(targetLimit: 1000); // Fetch all for local filter/pagination
  }

  Future<void> fetchBundlesFromApi({int? targetPage, int? targetLimit}) async {
    if (targetLimit != null) pageSize.value = targetLimit;
    final pageToFetch = targetPage ?? (pageIndex.value + 1);
    pageIndex.value = pageToFetch - 1;
    isLoading.value = true;
    try {
      String? apiStatus;
      if (selectedStatus.value != 'All Statuses') {
        final lower = selectedStatus.value.toLowerCase();
        if (lower.contains('pending')) {
          apiStatus = 'pending';
        } else if (lower.contains('stag')) {
          apiStatus = 'staged';
        } else if (lower.contains('truck') || lower.contains('assign')) {
          apiStatus = 'on_truck';
        } else if (lower.contains('load')) {
          apiStatus = 'loaded';
        } else if (lower.contains('draft')) {
          apiStatus = 'draft';
        }
      }

      String? apiSortBy;
      if (selectedSort.value.contains('Weight')) {
        apiSortBy = 'Weight';
      } else if (selectedSort.value == 'Oldest') {
        apiSortBy = 'Oldest';
      } else if (selectedSort.value == 'Latest') {
        apiSortBy = 'Latest';
      }

      final resMap = await _service.fetchBundleScansData(
        page: pageToFetch,
        limit: pageSize.value,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        sortBy: apiSortBy,
        status: apiStatus,
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
    final res = await _service.scanBundle(code);
    final success = res != null;
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
          statusText: 'Staged',
        );
      }
    }
    return success;
  }

  final selectedStatus = 'All Statuses'.obs;
  final selectedSort = 'Latest'.obs;

  List<BundleScanItem> get filteredBundles {
    var list = _allBundles.toList();
    if (selectedStatus.value != 'All Statuses') {
      final s = selectedStatus.value.toLowerCase().replaceAll('_', ' ');
      list = list.where((b) {
        final st = b.statusText.toLowerCase().replaceAll('_', ' ');
        final sn = b.status.name.toLowerCase().replaceAll('_', ' ');
        if (s.contains('truck') || s.contains('assign')) {
          return st.contains('truck') ||
              st.contains('assign') ||
              sn == 'assigned';
        }
        if (s.contains('stag')) {
          return st.contains('stag') || sn == 'staging';
        }
        if (s.contains('load')) {
          return st.contains('load') || sn == 'ready';
        }
        if (s.contains('pend')) {
          return st.contains('pend') || sn == 'pending';
        }
        if (s.contains('draft')) {
          return st.contains('draft');
        }
        return st.contains(s) || sn.contains(s);
      }).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list.where((b) =>
        b.bundleId.toLowerCase().contains(q) ||
        b.realMongoId.toLowerCase().contains(q) ||
        b.project.toLowerCase().contains(q) ||
        b.jobId.toLowerCase().contains(q) ||
        b.site.toLowerCase().contains(q) ||
        b.parts.toLowerCase().contains(q) ||
        b.loadId.toLowerCase().contains(q) ||
        b.shipper.toLowerCase().contains(q) ||
        b.driver.toLowerCase().contains(q) ||
        b.statusText.toLowerCase().contains(q) ||
        b.totalWeight.toLowerCase().contains(q),
      ).toList();
    }

    if (selectedSort.value.contains('Weight')) {
      if (selectedSort.value == 'Weight Low to High') {
        list.sort((a, b) =>
            _parseWeight(a.totalWeight).compareTo(_parseWeight(b.totalWeight)));
      } else {
        list.sort((a, b) =>
            _parseWeight(b.totalWeight).compareTo(_parseWeight(a.totalWeight)));
      }
    } else if (selectedSort.value == 'Oldest') {
      list.sort((a, b) => a.bundleId.compareTo(b.bundleId));
    } else {
      list.sort((a, b) => b.bundleId.compareTo(a.bundleId));
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
    fetchBundlesFromApi(targetPage: 1);
  }

  void setSort(String sort) {
    selectedSort.value = sort;
    pageIndex.value = 0;
    fetchBundlesFromApi(targetPage: 1);
  }

  int get totalPages {
    final t = filteredBundles.length;
    if (t == 0) return 1;
    final pSize = pageSize.value > 0 ? pageSize.value : 10;
    return (t / pSize).ceil().clamp(1, 999);
  }

  List<BundleScanItem> get pageBundles {
    if (filteredBundles.isEmpty) return [];
    final startIndex = pageIndex.value * pageSize.value;
    return filteredBundles.skip(startIndex).take(pageSize.value).toList();
  }

  void nextPage() {
    if (pageIndex.value < totalPages - 1) {
      pageIndex.value++;
    }
  }

  void prevPage() {
    if (pageIndex.value > 0) {
      pageIndex.value--;
    }
  }

  void goToPage(int p) {
    if (p >= 0 && p < totalPages) {
      pageIndex.value = p;
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
    super.onClose();
  }
}
