import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/packing_list_models.dart';
import '../services/packing_list_service.dart';

class PackingListController extends GetxController {
  PackingListController({PackingListService? service})
    : _service = service ?? PackingListService();

  final PackingListService _service;
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedItems = <String>{}.obs;
  final isLoading = false.obs;

  final _allPackingLists = <PackingListItem>[].obs;

  final pageIndex = 0.obs;
  final pageSize = 10.obs;

  final apiTotal = 0.obs;
  final apiReady = 0.obs;
  final apiBundlesAssigned = 0.obs;
  final apiDispatchToday = 0.obs;
  final hasApiStats = false.obs;

  int get totalPackingList => apiTotal.value;
  int get loadsReadyForDispatch => apiReady.value;
  int get bundlesAssigned => apiBundlesAssigned.value;
  int get loadsDispatchToday => apiDispatchToday.value;

  @override
  void onInit() {
    super.onInit();
    fetchPackingListsFromApi();
  }

  Future<void> fetchPackingListsFromApi({
    int? targetPage,
    int? targetLimit,
  }) async {
    if (targetLimit != null) pageSize.value = targetLimit;
    final pageToFetch = targetPage ?? (pageIndex.value + 1);
    pageIndex.value = pageToFetch - 1;
    isLoading.value = true;
    try {
      final resMap = await _service.fetchPackingListsData(
        page: pageToFetch,
        limit: pageSize.value,
      );
      final List<PackingListItem> list = resMap['items'] ?? [];
      final Map<String, dynamic> stats = resMap['stats'] ?? {};
      final int count = resMap['total'] ?? 0;

      hasApiStats.value = true;
      apiTotal.value = count;
      apiReady.value =
          (stats['ready'] as num?)?.toInt() ??
          (stats['loadsReadyForDispatch'] as num?)?.toInt() ??
          apiTotal.value;
      apiBundlesAssigned.value =
          (stats['bundlesAssigned'] as num?)?.toInt() ?? 0;
      apiDispatchToday.value = (stats['dispatchToday'] as num?)?.toInt() ?? 0;

      if (list.isNotEmpty) {
        _allPackingLists.assignAll(list);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> getPackingListDetail(String id) async {
    final idx = _allPackingLists.indexWhere(
      (item) => item.id == id || item.packingListId == id,
    );
    final reqId = idx >= 0 && _allPackingLists[idx].realMongoId.isNotEmpty
        ? _allPackingLists[idx].realMongoId
        : id;
    return await _service.fetchPackingListDetail(reqId);
  }

  Future<String?> downloadPdf(String id) async {
    final idx = _allPackingLists.indexWhere(
      (item) => item.id == id || item.packingListId == id,
    );
    final reqId = idx >= 0 && _allPackingLists[idx].realMongoId.isNotEmpty
        ? _allPackingLists[idx].realMongoId
        : id;
    return _service.downloadPackingListPdf(reqId);
  }

  Future<String?> exportExcel() => _service.exportPackingLists();

  Future<bool> markReadyForDispatch(String id) async {
    final idx = _allPackingLists.indexWhere(
      (item) => item.id == id || item.packingListId == id,
    );
    final reqId = idx >= 0 && _allPackingLists[idx].realMongoId.isNotEmpty
        ? _allPackingLists[idx].realMongoId
        : id;
    final success = await _service.markReady(reqId);
    if (success && idx >= 0) {
      _allPackingLists[idx] = _allPackingLists[idx].copyWith(
        status: PackingListStatus.ready,
        statusText: 'READY',
      );
    }
    return success;
  }

  Future<bool> markDispatch(String id) async {
    final idx = _allPackingLists.indexWhere(
      (item) => item.id == id || item.packingListId == id,
    );
    final reqId = idx >= 0 && _allPackingLists[idx].realMongoId.isNotEmpty
        ? _allPackingLists[idx].realMongoId
        : id;
    final success = await _service.markDispatch(reqId);
    if (success && idx >= 0) {
      _allPackingLists[idx] = _allPackingLists[idx].copyWith(
        status: PackingListStatus.ready,
        statusText: 'DISPATCHED',
      );
    }
    return success;
  }

  final selectedStatus = 'All Statuses'.obs;
  final selectedSort = 'Latest'.obs;

  List<PackingListItem> get filteredLists {
    var list = List<PackingListItem>.from(_allPackingLists);

    if (selectedStatus.value != 'All Statuses') {
      final filterText = selectedStatus.value.toUpperCase();
      list = list.where((item) {
        return item.statusText.toUpperCase().contains(filterText) ||
            item.status.name.toUpperCase().contains(filterText);
      }).toList();
    }

    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (item) =>
                item.packingListId.toLowerCase().contains(q) ||
                item.project.toLowerCase().contains(q) ||
                item.jobId.toLowerCase().contains(q) ||
                item.truck.toLowerCase().contains(q) ||
                item.destination.toLowerCase().contains(q) ||
                item.totalWeight.toLowerCase().contains(q) ||
                item.statusText.toLowerCase().contains(q),
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
    final t = totalPackingList;
    if (t == 0) return 1;
    final pSize = pageSize.value > 0 ? pageSize.value : 10;
    return (t / pSize).ceil().clamp(1, 999);
  }

  List<PackingListItem> get pageItems => filteredLists;
  List<PackingListItem> get pageLists => pageItems;

  void nextPage() {
    if (pageIndex.value < totalPages - 1) {
      fetchPackingListsFromApi(targetPage: pageIndex.value + 2);
    }
  }

  void prevPage() {
    if (pageIndex.value > 0) {
      fetchPackingListsFromApi(targetPage: pageIndex.value);
    }
  }

  void goToPage(int p) {
    if (p >= 0 && p < totalPages) {
      fetchPackingListsFromApi(targetPage: p + 1);
    }
  }

  void changePage(int pageNumber) {
    if (pageNumber >= 1 && pageNumber <= totalPages) {
      fetchPackingListsFromApi(targetPage: pageNumber);
    }
  }

  void changeLimit(int newLimit) {
    if (newLimit != pageSize.value) {
      fetchPackingListsFromApi(targetPage: 1, targetLimit: newLimit);
    }
  }

  void toggleSelect(String id) {
    if (selectedItems.contains(id)) {
      selectedItems.remove(id);
    } else {
      selectedItems.add(id);
    }
  }

  void toggleSelectAll(bool? val) {
    if (val == true) {
      selectedItems.assignAll(pageItems.map((e) => e.id));
    } else {
      selectedItems.clear();
    }
  }

  void onSearch(String val) {
    searchQuery.value = val;
    pageIndex.value = 0;
    fetchPackingListsFromApi(targetPage: 1);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
