import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/delivery_tracking_controller.dart';

import '../../../app/widgets/app_shimmer.dart';

class DeliverySummaryCards extends StatelessWidget {
  const DeliverySummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gap = (size.width * 0.01).clamp(10.0, 14.0);
    final controller = Get.find<DeliveryTrackingController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const AppShimmerSummaryRow(count: 4);
      }
      return Row(
        children: [
          Expanded(
            child: _SummaryCard(
              label: 'In Transit',
              value: '${controller.inTransitCount}',
              subtitle: 'Arriving at Plant',
              color: const Color(0xFF1E5BB4),
              icon: Icons.local_shipping_outlined,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _SummaryCard(
              label: 'Staged',
              value: '${controller.stagedCount}',
              subtitle: 'At Plant/Yard',
              color: const Color(0xFF34C759),
              icon: Icons.unarchive_outlined,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _SummaryCard(
              label: 'Ready',
              value: '${controller.readyCount}',
              subtitle: 'For Departure',
              color: const Color(0xFFFF6B4A),
              icon: Icons.check_circle_outline_rounded,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _SummaryCard(
              label: 'Total Today',
              value: '${controller.totalToday}',
              subtitle: 'All Deliveries',
              color: const Color(0xFF64748B),
              icon: Icons.inventory_2_outlined,
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
    required this.icon,
  });

  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.014,
        vertical: size.height * 0.016,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
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
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: (size.width * 0.010).clamp(11.0, 13.0),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: (size.width * 0.022).clamp(24.0, 30.0),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
        ],
      ),
    );
  }
}
