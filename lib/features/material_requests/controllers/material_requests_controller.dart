import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/services/api_client.dart';
import '../../../app/utils/app_logger.dart';
import '../../../app/utils/app_toast.dart';
import '../models/material_request_models.dart';
import '../services/material_requests_service.dart';

class MaterialRequestsController extends GetxController {
  MaterialRequestsController({MaterialRequestsService? service})
    : _service = service ?? Get.put(MaterialRequestsService());

  final MaterialRequestsService _service;

  final projects = <String>['All Projects'].obs;
  final priorityList = <String>[
    'All Priorities',
    'Low',
    'Medium',
    'High',
    'Critical',
  ].obs;
  final statusList = <String>[
    'All Statuses',
    'Pending',
    'Approved',
    'Rejected',
    'Fulfilled',
    'Cancelled',
  ].obs;

  // Backward compatibility properties
  final departments = <String>[
    'All Departments',
    'Construction',
    'Plant',
    'Yard',
    'Warehouse',
  ].obs;
  final requestedByList = <String>['All'].obs;
  final selectedDepartment = 'All Departments'.obs;
  final selectedRequestedBy = 'All'.obs;

  final requests = <MaterialRequestBoardItem>[].obs;
  final isLoading = false.obs;

  final totalRequestsStat = 0.obs;
  final pendingStat = 0.obs;
  final approvedStat = 0.obs;
  final rejectedStat = 0.obs;

  final selectedProject = 'All Projects'.obs;
  final selectedStatus = 'All Statuses'.obs;
  final selectedPriority = 'All Priorities'.obs;
  final searchQuery = ''.obs;
  final Map<String, String> _projectIdsByName = {};
  final Map<String, String> _requesterIdsByName = {};

  final dateFrom = Rxn<DateTime>();
  final dateTo = Rxn<DateTime>();

  // Pagination
  final pageIndex = 0.obs;
  final pageSize = 10;
  final serverTotal = 0.obs;

  final filteredRequests = <MaterialRequestBoardItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initialLoad();
  }

  Future<void> _initialLoad() async {
    final filterData = await _service.getFilters();
    final names = <String>['All Projects'];
    if (filterData != null && filterData['projects'] is List) {
      final pList = filterData['projects'] as List;
      for (final p in pList) {
        if (p is Map) {
          final pName = (p['projectName'] ?? p['jobId'] ?? '').toString();
          final jId = (p['jobId'] ?? '').toString();
          final id = (p['leadId'] ?? p['_id'] ?? '').toString();
          final label = pName.isNotEmpty && jId.isNotEmpty && pName != jId
              ? '$pName ($jId)'
              : (pName.isNotEmpty ? pName : jId);
          if (label.isNotEmpty && id.isNotEmpty) {
            _projectIdsByName[label] = id;
            names.add(label);
          }
        }
      }
    }

    if (names.length <= 1) {
      final projectRows = await _service.getProjects();
      for (final row in projectRows) {
        final name = (row['projectName'] ?? row['jobId'] ?? '').toString();
        final id = (row['_id'] ?? row['leadId'] ?? '').toString();
        if (name.isNotEmpty && id.isNotEmpty) {
          _projectIdsByName[name] = id;
          names.add(name);
        }
      }
    }
    projects.assignAll(names.toSet());

    if (filterData != null) {
      if (filterData['statuses'] is List &&
          (filterData['statuses'] as List).isNotEmpty) {
        final sList = filterData['statuses'] as List;
        final list = <String>['All Statuses'];
        for (final s in sList) {
          final str = s.toString();
          if (str.isNotEmpty) {
            list.add(str[0].toUpperCase() + str.substring(1));
          }
        }
        statusList.assignAll(list.toSet());
      }
      if (filterData['priorities'] is List &&
          (filterData['priorities'] as List).isNotEmpty) {
        final prList = filterData['priorities'] as List;
        final list = <String>['All Priorities'];
        for (final pr in prList) {
          final str = pr.toString();
          if (str.isNotEmpty) {
            list.add(str[0].toUpperCase() + str.substring(1));
          }
        }
        priorityList.assignAll(list.toSet());
      }
    }

    await fetchRequests();
  }

  String _formatDateForApi(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> fetchRequests() async {
    isLoading.value = true;
    try {
      final res = await _service.getMaterialRequests(
        page: pageIndex.value + 1,
        limit: pageSize,
        project:
            _projectIdsByName[selectedProject.value] ?? selectedProject.value,
        department: selectedDepartment.value,
        status: selectedStatus.value,
        priority: selectedPriority.value,
        search: searchQuery.value.trim(),
        requestedBy:
            _requesterIdsByName[selectedRequestedBy.value] ??
            selectedRequestedBy.value,
        dateFrom: dateFrom.value != null
            ? _formatDateForApi(dateFrom.value!)
            : null,
        dateTo: dateTo.value != null
            ? _formatDateForApi(dateTo.value!)
            : null,
      );

      if (res != null) {
        serverTotal.value = (res['total'] as num?)?.toInt() ?? 0;
        if (res['stats'] is Map) {
          final st = res['stats'] as Map;
          totalRequestsStat.value =
              (st['totalRequests'] as num?)?.toInt() ??
              (st['total'] as num?)?.toInt() ??
              0;
          pendingStat.value = (st['pending'] as num?)?.toInt() ?? 0;
          approvedStat.value = (st['approved'] as num?)?.toInt() ?? 0;
          rejectedStat.value = (st['rejected'] as num?)?.toInt() ?? 0;
        }

        if (res['materialRequests'] is List) {
          final list = res['materialRequests'] as List;
          final parsed = <MaterialRequestBoardItem>[];
          final dOpts = <String>{
            'All Departments',
            'Construction',
            'Plant',
            'Yard',
            'Warehouse',
          };
          final rOpts = <String>{'All'};

          for (final item in list) {
            if (item is Map) {
              final boardItem = MaterialRequestBoardItem.fromJson(
                Map<String, dynamic>.from(item),
              );
              parsed.add(boardItem);

              if (boardItem.department.isNotEmpty) {
                dOpts.add(boardItem.department);
              }
              if (boardItem.requestedBy.isNotEmpty &&
                  boardItem.requestedBy != 'Unassigned') {
                rOpts.add(boardItem.requestedBy);
                if (boardItem.requestedById.isNotEmpty) {
                  _requesterIdsByName[boardItem.requestedBy] =
                      boardItem.requestedById;
                }
              }
            }
          }

          departments.assignAll(dOpts.toList());
          requestedByList.assignAll(rOpts.toList());
          requests.assignAll(parsed);
        } else {
          requests.clear();
        }
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'fetchRequests Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'MAT_REQ_CTRL',
      );
    } finally {
      isLoading.value = false;
      _recomputeFiltered();
    }
  }

  void resetPagination() {
    pageIndex.value = 0;
  }

  bool get hasDateFilter => dateFrom.value != null || dateTo.value != null;

  bool get hasActiveFilters {
    return selectedProject.value != 'All Projects' ||
        (selectedStatus.value != 'All Statuses' &&
            selectedStatus.value != 'All Status') ||
        selectedPriority.value != 'All Priorities' ||
        searchQuery.value.trim().isNotEmpty ||
        dateFrom.value != null ||
        dateTo.value != null;
  }

  void resetFilters() {
    selectedProject.value = 'All Projects';
    selectedStatus.value = 'All Statuses';
    selectedPriority.value = 'All Priorities';
    searchQuery.value = '';
    dateFrom.value = null;
    dateTo.value = null;
    resetPagination();
    fetchRequests();
  }

  void setFilters({
    String? project,
    String? status,
    String? priority,
    String? search,
    DateTime? from,
    DateTime? to,
    bool clearDates = false,
    String? department,
    String? requestedBy,
  }) {
    if (project != null) selectedProject.value = project;
    if (status != null) selectedStatus.value = status;
    if (priority != null) selectedPriority.value = priority;
    if (search != null) searchQuery.value = search;
    if (department != null) selectedDepartment.value = department;
    if (requestedBy != null) selectedRequestedBy.value = requestedBy;

    if (clearDates) {
      dateFrom.value = null;
      dateTo.value = null;
    } else {
      if (from != null) dateFrom.value = from;
      if (to != null) dateTo.value = to;
    }

    resetPagination();
    fetchRequests();
  }

  List<MaterialRequestBoardItem> get pageRequests {
    return filteredRequests.toList();
  }

  int get totalPages {
    if (serverTotal.value == 0) return 1;
    return (serverTotal.value / pageSize).ceil();
  }

  String get dateRangeLabel {
    final f = dateFrom.value;
    final t = dateTo.value;
    if (f == null && t == null) return 'dd/mm/yyyy - dd/mm/yyyy';
    final fmt = MaterialRequestControllerDateFormatter();
    if (f != null && t != null) {
      return '${fmt.formatDdMmYyyy(f)} - ${fmt.formatDdMmYyyy(t)}';
    } else if (f != null) {
      return '${fmt.formatDdMmYyyy(f)} - dd/mm/yyyy';
    } else {
      return 'dd/mm/yyyy - ${fmt.formatDdMmYyyy(t!)}';
    }
  }

  void clearDateRange() {
    dateFrom.value = null;
    dateTo.value = null;
    resetPagination();
    fetchRequests();
  }

  Future<MaterialRequestBoardItem> loadDetails(
    MaterialRequestBoardItem item,
  ) async {
    final detail = await _service.getMaterialRequestDetail(
      item.databaseId.isNotEmpty ? item.databaseId : item.id,
    );
    return detail == null ? item : MaterialRequestBoardItem.fromJson(detail);
  }

  Future<bool> updateStatus(
    String requestId,
    String status, {
    String notes = '',
  }) async {
    final success = await _service.updateMaterialRequestStatus(
      requestId,
      status,
      notes,
    );
    if (success) await fetchRequests();
    return success;
  }

  Future<bool> sendQuotation(String requestId, Map<String, dynamic> payload) =>
      _service.sendQuotation(requestId, payload);

  Future<bool> markItemDelivered({
    required String requestId,
    required String itemId,
    required String deliveryId,
    required String deliveryReference,
  }) => _service.markItemDelivered(
    requestId: requestId,
    itemId: itemId,
    deliveryId: deliveryId,
    deliveryReference: deliveryReference,
  );

  Future<bool> addRequest(MaterialRequestBoardItem request) async {
    final leadId = _projectIdsByName[request.project] ?? '';
    if (leadId.isEmpty) {
      AppToast.showError(
        title: 'Project Required',
        description: 'Select a live project before submitting.',
      );
      return false;
    }
    final payload = {
      'leadId': leadId,
      'siteLocation': request.site,
      'department': request.department,
      'priority': request.priority.toLowerCase(),
      if (request.requiredBy != null)
        'requiredBy': request.requiredBy!.toIso8601String().split('T')[0],
      'requestedItems': request.items
          .map(
            (i) => {
              'name': i.name,
              'quantity': i.quantity,
              'unit': i.unit,
              'notes': i.remarks,
            },
          )
          .toList(),
    };

    final success = await _service.createMaterialRequest(payload);
    if (success) {
      AppToast.showSuccess(
        title: 'Success',
        description: 'Material Request submitted successfully!',
      );
      resetPagination();
      fetchRequests();
      return true;
    } else {
      AppToast.showError(
        title: 'Error',
        description: 'Failed to submit Material Request.',
      );
      return false;
    }
  }

  Future<bool> cancelRequest(
    String requestId,
    String databaseId, {
    String reason = 'Cancelled by user',
  }) async {
    isLoading.value = true;
    try {
      final success = await _service.updateMaterialRequestStatus(
        databaseId.isNotEmpty ? databaseId : requestId,
        'cancelled',
        reason,
      );
      if (success) {
        AppToast.showSuccess(
          title: 'Request Cancelled',
          description: 'Material Request #$requestId has been cancelled.',
        );
        // Optimistically update memory list
        final index = requests.indexWhere((r) => r.id == requestId);
        if (index != -1) {
          final old = requests[index];
          requests[index] = MaterialRequestBoardItem(
            id: old.id,
            databaseId: old.databaseId,
            project: old.project,
            site: old.site,
            department: old.department,
            requestedBy: old.requestedBy,
            requestDate: old.requestDate,
            requiredBy: old.requiredBy,
            requestedItemsCount: old.requestedItemsCount,
            status: MaterialRequestStatus.cancelled,
            priority: old.priority,
            statusColor: const Color(0xFFEF4444),
            priorityColor: old.priorityColor,
            items: old.items,
            itemsPreview: old.itemsPreview,
            requestedById: old.requestedById,
            requestedByRole: old.requestedByRole,
            requestNotes: old.requestNotes,
          );
          _recomputeFiltered();
        }
        await fetchRequests();
        return true;
      } else {
        AppToast.showError(
          title: 'Action Failed',
          description: 'Could not cancel Material Request. Please try again.',
        );
        return false;
      }
    } on ApiException catch (e) {
      AppToast.showError(title: 'Action Failed', description: e.message);
      return false;
    } catch (e) {
      AppToast.showError(
        title: 'Error',
        description: 'Failed to cancel request: $e',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void nextPage() {
    if (pageIndex.value < totalPages - 1) {
      pageIndex.value++;
      fetchRequests();
    }
  }

  void prevPage() {
    if (pageIndex.value > 0) {
      pageIndex.value--;
      fetchRequests();
    }
  }

  void goToPage(int index) {
    if (index < 0 || index >= totalPages || index == pageIndex.value) return;
    pageIndex.value = index;
    fetchRequests();
  }

  void _recomputeFiltered() {
    // Backend handles filtering and pagination, so we just use the loaded requests.
    filteredRequests.value = requests.toList();
  }

  Future<void> exportReport() async {
    try {
      final rows = <List<Object?>>[
        [
          'Request ID',
          'Project',
          'Site',
          'Department',
          'Status',
          'Priority',
          'Requested By',
          'Request Date',
          'Required By',
        ],
        ...requests.map((r) => [
              r.id,
              r.project,
              r.site,
              r.department,
              r.status.name.toUpperCase(),
              r.priority,
              r.requestedBy,
              r.requestDate.toIso8601String(),
              r.requiredBy?.toIso8601String() ?? '',
            ]),
      ];
      final saved = await file_picker.FilePicker.saveFile(
        dialogTitle: 'Save Material Requests',
        fileName: 'material_requests.csv',
        type: file_picker.FileType.custom,
        allowedExtensions: ['csv'],
        bytes: _encodeCsv(rows),
      );
      if (saved != null) {
        AppToast.showSuccess(
          title: 'Exported',
          description: 'Material requests exported successfully.',
        );
      }
    } catch (e, st) {
      AppLogger.e('Export error', error: e, stackTrace: st, tag: 'MAT_REQ_CTRL');
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
}

class MaterialRequestControllerDateFormatter {
  String shortDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String formatDdMmYyyy(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }
}
