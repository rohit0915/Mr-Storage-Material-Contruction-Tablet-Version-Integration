import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../tasks/widgets/task_calendar_dialog.dart';
import '../controllers/material_requests_controller.dart';

class MaterialRequestFiltersRow extends GetView<MaterialRequestsController> {
  const MaterialRequestFiltersRow({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gap = (size.width * 0.012).clamp(10.0, 14.0);
    final boxPadV = size.height * 0.014;
    final boxPadH = size.width * 0.012;

    // For tablet landscape, keep everything on one row; on smaller widths wrap.
    return Obx(() {
      // Read reactive values directly in Obx scope so GetX can track them.
      final project = controller.selectedProject.value;
      final department = controller.selectedDepartment.value;
      final status = controller.selectedStatus.value;
      final requestedBy = controller.selectedRequestedBy.value;
      final dateRange = controller.dateRangeLabel;

      return LayoutBuilder(
        builder: (context, constraints) {
          final children = <Widget>[
            Expanded(
              child: _DropdownBox(
                label: 'Projects',
                value: project,
                items: controller.projects,
                onChanged: (v) => controller.setFilters(project: v),
                padH: boxPadH,
                padV: boxPadV,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _DropdownBox(
                label: 'Departments',
                value: department,
                items: controller.departments,
                onChanged: (v) => controller.setFilters(department: v),
                padH: boxPadH,
                padV: boxPadV,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _DropdownBox(
                label: 'Status',
                value: status,
                items: controller.statusList,
                onChanged: (v) => controller.setFilters(status: v),
                padH: boxPadH,
                padV: boxPadV,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _DropdownBox(
                label: 'Requested By',
                value: requestedBy,
                items: controller.requestedByList,
                onChanged: (v) => controller.setFilters(requestedBy: v),
                padH: boxPadH,
                padV: boxPadV,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _DateRangeBox(
                label: 'Date Range',
                value: dateRange,
              ),
            ),
          ];

          return Row(children: children);
        },
      );
    });
  }
}

class _DropdownBox extends StatelessWidget {
  const _DropdownBox({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.padH,
    required this.padV,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final double padH;
  final double padV;

  @override
  Widget build(BuildContext context) {
    final labelSize = (MediaQuery.sizeOf(context).width * 0.008).clamp(10.0, 12.0);
    final valueSize = (MediaQuery.sizeOf(context).width * 0.010).clamp(12.0, 13.0);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: labelSize, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            key: ValueKey(value),
            initialValue: value,
            isExpanded: true,
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            dropdownColor: Colors.white,
            items: items
                .map(
                  (e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)),
                )
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              onChanged(v);
            },
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRangeBox extends StatelessWidget {
  const _DateRangeBox({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MaterialRequestsController>();
    final labelSize = (MediaQuery.sizeOf(context).width * 0.008).clamp(10.0, 12.0);
    final valueSize = (MediaQuery.sizeOf(context).width * 0.010).clamp(12.0, 13.0);

    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final from = await pickTaskDate(
          context,
          initialDate: controller.dateFrom.value ?? now,
          title: 'Calendar',
          confirmLabel: 'Done',
        );
        if (from == null || !context.mounted) return;

        final to = await pickTaskDate(
          context,
          initialDate: controller.dateTo.value ?? from,
          title: 'Calendar',
          confirmLabel: 'Done',
        );
        if (to == null || !context.mounted) return;

        final start = from.isAfter(to) ? to : from;
        final end = from.isAfter(to) ? from : to;
        controller.setFilters(
          from: DateTime(start.year, start.month, start.day),
          to: DateTime(end.year, end.month, end.day),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: MediaQuery.sizeOf(context).width * 0.012, vertical: MediaQuery.sizeOf(context).height * 0.014),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: labelSize, color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
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
            const SizedBox(width: 8),
            const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

