import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/utils/app_logger.dart';
import '../../../app/utils/app_toast.dart';
import '../models/task_models.dart';
import '../services/tasks_service.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/daily_work_log_dialog.dart';
import '../widgets/task_success_dialog.dart';

class TasksController extends GetxController {
  TasksController({TasksService? tasksService})
      : _tasksService = tasksService ?? Get.put(TasksService());

  final TasksService _tasksService;

  final tasks = <TaskBoardItem>[].obs;
  final isLoading = false.obs;

  final totalTasksCount = 0.obs;
  final completedCountStat = 0.obs;
  final inProgressCountStat = 0.obs;
  final overdueCountStat = 0.obs;

  int get todoCount => tasks.where((t) => t.column == TaskColumn.todo).length;
  int get inProgressCount => tasks.where((t) => t.column == TaskColumn.inProgress).length;
  int get doneCount => tasks.where((t) => t.column == TaskColumn.done).length;

  List<TaskBoardItem> itemsFor(TaskColumn column) =>
      tasks.where((t) => t.column == column).toList();

  @override
  void onInit() {
    super.onInit();
    fetchTasksAndStats();
  }

  Future<void> fetchTasksAndStats() async {
    isLoading.value = true;
    try {
      final statsData = await _tasksService.getTaskStats();
      if (statsData != null && statsData['stats'] is Map) {
        final st = statsData['stats'] as Map;
        totalTasksCount.value = (st['total'] as num?)?.toInt() ?? 0;
        completedCountStat.value = (st['completed'] as num?)?.toInt() ?? 0;
        inProgressCountStat.value = (st['inProgress'] as num?)?.toInt() ?? 0;
        overdueCountStat.value = (st['overdue'] as num?)?.toInt() ?? 0;
      }

      final tasksData = await _tasksService.getTasks();
      if (tasksData != null && tasksData['tasks'] is List) {
        final list = tasksData['tasks'] as List;
        final parsed = <TaskBoardItem>[];
        for (final item in list) {
          if (item is Map) {
            parsed.add(TaskBoardItem.fromJson(Map<String, dynamic>.from(item)));
          }
        }
        tasks.assignAll(parsed);
      }
    } catch (e, stackTrace) {
      AppLogger.e('fetchTasksAndStats Error', error: e, stackTrace: stackTrace, tag: 'TASKS_CTRL');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> moveTask(TaskBoardItem item, TaskColumn targetColumn) async {
    final index = tasks.indexWhere((t) => t.id == item.id);
    if (index != -1) {
      final old = tasks[index];
      tasks[index] = old.copyWith(
        column: targetColumn,
        completed: targetColumn == TaskColumn.done,
      );
      tasks.refresh();

      String apiStatus = 'todo';
      if (targetColumn == TaskColumn.inProgress) {
        apiStatus = 'in_progress';
      } else if (targetColumn == TaskColumn.done) {
        apiStatus = 'done';
      }

      final success = await _tasksService.updateTask(old.id, {'status': apiStatus});
      if (!success) {
        tasks[index] = old;
        tasks.refresh();
        AppToast.showError(title: 'Update Failed', description: 'Failed to update task status on server.');
      } else {
        fetchTasksAndStats();
      }
    }
  }

  Future<void> openDailyWorkLog(BuildContext context) async {
    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const DailyWorkLogDialog(),
    );
    if (created == true && context.mounted) {
      fetchTasksAndStats();
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const TaskSuccessDialog(
          title: 'Work Log added Successfully',
        ),
      );
    }
  }

  Future<void> openAddTask(BuildContext context) async {
    final created = await showDialog<TaskBoardItem>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddTaskDialog(),
    );
    if (created != null) {
      fetchTasksAndStats();
      if (context.mounted) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const TaskSuccessDialog(
            title: 'Task added Successfully',
          ),
        );
      }
    }
  }
}
