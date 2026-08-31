import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/get_builder_ids.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
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
        final list = controller.projectCards;
        if (controller.isLoadingProjects) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
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
        return LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth < 850 ? 2 : 3;
            final cardWidth = (constraints.maxWidth - (gap * (cols - 1))) / cols;
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
                      trailing:
                          _Pill(text: item.status, color: item.statusColor),
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
                            'id': item.realLeadId.isNotEmpty ? item.realLeadId : item.projectId,
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
  const _MetaRow({
    required this.label,
    this.value,
    this.trailing,
  });

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
          style: TextStyle(
            fontSize: fontSize,
            color: AppColors.textSecondary,
          ),
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
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
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
