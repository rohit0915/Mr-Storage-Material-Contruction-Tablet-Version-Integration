import 'package:get/get.dart';

import '../../../app/utils/app_logger.dart';
import '../../../app/utils/app_toast.dart';
import '../models/material_request_models.dart';
import '../services/material_requests_service.dart';

class MaterialRequestsController extends GetxController {
  MaterialRequestsController({MaterialRequestsService? service})
      : _service = service ?? Get.put(MaterialRequestsService());

  final MaterialRequestsService _service;

  final projects = <String>['All Projects'].obs;
  final departments = <String>['All Departments'].obs;
  final requestedByList = <String>['All'].obs;
  final priorityList = const <String>['Low', 'Medium', 'High'];
  final statusList = const <String>['All Status', 'Pending', 'Approved', 'Rejected'];

  final requests = <MaterialRequestBoardItem>[].obs;
  final isLoading = false.obs;

  final totalRequestsStat = 0.obs;
  final pendingStat = 0.obs;
  final approvedStat = 0.obs;
  final rejectedStat = 0.obs;

  final selectedProject = 'All Projects'.obs;
  final selectedDepartment = 'All Departments'.obs;
  final selectedRequestedBy = 'All'.obs;
  final selectedStatus = 'All Status'.obs;

  final dateFrom = Rxn<DateTime>();
  final dateTo = Rxn<DateTime>();

  // Pagination
  final pageIndex = 0.obs;
  final pageSize = 10;

  final filteredRequests = <MaterialRequestBoardItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    isLoading.value = true;
    try {
      final res = await _service.getMaterialRequests(
        leadId: selectedProject.value,
        department: selectedDepartment.value,
        status: selectedStatus.value,
        requestedBy: selectedRequestedBy.value,
        dateFrom: dateFrom.value?.toIso8601String(),
        dateTo: dateTo.value?.toIso8601String(),
      );

      if (res != null) {
        if (res['stats'] is Map) {
          final st = res['stats'] as Map;
          totalRequestsStat.value = (st['totalRequests'] as num?)?.toInt() ?? (st['total'] as num?)?.toInt() ?? 0;
          pendingStat.value = (st['pending'] as num?)?.toInt() ?? 0;
          approvedStat.value = (st['approved'] as num?)?.toInt() ?? 0;
          rejectedStat.value = (st['rejected'] as num?)?.toInt() ?? 0;
        }

        if (res['materialRequests'] is List) {
          final list = res['materialRequests'] as List;
          final parsed = <MaterialRequestBoardItem>[];
          final pOpts = <String>{'All Projects'};
          final dOpts = <String>{'All Departments'};
          final rOpts = <String>{'All'};

          for (final item in list) {
            if (item is Map) {
              final boardItem = MaterialRequestBoardItem.fromJson(Map<String, dynamic>.from(item));
              parsed.add(boardItem);

              if (boardItem.project.isNotEmpty && boardItem.project != 'No Project') {
                pOpts.add(boardItem.project);
              }
              if (boardItem.department.isNotEmpty) {
                dOpts.add(boardItem.department);
              }
              if (boardItem.requestedBy.isNotEmpty && boardItem.requestedBy != 'Unassigned') {
                rOpts.add(boardItem.requestedBy);
              }
            }
          }

          projects.assignAll(pOpts.toList());
          departments.assignAll(dOpts.toList());
          requestedByList.assignAll(rOpts.toList());
          requests.assignAll(parsed);
        }
      }
    } catch (e, stackTrace) {
      AppLogger.e('fetchRequests Error', error: e, stackTrace: stackTrace, tag: 'MAT_REQ_CTRL');
    } finally {
      isLoading.value = false;
      _recomputeFiltered();
    }
  }

  void resetPagination() {
    pageIndex.value = 0;
  }

  void setFilters({
    String? project,
    String? department,
    String? requestedBy,
    String? status,
    DateTime? from,
    DateTime? to,
  }) {
    if (project != null) selectedProject.value = project;
    if (department != null) selectedDepartment.value = department;
    if (requestedBy != null) selectedRequestedBy.value = requestedBy;
    if (status != null) selectedStatus.value = status;
    if (from != null) dateFrom.value = from;
    if (to != null) dateTo.value = to;

    resetPagination();
    fetchRequests();
  }

  List<MaterialRequestBoardItem> get pageRequests {
    final start = pageIndex.value * pageSize;
    return filteredRequests.skip(start).take(pageSize).toList();
  }

  int get totalPages {
    if (filteredRequests.isEmpty) return 1;
    return ((filteredRequests.length) / pageSize).ceil();
  }

  String get dateRangeLabel {
    final f = dateFrom.value;
    final t = dateTo.value;
    if (f == null || t == null) return 'May 1 - May 31, 2025';
    final fmt = MaterialRequestControllerDateFormatter();
    return '${fmt.shortDate(f)} - ${fmt.shortDate(t)}';
  }

  void clearDateRange() {
    dateFrom.value = null;
    dateTo.value = null;
    resetPagination();
    fetchRequests();
  }

  Future<void> openDetails(MaterialRequestBoardItem item) async {
    return;
  }

  Future<bool> addRequest(MaterialRequestBoardItem request) async {
    final payload = {
      'siteLocation': request.site,
      'department': request.department,
      'priority': request.priority.toLowerCase(),
      'requiredBy': request.requiredBy.toIso8601String().split('T')[0],
      'requestedItems': request.items
          .map((i) => {
                'name': i.name,
                'quantity': i.quantity,
                'unit': i.unit,
                'notes': i.remarks,
              })
          .toList(),
    };

    final success = await _service.createMaterialRequest(payload);
    if (success) {
      AppToast.showSuccess(title: 'Success', description: 'Material Request submitted successfully!');
      resetPagination();
      fetchRequests();
      return true;
    } else {
      AppToast.showError(title: 'Error', description: 'Failed to submit Material Request.');
      return false;
    }
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

  void _recomputeFiltered() {
    final list = requests.where((r) {
      final matchesProject =
          selectedProject.value == 'All Projects' || r.project == selectedProject.value;
      final matchesDept = selectedDepartment.value == 'All Departments' ||
          r.department == selectedDepartment.value;
      final matchesBy = selectedRequestedBy.value == 'All' ||
          r.requestedBy == selectedRequestedBy.value;
      final matchesStatus = selectedStatus.value == 'All Status' ||
          (selectedStatus.value == 'Pending' && r.status == MaterialRequestStatus.pending) ||
          (selectedStatus.value == 'Approved' && r.status == MaterialRequestStatus.approved) ||
          (selectedStatus.value == 'Rejected' && r.status == MaterialRequestStatus.rejected);

      final f = dateFrom.value;
      final t = dateTo.value;
      final matchesDate = (f == null || t == null)
          ? true
          : r.requestDate.isAfter(f.subtract(const Duration(days: 1))) &&
              r.requestDate.isBefore(t.add(const Duration(days: 1)));

      return matchesProject && matchesDept && matchesBy && matchesStatus && matchesDate;
    }).toList();

    filteredRequests.value = list;
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
}

