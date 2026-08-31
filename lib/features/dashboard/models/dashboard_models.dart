import 'package:flutter/material.dart';

import '../../../app/constants/app_assets.dart';
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

  factory SiteRow.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] ?? json['lifecycleStatus'] ?? 'On Track';
    Color sColor = AppColors.badgeGreen;
    if (statusStr.toString().toLowerCase().contains('delay')) {
      sColor = AppColors.badgeRed;
    } else if (statusStr.toString().toLowerCase().contains('transit') || statusStr.toString().toLowerCase().contains('progress')) {
      sColor = AppColors.badgePink;
    }

    final double prog = (json['progress'] is num)
        ? (json['progress'] as num).toDouble()
        : ((json['completionPct'] is num) ? (json['completionPct'] as num).toDouble() / 100.0 : 0.5);

    return SiteRow(
      project: json['projectName'] ?? json['project'] ?? json['title'] ?? 'Project',
      location: json['location'] ?? json['siteLocation'] ?? 'Site A',
      progress: prog,
      deadline: json['deadline'] ?? json['targetDate'] ?? json['dueDate'] ?? '',
      status: statusStr.toString(),
      statusColor: sColor,
      barColor: const Color(0xFFF97316),
    );
  }
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

  factory DeadlineItem.fromJson(Map<String, dynamic> json) {
    return DeadlineItem(
      project: json['projectName'] ?? json['project'] ?? json['title'] ?? 'Project',
      location: json['location'] ?? json['siteLocation'] ?? 'Site A',
      date: json['date'] ?? json['targetDate'] ?? json['dueDate'] ?? '',
      daysLeft: json['daysLeft'] != null ? '${json['daysLeft']} Days Left' : 'Upcoming',
    );
  }
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

  factory TimelineStep.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] ?? 'Upcoming';
    final isDone = statusStr.toString().toLowerCase() == 'completed' || json['done'] == true;
    final isInProg = statusStr.toString().toLowerCase() == 'inprogress' || statusStr.toString().toLowerCase() == 'in_progress';

    return TimelineStep(
      title: json['title'] ?? json['name'] ?? 'Step',
      date: json['date'] ?? json['targetDate'] ?? '',
      status: statusStr.toString(),
      statusColor: isDone ? AppColors.badgeGreen : AppColors.badgePink,
      done: isDone,
      inProgress: isInProg,
    );
  }
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

  factory CarrierRow.fromJson(Map<String, dynamic> json) {
    final statusStr = json['priority'] ?? json['status'] ?? 'On Time';
    final isDelayed = statusStr.toString().toLowerCase().contains('delay');

    return CarrierRow(
      carrier: json['carrier'] ?? json['name'] ?? json['transporter'] ?? 'Carrier',
      loadsToday: json['loadsToday']?.toString() ?? json['loads']?.toString() ?? '0',
      onTime: json['onTime']?.toString() ?? '0',
      delayed: json['delayed']?.toString() ?? '0',
      priority: statusStr.toString(),
      priorityColor: isDelayed ? AppColors.badgeRed : AppColors.badgeGreen,
    );
  }
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

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      title: json['title'] ?? json['description'] ?? json['message'] ?? 'Activity',
      time: json['time'] ?? json['timestamp'] ?? json['createdAt'] ?? '',
      iconAsset: AppAssets.iconDocBlue,
    );
  }
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
