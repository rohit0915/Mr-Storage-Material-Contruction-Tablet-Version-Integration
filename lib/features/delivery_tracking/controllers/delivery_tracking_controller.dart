import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/utils/app_logger.dart';
import '../models/delivery_tracking_models.dart';
import '../services/delivery_tracking_service.dart';

class DeliveryTrackingController extends GetxController {
  DeliveryTrackingController({DeliveryTrackingService? service})
    : _service = service ?? Get.put(DeliveryTrackingService()) {
    materialTypeController.addListener(() {
      materialTypeQuery.value = materialTypeController.text;
    });
  }

  final DeliveryTrackingService _service;

  final isLoading = false.obs;
  final deliveries = <DeliveryItem>[].obs;
  String leadId = '';
  String scopedProject = '';
  String scopedJobId = '';
  bool isProjectScoped = false;

  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedStatus = 'All Statuses'.obs;

  final isFilterByProjectOnly = false.obs;

  // Advanced Filters & Sort State
  final isAdvancedFiltersVisible = false.obs;
  final selectedSort = 'Latest'.obs;
  final selectedProject = 'All Projects'.obs;
  final materialTypeController = TextEditingController();
  final materialTypeQuery = ''.obs;
  final selectedDestination = 'All Destinations'.obs;
  final selectedTransporter = 'All Transporters'.obs;
  final selectedDriver = 'All Drivers'.obs;
  final deliveryDateFrom = Rxn<DateTime>();
  final deliveryDateTo = Rxn<DateTime>();

  final pageIndex = 0.obs;
  final pageSize = 5;

  List<DeliveryItem> get paginatedDeliveries {
    final list = filteredDeliveries;
    final start = pageIndex.value * pageSize;
    if (start >= list.length) return [];
    return list.skip(start).take(pageSize).toList();
  }

  int get totalPages {
    final len = filteredDeliveries.length;
    if (len == 0) return 1;
    return (len / pageSize).ceil();
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

  List<String> get availableProjects {
    final set = <String>{};
    for (final d in baseDeliveries) {
      final p = d.project.trim();
      if (p.isNotEmpty && p != '-' && p.toLowerCase() != 'project') {
        set.add(p);
      }
    }
    final sorted = set.toList()..sort();
    return ['All Projects', ...sorted];
  }

  List<String> get availableDestinations {
    final set = <String>{};
    for (final d in baseDeliveries) {
      final dest = d.finalDestination.trim().isNotEmpty
          ? d.finalDestination.trim()
          : d.location.trim();
      if (dest.isNotEmpty && dest != '-') {
        set.add(dest);
      }
    }
    final sorted = set.toList()..sort();
    return ['All Destinations', ...sorted];
  }

  List<String> get availableTransporters {
    final set = <String>{};
    for (final d in baseDeliveries) {
      final c = d.carrier.trim();
      if (c.isNotEmpty && c != '-' && c.toLowerCase() != 'not assigned') {
        set.add(c);
      }
    }
    final sorted = set.toList()..sort();
    return ['All Transporters', ...sorted];
  }

  List<String> get availableDrivers {
    final set = <String>{};
    for (final d in baseDeliveries) {
      final drv = d.driver.trim();
      if (drv.isNotEmpty && drv != '-') {
        set.add(drv);
      }
    }
    final sorted = set.toList()..sort();
    return ['All Drivers', ...sorted];
  }

  int get activeFiltersCount {
    int count = 0;
    if (selectedProject.value != 'All Projects') count++;
    if (materialTypeQuery.value.trim().isNotEmpty) count++;
    if (selectedDestination.value != 'All Destinations') count++;
    if (selectedTransporter.value != 'All Transporters') count++;
    if (selectedDriver.value != 'All Drivers') count++;
    if (deliveryDateFrom.value != null) count++;
    if (deliveryDateTo.value != null) count++;
    return count;
  }

  void setSort(String sort) { selectedSort.value = sort; pageIndex.value = 0; }
  void setProject(String proj) { selectedProject.value = proj; pageIndex.value = 0; }
  void setMaterialType(String val) {
    materialTypeController.text = val;
    materialTypeQuery.value = val;
    pageIndex.value = 0;
  }
  void setDestination(String dest) { selectedDestination.value = dest; pageIndex.value = 0; }
  void setTransporter(String trans) { selectedTransporter.value = trans; pageIndex.value = 0; }
  void setDriver(String driver) { selectedDriver.value = driver; pageIndex.value = 0; }
  void setDeliveryDateFrom(DateTime? date) { deliveryDateFrom.value = date; pageIndex.value = 0; }
  void setDeliveryDateTo(DateTime? date) { deliveryDateTo.value = date; pageIndex.value = 0; }

  void clearAllFilters() {
    selectedProject.value = 'All Projects';
    materialTypeController.clear();
    materialTypeQuery.value = '';
    selectedDestination.value = 'All Destinations';
    selectedTransporter.value = 'All Transporters';
    selectedDriver.value = 'All Drivers';
    deliveryDateFrom.value = null;
    deliveryDateTo.value = null;
    selectedStatus.value = 'All Statuses';
    searchController.clear();
    searchQuery.value = '';
    selectedSort.value = 'Latest';
    pageIndex.value = 0;
  }

  DateTime? parseDeliveryDate(String dateStr) {
    if (dateStr.isEmpty || dateStr == '-') return null;

    final direct = DateTime.tryParse(dateStr);
    if (direct != null) return direct;

    final patterns = [
      'MMM d, yyyy hh:mm a',
      'MMM d, yyyy HH:mm',
      'MMM d, yyyy',
      'MMM d, hh:mm a',
      'MMM d, HH:mm',
      'MMM d',
      'yyyy-MM-dd',
      'dd/MM/yyyy',
    ];

    for (final p in patterns) {
      try {
        final parsed = DateFormat(p).parseLoose(dateStr);
        if (parsed.year == 1970) {
          return DateTime(
            DateTime.now().year,
            parsed.month,
            parsed.day,
            parsed.hour,
            parsed.minute,
          );
        }
        return parsed;
      } catch (_) {}
    }
    return null;
  }

  double parseQuantity(String qty) {
    final clean = qty.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(clean) ?? 0.0;
  }

  List<DeliveryItem> get projectDeliveries {
    if (!isProjectScoped) return deliveries;
    return deliveries.where((d) {
      if (scopedJobId.isNotEmpty &&
          (d.jobId.toLowerCase().contains(scopedJobId.toLowerCase()) ||
              d.project.toLowerCase().contains(scopedJobId.toLowerCase()))) {
        return true;
      }
      if (scopedProject.isNotEmpty &&
          d.project.toLowerCase().contains(scopedProject.toLowerCase())) {
        return true;
      }
      if (leadId.isNotEmpty && (d.realMongoId == leadId || d.id == leadId)) {
        return true;
      }
      return false;
    }).toList();
  }

  bool get projectHasDeliveries => projectDeliveries.isNotEmpty;

  List<DeliveryItem> get baseDeliveries {
    if (isProjectScoped &&
        projectHasDeliveries &&
        !isFilterByProjectOnly.value) {
      return projectDeliveries;
    }
    if (isProjectScoped && isFilterByProjectOnly.value) {
      return projectDeliveries;
    }
    return deliveries;
  }

  List<DeliveryItem> get filteredDeliveries {
    var list = List<DeliveryItem>.from(baseDeliveries);

    // Status filter
    if (selectedStatus.value != 'All Statuses') {
      final filterText = selectedStatus.value.toLowerCase();
      list = list
          .where((d) => d.status.name.toLowerCase().contains(filterText))
          .toList();
    }

    // Search query filter
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (d) =>
                d.id.toLowerCase().contains(q) ||
                d.title.toLowerCase().contains(q) ||
                d.project.toLowerCase().contains(q) ||
                d.jobId.toLowerCase().contains(q) ||
                d.driver.toLowerCase().contains(q) ||
                d.truck.toLowerCase().contains(q) ||
                d.carrier.toLowerCase().contains(q) ||
                d.location.toLowerCase().contains(q) ||
                d.finalDestination.toLowerCase().contains(q) ||
                d.notes.toLowerCase().contains(q) ||
                d.status.name.toLowerCase().contains(q),
          )
          .toList();
    }

    // Project filter
    if (selectedProject.value != 'All Projects') {
      final selProj = selectedProject.value.toLowerCase();
      list = list
          .where((d) => d.project.toLowerCase() == selProj)
          .toList();
    }

    // Material type filter
    final matQ = materialTypeQuery.value.trim().toLowerCase();
    if (matQ.isNotEmpty) {
      list = list
          .where(
            (d) =>
                d.title.toLowerCase().contains(matQ) ||
                d.notes.toLowerCase().contains(matQ),
          )
          .toList();
    }

    // Destination filter
    if (selectedDestination.value != 'All Destinations') {
      final selDest = selectedDestination.value.toLowerCase();
      list = list
          .where(
            (d) =>
                d.finalDestination.toLowerCase().contains(selDest) ||
                d.location.toLowerCase().contains(selDest),
          )
          .toList();
    }

    // Transporter filter
    if (selectedTransporter.value != 'All Transporters') {
      final selTrans = selectedTransporter.value.toLowerCase();
      list = list
          .where((d) => d.carrier.toLowerCase() == selTrans)
          .toList();
    }

    // Driver filter
    if (selectedDriver.value != 'All Drivers') {
      final selDriver = selectedDriver.value.toLowerCase();
      list = list
          .where((d) => d.driver.toLowerCase() == selDriver)
          .toList();
    }

    // Date range filter
    if (deliveryDateFrom.value != null || deliveryDateTo.value != null) {
      final from = deliveryDateFrom.value != null
          ? DateTime(
              deliveryDateFrom.value!.year,
              deliveryDateFrom.value!.month,
              deliveryDateFrom.value!.day,
              0,
              0,
              0,
            )
          : null;
      final to = deliveryDateTo.value != null
          ? DateTime(
              deliveryDateTo.value!.year,
              deliveryDateTo.value!.month,
              deliveryDateTo.value!.day,
              23,
              59,
              59,
            )
          : null;

      list = list.where((d) {
        final dtArrival = parseDeliveryDate(d.arrivalAtPlant);
        final dtDeparture = parseDeliveryDate(d.departureFromPlant);
        final dtEta = parseDeliveryDate(d.eta);

        final candidateDates = [dtArrival, dtDeparture, dtEta]
            .whereType<DateTime>()
            .toList();
        if (candidateDates.isEmpty) return false;

        return candidateDates.any((dDate) {
          if (from != null && dDate.isBefore(from)) return false;
          if (to != null && dDate.isAfter(to)) return false;
          return true;
        });
      }).toList();
    }

    // Sorting
    switch (selectedSort.value) {
      case 'Oldest':
        list.sort((a, b) {
          final dateA =
              parseDeliveryDate(a.arrivalAtPlant) ??
              parseDeliveryDate(a.departureFromPlant);
          final dateB =
              parseDeliveryDate(b.arrivalAtPlant) ??
              parseDeliveryDate(b.departureFromPlant);
          if (dateA == null && dateB == null) return a.id.compareTo(b.id);
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateA.compareTo(dateB);
        });
        break;
      case 'Delivery Date':
        list.sort((a, b) {
          final dateA =
              parseDeliveryDate(a.arrivalAtPlant) ??
              parseDeliveryDate(a.departureFromPlant);
          final dateB =
              parseDeliveryDate(b.arrivalAtPlant) ??
              parseDeliveryDate(b.departureFromPlant);
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateA.compareTo(dateB);
        });
        break;
      case 'Quantity':
        list.sort((a, b) {
          final qtyA = parseQuantity(a.quantity);
          final qtyB = parseQuantity(b.quantity);
          return qtyB.compareTo(qtyA);
        });
        break;
      case 'Latest':
      default:
        list.sort((a, b) {
          final dateA =
              parseDeliveryDate(a.arrivalAtPlant) ??
              parseDeliveryDate(a.departureFromPlant);
          final dateB =
              parseDeliveryDate(b.arrivalAtPlant) ??
              parseDeliveryDate(b.departureFromPlant);
          if (dateA == null && dateB == null) return b.id.compareTo(a.id);
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateB.compareTo(dateA);
        });
        break;
    }

    return list;
  }

  void onSearch(String val) {
    searchQuery.value = val;
    pageIndex.value = 0;
  }

  void setStatusFilter(String status) {
    selectedStatus.value = status;
    pageIndex.value = 0;
  }

  void toggleProjectFilter(bool onlyProject) {
    isFilterByProjectOnly.value = onlyProject;
    pageIndex.value = 0;
  }

  final hasApiStats = false.obs;
  final apiInTransit = 0.obs;
  final apiStaged = 0.obs;
  final apiReady = 0.obs;
  final apiTotalToday = 0.obs;

  int get inTransitCount => hasApiStats.value
      ? apiInTransit.value
      : baseDeliveries
            .where((d) => d.status == DeliveryStatus.inTransit)
            .length;

  int get stagedCount => hasApiStats.value
      ? apiStaged.value
      : baseDeliveries.where((d) => d.status == DeliveryStatus.staged).length;

  int get readyCount => hasApiStats.value
      ? apiReady.value
      : baseDeliveries.where((d) => d.status == DeliveryStatus.ready).length;

  int get totalToday => hasApiStats.value
      ? apiTotalToday.value
      : baseDeliveries.where((d) {
          final eta = d.eta.toLowerCase();
          final arrival = d.arrivalAtPlant.toLowerCase();
          return eta.contains('today') || arrival.contains('today');
        }).length;

  @override
  void onInit() {
    super.onInit();
    materialTypeController.addListener(() {
      materialTypeQuery.value = materialTypeController.text;
    });
    final args = Get.arguments;
    if (args is Map) {
      leadId = (args['leadId'] ?? '').toString();
      scopedProject = (args['project'] ?? '').toString();
      scopedJobId = (args['jobId'] ?? '').toString();
      isProjectScoped =
          args['fromProject'] == true ||
          leadId.isNotEmpty ||
          scopedJobId.isNotEmpty;
    }
    fetchDeliveries();
  }

  Future<void> fetchDeliveries() async {
    isLoading.value = true;
    try {
      final res = await _service.getDeliveries(leadId: leadId);
      if (res != null) {
        List list = [];
        if (res is Map) {
          if (res['deliveries'] is List) {
            list = res['deliveries'] as List;
          }
          if (res['stats'] is Map) {
            final st = res['stats'] as Map;
            apiInTransit.value = (st['inTransit'] as num?)?.toInt() ?? 0;
            apiStaged.value = (st['staged'] as num?)?.toInt() ?? 0;
            apiReady.value = (st['ready'] as num?)?.toInt() ?? 0;
            apiTotalToday.value = (st['totalToday'] as num?)?.toInt() ?? 0;
            hasApiStats.value = true;
          }
        } else if (res is List) {
          list = res;
        }

        final parsed = <DeliveryItem>[];
        for (final item in list) {
          if (item is Map) {
            parsed.add(DeliveryItem.fromJson(Map<String, dynamic>.from(item)));
          }
        }
        deliveries.assignAll(parsed);
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'fetchDeliveries Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'DELIVERY_CTRL',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markReceived(String id) async {
    final idx = deliveries.indexWhere((d) => d.id == id || d.realMongoId == id);
    if (idx >= 0) {
      final target = deliveries[idx];
      deliveries[idx] = target.copyWith(status: DeliveryStatus.delivered);
      final reqId = target.realMongoId.isNotEmpty
          ? target.realMongoId
          : target.id;
      final success = await _service.markReceived(reqId);
      if (!success) {
        deliveries[idx] = target;
      } else {
        await fetchDeliveries();
      }
    }
  }

  Future<void> markPartialReceived(String id, String notes) async {
    final idx = deliveries.indexWhere((d) => d.id == id || d.realMongoId == id);
    if (idx >= 0) {
      final target = deliveries[idx];
      deliveries[idx] = target.copyWith(status: DeliveryStatus.staged);
      final reqId = target.realMongoId.isNotEmpty
          ? target.realMongoId
          : target.id;
      final success = await _service.markPartial(reqId, notes);
      if (!success) {
        deliveries[idx] = target;
      } else {
        await fetchDeliveries();
      }
    }
  }

  Future<DeliveryItem?> getDeliveryDetail(String id) async {
    final local = deliveries.firstWhereOrNull(
      (d) => d.id == id || d.realMongoId == id,
    );
    final requestId = local?.realMongoId.isNotEmpty == true
        ? local!.realMongoId
        : id;
    final data = await _service.getDeliveryDetail(requestId);
    return data == null ? local : DeliveryItem.fromJson(data);
  }

  Future<bool> updateSiteContact(
    String id,
    Map<String, dynamic> contactData,
  ) async {
    final idx = deliveries.indexWhere((d) => d.id == id || d.realMongoId == id);
    final reqId = idx >= 0 && deliveries[idx].realMongoId.isNotEmpty
        ? deliveries[idx].realMongoId
        : id;
    return await _service.updateSiteContact(reqId, contactData);
  }

  Future<bool> scanQrCode(String code, {String? projectId}) async {
    return await _service.scanQrCode(code, projectId: projectId);
  }

  @override
  void onClose() {
    searchController.dispose();
    materialTypeController.dispose();
    super.onClose();
  }
}
