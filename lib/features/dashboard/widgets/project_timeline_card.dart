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
    final titleSize = (size.width * 0.012).clamp(14.0, 16.0);
    final itemSize = (size.width * 0.010).clamp(12.0, 14.0);

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Title and Action Dropdown
          Row(
            children: [
              Expanded(
                child: Text(
                  'Project Timeline (Overall)',
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    'View Full Timeline',
                    style: TextStyle(
                      fontSize: itemSize,
                      color: const Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: Color(0xFF475569),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: DashboardGap.section(context)),

          // Timeline Steps List
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
                      style: TextStyle(
                        fontSize: itemSize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: steps.map((step) {
                  return _TimelineRowItem(step: step, fontSize: itemSize);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TimelineRowItem extends StatelessWidget {
  const _TimelineRowItem({required this.step, required this.fontSize});

  final TimelineStep step;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    // Determine Lead Icon Widget matching Image 1
    Widget leadIcon;
    if (step.done) {
      // Green box with orange border and white checkmark
      leadIcon = Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFF22C55E),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFF97316), width: 1.5),
        ),
        child: const Icon(Icons.check, size: 16, color: Colors.white),
      );
    } else if (step.inProgress) {
      // Solid grey rounded square box
      leadIcon = Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(6),
        ),
      );
    } else {
      // Outlined light grey rounded square box
      leadIcon = Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
        ),
      );
    }

    // Determine Status Badge Pill styling matching Image 1
    final (statusText, badgeBg, badgeFg) = switch ((
      step.done,
      step.inProgress,
    )) {
      (true, _) => (
        '• Completed',
        const Color(0xFFDCFCE7),
        const Color(0xFF16A34A),
      ),
      (false, true) => (
        '• Inprogress',
        const Color(0xFFF3E8FF),
        const Color(0xFFA855F7),
      ),
      (false, false) => (
        '• Upcoming',
        const Color(0xFFF3E8FF),
        const Color(0xFFA855F7),
      ),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEF2F6)),
      ),
      child: Row(
        children: [
          leadIcon,
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Text(
                  step.title,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                if (step.date.isNotEmpty && step.date != '-') ...[
                  const SizedBox(width: 8),
                  Text(
                    step.date,
                    style: TextStyle(
                      fontSize: fontSize - 1,
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: fontSize - 2,
                fontWeight: FontWeight.w700,
                color: badgeFg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
