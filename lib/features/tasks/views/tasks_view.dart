import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/shell/app_scaffold.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/app_shimmer.dart';
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

            // Task Board Card Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Board Header Row
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
                          backgroundColor: const Color(0xFF22C55E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Daily Work Log',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => controller.openAddTask(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Add Task',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: gap),

                  // Kanban 3 Columns
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

                    const colGap = 16.0;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _BoardColumn(
                            title: 'To Do (${todo.length})',
                            color: const Color(0xFFF1F5F9),
                            items: todo,
                            column: TaskColumn.todo,
                          ),
                        ),
                        const SizedBox(width: colGap),
                        Expanded(
                          child: _BoardColumn(
                            title: 'In Progress (${inProgress.length})',
                            color: const Color(0xFFEFF6FF),
                            items: inProgress,
                            column: TaskColumn.inProgress,
                          ),
                        ),
                        const SizedBox(width: colGap),
                        Expanded(
                          child: _BoardColumn(
                            title: 'Done (${done.length})',
                            color: const Color(0xFFF0FDF4),
                            items: done,
                            column: TaskColumn.done,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends GetView<TasksController> {
  const _SummaryRow();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gap = (size.width * 0.01).clamp(10.0, 14.0);

    return Obx(() {
      if (controller.isLoading.value) {
        return const AppShimmerSummaryRow(count: 3);
      }
      return Row(
        children: [
          Expanded(
            child: _SummaryCard(
              label: 'Total Tasks',
              value: '${controller.totalTasksCount.value}',
              color: const Color(0xFF1E5BB4),
              icon: Icons.folder_outlined,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _SummaryCard(
              label: 'Completed',
              value: '${controller.completedCountStat.value}',
              color: const Color(0xFF34C759),
              icon: Icons.check_rounded,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _SummaryCard(
              label: 'In Progress',
              value: '${controller.inProgressCountStat.value}',
              color: const Color(0xFFEAB308),
              icon: Icons.access_time_rounded,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _SummaryCard(
              label: 'Overdue',
              value: '${controller.overdueCountStat.value}',
              color: const Color(0xFFFF6B4A),
              icon: Icons.shield_outlined,
            ),
          ),
        ],
      );
    });
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
        horizontal: size.width * 0.014,
        vertical: size.height * 0.016,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
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
                    fontSize: (size.width * 0.010).clamp(11.0, 13.0),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: (size.width * 0.022).clamp(24.0, 30.0),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
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
    required this.column,
  });

  final String title;
  final Color color;
  final List<TaskBoardItem> items;
  final TaskColumn column;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TaskCard(item: t),
            ),
          ),
          if (items.isEmpty)
            Container(
              height: 90,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.cardBorder,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'No tasks',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
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
    final isPlumbing = item.title.contains('Plumbing');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
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
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (item.completed)
                const Icon(
                  Icons.check_rounded,
                  color: AppColors.badgeGreen,
                  size: 20,
                )
              else
                _PriorityBadge(priority: item.priority, isYellow: isPlumbing),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.project,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.3,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  item.completed ? 'Completed' : 'Due $dateLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                item.assignee,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: AppColors.textPrimary,
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
  const _PriorityBadge({required this.priority, required this.isYellow});

  final String priority;
  final bool isYellow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: isYellow ? const Color(0xFFFEF9C3) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 10,
          color: isYellow ? const Color(0xFFD97706) : const Color(0xFFEF4444),
        ),
      ),
    );
  }
}
