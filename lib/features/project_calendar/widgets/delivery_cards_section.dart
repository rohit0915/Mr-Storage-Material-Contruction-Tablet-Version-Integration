import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/project_calendar_controller.dart';
import '../models/project_calendar_models.dart';

class DeliveryCardsSection extends GetView<ProjectCalendarController> {
  const DeliveryCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final titleSize = (size.width * 0.013).clamp(14.0, 16.0);
    final gap = (size.width * 0.01).clamp(10.0, 14.0);

    return Obx(() {
      final day = controller.selectedDay.value;
      final events = controller.selectedDayEvents;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$day September 2022',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                'View All',
                style: TextStyle(
                  fontSize: (size.width * 0.010).clamp(11.0, 13.0),
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (events.isNotEmpty) ...[
            SizedBox(height: size.height * 0.01),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: events
                  .map(
                    (e) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: e.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        e.title,
                        style: TextStyle(
                          color: e.color,
                          fontWeight: FontWeight.w600,
                          fontSize: (size.width * 0.009).clamp(10.0, 12.0),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          SizedBox(height: size.height * 0.014),
          Row(
            children: [
              Text(
                'Deliveries on this date',
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.cardBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('View All'),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.012),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: controller.deliveries
                    .map((d) => SizedBox(
                          width: cardWidth,
                          child: _DeliveryCard(item: d),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      );
    });
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.item});

  final DeliveryItem item;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final titleSize = (size.width * 0.012).clamp(13.0, 15.0);
    final bodySize = (size.width * 0.010).clamp(11.0, 13.0);

    return Container(
      padding: EdgeInsets.all((size.width * 0.012).clamp(12.0, 16.0)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.id,
            style: TextStyle(
              fontSize: bodySize,
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: size.height * 0.004),
          Text(
            item.title,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            item.location,
            style: TextStyle(
              fontSize: bodySize,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: size.height * 0.014),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.inventory_2_outlined,
                      iconBg: AppColors.chartPurple.withValues(alpha: 0.15),
                      iconColor: AppColors.chartPurple,
                      label: 'Quantity',
                      value: item.quantity,
                    ),
                    SizedBox(height: size.height * 0.01),
                    _InfoRow(
                      icon: Icons.place_outlined,
                      iconBg: AppColors.info.withValues(alpha: 0.15),
                      iconColor: AppColors.info,
                      label: 'Staging Area',
                      value: item.stagingArea,
                    ),
                  ],
                ),
              ),
              SizedBox(width: size.width * 0.01),
              Expanded(
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.login,
                      iconBg: AppColors.success.withValues(alpha: 0.15),
                      iconColor: AppColors.success,
                      label: 'Arrival at Plant',
                      value: item.arrival,
                    ),
                    SizedBox(height: size.height * 0.01),
                    _InfoRow(
                      icon: Icons.logout,
                      iconBg: AppColors.orange.withValues(alpha: 0.15),
                      iconColor: AppColors.orange,
                      label: 'Departure from Plant',
                      value: item.departure,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.014),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed(
                AppRoutes.deliveryDetails,
                arguments: {
                  'id': item.id,
                  'title': item.title,
                  'location': item.location,
                  'quantity': item.quantity,
                  'stagingArea': item.stagingArea,
                  'arrival': item.arrival,
                  'departure': item.departure,
                },
              ),
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text('View Details'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: size.height * 0.014),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final labelSize = (size.width * 0.008).clamp(9.0, 11.0);
    final valueSize = (size.width * 0.010).clamp(11.0, 13.0);

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: iconColor),
        ),
        SizedBox(width: size.width * 0.006),
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
                style: TextStyle(
                  fontSize: valueSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
