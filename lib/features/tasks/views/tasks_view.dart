import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/tasks_controller.dart';
import '../models/task_models.dart';

class TasksView extends GetView<TasksController> {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = size.width * 0.016;
    final padV = size.height * 0.014;
    final gap = size.height * 0.014;

    return AppScaffold(
      menuTitle: 'Tasks',
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padH, gap, padH, padV),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tasks',
              style: TextStyle(
                fontSize: (size.width * 0.018).clamp(20.0, 26.0),
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: gap),
            const _SummaryRow(),
            SizedBox(height: gap),
            Row(
              children: [
                Text(
                  'Task Board',
                  style: TextStyle(
                    fontSize: (size.width * 0.014).clamp(15.0, 18.0),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => controller.openDailyWorkLog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.014,
                      vertical: size.height * 0.014,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Daily Work Log',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(width: size.width * 0.008),
                ElevatedButton(
                  onPressed: () => controller.openAddTask(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.014,
                      vertical: size.height * 0.014,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Add Task',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            SizedBox(height: gap),
            Obx(() {
              final taskList = controller.tasks;
              final todo = taskList
                  .where((t) => t.column == TaskColumn.todo)
                  .toList();
              final inProgress = taskList
                  .where((t) => t.column == TaskColumn.inProgress)
                  .toList();
              final done = taskList
                  .where((t) => t.column == TaskColumn.done)
                  .toList();

              const colGap = 12.0;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _BoardColumn(
                      title: 'To Do (${todo.length})',
                      color: const Color(0xFFF3F4F6),
                      items: todo,
                    ),
                  ),
                  const SizedBox(width: colGap),
                  Expanded(
                    child: _BoardColumn(
                      title: 'In Progress (${inProgress.length})',
                      color: const Color(0xFFE8F1FF),
                      items: inProgress,
                    ),
                  ),
                  const SizedBox(width: colGap),
                  Expanded(
                    child: _BoardColumn(
                      title: 'Done (${done.length})',
                      color: const Color(0xFFE8F8EF),
                      items: done,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gap = (size.width * 0.01).clamp(10.0, 14.0);

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Total Tasks',
            value: '56',
            color: AppColors.primaryBlue,
            icon: Icons.folder_outlined,
          ),
        ),
        SizedBox(width: gap),
        const Expanded(
          child: _SummaryCard(
            label: 'Completed',
            value: '29',
            color: AppColors.success,
            icon: Icons.check_box_outlined,
          ),
        ),
        SizedBox(width: gap),
        const Expanded(
          child: _SummaryCard(
            label: 'In Progress',
            value: '13',
            color: AppColors.chartYellow,
            icon: Icons.access_time,
          ),
        ),
        SizedBox(width: gap),
        const Expanded(
          child: _SummaryCard(
            label: 'Overdue',
            value: '3',
            color: AppColors.danger,
            icon: Icons.verified_user_outlined,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.012,
        vertical: size.height * 0.018,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: (size.width * 0.011).clamp(12.0, 14.0),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: (size.width * 0.022).clamp(24.0, 32.0),
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: Colors.white, size: 32),
        ],
      ),
    );
  }
}

class _BoardColumn extends StatelessWidget {
  const _BoardColumn({
    required this.title,
    required this.color,
    required this.items,
  });

  final String title;
  final Color color;
  final List<TaskBoardItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TaskCard(item: t),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.item});

  final TaskBoardItem item;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('yyyy-MM-dd').format(item.dueDate);
    final isMediumPriority = item.title.contains('Plumbing');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (item.completed)
                const Icon(Icons.check_circle, color: AppColors.success, size: 22)
              else
                _PriorityBadge(
                  priority: item.priority,
                  isMedium: isMediumPriority,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.project,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              height: 1.3,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  item.completed ? 'Completed' : 'Due $dateLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: item.completed
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 10,
                backgroundColor: AppColors.primaryBlue,
                child: Icon(Icons.person, size: 12, color: Colors.white),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  item.assignee,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({
    required this.priority,
    required this.isMedium,
  });

  final String priority;
  final bool isMedium;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isMedium
            ? AppColors.chartYellow.withValues(alpha: 0.25)
            : const Color(0xFFFCE7F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: isMedium ? const Color(0xFF92400E) : const Color(0xFFBE185D),
        ),
      ),
    );
  }
}
