import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    final statusStr =
        json['deliveryStatus'] ??
        json['status'] ??
        json['lifecycleStatus'] ??
        'On Track';
    Color sColor = AppColors.badgeGreen;
    if (statusStr.toString().toLowerCase().contains('delay')) {
      sColor = AppColors.badgeRed;
    } else if (statusStr.toString().toLowerCase().contains('transit') ||
        statusStr.toString().toLowerCase().contains('progress')) {
      sColor = AppColors.badgePink;
    }

    final rawProgress =
        json['progressPct'] ?? json['completionPct'] ?? json['progress'] ?? 0;
    final progress = rawProgress is num
        ? rawProgress.toDouble()
        : double.tryParse(rawProgress.toString()) ?? 0;
    final site = (json['site'] ?? json['location'] ?? 'N/A').toString();
    final jobId = json['jobId']?.toString();
    final buildingType = json['buildingType']?.toString();
    final location = [
      site,
      if (jobId != null && jobId.isNotEmpty) jobId,
      if (buildingType != null && buildingType.isNotEmpty) buildingType,
    ].join(' • ');

    return SiteRow(
      project:
          json['projectName'] ?? json['project'] ?? json['title'] ?? 'Project',
      location: location,
      progress:
          (json.containsKey('progressPct') || json.containsKey('completionPct'))
          ? (progress / 100).clamp(0.0, 1.0)
          : (progress > 1 ? progress / 100 : progress).clamp(0.0, 1.0),
      deadline: _formatDashboardDate(
        json['deadline'] ?? json['targetDate'] ?? json['dueDate'],
      ),
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
    this.taskId = '',
    this.leadId = '',
    this.title = '',
    this.jobId = '',
    this.startDate = '—',
    this.estimatedEndDate = '—',
    this.completedDate,
    this.badgeLabel = 'Pending',
    this.badgeTone = 'warning',
    this.timelineStatusLine,
    this.onTimeStatus = '',
    this.daysLeftNumber,
    this.status = '',
    this.priority = '',
    this.assignedTo = '',
  });

  final String project;
  final String location;
  final String date;
  final String daysLeft;
  final String taskId;
  final String leadId;
  final String title;
  final String jobId;
  final String startDate;
  final String estimatedEndDate;
  final String? completedDate;
  final String badgeLabel;
  final String badgeTone;
  final String? timelineStatusLine;
  final String onTimeStatus;
  final int? daysLeftNumber;
  final String status;
  final String priority;
  final String assignedTo;

  Color get badgeTextColor {
    final t = badgeTone.toLowerCase();
    final l = badgeLabel.toLowerCase();
    if (t == 'danger' || l.contains('delayed') || l.contains('overdue')) {
      return const Color(0xFFB91C1C); // Red
    }
    if (t == 'success' ||
        l.contains('completed') ||
        l.contains('under timeline')) {
      return const Color(0xFF15803D); // Green
    }
    if (t == 'info' || l.contains('progress')) {
      return const Color(0xFF1D4ED8); // Blue
    }
    return const Color(0xFFD97706); // Amber
  }

  Color get badgeBgColor {
    final t = badgeTone.toLowerCase();
    final l = badgeLabel.toLowerCase();
    if (t == 'danger' || l.contains('delayed') || l.contains('overdue')) {
      return const Color(0xFFFEE2E2); // Light Red
    }
    if (t == 'success' ||
        l.contains('completed') ||
        l.contains('under timeline')) {
      return const Color(0xFFDCFCE7); // Light Green
    }
    if (t == 'info' || l.contains('progress')) {
      return const Color(0xFFDBEAFE); // Light Blue
    }
    return const Color(0xFFFEF3C7); // Light Amber
  }

  Color get badgeDotColor {
    final t = badgeTone.toLowerCase();
    final l = badgeLabel.toLowerCase();
    if (t == 'danger' || l.contains('delayed') || l.contains('overdue')) {
      return const Color(0xFFDC2626);
    }
    if (t == 'success' ||
        l.contains('completed') ||
        l.contains('under timeline')) {
      return const Color(0xFF16A34A);
    }
    if (t == 'info' || l.contains('progress')) {
      return const Color(0xFF2563EB);
    }
    return const Color(0xFFD97706);
  }

  factory DeadlineItem.fromJson(Map<String, dynamic> json) {
    final projectMap = json['project'] is Map
        ? Map<String, dynamic>.from(json['project'] as Map)
        : null;

    final taskId =
        (json['taskId'] ?? json['_id'] ?? json['id'] ?? '').toString();
    final leadId = (projectMap?['leadId'] ?? json['leadId'] ?? '').toString();
    final jobId = (projectMap?['jobId'] ?? json['jobId'] ?? '').toString();

    final projectName = (projectMap?['projectName'] ??
            json['projectName'] ??
            json['project'] ??
            'Project')
        .toString();

    final taskTitle = (json['title'] ??
            json['taskTitle'] ??
            json['name'] ??
            projectName)
        .toString();

    final loc = (projectMap?['location'] ??
            json['location'] ??
            json['site'] ??
            json['siteLocation'] ??
            json['locationName'] ??
            '—')
        .toString();

    final deadlineRaw = json['estimatedEndDate'] ??
        json['endDate'] ??
        json['expectedCloseDate'] ??
        json['deadline'] ??
        json['date'] ??
        json['targetDate'] ??
        json['dueDate'];

    final formattedEstEnd = _formatDashboardDate(deadlineRaw);
    final formattedStart = _formatDashboardDate(
      json['startDate'] ?? json['start_date'] ?? json['createdAt'],
    );
    final completedRaw = json['completedDate'] ?? json['completedAt'];
    final formattedCompleted = completedRaw != null &&
            completedRaw.toString().isNotEmpty &&
            completedRaw.toString() != 'null'
        ? _formatDashboardDate(completedRaw)
        : null;

    // Timeline badge
    String badgeLabel = '';
    String badgeTone = '';
    if (json['timelineBadge'] is Map) {
      final bMap = json['timelineBadge'] as Map;
      badgeLabel = bMap['label']?.toString() ?? '';
      badgeTone = bMap['tone']?.toString() ?? '';
    }

    final statusLine = json['timelineStatusLine']?.toString();

    // Days left calculation / formatting
    int? daysLeftNum;
    if (json['daysLeft'] != null) {
      if (json['daysLeft'] is num) {
        daysLeftNum = (json['daysLeft'] as num).toInt();
      } else {
        daysLeftNum = int.tryParse(json['daysLeft'].toString());
      }
    }

    String daysLeftStr;
    if (statusLine != null && statusLine.trim().isNotEmpty) {
      daysLeftStr = statusLine.trim();
    } else if (daysLeftNum != null) {
      if (daysLeftNum < 0) {
        daysLeftStr = '${daysLeftNum.abs()} Days Overdue';
      } else if (daysLeftNum == 0) {
        daysLeftStr = 'Due Today';
      } else {
        daysLeftStr = '$daysLeftNum Days Left';
      }
    } else if (deadlineRaw != null && deadlineRaw.toString().isNotEmpty) {
      final parsedDate = DateTime.tryParse(deadlineRaw.toString());
      if (parsedDate != null) {
        final now = DateUtils.dateOnly(DateTime.now());
        final target = DateUtils.dateOnly(parsedDate);
        final diff = target.difference(now).inDays;
        daysLeftNum = diff;
        if (diff < 0) {
          daysLeftStr = '${diff.abs()} Days Overdue';
        } else if (diff == 0) {
          daysLeftStr = 'Due Today';
        } else {
          daysLeftStr = '$diff Days Left';
        }
      } else {
        daysLeftStr = 'Upcoming';
      }
    } else {
      daysLeftStr = 'Upcoming';
    }

    if (badgeLabel.isEmpty) {
      if (daysLeftNum != null && daysLeftNum < 0) {
        badgeLabel = 'Delayed';
        badgeTone = 'danger';
      } else if (json['status'] == 'in_progress') {
        badgeLabel = 'In Progress';
        badgeTone = 'info';
      } else {
        badgeLabel = 'Pending';
        badgeTone = 'warning';
      }
    }

    String assignedToName = '';
    if (json['assignedTo'] is Map) {
      assignedToName =
          (json['assignedTo']['name'] ?? json['assignedTo']['email'] ?? '')
              .toString();
    } else if (json['assignedTo'] != null) {
      assignedToName = json['assignedTo'].toString();
    }

    return DeadlineItem(
      project: projectName,
      location: loc,
      date: formattedEstEnd.isNotEmpty ? formattedEstEnd : '—',
      daysLeft: daysLeftStr,
      taskId: taskId,
      leadId: leadId,
      title: taskTitle,
      jobId: jobId,
      startDate: formattedStart.isNotEmpty ? formattedStart : '—',
      estimatedEndDate: formattedEstEnd.isNotEmpty ? formattedEstEnd : '—',
      completedDate: formattedCompleted,
      badgeLabel: badgeLabel,
      badgeTone: badgeTone,
      timelineStatusLine: statusLine,
      onTimeStatus: (json['onTimeStatus'] ?? '').toString(),
      daysLeftNumber: daysLeftNum,
      status: (json['status'] ?? '').toString(),
      priority: (json['priority'] ?? '').toString(),
      assignedTo: assignedToName,
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
    final isDone =
        statusStr.toString().toLowerCase() == 'completed' ||
        json['done'] == true;
    final isInProg =
        statusStr.toString().toLowerCase() == 'inprogress' ||
        statusStr.toString().toLowerCase() == 'in_progress';

    return TimelineStep(
      title: json['label'] ?? json['title'] ?? json['name'] ?? 'Step',
      date: _formatDashboardDate(
        json['date'] ?? json['targetDate'],
        pattern: 'dd/MM/yyyy',
      ),
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
      carrier:
          json['carrierName'] ??
          json['carrier'] ??
          json['name'] ??
          json['transporter'] ??
          'Carrier',
      loadsToday:
          json['loadsToday']?.toString() ?? json['loads']?.toString() ?? '0',
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
    final project = json['project'] is Map ? json['project'] as Map : const {};
    final projectName = project['projectName']?.toString();
    final jobId = project['jobId']?.toString() ?? '-';
    final rawStatus =
        json['status']?.toString().replaceAll('_', ' ') ?? 'unknown';
    final deliveryTitle = projectName == null || projectName.isEmpty
        ? 'Delivery ($rawStatus) [$jobId]'
        : 'Delivery ($rawStatus) for $projectName [$jobId]';
    var displayTime =
        (json['time'] ??
                json['timestamp'] ??
                json['occurredAt'] ??
                json['createdAt'] ??
                '')
            .toString();
    final occurredAt = DateTime.tryParse(displayTime);
    if (occurredAt != null) {
      displayTime = DateFormat('hh:mm:ss a').format(occurredAt.toLocal());
    }
    final rawDate = json['deliveryDate'];
    if (rawDate != null) {
      final parsed = DateTime.tryParse(rawDate.toString());
      if (parsed != null) {
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        displayTime = '${months[parsed.month - 1]} ${parsed.day}';
      }
    }
    return ActivityItem(
      title: json['deliveryId'] != null
          ? deliveryTitle
          : (json['title'] ??
                    json['description'] ??
                    json['message'] ??
                    'Activity')
                .toString(),
      time: displayTime,
      iconAsset: AppAssets.iconDocBlue,
    );
  }
}

String _formatDashboardDate(dynamic value, {String pattern = 'MMM d, yyyy'}) {
  if (value == null || value.toString().isEmpty) return '';
  final parsed = DateTime.tryParse(value.toString());
  return parsed == null ? value.toString() : DateFormat(pattern).format(parsed);
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
      (MediaQuery.sizeOf(context).width * 0.012).clamp(12.0, 24.0);
  static double section(BuildContext context) =>
      (MediaQuery.sizeOf(context).height * 0.014).clamp(12.0, 20.0);
  static double item(BuildContext context) =>
      MediaQuery.sizeOf(context).height * 0.01;
  static const double radius = 5;
  static const BorderSide border = BorderSide(color: AppColors.cardBorder);
}
