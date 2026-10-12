import 'dart:async';
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
  final allDeliveries = <DeliveryItem>[].obs;
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

  // API filter options and project lookups
  final apiDestinations = <String>[].obs;
  final apiTransporters = <String>[].obs;
  final apiDrivers = <String>[].obs;
  final apiStatuses = <String>[].obs;
  final projectLookup = <String, String>{}.obs; // id / leadId / jobId -> projectName
  final projectIdLookup = <String, String>{}.obs; // projectName -> leadId / id

  Timer? _searchDebounce;
  Timer? _materialDebounce;

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

  String resolveProjectName(DeliveryItem item) {
    final p = item.project.trim();
    if (p.isNotEmpty &&
        p != '-' &&
        p.toLowerCase() != 'project' &&
        !RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(p)) {
      return p;
    }

    String? lookup(String key) {
      if (key.isEmpty) return null;
      if (projectLookup.containsKey(key)) return projectLookup[key];
      final kl = key.toLowerCase();
      for (final entry in projectLookup.entries) {
        if (entry.key.toLowerCase() == kl) return entry.value;
      }
      return null;
    }

    final byLead = lookup(item.leadId);
    if (byLead != null && byLead.isNotEmpty) return byLead;

    final byProjId = lookup(item.projectMongoId);
    if (byProjId != null && byProjId.isNotEmpty) return byProjId;

    final byJob = lookup(item.jobId);
    if (byJob != null && byJob.isNotEmpty) return byJob;

    final byReal = lookup(item.realMongoId);
    if (byReal != null && byReal.isNotEmpty) return byReal;

    final byP = lookup(p);
    if (byP != null && byP.isNotEmpty) return byP;

    if (isProjectScoped && scopedProject.isNotEmpty) {
      return scopedProject;
    }
    return p.isNotEmpty && p.toLowerCase() != 'project' ? p : '';
  }

  List<String> get availableProjects {
    final set = <String>{};
    for (final d in baseDeliveries) {
      final p = resolveProjectName(d).trim();
      if (p.isNotEmpty && p != '-' && p.toLowerCase() != 'project') {
        set.add(p);
      }
    }
    for (final p in projectLookup.values) {
      if (p.isNotEmpty && p != '-' && p.toLowerCase() != 'project') {
        set.add(p);
      }
    }
    final sorted = set.toList()..sort();
    return ['All Projects', ...sorted];
  }

  List<String> get availableDestinations {
    final set = <String>{};
    set.addAll(apiDestinations);
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
    set.addAll(apiTransporters);
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
    set.addAll(apiDrivers);
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

  void setSort(String sort) {
    selectedSort.value = sort;
    pageIndex.value = 0;
    fetchDeliveries(isFilterUpdate: true);
  }

  void setProject(String proj) {
    selectedProject.value = proj;
    pageIndex.value = 0;
    fetchDeliveries(isFilterUpdate: true);
  }

  void setMaterialType(String val) {
    materialTypeController.text = val;
    materialTypeQuery.value = val;
    pageIndex.value = 0;
    _materialDebounce?.cancel();
    _materialDebounce = Timer(const Duration(milliseconds: 400), () {
      fetchDeliveries(isFilterUpdate: true);
    });
  }

  void setDestination(String dest) {
    selectedDestination.value = dest;
    pageIndex.value = 0;
    fetchDeliveries(isFilterUpdate: true);
  }

  void setTransporter(String trans) {
    selectedTransporter.value = trans;
    pageIndex.value = 0;
    fetchDeliveries(isFilterUpdate: true);
  }

  void setDriver(String driver) {
    selectedDriver.value = driver;
    pageIndex.value = 0;
    fetchDeliveries(isFilterUpdate: true);
  }

  void setDeliveryDateFrom(DateTime? date) {
    deliveryDateFrom.value = date;
    pageIndex.value = 0;
    fetchDeliveries(isFilterUpdate: true);
  }

  void setDeliveryDateTo(DateTime? date) {
    deliveryDateTo.value = date;
    pageIndex.value = 0;
    fetchDeliveries(isFilterUpdate: true);
  }

  void setStatusFilter(String status) {
    selectedStatus.value = status;
    pageIndex.value = 0;
    fetchDeliveries(isFilterUpdate: true);
  }

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
    fetchDeliveries(isFilterUpdate: true);
  }

  DateTime? parseDeliveryDate(String dateStr) {
    if (dateStr.isEmpty || dateStr == '-') return null;

    var clean = dateStr.trim();
    if (clean.toLowerCase().startsWith('eta')) {
      clean = clean.substring(3).trim();
    }
    if (clean.isEmpty || clean == '-') return null;

    final direct = DateTime.tryParse(clean);
    if (direct != null) return direct;

    final patterns = [
      'MMM d, yyyy hh:mm a',
      'MMM d, yyyy h:mm a',
      'MMM d, yyyy HH:mm',
      'MMM d, yyyy H:mm',
      'MMM d, yyyy',
      'MMM dd, yyyy',
      'MMMM d, yyyy',
      'MMM d, hh:mm a',
      'MMM d, h:mm a',
      'MMM d, HH:mm',
      'MMM d',
      'yyyy-MM-dd HH:mm:ss',
      'yyyy-MM-dd',
      'dd/MM/yyyy',
      'MM/dd/yyyy',
    ];

    for (final p in patterns) {
      try {
        final parsed = DateFormat(p).parseLoose(clean);
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
    final source = deliveries.isNotEmpty ? deliveries : allDeliveries;
    if (!isProjectScoped) return source;
    return source.where((d) {
      final pName = resolveProjectName(d).toLowerCase();
      if (scopedJobId.isNotEmpty &&
          (d.jobId.toLowerCase().contains(scopedJobId.toLowerCase()) ||
              d.project.toLowerCase().contains(scopedJobId.toLowerCase()) ||
              pName.contains(scopedJobId.toLowerCase()))) {
        return true;
      }
      if (scopedProject.isNotEmpty &&
          (d.project.toLowerCase().contains(scopedProject.toLowerCase()) ||
              pName.contains(scopedProject.toLowerCase()))) {
        return true;
      }
      if (leadId.isNotEmpty &&
          (d.realMongoId == leadId ||
              d.id == leadId ||
              d.leadId == leadId ||
              d.projectMongoId == leadId)) {
        return true;
      }
      return false;
    }).toList();
  }

  bool get projectHasDeliveries => projectDeliveries.isNotEmpty;

  List<DeliveryItem> get baseDeliveries {
    final source = deliveries.isNotEmpty ? deliveries : allDeliveries;
    if (isProjectScoped &&
        projectHasDeliveries &&
        !isFilterByProjectOnly.value) {
      return projectDeliveries;
    }
    if (isProjectScoped && isFilterByProjectOnly.value) {
      return projectDeliveries;
    }
    return source;
  }

  List<DeliveryItem> get filteredDeliveries {
    var list = List<DeliveryItem>.from(baseDeliveries);

    // Status filter
    if (selectedStatus.value != 'All Statuses') {
      final filterText = selectedStatus.value.toLowerCase().replaceAll('_', ' ');
      list = list
          .where((d) => d.status.name.toLowerCase().contains(filterText) ||
              d.status.name.toLowerCase().replaceAll('_', ' ').contains(filterText))
          .toList();
    }

    // Search query filter (Project name, delivery #, material, driver, location, etc.)
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (d) {
              final pName = resolveProjectName(d).toLowerCase();
              return d.id.toLowerCase().contains(q) ||
                  d.realMongoId.toLowerCase().contains(q) ||
                  d.title.toLowerCase().contains(q) ||
                  d.project.toLowerCase().contains(q) ||
                  pName.contains(q) ||
                  d.jobId.toLowerCase().contains(q) ||
                  d.leadId.toLowerCase().contains(q) ||
                  d.projectMongoId.toLowerCase().contains(q) ||
                  d.driver.toLowerCase().contains(q) ||
                  d.truck.toLowerCase().contains(q) ||
                  d.carrier.toLowerCase().contains(q) ||
                  d.location.toLowerCase().contains(q) ||
                  d.finalDestination.toLowerCase().contains(q) ||
                  d.stagingArea.toLowerCase().contains(q) ||
                  d.notes.toLowerCase().contains(q) ||
                  d.status.name.toLowerCase().contains(q);
            },
          )
          .toList();
    }

    // Project filter
    if (selectedProject.value != 'All Projects') {
      final selProj = selectedProject.value.toLowerCase();
      list = list
          .where((d) {
            final pName = resolveProjectName(d).toLowerCase();
            return d.project.toLowerCase() == selProj || pName == selProj;
          })
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
          .where((d) =>
              d.carrier.toLowerCase().contains(selTrans) ||
              selTrans.contains(d.carrier.toLowerCase()))
          .toList();
    }

    // Driver filter
    if (selectedDriver.value != 'All Drivers') {
      final selDriver = selectedDriver.value.toLowerCase();
      list = list
          .where((d) =>
              d.driver.toLowerCase().contains(selDriver) ||
              selDriver.contains(d.driver.toLowerCase()))
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
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      fetchDeliveries(isSearch: true);
    });
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
    fetchFiltersAndProjects();
    fetchDeliveries();
  }

  Future<void> fetchFiltersAndProjects() async {
    // 1. Fetch filters from /construction/deliveries/filters
    try {
      final fData = await _service.getDeliveryFilters();
      if (fData != null) {
        if (fData['siteDestinations'] is List) {
          apiDestinations.assignAll(
            (fData['siteDestinations'] as List).map((e) => e.toString()).toList(),
          );
        }
        if (fData['transporters'] is List) {
          apiTransporters.assignAll(
            (fData['transporters'] as List).map((e) => e.toString()).toList(),
          );
        }
        if (fData['drivers'] is List) {
          apiDrivers.assignAll(
            (fData['drivers'] as List).map((e) => e.toString()).toList(),
          );
        }
        if (fData['deliveryStatuses'] is List) {
          apiStatuses.assignAll(
            (fData['deliveryStatuses'] as List).map((e) => e.toString()).toList(),
          );
        }
      }
    } catch (_) {}

    // 2. Fetch projects from /construction/projects
    try {
      final pList = await _service.getProjects();
      for (final p in pList) {
        final id = (p['id'] ?? '').toString();
        final name = (p['name'] ?? '').toString();
        final jId = (p['jobId'] ?? '').toString();
        final lId = (p['leadId'] ?? '').toString();
        if (name.isNotEmpty) {
          if (id.isNotEmpty) {
            projectLookup[id] = name;
            projectIdLookup[name] = id;
          }
          if (lId.isNotEmpty) {
            projectLookup[lId] = name;
          }
          if (jId.isNotEmpty) {
            projectLookup[jId] = name;
          }
        }
      }
    } catch (_) {}
  }

  Future<void> fetchDeliveries({bool isFilterUpdate = false, bool isSearch = false}) async {
    if (!isFilterUpdate && !isSearch) {
      isLoading.value = true;
    }
    try {
      final query = searchQuery.value.trim();
      final selProj = selectedProject.value;
      String? reqLeadId;
      if (selProj != 'All Projects') {
        reqLeadId = projectIdLookup[selProj];
        if (reqLeadId == null || reqLeadId.isEmpty) {
          for (final entry in projectLookup.entries) {
            if (entry.value.toLowerCase() == selProj.toLowerCase()) {
              reqLeadId = entry.key;
              break;
            }
          }
        }
      } else if (leadId.isNotEmpty) {
        reqLeadId = leadId;
      } else if (query.isNotEmpty) {
        // If user is searching by project name, resolve the corresponding leadId for backend
        final qLower = query.toLowerCase();
        for (final entry in projectIdLookup.entries) {
          if (entry.key.toLowerCase().contains(qLower) || qLower.contains(entry.key.toLowerCase())) {
            reqLeadId = entry.value;
            break;
          }
        }
        if (reqLeadId == null) {
          for (final entry in projectLookup.entries) {
            if (entry.value.toLowerCase().contains(qLower) || qLower.contains(entry.value.toLowerCase())) {
              reqLeadId = entry.key;
              break;
            }
          }
        }
      }

      final selStatus = selectedStatus.value != 'All Statuses' ? selectedStatus.value : null;
      final selSort = selectedSort.value;
      final matType = materialTypeQuery.value.trim();
      final dest = selectedDestination.value != 'All Destinations' ? selectedDestination.value : null;
      final transp = selectedTransporter.value != 'All Transporters' ? selectedTransporter.value : null;
      final driv = selectedDriver.value != 'All Drivers' ? selectedDriver.value : null;
      final startDateStr = deliveryDateFrom.value != null ? DateFormat('yyyy-MM-dd').format(deliveryDateFrom.value!) : null;
      final endDateStr = deliveryDateTo.value != null ? DateFormat('yyyy-MM-dd').format(deliveryDateTo.value!) : null;

      final res = await _service.getDeliveries(
        leadId: reqLeadId,
        search: query.isNotEmpty ? query : null,
        status: selStatus,
        sortBy: selSort,
        materialType: matType.isNotEmpty ? matType : null,
        siteDestination: dest,
        transporter: transp,
        driver: driv,
        startDate: startDateStr,
        endDate: endDateStr,
      );
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

        // Cache any observed project names from deliveries into projectLookup
        for (final d in parsed) {
          final p = d.project.trim();
          if (p.isNotEmpty && p != '-' && p.toLowerCase() != 'project' && !RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(p)) {
            if (d.leadId.isNotEmpty) {
              projectLookup[d.leadId] = p;
              projectIdLookup[p] = d.leadId;
            }
            if (d.projectMongoId.isNotEmpty) {
              projectLookup[d.projectMongoId] = p;
            }
            if (d.jobId.isNotEmpty) {
              projectLookup[d.jobId] = p;
            }
            if (d.realMongoId.isNotEmpty) {
              projectLookup[d.realMongoId] = p;
            }
          }
        }

        if (!isSearch) {
          allDeliveries.assignAll(parsed);
          deliveries.assignAll(parsed);
        } else {
          // If searching: retain master list items and merge with newly returned items
          final mergedMap = <String, DeliveryItem>{};
          for (final item in allDeliveries) {
            final key = item.realMongoId.isNotEmpty ? item.realMongoId : item.id;
            mergedMap[key] = item;
          }
          for (final item in parsed) {
            final key = item.realMongoId.isNotEmpty ? item.realMongoId : item.id;
            mergedMap[key] = item;
          }
          deliveries.assignAll(mergedMap.values.toList());
        }
      }
    } catch (e, stackTrace) {
      AppLogger.e(
        'fetchDeliveries Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'DELIVERY_CTRL',
      );
    } finally {
      if (!isFilterUpdate && !isSearch) {
        isLoading.value = false;
      }
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
    _searchDebounce?.cancel();
    _materialDebounce?.cancel();
    searchController.dispose();
    materialTypeController.dispose();
    super.onClose();
  }
}
