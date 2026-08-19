import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/bundle_scan_models.dart';

class BundleScanController extends GetxController {
  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  final _allBundles = <BundleScanItem>[
    const BundleScanItem(id: '1', bundleId: 'BND-001', project: 'ABC Construction LLC', site: 'Construction Site A', parts: 'STL-B12', totalWeight: '18,500 lbs', time: '10:32 AM', status: BundleScanStatus.staging),
    const BundleScanItem(id: '2', bundleId: 'BND-002', project: 'Riverside Office Build', site: 'Construction Site B', parts: 'STL-B13', totalWeight: '37,700 lbs', time: '10:32 AM', status: BundleScanStatus.ready),
    const BundleScanItem(id: '3', bundleId: 'BND-003', project: 'ABC Construction LLC', site: 'Construction Site A', parts: 'STL-B14', totalWeight: '21,400 lbs', time: '10:32 AM', status: BundleScanStatus.staging),
    const BundleScanItem(id: '4', bundleId: 'BND-004', project: 'ABC Construction LLC', site: 'Construction Site A', parts: 'STL-B12', totalWeight: '18,500 lbs', time: '10:32 AM', status: BundleScanStatus.ready),
    const BundleScanItem(id: '5', bundleId: 'BND-005', project: 'ABC Construction LLC', site: 'Construction Site A', parts: 'STL-B12', totalWeight: '37,700 lbs', time: '10:32 AM', status: BundleScanStatus.staging),
    const BundleScanItem(id: '6', bundleId: 'BND-006', project: 'ABC Construction LLC', site: 'Construction Site A', parts: 'STL-B12', totalWeight: '21,400 lbs', time: '10:32 AM', status: BundleScanStatus.ready),
    const BundleScanItem(id: '7', bundleId: 'BND-007', project: 'ABC Construction LLC', site: 'Construction Site A', parts: 'STL-B12', totalWeight: '18,500 lbs', time: '10:32 AM', status: BundleScanStatus.staging),
    const BundleScanItem(id: '8', bundleId: 'BND-008', project: 'ABC Construction LLC', site: 'Construction Site A', parts: 'STL-B12', totalWeight: '37,700 lbs', time: '10:32 AM', status: BundleScanStatus.ready),
    const BundleScanItem(id: '9', bundleId: 'BND-009', project: 'ABC Construction LLC', site: 'Construction Site A', parts: 'STL-B12', totalWeight: '21,400 lbs', time: '10:32 AM', status: BundleScanStatus.pending),
    const BundleScanItem(id: '10', bundleId: 'BND-010', project: 'ABC Construction LLC', site: 'Construction Site A', parts: 'STL-B12', totalWeight: '18,500 lbs', time: '10:32 AM', status: BundleScanStatus.ready),
  ].obs;

  final pageIndex = 0.obs;
  final pageSize = 10;

  int get bundlesScanned => 3;
  int get bundlesRemaining => 2;
  int get bundlesLoaded => 1;

  List<BundleScanItem> get filteredBundles {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return _allBundles;
    return _allBundles
        .where((b) =>
            b.bundleId.toLowerCase().contains(q) ||
            b.project.toLowerCase().contains(q) ||
            b.parts.toLowerCase().contains(q))
        .toList();
  }

  int get totalPages => ((filteredBundles.length / pageSize).ceil()).clamp(1, 999);

  List<BundleScanItem> get pageBundles {
    final start = pageIndex.value * pageSize;
    final end = (start + pageSize).clamp(0, filteredBundles.length);
    if (start >= filteredBundles.length) return [];
    return filteredBundles.sublist(start, end);
  }

  void nextPage() {
    if (pageIndex.value < totalPages - 1) pageIndex.value++;
  }

  void prevPage() {
    if (pageIndex.value > 0) pageIndex.value--;
  }

  void goToPage(int p) {
    if (p >= 0 && p < totalPages) pageIndex.value = p;
  }

  void onSearch(String v) {
    searchQuery.value = v;
    pageIndex.value = 0;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
