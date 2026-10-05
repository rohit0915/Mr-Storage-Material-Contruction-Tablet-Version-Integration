import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/get_builder_ids.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/project_calendar_controller.dart';

class ProjectTabBody extends StatelessWidget {
  const ProjectTabBody({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProjectCalendarController>(
      id: AppGetIds.projectCards,
      builder: (controller) {
        if (controller.isLoadingProjects) {
          return const SizedBox(
            height: 300,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        var list = controller.projectCards;
        if (controller.selectedProjectId.value.isNotEmpty) {
          final sel = controller.selectedProjectId.value;
          list = list.where((p) => p.projectId == sel || p.realLeadId == sel).toList();
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Project List',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.cardBorder),

              if (list.isEmpty)
                const SizedBox(
                  height: 200,
                  child: Center(
                    child: Text(
                      'No projects found',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final minTableWidth = constraints.maxWidth < 950
                        ? 950.0
                        : constraints.maxWidth;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: minTableWidth,
                        child: Column(
                          children: [
                            // Table Header Row
                            Container(
                              color: const Color(0xFFF8FAFC),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: const Row(
                                children: [
                                  Expanded(flex: 2, child: _TblHeader('Project ID')),
                                  Expanded(flex: 4, child: _TblHeader('Project / Site')),
                                  Expanded(flex: 3, child: _TblHeader('Status')),
                                  Expanded(flex: 2, child: _TblHeader('Priority')),
                                  Expanded(flex: 4, child: _TblHeader('Actions')),
                                ],
                              ),
                            ),
                            const Divider(height: 1, color: AppColors.cardBorder),

                            // Table Rows
                            ...list.asMap().entries.map((entry) {
                              final item = entry.value;
                              final isLast = entry.key == list.length - 1;
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                    child: Row(
                                      children: [
                                        // Project ID
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            item.projectId,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        // Project / Site
                                        Expanded(
                                          flex: 4,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                item.location,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Status
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            item.status,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              color: _getStatusColor(item.status),
                                            ),
                                          ),
                                        ),
                                        // Priority
                                        Expanded(
                                          flex: 2,
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: _PriorityBadge(priority: item.priority),
                                          ),
                                        ),
                                        // Actions
                                        Expanded(
                                          flex: 4,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _ActionButton(
                                                icon: Icons.calendar_today_outlined,
                                                label: 'Calendar',
                                                onTap: () {
                                                  controller.selectProjectAndOpenCalendar(item);
                                                },
                                              ),
                                              const SizedBox(width: 8),
                                              _ActionButton(
                                                label: 'View',
                                                onTap: () {
                                                  Get.toNamed(
                                                    AppRoutes.projectDetails,
                                                    arguments: {
                                                      'id': item.realLeadId.isNotEmpty ? item.realLeadId : item.projectId,
                                                      'title': item.title,
                                                      'location': item.location,
                                                      'buildingType': item.buildingType,
                                                      'jobId': item.projectId,
                                                      'status': item.status,
                                                      'fromProject': true,
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isLast) const Divider(height: 1, color: AppColors.cardBorder),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
              _ProjectPaginationBar(controller: controller),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('released') || s.contains('material check')) {
      return const Color(0xFFF59E0B); // Orange-yellow from screenshot
    }
    return AppColors.textPrimary;
  }
}

class _TblHeader extends StatelessWidget {
  const _TblHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});
  final String priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        priority,
        style: const TextStyle(
          color: Color(0xFFD97706),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap, this.icon});

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: AppColors.primaryBlue),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectPaginationBar extends StatelessWidget {
  const _ProjectPaginationBar({required this.controller});

  final ProjectCalendarController controller;

  @override
  Widget build(BuildContext context) {
    final currPage = controller.projectPage;
    final totalPages = controller.projectTotalPages;
    final currLimit = controller.projectLimit;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 500;
          final showingWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Showing',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: [10, 20, 50].contains(currLimit) ? currLimit : 10,
                    isDense: true,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                    items: const [
                      DropdownMenuItem(value: 10, child: Text('10')),
                      DropdownMenuItem(value: 20, child: Text('20')),
                      DropdownMenuItem(value: 50, child: Text('50')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        controller.changeProjectLimit(val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Results',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );

          final pagerWidget = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  color: currPage > 1
                      ? AppColors.textPrimary
                      : AppColors.textSecondary.withValues(alpha: 0.4),
                  onPressed: currPage > 1
                      ? () => controller.changeProjectPage(currPage - 1)
                      : null,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
                for (int p = 1; p <= totalPages; p++) ...[
                  InkWell(
                    onTap: () => controller.changeProjectPage(p),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: p == currPage ? Border.all(color: AppColors.primaryBlue) : null,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '$p',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: p == currPage ? FontWeight.w700 : FontWeight.normal,
                          color: p == currPage ? AppColors.primaryBlue : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  color: currPage < totalPages
                      ? AppColors.textPrimary
                      : AppColors.textSecondary.withValues(alpha: 0.4),
                  onPressed: currPage < totalPages
                      ? () => controller.changeProjectPage(currPage + 1)
                      : null,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                showingWidget,
                const SizedBox(height: 12),
                pagerWidget,
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              showingWidget,
              pagerWidget,
            ],
          );
        },
      ),
    );
  }
}
