import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/get_builder_ids.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_models.dart';
import 'section_card.dart';

class ProjectTimelineCard extends StatelessWidget {
  const ProjectTimelineCard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final titleSize = (size.width * 0.012).clamp(13.0, 15.0);
    final itemSize = (size.width * 0.010).clamp(11.0, 13.0);
    final gap = DashboardGap.item(context);

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Project Timeline (Overall)',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                'View Full Timeline',
                style: TextStyle(
                  fontSize: itemSize,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          SizedBox(height: DashboardGap.section(context)),
          GetBuilder<DashboardController>(
            id: AppGetIds.projectTimeline,
            builder: (controller) {
              final steps = controller.timeline;
              if (steps.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No timeline steps available',
                      style: TextStyle(fontSize: itemSize, color: AppColors.textSecondary),
                    ),
                  ),
                );
              }

              return Column(
                children: steps.map((step) {
                  Color badgeBg;
                  Color badgeText;

                  if (step.done) {
                    badgeBg = const Color(0xFFDCFCE7);
                    badgeText = const Color(0xFF16A34A);
                  } else if (step.inProgress) {
                    badgeBg = const Color(0xFFDBEAFE);
                    badgeText = const Color(0xFF2563EB);
                  } else {
                    badgeBg = const Color(0xFFFCE7F3);
                    badgeText = const Color(0xFFDB2777);
                  }

                  Widget leadIcon;
                  if (step.done) {
                    leadIcon = Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 14, color: Color(0xFF16A34A)),
                    );
                  } else if (step.inProgress) {
                    leadIcon = Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF2563EB), width: 2),
                      ),
                      child: Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  } else {
                    leadIcon = Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
                      ),
                      child: Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF94A3B8),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }

                  return Padding(
                    padding: EdgeInsets.only(bottom: gap * 1.2),
                    child: Row(
                      children: [
                        leadIcon,
                        SizedBox(width: size.width * 0.01),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.title,
                                style: TextStyle(
                                  fontSize: itemSize,
                                  fontWeight: FontWeight.w700,
                                  color: step.done || step.inProgress
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                step.date.isEmpty ? '-' : step.date,
                                style: TextStyle(
                                  fontSize: itemSize - 1,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            step.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: itemSize - 2,
                              fontWeight: FontWeight.w800,
                              color: badgeText,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

