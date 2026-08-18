import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/app_assets.dart';
import '../../../app/theme/app_colors.dart';
import '../controllers/label_printing_controller.dart';

class LabelPrintingSummaryCards extends GetView<LabelPrintingController> {
  const LabelPrintingSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gap = (size.width * 0.01).clamp(10.0, 14.0);

    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: _SummaryCard(
              label: 'Total Bundles',
              value: '${controller.totalBundles}',
              subtitle: '+ 5.62% from last month',
              subtitleColor: AppColors.success,
              iconAsset: AppAssets.iconDocChartPink,
              iconCircleColor: AppColors.brandPrimary,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _SummaryCard(
              label: 'Labels Printed',
              value: '${controller.labelsPrinted}',
              subtitle: '+ 11.4% from last month',
              subtitleColor: AppColors.success,
              iconAsset: AppAssets.iconTruckGreen,
              iconCircleColor: AppColors.success,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _SummaryCard(
              label: 'Labels Pending',
              value: '${controller.labelsPending}',
              subtitle: '+ 8.52% from last month',
              subtitleColor: AppColors.success,
              iconAsset: AppAssets.iconStatClock,
              iconCircleColor: AppColors.chartYellow,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _SummaryCard(
              label: 'Labels Printed Today',
              value: '${controller.labelsPrintedToday}',
              subtitle: '- 7.45% from last month',
              subtitleColor: AppColors.danger,
              iconAsset: AppAssets.iconActivityOrange,
              iconCircleColor: AppColors.danger,
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
    required this.subtitleColor,
    required this.iconAsset,
    required this.iconCircleColor,
  });

  final String label;
  final String value;
  final String subtitle;
  final Color subtitleColor;
  final String iconAsset;
  final Color iconCircleColor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final labelSize = (size.width * 0.009).clamp(11.0, 13.0);
    final valueSize = (size.width * 0.018).clamp(22.0, 28.0);
    final subSize = (size.width * 0.008).clamp(10.0, 12.0);
    final circleSize = (size.width * 0.042).clamp(40.0, 48.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.012,
        vertical: size.height * 0.018,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: labelSize,
                  ),
                ),
                SizedBox(height: size.height * 0.006),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: valueSize,
                  ),
                ),
                SizedBox(height: size.height * 0.004),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: subtitleColor,
                    fontWeight: FontWeight.w600,
                    fontSize: subSize,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              color: iconCircleColor,
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(circleSize * 0.22),
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                child: Image.asset(iconAsset, fit: BoxFit.contain),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
