import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/constants/get_builder_ids.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/project_calendar_controller.dart';
import 'day_events_dialog.dart';

class CalendarMonthGrid extends GetView<ProjectCalendarController> {
  const CalendarMonthGrid({super.key});

  static const _weekDays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cellFont = (size.width * 0.010).clamp(11.0, 13.0);
    final eventFont = (size.width * 0.008).clamp(9.0, 11.0);

    return GetBuilder<ProjectCalendarController>(
      id: AppGetIds.calendarEvents,
      builder: (controller) {
        final month = controller.focusedMonth.value;
        final selectedDay = controller.selectedDay.value;
        final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
        final firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
        final totalCells = ((firstWeekday + daysInMonth + 6) ~/ 7) * 7;
        final monthLabel = DateFormat('MMMM yyyy').format(month);

        return Container(
          padding: EdgeInsets.all((size.width * 0.012).clamp(12.0, 16.0)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  OutlinedButton(
                    onPressed: controller.goToday,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.cardBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Today'),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: controller.previousMonth,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    monthLabel,
                    style: TextStyle(
                      fontSize: (size.width * 0.014).clamp(14.0, 18.0),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: controller.nextMonth,
                    icon: const Icon(Icons.chevron_right),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    tooltip: 'Calendar View Options',
                    onSelected: (value) async {
                      if (value == 'month') {
                        controller.calendarViewMode.value = 'Month';
                      } else if (value == 'today') {
                        controller.goToday();
                      } else if (value == 'pick_month') {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: controller.focusedMonth.value,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          helpText: 'Select Month & Year',
                          initialDatePickerMode: DatePickerMode.year,
                        );
                        if (picked != null) {
                          controller.selectMonthYear(picked);
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'month',
                        child: Row(
                          children: const [
                            Icon(
                              Icons.calendar_month,
                              size: 18,
                              color: AppColors.primaryBlue,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Month View',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'today',
                        child: Row(
                          children: const [
                            Icon(
                              Icons.today,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 8),
                            Text('Jump to Today'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'pick_month',
                        child: Row(
                          children: const [
                            Icon(
                              Icons.date_range,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 8),
                            Text('Pick Month & Year...'),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.cardBorder),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Obx(
                            () => Text(
                              controller.calendarViewMode.value,
                              style: TextStyle(
                                fontSize: cellFont,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                children: _weekDays
                    .map(
                      (d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: TextStyle(
                              fontSize: cellFont,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: size.height * 0.008),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: totalCells,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: size.width > 1100 ? 0.95 : 0.85,
                ),
                itemBuilder: (context, index) {
                  final dayNum = index - firstWeekday + 1;
                  if (dayNum < 1 || dayNum > daysInMonth) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.cardBorder),
                        borderRadius: BorderRadius.circular(6),
                        color: const Color(0xFFF8FAFC),
                      ),
                    );
                  }

                  final events = controller.monthEvents[dayNum] ?? const [];
                  final deliveries =
                      controller.dayDeliveriesMap[dayNum] ?? const [];
                  final isSelected = dayNum == selectedDay;
                  final hasExtra = events.length > 3;

                  return InkWell(
                    onTap: () => controller.selectDay(dayNum),
                    onLongPress: events.isNotEmpty
                        ? () {
                            controller.selectDay(dayNum);
                            DayEventsDialog.show(
                              context,
                              date: DateTime(
                                month.year,
                                month.month,
                                dayNum,
                              ),
                              events: events,
                              deliveries: deliveries,
                            );
                          }
                        : null,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.cardBorder,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryBlue
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$dayNum',
                              style: TextStyle(
                                fontSize: cellFont,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...events.take(3).map(
                                    (e) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 2,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 5,
                                            height: 5,
                                            margin: const EdgeInsets.only(
                                              right: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: e.color,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              e.title,
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: eventFont,
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (hasExtra)
                                    InkWell(
                                      onTap: () {
                                        controller.selectDay(dayNum);
                                        DayEventsDialog.show(
                                          context,
                                          date: DateTime(
                                            month.year,
                                            month.month,
                                            dayNum,
                                          ),
                                          events: events,
                                          deliveries: deliveries,
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(4),
                                      child: Tooltip(
                                        message: events
                                            .skip(3)
                                            .map((e) => e.title)
                                            .join(', '),
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '+${events.length - 3} more',
                                                style: TextStyle(
                                                  fontSize: eventFont,
                                                  color: AppColors.primaryBlue,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Icon(
                                                Icons.arrow_forward_ios_rounded,
                                                size: (eventFont - 2)
                                                    .clamp(7.0, 9.0),
                                                color: AppColors.primaryBlue,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
