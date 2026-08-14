import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';

class ChartSlice {
  const ChartSlice({
    required this.label,
    required this.percent,
    required this.color,
  });

  final String label;
  final double percent;
  final Color color;
}

class MetricItem {
  const MetricItem({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.iconBg,
    required this.iconColor,
    required this.subtitleColor,
    this.icon,
    this.iconAsset,
    this.up = true,
  });

  final String value;
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? iconAsset;
  final Color iconBg;
  final Color iconColor;
  final Color subtitleColor;
  final bool up;
}

class SiteRow {
  const SiteRow({
    required this.project,
    required this.location,
    required this.progress,
    required this.deadline,
    required this.status,
    required this.statusColor,
    required this.barColor,
  });

  final String project;
  final String location;
  final double progress;
  final String deadline;
  final String status;
  final Color statusColor;
  final Color barColor;
}

class DeadlineItem {
  const DeadlineItem({
    required this.project,
    required this.location,
    required this.date,
    required this.daysLeft,
  });

  final String project;
  final String location;
  final String date;
  final String daysLeft;
}

class TimelineStep {
  const TimelineStep({
    required this.title,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.done,
    this.inProgress = false,
  });

  final String title;
  final String date;
  final String status;
  final Color statusColor;
  final bool done;
  final bool inProgress;
}

class CarrierRow {
  const CarrierRow({
    required this.carrier,
    required this.loadsToday,
    required this.onTime,
    required this.delayed,
    required this.priority,
    required this.priorityColor,
  });

  final String carrier;
  final String loadsToday;
  final String onTime;
  final String delayed;
  final String priority;
  final Color priorityColor;
}

class ActivityItem {
  const ActivityItem({
    required this.title,
    required this.time,
    required this.iconAsset,
  });

  final String title;
  final String time;
  final String iconAsset;
}

class FreightSummary {
  const FreightSummary({
    required this.value,
    required this.label,
    required this.iconAsset,
    required this.iconBg,
    this.progress,
    this.progressColor,
  });

  final String value;
  final String label;
  final String iconAsset;
  final Color iconBg;
  final double? progress;
  final Color? progressColor;
}

/// Shared spacing used across dashboard cards.
class DashboardGap {
  DashboardGap._();

  static double page(BuildContext context) =>
      MediaQuery.sizeOf(context).width * 0.012;
  static double section(BuildContext context) =>
      MediaQuery.sizeOf(context).height * 0.014;
  static double item(BuildContext context) =>
      MediaQuery.sizeOf(context).height * 0.01;
  static const double radius = 5;
  static const BorderSide border = BorderSide(color: AppColors.cardBorder);
}
