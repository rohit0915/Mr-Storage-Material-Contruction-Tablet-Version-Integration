import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/label_printing_models.dart';

enum LabelSortOption { latest, oldest, weightHigh, weightLow }

class LabelPrintingController extends GetxController {
  final searchController = TextEditingController();

  final bundles = <LabelBundleItem>[
    const LabelBundleItem(
      id: 'BND-001',
      loadId: 'LOAD-001',
      part: 'STL-B12',
      totalWeightLbs: 18500,
      lengthFt: 20,
      status: LabelPrintStatus.pending,
      project: 'RiversideComplex',
      shipper: 'SHP-1044',
    ),
    const LabelBundleItem(
      id: 'BND-002',
      loadId: 'LOAD-002',
      part: 'STL-B13',
      totalWeightLbs: 37700,
      lengthFt: 30,
      status: LabelPrintStatus.printed,
      project: 'RiversideComplex',
      shipper: 'SHP-1044',
    ),
    const LabelBundleItem(
      id: 'BND-003',
      loadId: 'LOAD-003',
      part: 'STL-B14',
      totalWeightLbs: 18500,
      lengthFt: 20,
      status: LabelPrintStatus.pending,
      project: 'Downtown Office Complex',
      shipper: 'SHP-1045',
    ),
    const LabelBundleItem(
      id: 'BND-004',
      loadId: 'LOAD-004',
      part: 'STL-B15',
      totalWeightLbs: 37700,
      lengthFt: 30,
      status: LabelPrintStatus.printed,
      project: 'Residential Tower A',
      shipper: 'SHP-1046',
    ),
    const LabelBundleItem(
      id: 'BND-005',
      loadId: 'LOAD-005',
      part: 'STL-B16',
      totalWeightLbs: 18500,
      lengthFt: 20,
      status: LabelPrintStatus.pending,
      project: 'ABC Construction Site A',
      shipper: 'SHP-1047',
    ),
    const LabelBundleItem(
      id: 'BND-006',
      loadId: 'LOAD-006',
      part: 'STL-B17',
      totalWeightLbs: 37700,
      lengthFt: 30,
      status: LabelPrintStatus.printed,
      project: 'XYZ Building Complex',
      shipper: 'SHP-1048',
    ),
    const LabelBundleItem(
      id: 'BND-007',
      loadId: 'LOAD-007',
      part: 'STL-B18',
      totalWeightLbs: 21400,
      lengthFt: 20,
      status: LabelPrintStatus.pending,
      project: 'RiversideComplex',
      shipper: 'SHP-1044',
    ),
    const LabelBundleItem(
      id: 'BND-008',
      loadId: 'LOAD-008',
      part: 'STL-B19',
      totalWeightLbs: 3600,
      lengthFt: 20,
      status: LabelPrintStatus.printed,
      project: 'Duplex Villa',
      shipper: 'SHP-1049',
    ),
    const LabelBundleItem(
      id: 'BND-009',
      loadId: 'LOAD-009',
      part: 'STL-B20',
      totalWeightLbs: 18500,
      lengthFt: 30,
      status: LabelPrintStatus.pending,
      project: 'RiversideComplex',
      shipper: 'SHP-1044',
    ),
    const LabelBundleItem(
      id: 'BND-010',
      loadId: 'LOAD-010',
      part: 'STL-B21',
      totalWeightLbs: 37700,
      lengthFt: 20,
      status: LabelPrintStatus.printed,
      project: 'Downtown Office Complex',
      shipper: 'SHP-1045',
    ),
    const LabelBundleItem(
      id: 'BND-011',
      loadId: 'LOAD-011',
      part: 'STL-B22',
      totalWeightLbs: 18500,
      lengthFt: 30,
      status: LabelPrintStatus.pending,
      project: 'Residential Tower A',
      shipper: 'SHP-1046',
    ),
    const LabelBundleItem(
      id: 'BND-012',
      loadId: 'LOAD-012',
      part: 'STL-B23',
      totalWeightLbs: 37700,
      lengthFt: 20,
      status: LabelPrintStatus.printed,
      project: 'XYZ Building Complex',
      shipper: 'SHP-1048',
    ),
  ].obs;

  final searchQuery = ''.obs;
  final sortOption = LabelSortOption.latest.obs;
  final selectedIds = <String>{}.obs;
  final filteredBundles = <LabelBundleItem>[].obs;
  final pageIndex = 0.obs;
  final pageSize = 10;

  int get totalBundles => bundles.length;
  int get labelsPrinted =>
      bundles.where((b) => b.status == LabelPrintStatus.printed).length;
  int get labelsPending =>
      bundles.where((b) => b.status == LabelPrintStatus.pending).length;
  int get labelsPrintedToday => 4;

  int get selectedCount => selectedIds.length;

  List<LabelBundleItem> get pageBundles {
    final start = pageIndex.value * pageSize;
    return filteredBundles.skip(start).take(pageSize).toList();
  }

  int get totalPages {
    if (filteredBundles.isEmpty) return 1;
    return (filteredBundles.length / pageSize).ceil();
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
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text.trim();
    resetPagination();
    _recomputeFiltered();
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
    if (pageIndex.value < totalPages - 1) pageIndex.value++;
  }

  void prevPage() {
    if (pageIndex.value > 0) pageIndex.value--;
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

  void markPrinted(LabelBundleItem item) {
    final idx = bundles.indexWhere((b) => b.id == item.id);
    if (idx >= 0) {
      bundles[idx] = item.copyWith(status: LabelPrintStatus.printed);
      _recomputeFiltered();
    }
  }

  void markSelectedAsPrinted() {
    for (var i = 0; i < bundles.length; i++) {
      if (selectedIds.contains(bundles[i].id)) {
        bundles[i] = bundles[i].copyWith(status: LabelPrintStatus.printed);
      }
    }
    selectedIds.clear();
    selectedIds.refresh();
    _recomputeFiltered();
  }

  void _recomputeFiltered() {
    final q = searchQuery.value.toLowerCase();
    var list = bundles.where((b) {
      if (q.isEmpty) return true;
      return b.id.toLowerCase().contains(q) ||
          b.loadId.toLowerCase().contains(q) ||
          b.part.toLowerCase().contains(q) ||
          b.project.toLowerCase().contains(q);
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
