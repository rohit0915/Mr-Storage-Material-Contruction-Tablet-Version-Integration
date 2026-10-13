import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/utils/app_logger.dart';
import '../../../app/utils/app_toast.dart';

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
  final pageSize = 10.obs;
  final pageSizeOptions = const [10, 15, 20, 25, 50];

  void setPageSize(int size) {
    if (pageSize.value == size) return;
    pageSize.value = size;
    pageIndex.value = 0;
  }

  final apiTotalBundles = 0.obs;
  final apiLabelsPrinted = 0.obs;
  final apiLabelsPending = 0.obs;
  final apiLabelsPrintedToday = 0.obs;
  final hasApiStats = false.obs;

  int get totalBundles =>
      hasApiStats.value && apiTotalBundles.value > 0 ? apiTotalBundles.value : bundles.length;
  int get labelsPrinted {
    final localCount = bundles.where((b) => b.status == LabelPrintStatus.printed).length;
    if (hasApiStats.value && apiLabelsPrinted.value > 0) {
      return apiLabelsPrinted.value;
    }
    return localCount;
  }
  int get labelsPending {
    final localCount = bundles
        .where(
          (b) =>
              b.status == LabelPrintStatus.pending ||
              b.status == LabelPrintStatus.assigned,
        )
        .length;
    if (hasApiStats.value && apiLabelsPending.value > 0) {
      return apiLabelsPending.value;
    }
    return localCount;
  }
  int get labelsPrintedToday {
    if (hasApiStats.value && apiLabelsPrintedToday.value > 0) {
      return apiLabelsPrintedToday.value;
    }
    return bundles.where((b) => b.status == LabelPrintStatus.printed).length;
  }

  int get selectedCount => selectedIds.length;

  List<LabelBundleItem> get pageBundles {
    if (filteredBundles.isEmpty) return [];
    final startIndex = pageIndex.value * pageSize.value;
    return filteredBundles.skip(startIndex).take(pageSize.value).toList();
  }

  int get totalPages {
    final total = filteredBundles.length;
    if (total == 0) return 1;
    return (total / pageSize.value).ceil();
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
    fetchLabelsFromApi(targetPage: 1, limit: 1000); // Fetch all for local filter/pagination
  }

  Future<void> fetchLabelsFromApi({int? targetPage, int? limit}) async {
    isLoading.value = true;
    try {
      final resMap = await _service.fetchLabelsData(
        page: 1,
        limit: limit ?? 1000,
      );
      final List<LabelBundleItem> apiList = resMap['items'] ?? [];
      final Map<String, dynamic> stats = resMap['stats'] ?? {};
      final int totalCount = resMap['total'] ?? stats['total'] ?? 0;

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
    var filtered = bundles.toList();
    
    if (selectedStatus.value != 'All Statuses') {
      final status = selectedStatus.value.toLowerCase().replaceAll(' ', '_');
      filtered = filtered.where((b) {
        final st = b.statusText.toLowerCase().replaceAll(' ', '_');
        final nm = b.status.name.toLowerCase();
        return st.contains(status) || nm.contains(status) || status.contains(st);
      }).toList();
    }
    
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      filtered = filtered.where((b) => 
        b.id.toLowerCase().contains(q) || 
        b.realMongoId.toLowerCase().contains(q) ||
        b.project.toLowerCase().contains(q) ||
        b.loadId.toLowerCase().contains(q) ||
        b.part.toLowerCase().contains(q) ||
        b.shipper.toLowerCase().contains(q) ||
        b.statusText.toLowerCase().contains(q)
      ).toList();
    }

    if (sortOption.value == LabelSortOption.weightHigh) {
      filtered.sort((a, b) => b.totalWeightLbs.compareTo(a.totalWeightLbs));
    } else if (sortOption.value == LabelSortOption.weightLow) {
      filtered.sort((a, b) => a.totalWeightLbs.compareTo(b.totalWeightLbs));
    } else if (sortOption.value == LabelSortOption.oldest) {
      filtered.sort((a, b) => a.id.compareTo(b.id));
    } else {
      filtered.sort((a, b) => b.id.compareTo(a.id));
    }

    filteredBundles.value = filtered;
  }

  Future<void> exportReport() async {
    try {
      final rows = <List<Object?>>[
        [
          'Bundle ID',
          'Project',
          'Load ID',
          'Part#',
          'Weight (lbs)',
          'Length (ft)',
          'Status',
        ],
        ...bundles.map((b) => [
              b.id,
              b.project,
              b.loadId,
              b.part,
              b.totalWeightLbs,
              b.lengthFt,
              b.statusText,
            ]),
      ];
      final saved = await file_picker.FilePicker.saveFile(
        dialogTitle: 'Save Label Printing',
        fileName: 'label_printing.csv',
        type: file_picker.FileType.custom,
        allowedExtensions: ['csv'],
        bytes: _encodeCsv(rows),
      );
      if (saved != null) {
        AppToast.showSuccess(
          title: 'Exported',
          description: 'Label printing exported successfully.',
        );
      }
    } catch (e, st) {
      AppLogger.e('Export error', error: e, stackTrace: st, tag: 'LABEL_CTRL');
      AppToast.showError(
        title: 'Export failed',
        description: 'An error occurred while exporting.',
      );
    }
  }

  Uint8List _encodeCsv(List<List<Object?>> rows) {
    String cell(Object? value) {
      var text = value?.toString() ?? '';
      if (value is String && RegExp(r'^\s*[=+\-@]').hasMatch(text)) {
        text = "'$text";
      }
      return '"${text.replaceAll('"', '""')}"';
    }

    final csv = rows.map((row) => row.map(cell).join(',')).join('\r\n');
    return Uint8List.fromList(utf8.encode('\uFEFF$csv\r\n'));
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
