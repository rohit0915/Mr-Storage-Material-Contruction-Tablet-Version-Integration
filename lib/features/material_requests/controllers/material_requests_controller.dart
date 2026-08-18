import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/material_request_models.dart';

class MaterialRequestsController extends GetxController {
  // Filter dropdown values
  final projects = const <String>[
    'All Projects',
    'Downtown Office Complex',
    'Residential Tower A',
    'ABC Construction Site A',
    'Riverside Office Complex',
    'XYZ Building Complex',
    'Duplex Villa',
  ];

  final departments = const <String>[
    'All Departments',
    'Construction',
    'Site Engineer',
    'Sales Plant',
  ];

  final requestedByList = const <String>[
    'All',
    'John Smith',
    'Sarah Wilson',
    'Robert Chen',
    'Michael Jordan',
    'James Cooper',
    'Kim',
  ];

  final priorityList = const <String>['Low', 'Medium', 'High'];

  final statusList = const <String>[
    'All Status',
    'Pending',
    'Approved',
    'Rejected',
  ];

  // Main data (mock)
  final requests = <MaterialRequestBoardItem>[
    MaterialRequestBoardItem(
      id: 'MR-2025-0031',
      project: 'Downtown Office Complex',
      site: 'Construction Site A',
      department: 'Construction',
      requestedBy: 'John Smith',
      requestDate: DateTime(2025, 5, 19, 16, 30),
      requiredBy: DateTime(2025, 5, 23),
      requestedItemsCount: 8,
      itemsPreview: 'Steel, Cements, Rocks...',
      status: MaterialRequestStatus.pending,
      priority: 'High',
      statusColor: const Color(0xFFFFC107),
      priorityColor: const Color(0xFFBE185D),
      items: const [
        MaterialRequestItemRow(name: 'Steel Beams', unit: 'kg', quantity: 5000, remarks: 'For Ground Floor'),
        MaterialRequestItemRow(name: 'Cement 50 kg', unit: 'Bags', quantity: 300, remarks: 'Ordinary Portland'),
        MaterialRequestItemRow(name: 'Rebar 12 mm', unit: 'kg', quantity: 3000, remarks: 'Fe 500'),
        MaterialRequestItemRow(name: 'Bricks (Red)', unit: 'Nos', quantity: 10000, remarks: 'Standard Quality'),
        MaterialRequestItemRow(name: 'Sand', unit: 'CFT', quantity: 500, remarks: 'River Sand'),
        MaterialRequestItemRow(name: 'Gravel', unit: 'CFT', quantity: 400, remarks: '-'),
        MaterialRequestItemRow(name: 'Plywood Sheets', unit: 'Sheets', quantity: 120, remarks: 'Shuttering'),
        MaterialRequestItemRow(name: 'Binding Wire', unit: 'kg', quantity: 200, remarks: 'GI Wire'),
      ],
    ),
    MaterialRequestBoardItem(
      id: 'MR-2025-0032',
      project: 'Residential Tower A',
      site: 'Residential Site B',
      department: 'Site Engineer',
      requestedBy: 'Sarah Wilson',
      requestDate: DateTime(2025, 5, 18, 10, 10),
      requiredBy: DateTime(2025, 5, 22),
      requestedItemsCount: 6,
      itemsPreview: 'Cement, Sand, Bricks...',
      status: MaterialRequestStatus.approved,
      priority: 'Medium',
      statusColor: const Color(0xFF22C55E),
      priorityColor: const Color(0xFF2563EB),
      items: const [
        MaterialRequestItemRow(
          name: 'Cement 50 kg',
          unit: 'bags',
          quantity: 220,
          remarks: 'For foundation',
        ),
      ],
    ),
    MaterialRequestBoardItem(
      id: 'MR-2025-0033',
      project: 'ABC Construction Site A',
      site: 'ABC Construction Site A',
      department: 'Construction',
      requestedBy: 'Robert Chen',
      requestDate: DateTime(2025, 5, 17, 12, 0),
      requiredBy: DateTime(2025, 5, 23),
      requestedItemsCount: 10,
      itemsPreview: 'Steel, Rebar, Gravel...',
      status: MaterialRequestStatus.rejected,
      priority: 'Low',
      statusColor: const Color(0xFFEF4444),
      priorityColor: const Color(0xFF8B5CF6),
      items: const [
        MaterialRequestItemRow(
          name: 'Bricks (Red)',
          unit: 'nos',
          quantity: 10000,
          remarks: 'Standard quality',
        ),
      ],
    ),
  ].obs;

  final selectedProject = 'All Projects'.obs;
  final selectedDepartment = 'All Departments'.obs;
  final selectedRequestedBy = 'All'.obs;
  final selectedStatus = 'All Status'.obs;

  final dateFrom = Rxn<DateTime>();
  final dateTo = Rxn<DateTime>();

  // Pagination
  final pageIndex = 0.obs; // 0-based
  final pageSize = 10;

  final filteredRequests = <MaterialRequestBoardItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _recomputeFiltered();
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
    _recomputeFiltered();
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
    _recomputeFiltered();
  }

  Future<void> openDetails(MaterialRequestBoardItem item) async {
    // details dialog is defined in the widget file
    return;
  }

  Future<bool> addRequest(MaterialRequestBoardItem request) async {
    requests.add(request);
    resetPagination();
    _recomputeFiltered();
    return true;
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

/// Local date formatting so we don't add intl dependency to this feature.
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

