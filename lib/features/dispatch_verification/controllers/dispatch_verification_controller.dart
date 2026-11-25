import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../bundle_scan/models/bundle_scan_models.dart';
import '../models/dispatch_verification_models.dart';
import '../services/dispatch_verification_service.dart';

class DispatchVerificationController extends GetxController {
  DispatchVerificationController({DispatchVerificationService? service})
    : _service = service ?? DispatchVerificationService();

  final DispatchVerificationService _service;
  TextEditingController _searchController = TextEditingController();
  TextEditingController get searchController {
    try {
      final _ = _searchController.text;
    } catch (_) {
      _searchController = TextEditingController(text: searchQuery.value);
    }
    return _searchController;
  }

  TextEditingController _projectSearchController = TextEditingController();
  TextEditingController get projectSearchController {
    try {
      final _ = _projectSearchController.text;
    } catch (_) {
      _projectSearchController =
          TextEditingController(text: projectSearchQuery.value);
    }
    return _projectSearchController;
  }

  TextEditingController _bundleSearchController = TextEditingController();
  TextEditingController get bundleSearchController {
    try {
      final _ = _bundleSearchController.text;
    } catch (_) {
      _bundleSearchController =
          TextEditingController(text: bundleSearchQuery.value);
    }
    return _bundleSearchController;
  }
  final isLoading = false.obs;
  final isStep2Loading = false.obs;
  final isStep3Loading = false.obs;

  /// Current Step:
  /// 1 = Project List (Image 1)
  /// 2 = Packing List / Loads for Project (Image 2)
  /// 3 = Bundle List for Load (Image 3)
  /// 4 = Bundle Detail & Verification (Image 4)
  final currentStep = 1.obs;
  final fromDeliveryTracking = false.obs;

  void resetToStep1() {
    currentStep.value = 1;
    selectedProject.value = null;
    selectedLoad.value = null;
    selectedBundle.value = null;
    fromDeliveryTracking.value = false;
    isStep2Loading.value = false;
    isStep3Loading.value = false;
  }

  void applyNavigationArguments(dynamic args) {
    if (args is! Map) {
      fromDeliveryTracking.value = false;
      return;
    }

    if (args['fromDeliveryTracking'] == true) {
      fromDeliveryTracking.value = true;
    } else {
      fromDeliveryTracking.value = false;
    }

    final step = args['initialStep'];
    final leadId = (args['leadId'] ?? '').toString();
    final projectId = (args['projectId'] ?? '').toString();
    final projectName = (args['projectName'] ?? '').toString();
    final location = (args['location'] ?? '').toString();

    if (projectName.isNotEmpty || leadId.isNotEmpty || projectId.isNotEmpty) {
      final existing = projects.firstWhereOrNull((p) =>
          (leadId.isNotEmpty && p.leadId == leadId) ||
          (projectId.isNotEmpty &&
              p.projectId.toLowerCase() == projectId.toLowerCase()) ||
          (projectName.isNotEmpty &&
              p.projectName.toLowerCase() == projectName.toLowerCase()));

      final proj = existing ??
          DispatchProjectItem(
            leadId: leadId,
            projectId: projectId.isNotEmpty ? projectId : 'PRJ',
            projectName: projectName.isNotEmpty ? projectName : 'Project',
            siteLocation: location,
            totalPackingLists: 0,
            totalBundles: 0,
            loads: [],
          );

      selectedProject.value = proj;
      if (step == 2 || step == null) {
        currentStep.value = 2;
        pageIndex.value = 0;
        searchQuery.value = '';
        searchController.clear();
        fetchLoadsForProject(proj);
      }
    } else if (step is int) {
      currentStep.value = step;
    }
  }

  // Selected Entities
  final projects = <DispatchProjectItem>[].obs;
  final selectedProject = Rxn<DispatchProjectItem>();
  final selectedLoad = Rxn<DispatchItem>();
  final selectedBundle = Rxn<BundleScanItem>();

  // Step 1: Project List Filters & Pagination
  final projectSearchQuery = ''.obs;
  final selectedProjectFilter = 'All Projects'.obs;
  final projectDateFrom = Rxn<DateTime>();
  final projectDateTo = Rxn<DateTime>();
  final projectDateRange = 'All Dates'.obs;
  final projectPageIndex = 0.obs;
  final projectPageSize = 10.obs;

  // Step 2: Loads Filters & Pagination
  final allItems = <DispatchItem>[].obs;
  final selectedItem = Rxn<DispatchItem>();
  final searchQuery = ''.obs;
  final selectedStatus = 'All Statuses'.obs;
  final selectedSort = 'Latest'.obs;
  final pageIndex = 0.obs;
  final pageSize = 10.obs;
  final pageSizeOptions = const [10, 15, 20, 25, 50];

  // Step 3: Bundle Filters & Pagination
  final bundleSearchQuery = ''.obs;
  final selectedBundleStatus = 'Status - All Status'.obs;
  final bundlePageIndex = 0.obs;
  final bundlePageSize = 10.obs;
  final bundlePageSizeOptions = const [10, 15, 20, 25, 50];

  void setBundlePageSize(int size) {
    if (bundlePageSize.value == size) return;
    bundlePageSize.value = size;
    bundlePageIndex.value = 0;
  }

  void setPageSize(int size) {
    if (pageSize.value == size) return;
    pageSize.value = size;
    pageIndex.value = 0;
  }

  void setProjectPageSize(int size) {
    if (projectPageSize.value == size) return;
    projectPageSize.value = size;
    projectPageIndex.value = 0;
  }

  // Reactive Stats matching Web Panel
  final loadsReadyCount = 0.obs;
  final bundlesVerifiedCount = 0.obs;
  final bundlesMissingCount = 0.obs;
  final dispatchedTodayCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      applyNavigationArguments(Get.arguments);
    }
    fetchDispatchesFromApi();
  }

  Future<void> fetchDispatchesFromApi() async {
    isLoading.value = true;
    try {
      final pList = await _service.fetchDispatchProjects();
      projects.assignAll(pList);

      final res = await _service.fetchDispatchVerificationsData();
      final list = (res['items'] as List<DispatchItem>?) ?? [];
      allItems.assignAll(list);
      if (res['stats'] is Map) {
        final st = res['stats'] as Map;
        loadsReadyCount.value =
            (st['loadsReady'] as num?)?.toInt() ?? list.length;
        bundlesVerifiedCount.value =
            (st['bundlesVerified'] as num?)?.toInt() ?? 0;
        bundlesMissingCount.value =
            (st['bundlesMissing'] as num?)?.toInt() ?? 0;
        dispatchedTodayCount.value =
            (st['dispatchedToday'] as num?)?.toInt() ?? 0;
      }

      if (selectedProject.value != null) {
        final currentLeadId = selectedProject.value!.leadId;
        final currentProjId = selectedProject.value!.projectId.toLowerCase();
        final currentName = selectedProject.value!.projectName.toLowerCase();
        final match = pList.firstWhereOrNull((p) =>
            (currentLeadId.isNotEmpty && p.leadId == currentLeadId) ||
            (currentProjId.isNotEmpty &&
                p.projectId.toLowerCase() == currentProjId) ||
            (currentName.isNotEmpty &&
                p.projectName.toLowerCase() == currentName));
        if (match != null) {
          final mergedLoads = match.loads.isNotEmpty
              ? match.loads
              : selectedProject.value!.loads;
          selectedProject.value = match.copyWith(loads: mergedLoads);
          if (mergedLoads.isEmpty) {
            fetchLoadsForProject(selectedProject.value!);
          }
        } else if (selectedProject.value!.loads.isEmpty) {
          fetchLoadsForProject(selectedProject.value!);
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Step 1: Filtered Projects
  List<DispatchProjectItem> get filteredProjects {
    var list = List<DispatchProjectItem>.from(projects);
    if (selectedProjectFilter.value != 'All Projects') {
      final filter = selectedProjectFilter.value.toLowerCase();
      list = list.where((p) => p.projectName.toLowerCase() == filter).toList();
    }
    final q = projectSearchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((p) =>
        p.projectId.toLowerCase().contains(q) ||
        p.projectName.toLowerCase().contains(q) ||
        p.siteLocation.toLowerCase().contains(q),
      ).toList();
    }

    final from = projectDateFrom.value;
    final to = projectDateTo.value;
    if (from != null || to != null) {
      final start = from != null ? DateTime(from.year, from.month, from.day) : null;
      final end = to != null ? DateTime(to.year, to.month, to.day, 23, 59, 59) : null;
      list = list.where((p) {
        final d = p.createdAt;
        if (d != null) {
          if (start != null && d.isBefore(start)) return false;
          if (end != null && d.isAfter(end)) return false;
          return true;
        }
        for (final l in p.loads) {
          final ld = l.createdAt;
          if (ld != null) {
            if (start != null && ld.isBefore(start)) continue;
            if (end != null && ld.isAfter(end)) continue;
            return true;
          }
        }
        return false;
      }).toList();
    }

    return list;
  }

  int get totalProjectPages =>
      (filteredProjects.length / projectPageSize.value).ceil().clamp(1, 999);

  List<DispatchProjectItem> get pageProjects {
    final list = filteredProjects;
    final start = projectPageIndex.value * projectPageSize.value;
    if (start >= list.length) return [];
    final end = (start + projectPageSize.value).clamp(0, list.length);
    return list.sublist(start, end);
  }

  void onProjectSearch(String q) {
    projectSearchQuery.value = q;
    projectPageIndex.value = 0;
  }

  void setProjectFilter(String projName) {
    selectedProjectFilter.value = projName;
    projectPageIndex.value = 0;
  }

  void setProjectDateRange(DateTime? from, DateTime? to) {
    projectDateFrom.value = from;
    projectDateTo.value = to;
    if (from == null && to == null) {
      projectDateRange.value = 'All Dates';
    } else if (from != null && to != null) {
      if (from.year == to.year && from.month == to.month && from.day == to.day) {
        projectDateRange.value = DateFormat('MMM d, yyyy').format(from);
      } else {
        projectDateRange.value =
            '${DateFormat('MMM d').format(from)} - ${DateFormat('MMM d, yyyy').format(to)}';
      }
    } else if (from != null) {
      projectDateRange.value = 'From ${DateFormat('MMM d, yyyy').format(from)}';
    } else if (to != null) {
      projectDateRange.value = 'Until ${DateFormat('MMM d, yyyy').format(to)}';
    }
    projectPageIndex.value = 0;
  }

  void nextProjectPage() {
    if (projectPageIndex.value < totalProjectPages - 1) projectPageIndex.value++;
  }

  void prevProjectPage() {
    if (projectPageIndex.value > 0) projectPageIndex.value--;
  }

  void goToProjectPage(int p) {
    projectPageIndex.value = p.clamp(0, totalProjectPages - 1);
  }

  // Navigation between Steps
  void selectProject(DispatchProjectItem proj) {
    selectedProject.value = proj;
    currentStep.value = 2;
    pageIndex.value = 0;
    searchQuery.value = '';
    searchController.clear();
    fetchLoadsForProject(proj);
  }

  Future<void> fetchLoadsForProject(DispatchProjectItem proj) async {
    isStep2Loading.value = true;
    try {
      List<DispatchItem> loads = [];
      if (proj.leadId.isNotEmpty) {
        try {
          loads = await _service.fetchProjectLoads(proj.leadId);
        } catch (_) {}
      }
      if (loads.isEmpty && allItems.isNotEmpty) {
        final pName = proj.projectName.toLowerCase();
        final pId = proj.projectId.toLowerCase();
        loads = allItems.where((i) {
          return (pName.isNotEmpty && i.project.toLowerCase() == pName) ||
              (pId.isNotEmpty && i.jobId.toLowerCase() == pId);
        }).toList();
      }
      final candidateLoads = loads.isNotEmpty ? loads : proj.loads;
      if (candidateLoads.isNotEmpty) {
        final seen = <String>{};
        final uniqueLoads = <DispatchItem>[];
        for (final l in candidateLoads) {
          final id = l.displayLoadId.isNotEmpty ? l.displayLoadId : l.loadId;
          if (seen.add(id)) {
            uniqueLoads.add(l);
          }
        }
        final updatedProj = proj.copyWith(loads: uniqueLoads);
        selectedProject.value = updatedProj;
        final idx = projects.indexWhere((p) =>
            (proj.leadId.isNotEmpty && p.leadId == proj.leadId) ||
            (proj.projectId.isNotEmpty && p.projectId == proj.projectId));
        if (idx >= 0) projects[idx] = updatedProj;

        // Populate bundles count for each load if bundles == 0
        for (var i = 0; i < uniqueLoads.length; i++) {
          final loadItem = uniqueLoads[i];
          if (loadItem.bundles == 0) {
            final targetId = loadItem.mongoId.isNotEmpty ? loadItem.mongoId : loadItem.loadId;
            if (targetId.isNotEmpty) {
              _service.getDispatchLoadDetail(targetId, packingListId: loadItem.packingListMongoId).then((res) {
                if (res != null) {
                  final bList = res['bundles'] ?? res['items'] ?? res['bundleItems'];
                  if (bList is List && bList.isNotEmpty) {
                    final parsedList = <DispatchBundleItem>[];
                    for (var bi = 0; bi < bList.length; bi++) {
                      final bm = bList[bi];
                      if (bm is Map) {
                        parsedList.add(DispatchBundleItem.fromJson(Map<String, dynamic>.from(bm), bi));
                      }
                    }
                    final updatedLoad = loadItem.copyWith(
                      bundles: bList.length,
                      bundleList: parsedList,
                    );
                    final currentLoads = List<DispatchItem>.from(selectedProject.value?.loads ?? []);
                    final lIdx = currentLoads.indexWhere((it) => it.loadId == loadItem.loadId || it.displayLoadId == loadItem.displayLoadId);
                    if (lIdx >= 0) {
                      currentLoads[lIdx] = updatedLoad;
                      selectedProject.value = selectedProject.value?.copyWith(loads: currentLoads);
                      final aIdx = allItems.indexWhere((it) => it.loadId == loadItem.loadId || it.displayLoadId == loadItem.displayLoadId);
                      if (aIdx >= 0) allItems[aIdx] = updatedLoad;
                    }
                  }
                }
              });
            }
          }
        }
      }
    } catch (_) {
    } finally {
      isStep2Loading.value = false;
    }
  }

  void selectLoad(DispatchItem load) {
    selectedLoad.value = load;
    isStep3Loading.value = true;
    currentStep.value = 3;
    bundleSearchQuery.value = '';
    bundleSearchController.clear();
    bundlePageIndex.value = 0;
    fetchLoadDetail(load);
  }

  void selectBundle(BundleScanItem bundle) {
    selectedBundle.value = bundle;
    currentStep.value = 4;
  }

  void goBack() {
    if (currentStep.value == 4) {
      currentStep.value = 3;
    } else if (currentStep.value == 3) {
      currentStep.value = 2;
    } else if (currentStep.value == 2) {
      if (fromDeliveryTracking.value) {
        Get.back();
      } else {
        currentStep.value = 1;
      }
    } else {
      Get.back();
    }
  }

  // Step 2: Loads filtered by selected project
  List<DispatchItem> get projectLoads {
    if (selectedProject.value != null) {
      if (selectedProject.value!.loads.isNotEmpty) {
        return selectedProject.value!.loads;
      }
      final pName = selectedProject.value!.projectName.toLowerCase();
      final pId = selectedProject.value!.projectId.toLowerCase();
      final match = allItems.where((i) {
        return i.project.toLowerCase() == pName ||
            i.jobId.toLowerCase() == pId ||
            selectedProject.value!.loads.any((l) => l.loadId == i.loadId);
      }).toList();
      if (match.isNotEmpty) return match;
    }
    return allItems;
  }

  // Step 2 Stats
  int get step2TotalPackingList => projectLoads
      .map((l) => l.packingListNo)
      .where((s) => s.isNotEmpty)
      .toSet()
      .length
      .clamp(1, 999);

  int get step2LoadsReady => projectLoads
      .where((l) =>
          l.status == DispatchStatus.verified ||
          l.statusText.toUpperCase().contains('READY'))
      .length;

  int get step2BundlesAssigned =>
      projectLoads.fold<int>(0, (sum, l) => sum + (l.bundles > 0 ? l.bundles : 4));

  int get step2LoadsDispatched => projectLoads
      .where((l) => l.statusText.toUpperCase().contains('DISPATCH'))
      .length;

  // Step 3: Bundles for selected Load
  List<BundleScanItem> get currentLoadBundles {
    final load = selectedLoad.value;
    if (load == null) return [];

    final result = <BundleScanItem>[];
    if (load.bundleList.isNotEmpty) {
      for (var i = 0; i < load.bundleList.length; i++) {
        final b = load.bundleList[i];
        final partsVal = b.parts.isNotEmpty ? b.parts : 'STL-B${12 + i}';
        final timeVal = b.time.isNotEmpty ? b.time : '10:32 AM';
        final weightVal = b.weight != '-' ? b.weight : '18,500 LBS';
        final isReady = b.isVerified || b.statusText == 'Ready';
        final isMismatch = b.statusText == 'Mismatch';
        final statusEnum = isReady
            ? BundleScanStatus.ready
            : (isMismatch ? BundleScanStatus.pending : BundleScanStatus.staging);

        final rawBundleId = b.bundleId;
        final bool isHex = rawBundleId.length == 24 && RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(rawBundleId);
        final displayId = isHex ? 'BND-${(i + 1).toString().padLeft(3, '0')}' : rawBundleId;
        final mongoId = b.realMongoId.isNotEmpty ? b.realMongoId : (isHex ? rawBundleId : '');

        result.add(
          BundleScanItem(
            id: mongoId.isNotEmpty ? mongoId : displayId,
            realMongoId: mongoId,
            bundleId: displayId,
            projectId: selectedProject.value?.leadId ?? '',
            project: load.project.isNotEmpty
                ? load.project
                : (selectedProject.value?.projectName ?? 'Project'),
            jobId: load.jobId.isNotEmpty
                ? load.jobId
                : (selectedProject.value?.projectId ?? 'PRJ-2025-0031'),
            site: load.destination.isNotEmpty
                ? load.destination
                : (selectedProject.value?.siteLocation ?? 'Site A'),
            parts: partsVal,
            totalWeight: weightVal,
            time: timeVal,
            status: statusEnum,
            statusText: b.statusText.isNotEmpty ? b.statusText : (isReady ? 'Ready' : 'Staging'),
            loadId: load.displayLoadId,
            truck: load.truck,
            quantity: b.quantity.isNotEmpty ? b.quantity : '7',
            length: b.length.isNotEmpty ? b.length : '20 ft',
            shipper: b.shipper.isNotEmpty ? b.shipper : 'SHP-1044',
            driver: load.driver.isNotEmpty ? load.driver : 'John Miller',
            totalProducts: b.totalProducts.isNotEmpty ? b.totalProducts : '4',
            packingListNo: load.packingListNo.isNotEmpty ? load.packingListNo : 'PKL-001',
            isVerified: isReady,
            qrUrl: 'project=${selectedProject.value?.projectName ?? "Downtown"}&Load=${load.displayLoadId}&Bundle=${b.bundleId}',
          ),
        );
      }
    }

    var filtered = result;
    if (selectedBundleStatus.value != 'Status - All Status') {
      final filter = selectedBundleStatus.value.toLowerCase();
      filtered = filtered.where((b) => b.statusText.toLowerCase() == filter).toList();
    }
    final q = bundleSearchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      filtered = filtered.where((b) =>
        b.bundleId.toLowerCase().contains(q) ||
        b.parts.toLowerCase().contains(q) ||
        b.totalWeight.toLowerCase().contains(q) ||
        b.statusText.toLowerCase().contains(q),
      ).toList();
    }

    return filtered;
  }

  // Step 3: Bundle Pagination Getters & Handlers
  int get totalBundlePages =>
      (currentLoadBundles.length / bundlePageSize.value).ceil().clamp(1, 999);

  List<BundleScanItem> get pageBundles {
    final list = currentLoadBundles;
    final start = bundlePageIndex.value * bundlePageSize.value;
    if (start >= list.length) return [];
    final end = (start + bundlePageSize.value).clamp(0, list.length);
    return list.sublist(start, end);
  }

  void nextBundlePage() {
    if (bundlePageIndex.value < totalBundlePages - 1) bundlePageIndex.value++;
  }

  void prevBundlePage() {
    if (bundlePageIndex.value > 0) bundlePageIndex.value--;
  }

  void goToBundlePage(int p) {
    bundlePageIndex.value = p.clamp(0, totalBundlePages - 1);
  }

  // Step 3 Stats
  int get step3BundlesScanned =>
      currentLoadBundles.where((b) => b.isVerified || b.statusText == 'Ready').length;
  int get step3BundlesRemaining =>
      currentLoadBundles.where((b) => !b.isVerified && b.statusText != 'Ready').length;
  int get step3BundlesLoaded =>
      currentLoadBundles.where((b) => b.statusText == 'Ready').length;

  final isActionLoading = false.obs;

  Future<bool> verifyDispatch(String loadId, {double? actualWeight}) async {
    isActionLoading.value = true;
    try {
      final success = await _service.verifyLoad(
        loadId,
        actualWeight: actualWeight,
      );
      final idx = allItems.indexWhere((i) => i.loadId == loadId);
      if (success && idx >= 0) {
        allItems[idx] = allItems[idx].copyWith(
          status: DispatchStatus.verified,
          statusText: 'VERIFIED',
          weightVerified: true,
          loadingVerified: true,
        );
        if (selectedItem.value?.loadId == loadId) {
          selectedItem.value = allItems[idx];
        }
      }
      return success;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<bool> confirmDispatch(String loadId, {String? packingListId}) async {
    isActionLoading.value = true;
    try {
      final success = await _service.confirmDispatch(
        loadId,
        packingListId: packingListId,
      );
      final idx = allItems.indexWhere((i) => i.loadId == loadId);
      if (success && idx >= 0) {
        allItems[idx] = allItems[idx].copyWith(
          status: DispatchStatus.verified,
          statusText: 'DISPATCHED',
        );
        if (selectedItem.value?.loadId == loadId) {
          selectedItem.value = allItems[idx];
        }
        dispatchedTodayCount.value++;
        if (loadsReadyCount.value > 0) loadsReadyCount.value--;
      }
      return success;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<void> fetchLoadDetail(DispatchItem item) async {
    selectedItem.value = item;
    isStep3Loading.value = true;
    try {
      final res = await _service.getDispatchLoadDetail(
        item.mongoId.isNotEmpty ? item.mongoId : item.loadId,
        packingListId: item.packingListMongoId.isNotEmpty
            ? item.packingListMongoId
            : item.packingListNo,
      );
      if (res != null) {
        final rawBundles =
            res['bundles'] ?? res['items'] ?? res['bundleItems'];
        if (rawBundles is List && rawBundles.isNotEmpty) {
          final List<DispatchBundleItem> parsedBundles = [];
          for (var i = 0; i < rawBundles.length; i++) {
            final b = rawBundles[i];
            if (b is Map) {
              parsedBundles.add(
                DispatchBundleItem.fromJson(Map<String, dynamic>.from(b), i),
              );
            } else {
              parsedBundles.add(
                DispatchBundleItem(
                  index: i + 1,
                  bundleNo: '${i + 1}',
                  bundleId: b.toString(),
                  weight: '-',
                  status: 'READY',
                  isVerified: true,
                ),
              );
            }
          }
          final updated = item.copyWith(
            bundleList: parsedBundles,
            bundles: parsedBundles.length,
          );
          selectedItem.value = updated;
          if (selectedLoad.value?.loadId == item.loadId ||
              selectedLoad.value?.mongoId == item.mongoId) {
            selectedLoad.value = updated;
          }
          final idx = allItems.indexWhere((it) => it.loadId == item.loadId);
          if (idx >= 0) allItems[idx] = updated;
        }
      }
    } catch (_) {
    } finally {
      isStep3Loading.value = false;
    }
  }

  DispatchItem? findLoadById(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return null;
    return allItems.firstWhereOrNull((item) {
      return item.loadId.toLowerCase() == clean ||
          item.displayLoadId.toLowerCase() == clean ||
          item.displayLoadId.toLowerCase().replaceAll('-', '') ==
              clean.replaceAll('-', '') ||
          item.packingListNo.toLowerCase() == clean ||
          item.packingListNo.toLowerCase().replaceAll('-', '') ==
              clean.replaceAll('-', '') ||
          item.mongoId.toLowerCase() == clean;
    });
  }

  Future<String?> exportExcel() => _service.exportDispatchVerifications();

  List<DispatchItem> get filteredItems {
    var list = List<DispatchItem>.from(projectLoads);
    if (selectedStatus.value != 'All Statuses') {
      final filterText = selectedStatus.value.toUpperCase();
      list = list
          .where(
            (i) =>
                i.statusText.toUpperCase().contains(filterText) ||
                i.status.name.toUpperCase().contains(filterText),
          )
          .toList();
    }
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (i) =>
                i.displayLoadId.toLowerCase().contains(q) ||
                i.loadId.toLowerCase().contains(q) ||
                i.packingListNo.toLowerCase().contains(q) ||
                i.project.toLowerCase().contains(q) ||
                i.jobId.toLowerCase().contains(q) ||
                i.driver.toLowerCase().contains(q) ||
                i.truck.toLowerCase().contains(q) ||
                i.destination.toLowerCase().contains(q) ||
                i.totalWeight.toLowerCase().contains(q) ||
                i.statusText.toLowerCase().contains(q),
          )
          .toList();
    }

    if (selectedSort.value == 'Weight High to Low') {
      list.sort(
        (a, b) =>
            _parseWeight(b.totalWeight).compareTo(_parseWeight(a.totalWeight)),
      );
    } else if (selectedSort.value == 'Weight Low to High') {
      list.sort(
        (a, b) =>
            _parseWeight(a.totalWeight).compareTo(_parseWeight(b.totalWeight)),
      );
    } else if (selectedSort.value == 'Oldest') {
      list = list.reversed.toList();
    }

    return list;
  }

  double _parseWeight(String w) {
    final clean = w.replaceAll('LBS', '').replaceAll(',', '').trim();
    return double.tryParse(clean) ?? 0.0;
  }

  void setStatusFilter(String s) {
    selectedStatus.value = s;
    pageIndex.value = 0;
  }

  void setSort(String s) {
    selectedSort.value = s;
  }

  int get totalPages => (filteredItems.length / pageSize.value).ceil().clamp(1, 999);

  List<DispatchItem> get pageItems {
    final list = filteredItems;
    final start = pageIndex.value * pageSize.value;
    if (start >= list.length) return [];
    final end = (start + pageSize.value).clamp(0, list.length);
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
    super.onClose();
  }
}
