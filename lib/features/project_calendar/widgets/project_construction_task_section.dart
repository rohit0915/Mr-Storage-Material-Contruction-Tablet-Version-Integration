import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/utils/app_toast.dart';
import '../../../app/widgets/app_shimmer.dart';
import '../controllers/project_details_controller.dart';
import '../models/project_calendar_models.dart';
import 'add_task_dialog.dart';
import 'step_detail_dialog.dart';

class ProjectConstructionTaskSection extends StatelessWidget {
  const ProjectConstructionTaskSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProjectDetailsController>();

    return Obx(() {
      final tasks = controller.timelineTasks;
      final isLoading = controller.isTimelineLoading.value;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section Header matching Screenshot
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Project Construction Task',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                // [+ Add] Button
                ElevatedButton.icon(
                  onPressed: () => AddTaskDialog.show(
                    context,
                    leadId: controller.leadId.value,
                  ),
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: const Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF334155), // Slate dark
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Horizontal Scrollable Cards List
            if (isLoading && tasks.isEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  children: List.generate(
                    3,
                    (index) => Container(
                      width: 280,
                      height: 150,
                      margin: EdgeInsets.only(right: index < 2 ? 14 : 0),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppShimmer(width: 130, height: 16, borderRadius: 4),
                              AppShimmer(width: 60, height: 18, borderRadius: 8),
                            ],
                          ),
                          SizedBox(height: 12),
                          AppShimmer(width: 100, height: 12, borderRadius: 4),
                          Spacer(),
                          AppShimmer(width: double.infinity, height: 6, borderRadius: 3),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              AppShimmer(width: 18, height: 18, shape: BoxShape.circle),
                              SizedBox(width: 6),
                              AppShimmer(width: 70, height: 12, borderRadius: 4),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else if (tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.assignment_outlined, size: 36, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'No construction tasks recorded yet.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Click "+ Add" to add the first project construction task.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    for (int i = 0; i < tasks.length; i++) ...[
                      if (i > 0) const SizedBox(width: 14),
                      _TaskCard(
                        task: tasks[i],
                        controller: controller,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.controller,
  });

  final ProjectTimelineTask task;
  final ProjectDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.isCompleted;

    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            task.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),

          // Start Date
          Text(
            'Start: ${task.startDate}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 3),

          // Est End Date
          Text(
            'Est End: ${task.estimatedEndDate}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 3),

          // Completed Date (shown if completed or present)
          if (isCompleted || task.completedDate != '-') ...[
            Text(
              'Completed: ${task.completedDate}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
          ] else ...[
            const SizedBox(height: 12),
          ],

          // Status Badge Pill (Under timeline, N Days Late, Delayed, In Progress, Pending)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: task.badgeBgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: task.badgeDotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  task.badgeLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: task.badgeTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Bottom Actions: Eye Icon + Optional [Mark Complete]
          Row(
            children: [
              // View Eye Button
              InkWell(
                onTap: () {
                  StepDetailDialog.show(
                    context,
                    task: task,
                    leadId: controller.leadId.value,
                  );
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  width: 38,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: const Icon(
                    Icons.visibility_outlined,
                    size: 18,
                    color: Color(0xFF334155),
                  ),
                ),
              ),

              // [Mark Complete] button shown when canMarkComplete is true (status !== done)
              if (task.canMarkComplete && !isCompleted) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: () async {
                        final ok = await controller.markTimelineTaskComplete(task.id);
                        if (ok) {
                          AppToast.showSuccess(
                            title: 'Completed',
                            description: '${task.title} marked as Complete ✓',
                          );
                        } else {
                          AppToast.showError(
                            title: 'Error',
                            description: 'Failed to mark task as complete.',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1D4ED8), // Blue matching Figma
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'Mark Complete',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

