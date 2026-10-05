import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/project_calendar_controller.dart';
import '../models/project_calendar_models.dart';
import 'delivery_details_dialog.dart';

class DayEventsDialog extends StatelessWidget {
  const DayEventsDialog({
    super.key,
    required this.date,
    required this.events,
    required this.deliveries,
  });

  final DateTime date;
  final List<CalendarDayEvent> events;
  final List<DeliveryItem> deliveries;

  static Future<void> show(
    BuildContext context, {
    required DateTime date,
    required List<CalendarDayEvent> events,
    required List<DeliveryItem> deliveries,
  }) {
    return showDialog(
      context: context,
      builder: (context) => DayEventsDialog(
        date: date,
        events: events,
        deliveries: deliveries,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(date);
    final controller = Get.isRegistered<ProjectCalendarController>()
        ? Get.find<ProjectCalendarController>()
        : null;

    final dialogWidth = (size.width * 0.45).clamp(380.0, 520.0);
    final maxHeight = size.height * 0.75;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: maxHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.primaryBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${events.length} ${events.length == 1 ? 'Delivery' : 'Deliveries'} Scheduled',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 20),
                    splashRadius: 20,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.cardBorder),
              const SizedBox(height: 12),

              // Deliveries List
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      for (int index = 0; index < events.length; index++) ...[
                        if (index > 0) const SizedBox(height: 10),
                        Builder(
                          builder: (context) {
                            final event = events[index];
                            DeliveryItem? delivery;
                            if (index < deliveries.length) {
                              delivery = deliveries[index];
                            }

                            final title = event.title;
                            final location = delivery?.location ?? '';
                            final code = delivery?.code ?? '';

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: event.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        if (location.isNotEmpty ||
                                            code.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              if (location.isNotEmpty) ...[
                                                const Icon(
                                                  Icons.location_on_outlined,
                                                  size: 13,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                                const SizedBox(width: 3),
                                                Flexible(
                                                  child: Text(
                                                    location,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                              ],
                                              if (code.isNotEmpty)
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      4,
                                                    ),
                                                    border: Border.all(
                                                      color:
                                                          AppColors.cardBorder,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    code,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: AppColors
                                                          .textSecondary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (delivery != null &&
                                      delivery.id.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        showDialog(
                                          context: context,
                                          builder: (ctx) =>
                                              DeliveryDetailsDialog(
                                            item: delivery!,
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primaryBlue,
                                        side: const BorderSide(
                                          color: AppColors.primaryBlue,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        minimumSize: Size.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                      ),
                                      child: const Text(
                                        'View',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.cardBorder),
              const SizedBox(height: 14),

              // Actions Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.cardBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                  if (controller != null)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        controller.openAddDelivery(context);
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Delivery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
