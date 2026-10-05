import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/utils/app_logger.dart';
import '../../../app/utils/app_toast.dart';
import '../models/work_log_model.dart';
import '../services/work_logs_service.dart';
import '../widgets/create_work_log_dialog.dart';
import '../widgets/work_log_details_dialog.dart';

class DailyWorkLogsController extends GetxController {
  DailyWorkLogsController({WorkLogsService? service})
      : _service = service ?? Get.put(WorkLogsService());

  final WorkLogsService _service;

  final isLoading = false.obs;
  final isCreating = false.obs;

  final workLogs = <WorkLogItem>[].obs;
  final allWorkLogs = <WorkLogItem>[].obs;

  final projects = <Map<String, String>>[].obs;
  final tasks = <Map<String, String>>[].obs;

  final searchController = TextEditingController();
  final searchQuery = ''.obs;
  final selectedProject = 'All Projects'.obs;

  // Pagination states
  final currentPage = 1.obs;
  final pageSize = 20.obs;
  final totalResults = 0.obs;
  final totalPages = 1.obs;

  final pageSizeOptions = const [10, 20, 50, 100];

  @override
  void onInit() {
    super.onInit();
    projects.assignAll(WorkLogsService.defaultProjectsList());
    allWorkLogs.assignAll(WorkLogItem.defaultLogs());
    workLogs.assignAll(WorkLogItem.defaultLogs());
    totalResults.value = workLogs.length;
    totalPages.value = 1;

    loadProjectsAndTasks();
    fetchWorkLogs();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadProjectsAndTasks() async {
    try {
      final pList = await _service.getProjects();
      if (pList.isNotEmpty) {
        projects.assignAll(pList);
      }
      final tList = await _service.getTasks();
      if (tList.isNotEmpty) {
        tasks.assignAll(tList);
      }
    } catch (_) {}
  }

  Future<void> fetchWorkLogs() async {
    isLoading.value = true;
    try {
      String? leadId;
      if (selectedProject.value != 'All Projects' && selectedProject.value.isNotEmpty) {
        final match = projects.firstWhere(
          (p) => p['name'] == selectedProject.value || p['displayName'] == selectedProject.value,
          orElse: () => {'id': ''},
        );
        leadId = match['id'];
      }

      final res = await _service.getWorkLogs(
        leadId: leadId,
        search: searchQuery.value,
        page: currentPage.value,
        limit: pageSize.value,
      );

      List rawList = [];
      if (res is Map) {
        if (res['data'] is List) {
          rawList = res['data'] as List;
        } else if (res['data'] is Map && res['data']['items'] is List) {
          rawList = res['data']['items'] as List;
        } else if (res['logs'] is List) {
          rawList = res['logs'] as List;
        } else if (res['workLogs'] is List) {
          rawList = res['workLogs'] as List;
        }

        // Pagination metadata
        final rawTotal = res['total'] ??
            res['totalCount'] ??
            res['totalResults'] ??
            res['pagination']?['total'];
        if (rawTotal != null) {
          totalResults.value = int.tryParse(rawTotal.toString()) ?? rawList.length;
        }

        final rawPages = res['totalPages'] ??
            res['pages'] ??
            res['pagination']?['totalPages'];
        if (rawPages != null) {
          totalPages.value = int.tryParse(rawPages.toString()) ?? 1;
        }
      } else if (res is List) {
        rawList = res;
        totalResults.value = rawList.length;
        totalPages.value = (rawList.length / pageSize.value).ceil().clamp(1, 999);
      }

      if (rawList.isNotEmpty) {
        final parsed = rawList
            .whereType<Map>()
            .map((e) => WorkLogItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        allWorkLogs.assignAll(parsed);
        applyLocalFilters();
      } else if (allWorkLogs.isEmpty) {
        allWorkLogs.assignAll(WorkLogItem.defaultLogs());
        applyLocalFilters();
      } else {
        applyLocalFilters();
      }
    } catch (e, stackTrace) {
      AppLogger.e('fetchWorkLogs Error', error: e, stackTrace: stackTrace, tag: 'DAILY_LOGS_CTRL');
      if (allWorkLogs.isEmpty) {
        allWorkLogs.assignAll(WorkLogItem.defaultLogs());
      }
      applyLocalFilters();
    } finally {
      isLoading.value = false;
    }
  }

  void onSearch(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
    applyLocalFilters();
  }

  void onProjectChanged(String? project) {
    if (project == null) return;
    selectedProject.value = project;
    currentPage.value = 1;
    applyLocalFilters();
    fetchWorkLogs();
  }

  void resetFilters() {
    searchController.clear();
    searchQuery.value = '';
    selectedProject.value = 'All Projects';
    currentPage.value = 1;
    applyLocalFilters();
    fetchWorkLogs();
  }

  void applyLocalFilters() {
    var filtered = List<WorkLogItem>.from(allWorkLogs);

    if (selectedProject.value != 'All Projects' && selectedProject.value.isNotEmpty) {
      filtered = filtered.where((item) =>
          item.projectName.toLowerCase() == selectedProject.value.toLowerCase() ||
          item.jobId == selectedProject.value).toList();
    }

    if (searchQuery.value.trim().isNotEmpty) {
      final q = searchQuery.value.trim().toLowerCase();
      filtered = filtered.where((item) {
        return item.workDescription.toLowerCase().contains(q) ||
            item.taskTitle.toLowerCase().contains(q) ||
            item.projectName.toLowerCase().contains(q) ||
            item.jobId.toLowerCase().contains(q) ||
            item.loggedByName.toLowerCase().contains(q);
      }).toList();
    }

    totalResults.value = filtered.length;
    totalPages.value = (filtered.length / pageSize.value).ceil().clamp(1, 999);

    if (currentPage.value > totalPages.value) {
      currentPage.value = 1;
    }

    // Pagination slice
    final start = (currentPage.value - 1) * pageSize.value;
    final end = (start + pageSize.value).clamp(0, filtered.length);
    if (start < filtered.length) {
      workLogs.assignAll(filtered.sublist(start, end));
    } else {
      workLogs.assignAll(filtered);
    }
  }

  void changePage(int newPage) {
    if (newPage < 1 || newPage > totalPages.value) return;
    currentPage.value = newPage;
    applyLocalFilters();
  }

  void changePageSize(int newSize) {
    pageSize.value = newSize;
    currentPage.value = 1;
    applyLocalFilters();
  }

  Future<void> openCreateLogDialog(BuildContext context) async {
    final newItem = await CreateWorkLogDialog.show(
      context,
      projects: projects.toList(),
      tasks: tasks.toList(),
      initialProject: selectedProject.value != 'All Projects' ? selectedProject.value : 'Storage 0011',
    );

    if (newItem != null) {
      isCreating.value = true;
      try {
        final payload = {
          'leadId': newItem.leadId,
          'taskId': newItem.taskId.isNotEmpty ? newItem.taskId : null,
          'date': newItem.date.toIso8601String().split('T')[0],
          'progress': newItem.progress,
          'description': newItem.workDescription,
          'photos': newItem.photos,
          'issues': newItem.issues != '—' ? newItem.issues : '',
        };

        final success = await _service.createWorkLog(payload);
        if (success) {
          AppToast.showSuccess(title: 'Work log created successfully');
        } else {
          // If server fails or mock, keep locally
          AppToast.showInfo(title: 'Work log added', description: 'Saved locally for your session.');
        }

        allWorkLogs.insert(0, newItem);
        applyLocalFilters();
      } catch (e) {
        allWorkLogs.insert(0, newItem);
        applyLocalFilters();
      } finally {
        isCreating.value = false;
      }
    }
  }

  void openLogDetails(BuildContext context, WorkLogItem item) {
    WorkLogDetailsDialog.show(context, item);
  }
}
