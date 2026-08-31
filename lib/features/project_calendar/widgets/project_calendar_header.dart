import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/project_calendar_controller.dart';
import '../models/project_calendar_models.dart';
import 'project_dropdown.dart';

class ProjectCalendarHeader extends GetView<ProjectCalendarController> {
  const ProjectCalendarHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final titleSize = (size.width * 0.018).clamp(18.0, 24.0);
    final subSize = (size.width * 0.011).clamp(12.0, 14.0);
    final btnTextSize = (size.width * 0.011).clamp(12.0, 14.0);

    return Obx(() {
      final tab = controller.selectedTab.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Projects and Calendar',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: size.height * 0.004),
                    Text(
                      'Construction Department Performance',
                      style: TextStyle(
                        fontSize: subSize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TabSegment(
                      label: 'Calendar',
                      selected: tab == ProjectCalendarTab.calendar,
                      onTap: () => controller.setTab(ProjectCalendarTab.calendar),
                    ),
                    _TabSegment(
                      label: 'Project',
                      selected: tab == ProjectCalendarTab.project,
                      onTap: () => controller.setTab(ProjectCalendarTab.project),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.016),
          Row(
            children: [
              Text(
                'Project',
                style: TextStyle(
                  fontSize: btnTextSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              const ProjectDropdown(),
              const Spacer(),
              if (tab == ProjectCalendarTab.calendar)
                ElevatedButton.icon(
                  onPressed: () => controller.openAddDelivery(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                    'Add Delivery',
                    style: TextStyle(
                      fontSize: btnTextSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.014,
                      vertical: size.height * 0.014,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
    });
  }
}

class _TabSegment extends StatelessWidget {
  const _TabSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final fontSize = (size.width * 0.011).clamp(12.0, 14.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.016,
          vertical: size.height * 0.010,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
