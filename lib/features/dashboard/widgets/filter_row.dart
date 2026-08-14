import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_models.dart';

class FilterRow extends GetView<DashboardController> {
  const FilterRow({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gap = DashboardGap.page(context);

    return Container(
      padding: EdgeInsets.all(gap),
      decoration: BoxDecoration(
        color: AppColors.tableHeader,
        borderRadius: BorderRadius.circular(DashboardGap.radius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => _FilterChip(
                label: 'Select Project',
                value: controller.selectedProject.value,
              ),
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: Obx(
              () => _FilterChip(
                label: 'Buildings',
                value: controller.selectedBuilding.value,
              ),
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: Obx(
              () => _FilterChip(
                label: 'Status',
                value: controller.selectedStatus.value,
              ),
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: Obx(
              () => _FilterChip(
                label: 'Date Range',
                value: controller.dateRange.value,
                icon: Icons.calendar_today_outlined,
              ),
            ),
          ),
          SizedBox(width: gap),
          OutlinedButton.icon(
            onPressed: controller.resetFilters,
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(
              'Restart',
              style: TextStyle(
                fontSize: (size.width * 0.010).clamp(11.0, 13.0),
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.cardBorder),
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.012,
                vertical: size.height * 0.016,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DashboardGap.radius),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.value,
    this.icon = Icons.keyboard_arrow_down_rounded,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final labelSize = (size.width * 0.008).clamp(9.0, 11.0);
    final valueSize = (size.width * 0.009).clamp(10.0, 12.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.01,
        vertical: size.height * 0.01,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DashboardGap.radius),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: labelSize,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: valueSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, size: 16, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
