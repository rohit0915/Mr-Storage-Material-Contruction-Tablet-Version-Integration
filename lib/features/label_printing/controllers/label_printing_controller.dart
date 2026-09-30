import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/label_printing_models.dart';
import '../services/label_printing_service.dart';

enum LabelSortOption { latest, oldest, weightHigh, weightLow }

class LabelPrintingController extends GetxController {
  LabelPrintingController({LabelPrintingService? service})
    : _service = service ?? LabelPrintingService();

  final LabelPrintingService _service;
  final searchController = TextEditingController();
  final isLoading = false.obs;

  final bundles = <LabelBundleItem>[].obs;
  final searchQuery = ''.obs;
  final sortOption = LabelSortOption.latest.obs;
  final selectedIds = <String>{}.obs;
  final filteredBundles = <LabelBundleItem>[].obs;
  final pageIndex = 0.obs;
  final pageSize = 10;

  final apiTotalBundles = 0.obs;
  final apiLabelsPrinted = 0.obs;
  final apiLabelsPending = 0.obs;
  final apiLabelsPrintedToday = 0.obs;
  final hasApiStats = false.obs;

  int get totalBundles =>
      hasApiStats.value ? apiTotalBundles.value : bundles.length;
  int get labelsPrinted => hasApiStats.value
      ? apiLabelsPrinted.value
      : bundles.where((b) => b.status == LabelPrintStatus.printed).length;
  int get labelsPending => hasApiStats.value
      ? apiLabelsPending.value
      : bundles
            .where(
              (b) =>
                  b.status == LabelPrintStatus.pending ||
                  b.status == LabelPrintStatus.assigned,
            )
            .length;
  int get labelsPrintedToday =>
      hasApiStats.value ? apiLabelsPrintedToday.value : 0;

  int get selectedCount => selectedIds.length;

  List<LabelBundleItem> get pageBundles {
    if (filteredBundles.isEmpty) return [];
    return filteredBundles;
  }

  int get totalPages {
    final total = totalBundles;
    if (total == 0) return 1;
    return (total / pageSize).ceil();
  }

  bool get isAllOnPageSelected {
    final page = pageBundles;
    if (page.isEmpty) return false;
    return page.every((b) => selectedIds.contains(b.id));
  }

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    _recomputeFiltered();
    fetchLabelsFromApi();
  }

  Future<void> fetchLabelsFromApi({int? targetPage}) async {
    final pageToFetch = targetPage ?? (pageIndex.value + 1);
    isLoading.value = true;
    try {
      final resMap = await _service.fetchLabelsData(
        page: pageToFetch,
        limit: pageSize,
      );
      final List<LabelBundleItem> apiList = resMap['items'] ?? [];
      final Map<String, dynamic> stats = resMap['stats'] ?? {};
      final int totalCount = resMap['total'] ?? stats['total'] ?? 222;

      if (stats.isNotEmpty || totalCount > 0) {
        hasApiStats.value = true;
        apiTotalBundles.value = (stats['total'] as num?)?.toInt() ?? totalCount;
        apiLabelsPrinted.value = (stats['printed'] as num?)?.toInt() ?? 0;
        apiLabelsPending.value = (stats['pending'] as num?)?.toInt() ?? 0;
        apiLabelsPrintedToday.value =
            (stats['printedToday'] as num?)?.toInt() ?? 0;
      }

      if (apiList.isNotEmpty) {
        bundles.assignAll(apiList);
      }
    } finally {
      isLoading.value = false;
      _recomputeFiltered();
    }
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text.trim();
    resetPagination();
    fetchLabelsFromApi(targetPage: 1);
  }

  void setSort(LabelSortOption option) {
    sortOption.value = option;
    resetPagination();
    _recomputeFiltered();
  }

  void resetPagination() {
    pageIndex.value = 0;
  }

  void nextPage() {
    if (pageIndex.value < totalPages - 1) {
      pageIndex.value++;
      fetchLabelsFromApi(targetPage: pageIndex.value + 1);
    }
  }

  void prevPage() {
    if (pageIndex.value > 0) {
      pageIndex.value--;
      fetchLabelsFromApi(targetPage: pageIndex.value + 1);
    }
  }

  void goToPage(int p) {
    if (p >= 0 && p < totalPages) {
      pageIndex.value = p;
      fetchLabelsFromApi(targetPage: p + 1);
    }
  }

  void toggleSelect(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    selectedIds.refresh();
  }

  void toggleSelectAllOnPage() {
    final page = pageBundles;
    if (isAllOnPageSelected) {
      for (final b in page) {
        selectedIds.remove(b.id);
      }
    } else {
      for (final b in page) {
        selectedIds.add(b.id);
      }
    }
    selectedIds.refresh();
  }

  Future<void> markPrinted(LabelBundleItem item) async {
    final reqId = item.realMongoId.isNotEmpty ? item.realMongoId : item.id;
    _service.printLabel([reqId]);
    final idx = bundles.indexWhere((b) => b.id == item.id);
    if (idx >= 0) {
      bundles[idx] = item.copyWith(
        status: LabelPrintStatus.printed,
        statusText: 'PRINTED',
      );
      _recomputeFiltered();
    }
  }

  Future<void> markSelectedAsPrinted() async {
    if (selectedIds.isNotEmpty) {
      final realIds = bundles
          .where((b) => selectedIds.contains(b.id))
          .map((b) => b.realMongoId.isNotEmpty ? b.realMongoId : b.id)
          .toList();
      _service.printLabel(realIds);
    }
    for (var i = 0; i < bundles.length; i++) {
      if (selectedIds.contains(bundles[i].id)) {
        bundles[i] = bundles[i].copyWith(
          status: LabelPrintStatus.printed,
          statusText: 'PRINTED',
        );
      }
    }
    selectedIds.clear();
    selectedIds.refresh();
    _recomputeFiltered();
  }

  final selectedStatus = 'All Statuses'.obs;

  void setStatusFilter(String status) {
    selectedStatus.value = status;
    pageIndex.value = 0;
    _recomputeFiltered();
  }

  void _recomputeFiltered() {
    final q = searchQuery.value.trim().toLowerCase();
    var list = bundles.where((b) {
      if (selectedStatus.value != 'All Statuses') {
        final filterText = selectedStatus.value.toUpperCase();
        if (!b.statusText.toUpperCase().contains(filterText) &&
            !b.status.name.toUpperCase().contains(filterText)) {
          return false;
        }
      }
      if (q.isEmpty) return true;
      return b.id.toLowerCase().contains(q) ||
          b.loadId.toLowerCase().contains(q) ||
          b.part.toLowerCase().contains(q) ||
          b.project.toLowerCase().contains(q) ||
          b.shipper.toLowerCase().contains(q) ||
          b.statusText.toLowerCase().contains(q);
    }).toList();

    switch (sortOption.value) {
      case LabelSortOption.latest:
        list = list.reversed.toList();
      case LabelSortOption.oldest:
        break;
      case LabelSortOption.weightHigh:
        list.sort((a, b) => b.totalWeightLbs.compareTo(a.totalWeightLbs));
      case LabelSortOption.weightLow:
        list.sort((a, b) => a.totalWeightLbs.compareTo(b.totalWeightLbs));
    }

    filteredBundles.value = list;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
