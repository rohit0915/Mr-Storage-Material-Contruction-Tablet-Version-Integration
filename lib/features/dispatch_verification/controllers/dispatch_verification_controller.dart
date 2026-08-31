import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/dispatch_verification_models.dart';

class DispatchVerificationController extends GetxController {
  final searchController = TextEditingController();

  final allItems = <DispatchItem>[
    const DispatchItem(loadId: 'LOAD-001', truck: 'TX-4582', driver: 'John Miler', bundles: 5, totalWeight: '18,500 IBS', destination: 'Site A', status: DispatchStatus.pending, isSelected: true),
    const DispatchItem(loadId: 'LOAD-002', truck: 'TX-2345', driver: 'Alex Turner', bundles: 8, totalWeight: '37,700 IBS', destination: 'Site A', status: DispatchStatus.verified),
    const DispatchItem(loadId: 'LOAD-003', truck: 'TX-4582', driver: 'John Miler', bundles: 6, totalWeight: '21,400 IBS', destination: 'Site B', status: DispatchStatus.pending),
    const DispatchItem(loadId: 'LOAD-004', truck: 'TX-2345', driver: 'Alex Turner', bundles: 5, totalWeight: '18,500 IBS', destination: 'Site C', status: DispatchStatus.verified),
    const DispatchItem(loadId: 'LOAD-005', truck: 'TX-4582', driver: 'John Miler', bundles: 8, totalWeight: '37,700 IBS', destination: 'Site A', status: DispatchStatus.pending),
    const DispatchItem(loadId: 'LOAD-006', truck: 'TX-2345', driver: 'Alex Turner', bundles: 6, totalWeight: '21,400 IBS', destination: 'Site A', status: DispatchStatus.verified),
    const DispatchItem(loadId: 'LOAD-007', truck: 'TX-4582', driver: 'John Miler', bundles: 3, totalWeight: '18,500 IBS', destination: 'Site B', status: DispatchStatus.pending),
    const DispatchItem(loadId: 'LOAD-008', truck: 'TX-2345', driver: 'Alex Turner', bundles: 4, totalWeight: '37,700 IBS', destination: 'Site C', status: DispatchStatus.verified),
    const DispatchItem(loadId: 'LOAD-009', truck: 'TX-4582', driver: 'John Miler', bundles: 2, totalWeight: '21,400 IBS', destination: 'Site C', status: DispatchStatus.pending),
    const DispatchItem(loadId: 'LOAD-010', truck: 'TX-2345', driver: 'Alex Turner', bundles: 4, totalWeight: '18,500 IBS', destination: 'Site A', status: DispatchStatus.verified),
    const DispatchItem(loadId: 'LOAD-011', truck: 'TX-4582', driver: 'John Miler', bundles: 5, totalWeight: '37,700 IBS', destination: 'Site A', status: DispatchStatus.pending),
    const DispatchItem(loadId: 'LOAD-012', truck: 'TX-2345', driver: 'Alex Turner', bundles: 8, totalWeight: '21,400 IBS', destination: 'Site T', status: DispatchStatus.verified),
    const DispatchItem(loadId: 'LOAD-013', truck: 'TX-4582', driver: 'John Miler', bundles: 6, totalWeight: '18,500 IBS', destination: 'Site A', status: DispatchStatus.pending),
    const DispatchItem(loadId: 'LOAD-014', truck: 'TX-2345', driver: 'Alex Turner', bundles: 8, totalWeight: '37,700 IBS', destination: 'Site A', status: DispatchStatus.pending),
  ].obs;

  final searchQuery = ''.obs;
  final pageIndex = 0.obs;
  final pageSize = 10;

  List<DispatchItem> get filteredItems {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return allItems;
    return allItems.where((i) =>
      i.loadId.toLowerCase().contains(q) ||
      i.driver.toLowerCase().contains(q) ||
      i.destination.toLowerCase().contains(q)
    ).toList();
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
