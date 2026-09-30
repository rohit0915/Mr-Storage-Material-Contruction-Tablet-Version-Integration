import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/get_builder_ids.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/project_calendar_controller.dart';
import '../models/project_calendar_models.dart';
import 'delivery_details_dialog.dart';

class DeliveryCardsSection extends GetView<ProjectCalendarController> {
  const DeliveryCardsSection({super.key});

  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final titleSize = (size.width * 0.013).clamp(14.0, 16.0);
    final buttonTextSize = (size.width * 0.009).clamp(11.0, 13.0);
    final gap = (size.width * 0.01).clamp(10.0, 14.0);

    return GetBuilder<ProjectCalendarController>(
      id: AppGetIds.calendarEvents,
      builder: (controller) {
        final day = controller.selectedDay.value;
        final focused = controller.focusedMonth.value;
        final selectedDate = DateTime(
          focused.year,
          focused.month,
          day.clamp(1, 31),
        );
        final monthName = _months[focused.month - 1];
        final weekdayName = _weekdays[selectedDate.weekday - 1];
        final dateHeaderStr = '$weekdayName, $monthName $day, ${focused.year}';

        final dayDeliveries = controller.selectedDayDeliveries;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateHeaderStr,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: size.height * 0.01),
            Row(
              children: [
                Text(
                  'Deliveries on this date',
                  style: TextStyle(
                    fontSize: (size.width * 0.010).clamp(11.0, 13.0),
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => controller.openAddDelivery(context),
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(
                    'Add Delivery',
                    style: TextStyle(
                      fontSize: buttonTextSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue.withValues(
                      alpha: 0.1,
                    ),
                    foregroundColor: AppColors.primaryBlue,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.014),
            if (dayDeliveries.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Center(
                  child: Text(
                    'No deliveries on this date',
                    style: TextStyle(
                      fontSize: buttonTextSize,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: dayDeliveries
                    .map(
                      (d) => Padding(
                        padding: EdgeInsets.only(bottom: gap),
                        child: _DeliveryCard(item: d),
                      ),
                    )
                    .toList(),
              ),
            SizedBox(height: size.height * 0.014),
            Center(
              child: TextButton(
                onPressed: () => Get.toNamed(AppRoutes.deliveryTracking),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All Deliveries',
                      style: TextStyle(
                        fontSize: buttonTextSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: AppColors.primaryBlue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.item});

  final DeliveryItem item;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final codeSize = (size.width * 0.012).clamp(13.0, 15.0);
    final labelSize = (size.width * 0.008).clamp(9.0, 11.0);
    final valueSize = (size.width * 0.010).clamp(11.0, 13.0);

    return InkWell(
      onTap: () => showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (_) => DeliveryDetailsDialog(item: item),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all((size.width * 0.012).clamp(12.0, 16.0)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.description.isNotEmpty ? item.description : item.code,
              style: TextStyle(
                fontSize: codeSize,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: size.height * 0.008),
            Text(
              'Project / Job ID',
              style: TextStyle(
                fontSize: labelSize,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              item.projectName,
              style: TextStyle(
                fontSize: valueSize,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: size.height * 0.008),
            Text(
              'Location',
              style: TextStyle(
                fontSize: labelSize,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              item.location.isNotEmpty ? item.location : 'N/A',
              style: TextStyle(
                fontSize: valueSize,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: size.height * 0.012),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Date',
                      style: TextStyle(
                        fontSize: labelSize,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.date,
                      style: TextStyle(
                        fontSize: valueSize,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Status',
                      style: TextStyle(
                        fontSize: labelSize,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: item.statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.status,
                        style: TextStyle(
                          fontSize: labelSize,
                          fontWeight: FontWeight.w700,
                          color: item.statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
