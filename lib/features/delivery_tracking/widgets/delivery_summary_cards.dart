import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/delivery_tracking_controller.dart';

class DeliverySummaryCards extends GetView<DeliveryTrackingController> {
  const DeliverySummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gap = (size.width * 0.01).clamp(10.0, 14.0);

    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: _SummaryCard(
              label: 'In Transit',
              value: '${controller.inTransitCount}',
              subtitle: 'Arriving at Plant',
              color: const Color(0xFF2563EB),
              iconData: Icons.local_shipping_outlined,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _SummaryCard(
              label: 'Staged',
              value: '${controller.stagedCount}',
              subtitle: 'At Plant/Yard',
              color: const Color(0xFF22C55E),
              iconData: Icons.inventory_2_outlined,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _SummaryCard(
              label: 'Ready',
              value: '${controller.readyCount}',
              subtitle: 'For Departure',
              color: const Color(0xFFF97316),
              iconData: Icons.check_circle_outline_rounded,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _SummaryCard(
              label: 'Total Today',
              value: '${controller.totalToday}',
              subtitle: 'All Deliveries',
              color: const Color(0xFF6B7280),
              iconData: Icons.calendar_today_outlined,
            ),
          ),
        ],
      );
    });
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.iconData,
  });

  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final labelSize = (size.width * 0.009).clamp(10.0, 12.0);
    final valueSize = (size.width * 0.020).clamp(24.0, 32.0);
    final subSize = (size.width * 0.008).clamp(10.0, 11.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.014,
        vertical: size.height * 0.016,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
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
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                    fontSize: labelSize,
                  ),
                ),
                SizedBox(height: size.height * 0.005),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: valueSize,
                  ),
                ),
                SizedBox(height: size.height * 0.004),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w500,
                    fontSize: subSize,
                  ),
                ),
              ],
            ),
          ),
          Icon(iconData, color: Colors.white.withValues(alpha: 0.6), size: 32),
        ],
      ),
    );
  }
}
