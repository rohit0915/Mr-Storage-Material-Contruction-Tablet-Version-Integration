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
              iconBg: const Color(0xFFF97316),
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
    final size = MediaQuery.sizeOf(context);
    final labelSize = (size.width * 0.009).clamp(11.0, 13.0);
    final valueSize = (size.width * 0.018).clamp(20.0, 26.0);
    final subSize = (size.width * 0.008).clamp(10.0, 12.0);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _CardWavePainter(color: iconBg)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.012,
              vertical: size.height * 0.016,
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
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: valueSize,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: subSize,
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
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: iconBg.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardWavePainter extends CustomPainter {
  const _CardWavePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final path1 = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.3, size.height)
      ..cubicTo(
        size.width * 0.5,
        size.height * 0.95,
        size.width * 0.7,
        size.height * 0.6,
        size.width,
        size.height * 0.68,
      )
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path1, paint1);

    final paint2 = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.5, size.height)
      ..cubicTo(
        size.width * 0.7,
        size.height * 0.8,
        size.width * 0.85,
        size.height * 0.4,
        size.width,
        size.height * 0.45,
      )
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _CardWavePainter oldDelegate) =>
      oldDelegate.color != color;
}
