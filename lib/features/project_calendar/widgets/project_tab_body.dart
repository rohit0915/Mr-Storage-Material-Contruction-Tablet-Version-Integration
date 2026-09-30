import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/get_builder_ids.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/widgets/app_shimmer.dart';
import '../controllers/project_calendar_controller.dart';
import '../models/project_calendar_models.dart';

class ProjectTabBody extends StatelessWidget {
  const ProjectTabBody({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gap = (size.width * 0.01).clamp(10.0, 14.0);

    return GetBuilder<ProjectCalendarController>(
      id: AppGetIds.projectCards,
      builder: (controller) {
        if (controller.isLoadingProjects) {
          return const AppShimmerGrid(itemCount: 6, crossAxisCount: 3);
        }
        var list = controller.projectCards;
        if (controller.selectedProjectId.value.isNotEmpty) {
          final sel = controller.selectedProjectId.value;
          list = list
              .where((p) => p.projectId == sel || p.realLeadId == sel)
              .toList();
        }
        if (list.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'No projects found',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final cols = constraints.maxWidth < 850 ? 2 : 3;
                final cardWidth =
                    (constraints.maxWidth - (gap * (cols - 1))) / cols;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: list
                      .map(
                        (p) => SizedBox(
                          width: cardWidth,
                          child: _ProjectCard(item: p),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            _ProjectPaginationBar(controller: controller),
          ],
        );
      },
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.item});

  final ProjectCardItem item;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final titleSize = (size.width * 0.012).clamp(13.0, 15.0);
    final bodySize = (size.width * 0.010).clamp(11.0, 13.0);
    final dpr = MediaQuery.devicePixelRatioOf(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardW = constraints.maxWidth;
        final cacheW = (cardW * dpr).round().clamp(400, 1200);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(
                      item.imageAsset,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      alignment: Alignment.center,
                      filterQuality: FilterQuality.high,
                      isAntiAlias: true,
                      cacheWidth: cacheW,
                      errorBuilder: (_, error, stackTrace) => Container(
                        color: AppColors.accentBlue.withValues(alpha: 0.12),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.apartment_rounded,
                          size: 56,
                          color: AppColors.accentBlue,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all((size.width * 0.01).clamp(12.0, 16.0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      item.location,
                      style: TextStyle(
                        fontSize: bodySize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: size.height * 0.012),
                    _MetaRow(label: 'Project ID', value: item.projectId),
                    SizedBox(height: size.height * 0.008),
                    _MetaRow(
                      label: 'Status',
                      trailing: _Pill(
                        text: item.status,
                        color: item.statusColor,
                      ),
                    ),
                    SizedBox(height: size.height * 0.008),
                    _MetaRow(
                      label: 'Priority',
                      trailing: _Pill(
                        text: item.priority,
                        color: item.priorityColor,
                      ),
                    ),
                    SizedBox(height: size.height * 0.014),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Get.toNamed(
                          AppRoutes.projectDetails,
                          arguments: {
                            'id': item.realLeadId.isNotEmpty
                                ? item.realLeadId
                                : item.projectId,
                            'title': item.title,
                            'location': item.location,
                            'buildingType': item.buildingType,
                            'jobId': item.projectId,
                            'status': item.status,
                            'fromProject': true,
                          },
                        ),
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: const Text('View'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                            vertical: size.height * 0.012,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, this.value, this.trailing});

  final String label;
  final String? value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final fontSize = (size.width * 0.010).clamp(11.0, 13.0);

    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: fontSize, color: AppColors.textSecondary),
        ),
        const Spacer(),
        if (value != null)
          Text(
            value!,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ?trailing,
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
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
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: SHOWING 10 RESULTS
          Row(
            children: [
              const Text(
                'SHOWING',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: [10, 20, 50].contains(currLimit) ? currLimit : 10,
                    isDense: true,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
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
                'RESULTS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          // Right side: < 1 2 3 >
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 20),
                color: currPage > 1
                    ? AppColors.textPrimary
                    : AppColors.textSecondary.withValues(alpha: 0.4),
                onPressed: currPage > 1
                    ? () => controller.changeProjectPage(currPage - 1)
                    : null,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 4),
              for (int p = 1; p <= totalPages; p++) ...[
                InkWell(
                  onTap: () => controller.changeProjectPage(p),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: p == currPage
                          ? AppColors.primaryBlue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$p',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: p == currPage
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 20),
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
        ],
      ),
    );
  }
}
