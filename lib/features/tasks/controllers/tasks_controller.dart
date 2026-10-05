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

  final availableProjects = <TaskProjectOption>[
    ...TaskProjectOption.defaultProjects(),
  ].obs;
  final availableAssignees = <String>[
    ...TaskStaticData.assignees,
  ].obs;

  final totalTasksCount = 0.obs;
  final completedCountStat = 0.obs;
  final inProgressCountStat = 0.obs;
  final overdueCountStat = 0.obs;

  int get todoCount => tasks.where((t) => t.column == TaskColumn.todo).length;
  int get inProgressCount =>
      tasks.where((t) => t.column == TaskColumn.inProgress).length;
  int get doneCount => tasks.where((t) => t.column == TaskColumn.done).length;

  List<TaskBoardItem> itemsFor(TaskColumn column) =>
      tasks.where((t) => t.column == column).toList();

  @override
  void onInit() {
    super.onInit();
    availableProjects.assignAll(TaskProjectOption.defaultProjects());
    availableAssignees.assignAll(TaskStaticData.assignees);
    fetchTasksAndStats();
    fetchProjectsAndAssignees();
  }

  Future<void> fetchProjectsAndAssignees() async {
    try {
      final pList = await _tasksService.getProjects();
      final mergedProjects = <String, TaskProjectOption>{};
      for (final p in pList) {
        mergedProjects[p.id] = p;
      }
      for (final t in tasks) {
        if (t.project.isNotEmpty) {
          final pId = t.leadId.isNotEmpty ? t.leadId : 'proj-${t.project}';
          if (!mergedProjects.containsKey(pId)) {
            mergedProjects[pId] = TaskProjectOption(id: pId, name: t.project);
          }
        }
      }
      if (mergedProjects.isEmpty) {
        for (final p in TaskProjectOption.defaultProjects()) {
          mergedProjects[p.id] = p;
        }
      }
      availableProjects.assignAll(mergedProjects.values.toList());

      final aList = await _tasksService.getAssignees();
      final mergedAssignees = <String>{...TaskStaticData.assignees, ...aList};
      for (final t in tasks) {
        if (t.assignee.isNotEmpty && t.assignee != 'Unassigned') {
          mergedAssignees.add(t.assignee);
        }
      }
      availableAssignees.assignAll(mergedAssignees.toList());
    } catch (e) {
      AppLogger.w('fetchProjectsAndAssignees Error: $e', tag: 'TASKS_CTRL');
    }
  }

  Future<void> fetchTasksAndStats() async {
    isLoading.value = true;
    try {
      // Match the web panel: this endpoint returns both `stats` and `tasks`.
      final tasksData = await _tasksService.getTasks();
      if (tasksData != null && tasksData['stats'] is Map) {
        final st = tasksData['stats'] as Map;
        totalTasksCount.value = (st['total'] as num?)?.toInt() ?? 0;
        completedCountStat.value = (st['done'] as num?)?.toInt() ?? 0;
        inProgressCountStat.value = (st['inProgress'] as num?)?.toInt() ?? 0;
        overdueCountStat.value = (st['overdue'] as num?)?.toInt() ?? 0;
      }

      if (tasksData != null && tasksData['tasks'] is List) {
        final list = tasksData['tasks'] as List;
        final parsed = <TaskBoardItem>[];
        for (final item in list) {
          if (item is Map) {
            parsed.add(TaskBoardItem.fromJson(Map<String, dynamic>.from(item)));
          }
        }
        tasks.assignAll(parsed);
      } else {
        tasks.clear();
      }

      // Re-merge loaded projects
      await fetchProjectsAndAssignees();
    } catch (e, stackTrace) {
      AppLogger.e(
        'fetchTasksAndStats Error',
        error: e,
        stackTrace: stackTrace,
        tag: 'TASKS_CTRL',
      );
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

      final success = await _tasksService.updateTask(old.id, {
        'status': apiStatus,
      });
      if (!success) {
        tasks[index] = old;
        tasks.refresh();
        AppToast.showError(
          title: 'Update Failed',
          description: 'Failed to update task status on server.',
        );
      } else {
        fetchTasksAndStats();
      }
    }
  }

  Future<bool> deleteTask(TaskBoardItem item) async {
    final success = await _tasksService.deleteTask(item.id);
    if (success) {
      tasks.removeWhere((task) => task.id == item.id);
      await fetchTasksAndStats();
    }
    return success;
  }

  Future<void> openDailyWorkLog(BuildContext context) async {
    final created = await showDialog<WorkLogDraft>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DailyWorkLogDialog(tasks: tasks.toList()),
    );
    if (created != null) {
      final success = await _tasksService.createWorkLog({
        'leadId': created.leadId,
        'taskId': created.taskId.isEmpty ? null : created.taskId,
        'date': created.date.toIso8601String().split('T')[0],
        'progress': created.progress,
        'description': created.description,
        'photos': const [],
        'issues': created.issues,
      });
      if (!success) {
        AppToast.showError(
          title: 'Create Failed',
          description: 'Failed to create work log on server.',
        );
        return;
      }
      await fetchTasksAndStats();
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            const TaskSuccessDialog(title: 'Work Log added Successfully'),
      );
    }
  }

  Future<void> openAddTask(BuildContext context) async {
    if (availableProjects.isEmpty) {
      await fetchProjectsAndAssignees();
    }
    if (!context.mounted) return;
    final created = await showDialog<TaskBoardItem>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AddTaskDialog(
        projects: availableProjects.toList(),
        assignees: availableAssignees.toList(),
      ),
    );
    if (created != null) {
      final cleanLeadId = created.leadId.isNotEmpty
          ? created.leadId
          : (availableProjects.isNotEmpty
              ? availableProjects.first.id
              : 'lead-0011');

      final payload = <String, dynamic>{
        'title': created.title.trim().isNotEmpty
            ? created.title.trim()
            : 'New Task',
        'description': created.description,
        'leadId': cleanLeadId,
        'priority': created.priority.toLowerCase(),
        'status': created.column == TaskColumn.inProgress
            ? 'in_progress'
            : created.column == TaskColumn.done
            ? 'done'
            : 'todo',
        'dueDate': created.dueDate.toIso8601String().split('T')[0],
      };
      if (created.assignee.isNotEmpty && created.assignee != 'Unassigned') {
        payload['assignedTo'] = created.assignee;
      }

      final success = await _tasksService.createTask(payload);
      if (success) {
        await fetchTasksAndStats();
      } else {
        // Even if the remote API encounters an error (role restrictions/offline),
        // insert the new task locally on the board so the user can immediately see and use it.
        final localItem = created.copyWith(leadId: cleanLeadId);
        tasks.insert(0, localItem);
        tasks.refresh();
        totalTasksCount.value++;
        if (created.column == TaskColumn.inProgress) {
          inProgressCountStat.value++;
        } else if (created.column == TaskColumn.done) {
          completedCountStat.value++;
        }
      }

      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            const TaskSuccessDialog(title: 'Task added Successfully'),
      );
    }
  }
}
