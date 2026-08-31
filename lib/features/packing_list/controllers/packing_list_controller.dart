import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/packing_list_models.dart';

class PackingListController extends GetxController {
  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedItems = <String>{}.obs;

  final _allPackingLists = <PackingListItem>[
    const PackingListItem(
      id: '1',
      packingListId: 'PKL-001',
      loadId: 'LOAD-001',
      truck: 'TX-4582',
      bundles: 5,
      totalWeight: '18,500 LBS',
      destination: 'Site A',
      status: PackingListStatus.loading,
      isSelected: true,
    ),
    const PackingListItem(
      id: '2',
      packingListId: 'PKL-002',
      loadId: 'LOAD-002',
      truck: 'TX-2345',
      bundles: 8,
      totalWeight: '37,700 LBS',
      destination: 'Site A',
      status: PackingListStatus.ready,
    ),
    const PackingListItem(
      id: '3',
      packingListId: 'PKL-003',
      loadId: 'LOAD-003',
      truck: 'TX-4582',
      bundles: 6,
      totalWeight: '21,400 LBS',
      destination: 'Site B',
      status: PackingListStatus.loading,
    ),
    const PackingListItem(
      id: '4',
      packingListId: 'PKL-004',
      loadId: 'LOAD-004',
      truck: 'TX-2345',
      bundles: 5,
      totalWeight: '18,500 LBS',
      destination: 'Site C',
      status: PackingListStatus.ready,
    ),
    const PackingListItem(
      id: '5',
      packingListId: 'PKL-005',
      loadId: 'LOAD-005',
      truck: 'TX-4582',
      bundles: 8,
      totalWeight: '37,700 LBS',
      destination: 'Site A',
      status: PackingListStatus.loading,
    ),
    const PackingListItem(
      id: '6',
      packingListId: 'PKL-006',
      loadId: 'LOAD-006',
      truck: 'TX-2345',
      bundles: 6,
      totalWeight: '21,400 LBS',
      destination: 'Site A',
      status: PackingListStatus.ready,
    ),
    const PackingListItem(
      id: '7',
      packingListId: 'PKL-007',
      loadId: 'LOAD-007',
      truck: 'TX-4582',
      bundles: 3,
      totalWeight: '18,500 LBS',
      destination: 'Site B',
      status: PackingListStatus.loading,
    ),
    const PackingListItem(
      id: '8',
      packingListId: 'PKL-008',
      loadId: 'LOAD-008',
      truck: 'TX-2345',
      bundles: 4,
      totalWeight: '37,700 LBS',
      destination: 'Site C',
      status: PackingListStatus.ready,
    ),
    const PackingListItem(
      id: '9',
      packingListId: 'PKL-009',
      loadId: 'LOAD-009',
      truck: 'TX-4582',
      bundles: 2,
      totalWeight: '21,400 LBS',
      destination: 'Site C',
      status: PackingListStatus.loading,
    ),
    const PackingListItem(
      id: '10',
      packingListId: 'PKL-010',
      loadId: 'LOAD-010',
      truck: 'TX-2345',
      bundles: 4,
      totalWeight: '18,500 LBS',
      destination: 'Site A',
      status: PackingListStatus.ready,
    ),
    const PackingListItem(
      id: '11',
      packingListId: 'PKL-011',
      loadId: 'LOAD-011',
      truck: 'TX-4582',
      bundles: 5,
      totalWeight: '37,700 LBS',
      destination: 'Site A',
      status: PackingListStatus.loading,
    ),
    const PackingListItem(
      id: '12',
      packingListId: 'PKL-012',
      loadId: 'LOAD-012',
      truck: 'TX-2345',
      bundles: 8,
      totalWeight: '21,400 LBS',
      destination: 'Site T',
      status: PackingListStatus.ready,
    ),
    const PackingListItem(
      id: '13',
      packingListId: 'PKL-013',
      loadId: 'LOAD-013',
      truck: 'TX-4582',
      bundles: 6,
      totalWeight: '18,500 LBS',
      destination: 'Site A',
      status: PackingListStatus.loading,
    ),
    const PackingListItem(
      id: '14',
      packingListId: 'PKL-014',
      loadId: 'LOAD-014',
      truck: 'TX-2345',
      bundles: 8,
      totalWeight: '37,700 LBS',
      destination: 'Site A',
      status: PackingListStatus.loading,
    ),
  ].obs;

  final pageIndex = 0.obs;
  final pageSize = 10;

  int get totalPackingList => 24;
  int get loadsReadyForDispatch => 15;
  int get bundlesAssigned => 58;
  int get loadsDispatchToday => 3;

  List<PackingListItem> get filteredLists {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return _allPackingLists;
    return _allPackingLists
        .where((item) =>
            item.packingListId.toLowerCase().contains(q) ||
            item.loadId.toLowerCase().contains(q) ||
            item.truck.toLowerCase().contains(q) ||
            item.destination.toLowerCase().contains(q))
        .toList();
  }

  int get totalPages =>
      ((filteredLists.length / pageSize).ceil()).clamp(1, 15);

  List<PackingListItem> get pageLists {
    final start = pageIndex.value * pageSize;
    final end = (start + pageSize).clamp(0, filteredLists.length);
    if (start >= filteredLists.length) return [];
    return filteredLists.sublist(start, end);
  }

  void toggleItemSelection(String id) {
    if (selectedItems.contains(id)) {
      selectedItems.remove(id);
    } else {
      selectedItems.add(id);
    }
  }

  bool isSelected(String id) => selectedItems.contains(id) || id == '1';

  void toggleSelectAll(bool? val) {
    if (val == true) {
      selectedItems.addAll(pageLists.map((e) => e.id));
    } else {
      selectedItems.clear();
    }
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
