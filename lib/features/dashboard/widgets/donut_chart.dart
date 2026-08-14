import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../models/dashboard_models.dart';

/// Reusable circular / donut progress chart used on the dashboard.
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.slices,
    required this.centerTitle,
    required this.centerValue,
    this.size,
    this.strokeWidth,
  });

  final List<ChartSlice> slices;
  final String centerTitle;
  final String centerValue;
  final double? size;
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    final chartSize = size ?? (mq.width * 0.12).clamp(110.0, 150.0);
    final stroke = strokeWidth ?? chartSize * 0.16;
    final titleSize = (mq.width * 0.008).clamp(9.0, 11.0);
    final valueSize = (mq.width * 0.016).clamp(16.0, 22.0);

    return SizedBox(
      width: chartSize,
      height: chartSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(chartSize),
            painter: _DonutPainter(slices: slices, strokeWidth: stroke),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: chartSize * 0.18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  centerTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleSize,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: chartSize * 0.02),
                Text(
                  centerValue,
                  style: TextStyle(
                    fontSize: valueSize,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Single-value circular progress (e.g. 85.8%).
class ProgressCircleBar extends StatelessWidget {
  const ProgressCircleBar({
    super.key,
    required this.progress,
    required this.color,
    this.size,
    this.strokeWidth,
    this.child,
  });

  final double progress;
  final Color color;
  final double? size;
  final double? strokeWidth;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    final chartSize = size ?? (mq.width * 0.045).clamp(36.0, 48.0);
    final stroke = strokeWidth ?? chartSize * 0.14;

    return SizedBox(
      width: chartSize,
      height: chartSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(chartSize),
            painter: _ProgressCirclePainter(
              progress: progress.clamp(0.0, 1.0),
              color: color,
              strokeWidth: stroke,
            ),
          ),
          ?child,
        ],
      ),
    );
  }
}

class ChartLegend extends StatelessWidget {
  const ChartLegend({super.key, required this.slices});

  final List<ChartSlice> slices;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final fontSize = (size.width * 0.009).clamp(10.0, 12.0);

    return Column(
      children: slices.map((slice) {
        return Padding(
          padding: EdgeInsets.only(bottom: size.height * 0.008),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: slice.color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: size.width * 0.006),
              Expanded(
                child: Text(
                  slice.label,
                  style: TextStyle(
                    fontSize: fontSize,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${slice.percent.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: fontSize,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.slices, required this.strokeWidth});

  final List<ChartSlice> slices;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    var start = -math.pi / 2;

    for (final slice in slices) {
      final sweep = (slice.percent / 100) * 2 * math.pi;
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.slices != slices || oldDelegate.strokeWidth != strokeWidth;
}

class _ProgressCirclePainter extends CustomPainter {
  _ProgressCirclePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bg = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 0, 2 * math.pi, false, bg);

    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, progress * 2 * math.pi, false, fg);
  }

  @override
  bool shouldRepaint(covariant _ProgressCirclePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}
