import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../controllers/material_requests_controller.dart';

import '../../../app/widgets/app_shimmer.dart';

class MaterialRequestSummaryCards extends GetView<MaterialRequestsController> {
  const MaterialRequestSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gap = (size.width * 0.01).clamp(10.0, 14.0);

    return Obx(() {
      if (controller.isLoading.value) {
        return const AppShimmerSummaryRow(count: 4);
      }
      return Row(
        children: [
          Expanded(
            child: _SummaryCard(
              label: 'Total Requests',
              value: '${controller.totalRequestsStat.value}',
              subtitle: 'All Requests',
              icon: Icons.inventory_2_outlined,
              iconBg: const Color(0xFFC084FC), // Light purple background for total requests
              iconColor: Colors.white,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _SummaryCard(
              label: 'Pending',
              value: '${controller.pendingStat.value}',
              subtitle: 'Awaiting Action',
              icon: Icons.shopping_bag_outlined,
              iconBg: const Color(0xFFFFB800),
              iconColor: Colors.white,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _SummaryCard(
              label: 'Approved',
              value: '${controller.approvedStat.value}',
              subtitle: 'Approved Requests',
              icon: Icons.lock_open_rounded,
              iconBg: const Color(0xFF22C55E),
              iconColor: Colors.white,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _SummaryCard(
              label: 'Rejected',
              value: '${controller.rejectedStat.value}',
              subtitle: 'Rejected Requests',
              icon: Icons.hourglass_empty_rounded,
              iconBg: const Color(0xFFEF4444),
              iconColor: Colors.white,
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
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBg.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: iconBg, size: 16), // Use iconBg for the icon color itself like the web
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
