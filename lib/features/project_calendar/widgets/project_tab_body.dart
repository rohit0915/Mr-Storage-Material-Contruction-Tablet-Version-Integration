import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/get_builder_ids.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/app_shimmer.dart';
import '../controllers/project_calendar_controller.dart';

class ProjectTabBody extends StatelessWidget {
  const ProjectTabBody({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProjectCalendarController>(
      id: AppGetIds.projectCards,
      builder: (controller) {
        if (controller.isLoadingProjects) {
          return const _ProjectTabShimmer();
        }

        var list = controller.projectCards;
        if (controller.selectedProjectId.value.isNotEmpty) {
          final sel = controller.selectedProjectId.value.toLowerCase();
          final selOpt = controller.selectedProject;
          list = list.where((p) {
            return p.projectId.toLowerCase() == sel ||
                p.realLeadId.toLowerCase() == sel ||
                p.title.toLowerCase() == sel ||
                (selOpt != null &&
                    selOpt.id.isNotEmpty &&
                    (p.realLeadId.toLowerCase() == selOpt.id.toLowerCase() ||
                        p.projectId.toLowerCase() ==
                            selOpt.code.toLowerCase() ||
                        p.title.toLowerCase() == selOpt.name.toLowerCase()));
          }).toList();
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
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  'Project List',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.cardBorder),

              if (list.isEmpty)
                const SizedBox(
                  height: 180,
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
                    final minTableWidth = constraints.maxWidth < 750
                        ? 750.0
                        : constraints.maxWidth;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: SizedBox(
                        width: minTableWidth,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.cardBorder, width: 1.0),
                          ),
                          child: Column(
                            children: [
                              // Table Header Row
                              Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF8FAFC),
                                  border: Border(bottom: BorderSide(color: AppColors.cardBorder, width: 1.0)),
                                ),
                                child: const Row(
                                  children: [
                                    _TblHeader('Project ID', flex: 2),
                                    _TblHeader('Project / Site', flex: 4),
                                    _TblHeader('Status', flex: 3),
                                    _TblHeader('Priority', flex: 2),
                                    _TblHeader('Actions', flex: 4, isLast: true),
                                  ],
                                ),
                              ),

                              // Table Rows
                              ...list.asMap().entries.map((entry) {
                                final item = entry.value;
                                final isLast = entry.key == list.length - 1;
                                return Container(
                                  decoration: BoxDecoration(
                                    border: isLast
                                        ? null
                                        : const Border(bottom: BorderSide(color: AppColors.cardBorder, width: 1.0)),
                                  ),
                                  child: Row(
                                    children: [
                                      // Project ID
                                      _tdCell(
                                        flex: 2,
                                        child: Text(
                                          item.projectId,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      // Project / Site
                                      _tdCell(
                                        flex: 4,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              item.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              item.location,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Status
                                      _tdCell(
                                        flex: 3,
                                        child: Text(
                                          _formatStatus(item.status),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: _getStatusColor(item.status),
                                          ),
                                        ),
                                      ),
                                      // Priority
                                      _tdCell(
                                        flex: 2,
                                        child: _PriorityBadge(priority: item.priority),
                                      ),
                                      // Actions
                                      _tdCell(
                                        flex: 4,
                                        isLast: true,
                                        child: Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: [
                                            _ActionButton(
                                              icon: Icons.calendar_today_outlined,
                                              label: 'Calendar',
                                              onTap: () {
                                                controller.selectProjectAndOpenCalendar(item);
                                              },
                                            ),
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
                                );
                              }),
                            ],
                          ),
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

  String _formatStatus(String status) {
    if (status.isEmpty) return 'Active';
    final clean = status.replaceAll('_', ' ').trim();
    if (clean.isEmpty) return 'Active';
    return clean
        .split(' ')
        .map((p) => p.isEmpty
            ? p
            : '${p[0].toUpperCase()}${p.substring(1).toLowerCase()}')
        .join(' ');
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('released') || s.contains('plant') || s.contains('pending')) {
      return const Color(0xFFD97706); // Orange-yellow
    }
    if (s.contains('delivered') || s.contains('complete')) {
      return const Color(0xFF0D5C75); // Dark teal
    }
    if (s.contains('material') || s.contains('check')) {
      return const Color(0xFF0F2C59); // Deep navy
    }
    return AppColors.textPrimary;
  }
}

class _TblHeader extends StatelessWidget {
  const _TblHeader(this.label, {this.flex = 1, this.isLast = false});
  final String label;
  final int flex;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(
          border: isLast ? null : const Border(right: BorderSide(color: AppColors.cardBorder, width: 1.0)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

Widget _tdCell({
  required Widget child,
  required int flex,
  bool isLast = false,
  Alignment alignment = Alignment.centerLeft,
}) {
  return Expanded(
    flex: flex,
    child: Container(
      decoration: BoxDecoration(
        border: isLast ? null : const Border(right: BorderSide(color: AppColors.cardBorder, width: 1.0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      alignment: alignment,
      child: child,
    ),
  );
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});
  final String priority;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        priority,
        style: const TextStyle(
          color: Color(0xFFD97706),
          fontWeight: FontWeight.w600,
          fontSize: 11,
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: AppColors.primaryBlue),
              const SizedBox(width: 3),
            ],
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                    value: [10, 15, 20, 50].contains(currLimit) ? currLimit : 10,
                    isDense: true,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                    items: const [
                      DropdownMenuItem(value: 10, child: Text('10')),
                      DropdownMenuItem(value: 15, child: Text('15')),
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

class _ProjectTabShimmer extends StatelessWidget {
  const _ProjectTabShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
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
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Project List',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.cardBorder),

          LayoutBuilder(
            builder: (context, constraints) {
              final minTableWidth = constraints.maxWidth < 750
                  ? 750.0
                  : constraints.maxWidth;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: minTableWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.cardBorder, width: 1.0),
                    ),
                    child: Column(
                      children: [
                        // Shimmer Header
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            border: Border(bottom: BorderSide(color: AppColors.cardBorder, width: 1.0)),
                          ),
                          child: const Row(
                            children: [
                              _TblHeader('Project ID', flex: 2),
                              _TblHeader('Project / Site', flex: 4),
                              _TblHeader('Status', flex: 3),
                              _TblHeader('Priority', flex: 2),
                              _TblHeader('Actions', flex: 4, isLast: true),
                            ],
                          ),
                        ),

                        // Shimmer Rows matching UI exactly
                        ...List.generate(7, (index) {
                          final isLast = index == 6;
                          return Container(
                            decoration: BoxDecoration(
                              border: isLast
                                  ? null
                                  : const Border(bottom: BorderSide(color: AppColors.cardBorder, width: 1.0)),
                            ),
                            child: Row(
                              children: [
                                // Project ID
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(right: BorderSide(color: AppColors.cardBorder, width: 1.0)),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    alignment: Alignment.centerLeft,
                                    child: const AppShimmer(width: 65, height: 14, borderRadius: 4),
                                  ),
                                ),
                                // Project / Site
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(right: BorderSide(color: AppColors.cardBorder, width: 1.0)),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    alignment: Alignment.centerLeft,
                                    child: const Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AppShimmer(width: 130, height: 14, borderRadius: 4),
                                        SizedBox(height: 5),
                                        AppShimmer(width: 80, height: 11, borderRadius: 4),
                                      ],
                                    ),
                                  ),
                                ),
                                // Status
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(right: BorderSide(color: AppColors.cardBorder, width: 1.0)),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    alignment: Alignment.centerLeft,
                                    child: const AppShimmer(width: 100, height: 14, borderRadius: 4),
                                  ),
                                ),
                                // Priority
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      border: Border(right: BorderSide(color: AppColors.cardBorder, width: 1.0)),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    alignment: Alignment.centerLeft,
                                    child: const AppShimmer(width: 58, height: 22, borderRadius: 5),
                                  ),
                                ),
                                // Actions
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    child: const Row(
                                      children: [
                                        AppShimmer(width: 76, height: 26, borderRadius: 6),
                                        SizedBox(width: 6),
                                        AppShimmer(width: 52, height: 26, borderRadius: 6),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Pagination Bar Shimmer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppShimmer(width: 140, height: 18, borderRadius: 4),
                AppShimmer(width: 90, height: 24, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
