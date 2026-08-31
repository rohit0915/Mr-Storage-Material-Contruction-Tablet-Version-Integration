import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
              subtitle: '5.62% from last month',
              isUp: true,
              themeColor: const Color(0xFF7C3AED), // Vibrant purple
              iconData: Icons.description_outlined,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _SummaryCard(
              label: 'Labels Printed',
              value: '${controller.labelsPrinted}',
              subtitle: '11.4% from last month',
              isUp: true,
              themeColor: const Color(0xFF10B981), // Emerald green
              iconData: Icons.check_circle_outline_rounded,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _SummaryCard(
              label: 'Labels Pending',
              value: '${controller.labelsPending}',
              subtitle: '8.52% from last month',
              isUp: true,
              themeColor: const Color(0xFFF59E0B), // Amber / Gold
              iconData: Icons.hourglass_empty_rounded,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _SummaryCard(
              label: 'Labels Printed Today',
              value: '${controller.labelsPrintedToday}',
              subtitle: '7.45% from last month',
              isUp: false,
              themeColor: const Color(0xFFEF4444), // Crimson Red
              iconData: Icons.error_outline_rounded,
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
    required this.isUp,
    required this.themeColor,
    required this.iconData,
  });

  final String label;
  final String value;
  final String subtitle;
  final bool isUp;
  final Color themeColor;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final labelSize = (size.width * 0.009).clamp(11.0, 13.0);
    final valueSize = (size.width * 0.018).clamp(22.0, 28.0);
    final subSize = (size.width * 0.008).clamp(10.0, 12.0);
    final circleSize = (size.width * 0.038).clamp(38.0, 44.0);

    final subColor = isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444);

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
          // Background Decorative Wave
          Positioned.fill(
            child: CustomPaint(
              painter: _CardWavePainter(color: themeColor),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.012,
              vertical: size.height * 0.016,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        ],
                      ),
                    ),

                    // Right Circle Icon
                    Container(
                      width: circleSize,
                      height: circleSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: themeColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: themeColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        iconData,
                        color: Colors.white,
                        size: circleSize * 0.55,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.008),

                // Subtitle Row with Trend Arrow
                Row(
                  children: [
                    Icon(
                      isUp ? Icons.north_east_rounded : Icons.south_east_rounded,
                      size: subSize + 2,
                      color: subColor,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: subColor,
                          fontWeight: FontWeight.w700,
                          fontSize: subSize,
                        ),
                      ),
                    ),
                  ],
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
        size.width * 0.5, size.height * 0.95,
        size.width * 0.7, size.height * 0.6,
        size.width, size.height * 0.68,
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
        size.width * 0.7, size.height * 0.8,
        size.width * 0.85, size.height * 0.4,
        size.width, size.height * 0.45,
      )
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant _CardWavePainter oldDelegate) =>
      oldDelegate.color != color;
}
