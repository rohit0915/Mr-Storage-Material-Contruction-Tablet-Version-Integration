import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_models.dart';

class FilterRow extends GetView<DashboardController> {
  const FilterRow({super.key});

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(
        start: DateTime(2025, 3, 24),
        end: DateTime(2025, 3, 31),
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatter = DateFormat('dd MMM yyyy');
      final formattedStr = '${formatter.format(picked.start)} - ${formatter.format(picked.end)}';
      controller.setDateRangeFilter(formattedStr);
    }
  }

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
              () => _DropdownFilterChip(
                label: 'Select Project',
                value: controller.selectedProject.value,
                options: controller.projectOptions,
                onSelected: controller.setProjectFilter,
              ),
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: Obx(
              () => _DropdownFilterChip(
                label: 'Buildings',
                value: controller.selectedBuilding.value,
                options: controller.buildingOptions,
                onSelected: controller.setBuildingFilter,
              ),
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: Obx(
              () => _DropdownFilterChip(
                label: 'Status',
                value: controller.selectedStatus.value,
                options: controller.statusOptions,
                onSelected: controller.setStatusFilter,
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
                onTap: () => _selectDateRange(context),
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

class _DropdownFilterChip extends StatelessWidget {
  const _DropdownFilterChip({
    required this.label,
    required this.value,
    required this.options,
    required this.onSelected,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (context) {
        return options.map((opt) {
          return PopupMenuItem<String>(
            value: opt,
            child: Row(
              children: [
                if (opt == value)
                  const Icon(Icons.check_rounded, size: 16, color: AppColors.primaryBlue)
                else
                  const SizedBox(width: 16),
                const SizedBox(width: 8),
                Text(
                  opt,
                  style: TextStyle(
                    fontWeight: opt == value ? FontWeight.w700 : FontWeight.w500,
                    color: opt == value ? AppColors.primaryBlue : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: _FilterChip(
        label: label,
        value: value,
        icon: Icons.keyboard_arrow_down_rounded,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.value,
    this.icon = Icons.keyboard_arrow_down_rounded,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final labelSize = (size.width * 0.008).clamp(9.0, 11.0);
    final valueSize = (size.width * 0.009).clamp(10.0, 12.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DashboardGap.radius),
      child: Container(
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
      ),
    );
  }
}

