import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/task_models.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/daily_work_log_dialog.dart';
import '../widgets/task_success_dialog.dart';

class TasksController extends GetxController {
  final tasks = <TaskBoardItem>[
    TaskBoardItem(
      id: '1',
      title: 'Steel Frame Installation',
      project: 'Downtown Office Complex',
      description: 'Install steel frame structure for floors 1-5.',
      assignee: 'Sarah Wilson',
      dueDate: DateTime(2024, 2, 15),
      priority: 'High',
      column: TaskColumn.todo,
    ),
    TaskBoardItem(
      id: '2',
      title: 'Steel Frame Installation',
      project: 'Downtown Office Complex',
      description: 'Excavation for building foundation and site prep.',
      assignee: 'Sarah Wilson',
      dueDate: DateTime(2024, 2, 15),
      priority: 'High',
      column: TaskColumn.inProgress,
    ),
    TaskBoardItem(
      id: '3',
      title: 'Plumbing Installation',
      project: 'Residential Tower A',
      description: 'Install plumbing lines for residential units.',
      assignee: 'Sarah Wilson',
      dueDate: DateTime(2024, 2, 15),
      priority: 'High',
      column: TaskColumn.inProgress,
    ),
    TaskBoardItem(
      id: '4',
      title: 'Electrical Wiring - Floor 1',
      project: 'Residential Tower A',
      description: 'Complete electrical wiring installation for first floor units.',
      assignee: 'Robert Chen',
      dueDate: DateTime(2024, 2, 15),
      priority: 'High',
      column: TaskColumn.done,
      completed: true,
    ),
  ].obs;

  int get todoCount =>
      tasks.where((t) => t.column == TaskColumn.todo).length;
  int get inProgressCount =>
      tasks.where((t) => t.column == TaskColumn.inProgress).length;
  int get doneCount =>
      tasks.where((t) => t.column == TaskColumn.done).length;

  List<TaskBoardItem> itemsFor(TaskColumn column) =>
      tasks.where((t) => t.column == column).toList();

  Future<void> openDailyWorkLog(BuildContext context) async {
    final created = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const DailyWorkLogDialog(),
    );
    if (created == true && context.mounted) {
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
      tasks.add(created);
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
