import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/dispatch_verification_models.dart';
import '../services/dispatch_verification_service.dart';

class DispatchVerificationController extends GetxController {
  DispatchVerificationController({DispatchVerificationService? service})
    : _service = service ?? DispatchVerificationService();

  final DispatchVerificationService _service;
  final searchController = TextEditingController();
  final isLoading = false.obs;

  final allItems = <DispatchItem>[].obs;
  final selectedItem = Rxn<DispatchItem>();

  final searchQuery = ''.obs;
  final selectedStatus = 'All Statuses'.obs;
  final selectedSort = 'Latest'.obs;
  final pageIndex = 0.obs;
  final pageSize = 10;

  // Reactive Stats matching Web Panel
  final loadsReadyCount = 0.obs;
  final bundlesVerifiedCount = 0.obs;
  final bundlesMissingCount = 0.obs;
  final dispatchedTodayCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDispatchesFromApi();
  }

  Future<void> fetchDispatchesFromApi() async {
    isLoading.value = true;
    try {
      final res = await _service.fetchDispatchVerificationsData();
      final list = (res['items'] as List<DispatchItem>?) ?? [];
      allItems.assignAll(list);
      if (res['stats'] is Map) {
        final st = res['stats'] as Map;
        loadsReadyCount.value =
            (st['loadsReady'] as num?)?.toInt() ?? list.length;
        bundlesVerifiedCount.value =
            (st['bundlesVerified'] as num?)?.toInt() ?? 0;
        bundlesMissingCount.value =
            (st['bundlesMissing'] as num?)?.toInt() ?? 0;
        dispatchedTodayCount.value =
            (st['dispatchedToday'] as num?)?.toInt() ?? 0;
      }
    } finally {
      isLoading.value = false;
    }
  }

  final isActionLoading = false.obs;

  Future<bool> verifyDispatch(String loadId, {double? actualWeight}) async {
    isActionLoading.value = true;
    try {
      final success = await _service.verifyLoad(
        loadId,
        actualWeight: actualWeight,
      );
      final idx = allItems.indexWhere((i) => i.loadId == loadId);
      if (success && idx >= 0) {
        allItems[idx] = allItems[idx].copyWith(
          status: DispatchStatus.verified,
          statusText: 'VERIFIED',
        );
        if (selectedItem.value?.loadId == loadId) {
          selectedItem.value = allItems[idx];
        }
      }
      return success;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<bool> confirmDispatch(String loadId, {String? packingListId}) async {
    isActionLoading.value = true;
    try {
      final success = await _service.confirmDispatch(
        loadId,
        packingListId: packingListId,
      );
      final idx = allItems.indexWhere((i) => i.loadId == loadId);
      if (success && idx >= 0) {
        allItems[idx] = allItems[idx].copyWith(
          status: DispatchStatus.verified,
          statusText: 'DISPATCHED',
        );
        if (selectedItem.value?.loadId == loadId) {
          selectedItem.value = allItems[idx];
        }
        dispatchedTodayCount.value++;
        if (loadsReadyCount.value > 0) loadsReadyCount.value--;
      }
      return success;
    } finally {
      isActionLoading.value = false;
    }
  }

  List<DispatchItem> get filteredItems {
    var list = List<DispatchItem>.from(allItems);
    if (selectedStatus.value != 'All Statuses') {
      final filterText = selectedStatus.value.toUpperCase();
      list = list
          .where(
            (i) =>
                i.statusText.toUpperCase().contains(filterText) ||
                i.status.name.toUpperCase().contains(filterText),
          )
          .toList();
    }
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (i) =>
                i.loadId.toLowerCase().contains(q) ||
                i.packingListNo.toLowerCase().contains(q) ||
                i.project.toLowerCase().contains(q) ||
                i.jobId.toLowerCase().contains(q) ||
                i.driver.toLowerCase().contains(q) ||
                i.truck.toLowerCase().contains(q) ||
                i.destination.toLowerCase().contains(q) ||
                i.totalWeight.toLowerCase().contains(q) ||
                i.statusText.toLowerCase().contains(q),
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

  void setStatusFilter(String s) {
    selectedStatus.value = s;
    pageIndex.value = 0;
  }

  void setSort(String s) {
    selectedSort.value = s;
  }

  int get totalPages => (filteredItems.length / pageSize).ceil().clamp(1, 999);

  List<DispatchItem> get pageItems {
    final list = filteredItems;
    final start = pageIndex.value * pageSize;
    if (start >= list.length) return [];
    final end = (start + pageSize).clamp(0, list.length);
    return list.sublist(start, end);
  }

  void onSearch(String q) {
    searchQuery.value = q;
    pageIndex.value = 0;
  }

  void nextPage() {
    if (pageIndex.value < totalPages - 1) pageIndex.value++;
  }

  void prevPage() {
    if (pageIndex.value > 0) pageIndex.value--;
  }

  void goToPage(int p) {
    pageIndex.value = p.clamp(0, totalPages - 1);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
