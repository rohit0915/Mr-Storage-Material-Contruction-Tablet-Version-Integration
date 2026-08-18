import 'package:flutter/material.dart';

import '../../../app/constants/app_assets.dart';
import '../../../app/theme/app_colors.dart';

/// Figma-style summary row: white cards with colored borders.
class MaterialRequestSummaryCards extends StatelessWidget {
  const MaterialRequestSummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gap = (size.width * 0.01).clamp(10.0, 14.0);

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Total Requests',
            value: '48',
            subtitle: 'All Payment Requests',
            iconAsset: AppAssets.iconDocChartPink,
            borderColor: const Color(0xFFAB47BC),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: _SummaryCard(
            label: 'Pending',
            value: '18',
            subtitle: '\$245,680.150',
            iconAsset: AppAssets.iconTruckGreen,
            borderColor: const Color(0xFF22C55E),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: _SummaryCard(
            label: 'Approved',
            value: '22',
            subtitle: '582,390.75',
            iconAsset: AppAssets.iconStatClock,
            borderColor: const Color(0xFFFFC107),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: _SummaryCard(
            label: 'Rejected',
            value: '6',
            subtitle: '378,420.20',
            iconAsset: AppAssets.iconActivityOrange,
            borderColor: const Color(0xFFEF4444),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.iconAsset,
    required this.borderColor,
  });

  final String label;
  final String value;
  final String subtitle;
  final String iconAsset;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final labelSize = (size.width * 0.009).clamp(11.0, 13.0);
    final valueSize = (size.width * 0.018).clamp(22.0, 28.0);
    final subSize = (size.width * 0.008).clamp(10.0, 12.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.012,
        vertical: size.height * 0.018,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
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
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: subSize,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: (size.width * 0.038).clamp(36.0, 44.0),
            height: (size.width * 0.038).clamp(36.0, 44.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor.withValues(alpha: 0.45)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Image.asset(iconAsset, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}
