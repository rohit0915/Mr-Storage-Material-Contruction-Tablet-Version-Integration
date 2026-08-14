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

    return Obx(() {
      final tab = controller.selectedTab.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project & Calendar',
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
              if (tab == ProjectCalendarTab.calendar)
                ElevatedButton.icon(
                  onPressed: () => controller.openAddDelivery(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                    'Add Delivery',
                    style: TextStyle(
                      fontSize: (size.width * 0.011).clamp(12.0, 14.0),
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
          SizedBox(height: size.height * 0.014),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TabChip(
                label: 'Calendar',
                icon: Icons.calendar_month_outlined,
                selected: tab == ProjectCalendarTab.calendar,
                onTap: () => controller.setTab(ProjectCalendarTab.calendar),
              ),
              SizedBox(width: size.width * 0.008),
              _TabChip(
                label: 'Project',
                icon: Icons.work_outline_rounded,
                selected: tab == ProjectCalendarTab.project,
                onTap: () => controller.setTab(ProjectCalendarTab.project),
              ),
              const Spacer(),
              if (tab == ProjectCalendarTab.calendar) const ProjectDropdown(),
            ],
          ),
        ],
      );
    });
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final fontSize = (size.width * 0.011).clamp(12.0, 14.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.014,
          vertical: size.height * 0.012,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : AppColors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : AppColors.primaryBlue,
            ),
            SizedBox(width: size.width * 0.006),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
