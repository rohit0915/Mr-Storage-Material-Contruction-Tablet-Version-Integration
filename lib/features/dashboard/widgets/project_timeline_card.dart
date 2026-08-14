import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_models.dart';
import 'section_card.dart';
import 'status_badge.dart';

class ProjectTimelineCard extends GetView<DashboardController> {
  const ProjectTimelineCard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final titleSize = (size.width * 0.012).clamp(13.0, 15.0);
    final itemSize = (size.width * 0.010).clamp(11.0, 13.0);
    final steps = controller.timeline;
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
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: AppColors.primaryBlue,
              ),
            ],
          ),
          SizedBox(height: DashboardGap.section(context)),
          for (final step in steps) ...[
            Container(
              margin: EdgeInsets.only(bottom: gap),
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.008,
                vertical: size.height * 0.01,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DashboardGap.radius),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: step.done ? AppColors.success : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: step.done
                            ? AppColors.success
                            : AppColors.cardBorder,
                        width: 2,
                      ),
                    ),
                    child: step.done
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
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
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          step.date,
                          style: TextStyle(
                            fontSize: itemSize - 1,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(
                    label: step.status,
                    color: step.statusColor,
                    solid: false,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
