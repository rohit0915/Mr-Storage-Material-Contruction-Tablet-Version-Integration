import 'package:flutter/material.dart';
import '../../../app/constants/app_assets.dart';
import '../../../app/theme/app_colors.dart';

enum ProjectCalendarTab { calendar, project }

class CalendarProjectOption {
  const CalendarProjectOption({
    required this.id,
    required this.name,
    required this.code,
    required this.imageAsset,
  });

  final String id;
  final String name;
  final String code;
  final String imageAsset;

  factory CalendarProjectOption.fromJson(Map<String, dynamic> json) {
    final idStr = json['_id'] ?? json['leadId'] ?? json['id'] ?? '';
    final nameStr =
        json['projectName'] ?? json['name'] ?? json['title'] ?? 'Project';
    final codeStr = json['jobId'] ?? json['leadNumber'] ?? json['projectId'] ?? json['code'] ?? '';
    return CalendarProjectOption(
      id: idStr.toString(),
      name: nameStr.toString(),
      code: codeStr.toString(),
      imageAsset: AppAssets.thumbBuilding,
    );
  }
}

class CalendarDayEvent {
  const CalendarDayEvent({
    required this.title,
    this.color = const Color(0xFF2563EB),
    this.createdAt,
  });

  final String title;
  final Color color;
  final DateTime? createdAt;

  factory CalendarDayEvent.fromJson(Map<String, dynamic> json) {
    String tStr = 'Event';
    if (json['title'] != null && json['title'].toString().trim().isNotEmpty) {
      tStr = json['title'].toString().trim();
    } else if (json['description'] != null &&
        json['description'].toString().trim().isNotEmpty) {
      tStr = json['description'].toString().trim();
    } else if (json['project'] is Map &&
        json['project']['projectName'] != null) {
      tStr = json['project']['projectName'].toString();
    } else {
      tStr =
          json['code'] ??
          json['deliveryNumber'] ??
          json['name'] ??
          json['deliveryName'] ??
          'Event';
    }

    final sStr = (json['status'] ?? json['deliveryStatus'] ?? '')
        .toString()
        .toLowerCase();

    Color eventColor = const Color(0xFF2563EB); // Blue default
    if (sStr.contains('confirm') ||
        sStr.contains('delivered') ||
        sStr.contains('bidding') ||
        sStr.contains('loaded')) {
      eventColor = AppColors.badgeGreen;
    } else if (sStr.contains('transit')) {
      eventColor = const Color(0xFF8B5CF6);
    } else if (sStr.contains('schedule') || sStr.contains('pending')) {
      eventColor = const Color(0xFFEC4899);
    }

    DateTime? created;
    final rawCreated = json['createdAt'] ?? json['created_at'] ?? json['updatedAt'] ?? json['updated_at'];
    if (rawCreated != null && rawCreated.toString().trim().isNotEmpty) {
      created = DateTime.tryParse(rawCreated.toString().trim());
    }
    if (created == null) {
      final idStr = (json['_id'] ?? json['id'] ?? '').toString();
      if (idStr.length >= 8) {
        try {
          final seconds = int.parse(idStr.substring(0, 8), radix: 16);
          if (seconds > 1500000000 && seconds < 2500000000) {
            created = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
          }
        } catch (_) {}
      }
    }

    return CalendarDayEvent(title: tStr, color: eventColor, createdAt: created);
  }
}

class DeliveryItem {
  const DeliveryItem({
    required this.id,
    required this.code,
    required this.projectName,
    required this.location,
    required this.date,
    required this.status,
    required this.statusColor,
    this.description = '',
    this.title = '',
    this.createdAt,
    this.quantity = '',
    this.stagingArea = '',
    this.arrivalDate = '',
    this.departureDate = '',
    this.warehouse = '',
  });

  final String id;
  final String code;
  final String projectName;
  final String location;
  final String date;
  final String status;
  final Color statusColor;
  final String description;
  final String title;
  final DateTime? createdAt;
  final String quantity;
  final String stagingArea;
  final String arrivalDate;
  final String departureDate;
  final String warehouse;

  factory DeliveryItem.fromJson(Map<String, dynamic> json) {
    final deliveryCode =
        json['code'] ??
        json['deliveryNumber'] ??
        json['deliveryCode'] ??
        json['deliveryId'] ??
        json['_id'] ??
        '';

    final titleStr = (json['title'] ?? '').toString().trim();

    String pName = 'No Project';
    String loc = 'Site Location';

    if (json['project'] is Map) {
      final pMap = json['project'] as Map;
      pName =
          pMap['projectName']?.toString() ??
          pMap['jobId']?.toString() ??
          'No Project';
      loc = pMap['location']?.toString() ?? 'Site Location';
    } else if (json['projectName'] != null) {
      pName = json['projectName'].toString();
    }

    if (json['sectionLocation'] != null &&
        json['sectionLocation'].toString().trim().isNotEmpty) {
      loc = json['sectionLocation'].toString().trim();
    } else if (json['section'] != null &&
        json['section'].toString().trim().isNotEmpty) {
      loc = json['section'].toString().trim();
    } else if (json['location'] != null &&
        json['location'].toString().trim().isNotEmpty &&
        loc == 'Site Location') {
      loc = json['location'].toString().trim();
    }

    final scheduleMap = json['schedule'] is Map ? json['schedule'] as Map : {};
    final rawDate =
        scheduleMap['deliveryDate'] ??
        scheduleMap['arrivalDate'] ??
        scheduleMap['pickupDate'] ??
        json['deliveryDate'] ??
        json['expectedDeliveryDate'] ??
        json['scheduledDate'] ??
        json['requiredDate'] ??
        json['arrivalDate'] ??
        json['expectedArrival'] ??
        json['date'] ??
        json['createdAt'] ??
        json['updatedAt'] ??
        '';

    String parsedDate = rawDate.toString().trim();
    if (parsedDate.isNotEmpty && parsedDate.toLowerCase() != 'null') {
      try {
        DateTime? d = DateTime.tryParse(parsedDate);
        if (d == null && parsedDate.contains('-')) {
          final cleanStr = parsedDate.split(' ')[0].split('T')[0];
          final parts = cleanStr.split('-');
          if (parts.length == 3) {
            d = DateTime(
              int.parse(parts[0]),
              int.parse(parts[1]),
              int.parse(parts[2]),
            );
          }
        }
        if (d != null) {
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
          parsedDate = '${months[d.month - 1]} ${d.day}, ${d.year}';
        }
      } catch (_) {}
    } else {
      parsedDate = '';
    }

    final deliveryDate = parsedDate;
    final rawStatus =
        (json['status'] ?? json['deliveryStatus'] ?? 'Scheduled').toString();
    final statusStr = rawStatus.isNotEmpty
        ? rawStatus[0].toUpperCase() + rawStatus.substring(1)
        : 'Scheduled';
    final descStr =
        json['description']?.toString() ?? json['notes']?.toString() ?? '';

    Color sColor = AppColors.badgeGreen;
    final sLower = statusStr.toLowerCase();
    if (sLower.contains('transit')) {
      sColor = const Color(0xFF8B5CF6); // Purple
    } else if (sLower.contains('schedule') || sLower.contains('pending')) {
      sColor = const Color(0xFFEC4899); // Pink
    } else if (sLower.contains('confirm') ||
        sLower.contains('delivered') ||
        sLower.contains('loaded')) {
      sColor = AppColors.badgeGreen;
    } else if (sLower.contains('delay')) {
      sColor = AppColors.badgeRed;
    }

    DateTime? created;
    final rawCreated = json['createdAt'] ?? json['created_at'] ?? json['updatedAt'] ?? json['updated_at'];
    if (rawCreated != null && rawCreated.toString().trim().isNotEmpty) {
      created = DateTime.tryParse(rawCreated.toString().trim());
    }
    if (created == null) {
      final idStr = (json['_id'] ?? json['id'] ?? deliveryCode ?? '').toString();
      if (idStr.length >= 8) {
        try {
          final seconds = int.parse(idStr.substring(0, 8), radix: 16);
          if (seconds > 1500000000 && seconds < 2500000000) {
            created = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
          }
        } catch (_) {}
      }
    }

    final qtyStr = (json['quantity'] ??
            json['weight'] ??
            json['totalWeight'] ??
            json['weightLbs'] ??
            json['qty'] ??
            '')
        .toString();

    final stagingStr = (json['stagingArea'] ??
            json['staging'] ??
            json['yard'] ??
            json['destination'] ??
            json['area'] ??
            '')
        .toString();

    final arrivalStr = (json['arrivalAtPlant'] ??
            json['arrivalDate'] ??
            scheduleMap['arrivalDate'] ??
            scheduleMap['arrivalAtPlant'] ??
            deliveryDate)
        .toString();

    final departureStr = (json['departureFromPlant'] ??
            json['departureDate'] ??
            scheduleMap['departureDate'] ??
            scheduleMap['departureFromPlant'] ??
            '')
        .toString();

    final whStr = (json['warehouse'] ??
            json['carrier'] ??
            json['supplier'] ??
            json['origin'] ??
            json['facility'] ??
            pName)
        .toString();

    return DeliveryItem(
      id: json['_id'] ?? json['id'] ?? deliveryCode.toString(),
      code: deliveryCode.toString(),
      title: titleStr,
      projectName: pName,
      location: loc,
      date: deliveryDate.toString(),
      status: statusStr,
      statusColor: sColor,
      description: descStr,
      createdAt: created,
      quantity: qtyStr,
      stagingArea: stagingStr,
      arrivalDate: arrivalStr,
      departureDate: departureStr,
      warehouse: whStr,
    );
  }
}

class ProjectCardItem {
  const ProjectCardItem({
    required this.title,
    required this.location,
    required this.projectId,
    required this.realLeadId,
    required this.status,
    required this.statusColor,
    required this.priority,
    required this.priorityColor,
    required this.imageAsset,
    this.buildingType = '',
    this.projectDate,
  });

  final String title;
  final String location;
  final String projectId;
  final String realLeadId;
  final String status;
  final Color statusColor;
  final String priority;
  final Color priorityColor;
  final String imageAsset;
  final String buildingType;
  final DateTime? projectDate;

  factory ProjectCardItem.fromJson(Map<String, dynamic> json) {
    final titleStr =
        (json['projectName'] != null &&
            json['projectName'].toString().isNotEmpty)
        ? json['projectName'].toString()
        : (json['title'] ?? json['name'] ?? 'Project').toString();
    final locationStr =
        (json['location'] != null && json['location'].toString().isNotEmpty)
        ? json['location'].toString()
        : 'Site Location';

    final mongoId = (json['_id'] ?? json['leadId'] ?? json['id'] ?? '')
        .toString();
    final displayCode = (json['jobId'] ??
            json['leadNumber'] ??
            json['projectId'] ??
            json['code'] ??
            mongoId)
        .toString();

    final statusStr =
        (json['lifecycleStatus'] ?? json['status'] ?? 'initial_contact')
            .toString();
    final bType = (json['buildingType'] ?? '').toString();

    final prioVal =
        json['priority'] ??
        json['projectPriority'] ??
        json['priorityLevel'] ??
        json['urgency'];
    String priorityStr = 'Normal';
    if (prioVal != null && prioVal.toString().isNotEmpty) {
      final pLower = prioVal.toString().toLowerCase();
      if (pLower.contains('high') || pLower.contains('urgent')) {
        priorityStr = 'High';
      } else if (pLower.contains('med') || pLower.contains('normal')) {
        priorityStr = 'Medium';
      } else if (pLower.contains('low')) {
        priorityStr = 'Low';
      } else {
        priorityStr =
            prioVal.toString()[0].toUpperCase() +
            prioVal.toString().substring(1);
      }
    } else {
      if (statusStr.toLowerCase().contains('delay') ||
          statusStr.toLowerCase().contains('cancel')) {
        priorityStr = 'High';
      } else {
        priorityStr = 'Normal';
      }
    }

    Color sColor = AppColors.chartYellow;
    final sLower = statusStr.toLowerCase();
    if (sLower.contains('delivered') ||
        sLower.contains('completed') ||
        sLower.contains('done')) {
      sColor = AppColors.badgeGreen;
    } else if (sLower.contains('plant') ||
        sLower.contains('po') ||
        sLower.contains('progress')) {
      sColor = AppColors.primaryBlue;
    } else if (sLower.contains('delay') || sLower.contains('cancel')) {
      sColor = AppColors.badgeRed;
    }

    Color pColor = AppColors.chartYellow;
    if (priorityStr.toLowerCase().contains('high') ||
        priorityStr.toLowerCase().contains('urgent')) {
      pColor = AppColors.danger;
    } else if (priorityStr.toLowerCase().contains('low')) {
      pColor = AppColors.badgeGreen;
    } else {
      pColor = AppColors.chartYellow;
    }

    // Extract project date / delivery date / deadline
    final sched = json['schedule'] is Map ? json['schedule'] as Map : {};
    final rawDateStr = (sched['deliveryDate'] ??
            sched['arrivalDate'] ??
            sched['pickupDate'] ??
            json['deliveryDate'] ??
            json['expectedDeliveryDate'] ??
            json['delivery_date'] ??
            json['targetDate'] ??
            json['target_date'] ??
            json['deadline'] ??
            json['projectDate'] ??
            json['project_date'] ??
            json['startDate'] ??
            json['start_date'] ??
            json['scheduledDate'] ??
            json['date'] ??
            json['createdAt'] ??
            json['created_at'])?.toString();
    DateTime? pDate;
    if (rawDateStr != null &&
        rawDateStr.isNotEmpty &&
        rawDateStr.toLowerCase() != 'null') {
      pDate = DateTime.tryParse(rawDateStr)?.toLocal();
      if (pDate == null && rawDateStr.contains('-')) {
        final clean = rawDateStr.split(' ')[0].split('T')[0];
        final parts = clean.split('-');
        if (parts.length == 3) {
          pDate = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
      }
    }

    return ProjectCardItem(
      title: titleStr,
      location: locationStr,
      projectId: displayCode,
      realLeadId: mongoId,
      status: statusStr,
      statusColor: sColor,
      priority: priorityStr,
      priorityColor: pColor,
      imageAsset: AppAssets.project1,
      buildingType: bType,
      projectDate: pDate,
    );
  }
}

class ProjectWorkflowStep {
  const ProjectWorkflowStep({
    required this.stepNumber,
    required this.title,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.estEndDate = '',
    this.completedDate = '',
    this.timelineBadge = '',
    this.description = '',
    this.photos = const [],
    this.stepKey = '',
    this.completionPct = 0,
    this.attachments = const [],
  });

  final int stepNumber;
  final String title;
  final String startDate;
  final String endDate;
  final String status;
  final String estEndDate;
  final String completedDate;
  final String timelineBadge;
  final String description;
  final List<String> photos;
  final String stepKey;
  final int completionPct;
  final List<Map<String, dynamic>> attachments;

  String get effectiveEstEndDate =>
      estEndDate.isNotEmpty ? estEndDate : endDate;

  String get effectiveCompletedDate {
    if (completedDate.isNotEmpty) return completedDate;
    if (status.toLowerCase().contains('complete')) return endDate;
    return '-';
  }

  String get displayTimelineBadge {
    if (timelineBadge.isNotEmpty) return timelineBadge;
    final s = status.toLowerCase();
    if (s.contains('delay')) return 'Delayed';
    if (s.contains('progress') || s.contains('inprogress')) return 'In Progress';
    if (s.contains('complete')) return 'Under timeline';
    return 'Pending';
  }

  Color get badgeTextColor {
    final b = displayTimelineBadge.toLowerCase();
    if (b.contains('late')) return const Color(0xFF0F766E); // Teal/green
    if (b.contains('timeline') || b.contains('complete')) return const Color(0xFF15803D); // Green
    if (b.contains('progress')) return const Color(0xFF1D4ED8); // Blue
    if (b.contains('delay')) return const Color(0xFFB91C1C); // Red
    return const Color(0xFFD97706);
  }

  Color get badgeBgColor {
    final b = displayTimelineBadge.toLowerCase();
    if (b.contains('late')) return const Color(0xFFCCFBF1);
    if (b.contains('timeline') || b.contains('complete')) return const Color(0xFFDCFCE7);
    if (b.contains('progress')) return const Color(0xFFDBEAFE);
    if (b.contains('delay')) return const Color(0xFFFEE2E2);
    return const Color(0xFFFEF3C7);
  }

  Color get badgeDotColor {
    final b = displayTimelineBadge.toLowerCase();
    if (b.contains('late')) return const Color(0xFF0D9488);
    if (b.contains('timeline') || b.contains('complete')) return const Color(0xFF16A34A);
    if (b.contains('progress')) return const Color(0xFF2563EB);
    if (b.contains('delay')) return const Color(0xFFDC2626);
    return const Color(0xFFD97706);
  }

  factory ProjectWorkflowStep.fromJson(Map<String, dynamic> json, int index) {
    final key = (json['stepKey'] ?? json['key'] ?? '').toString();
    final rawLabel = (json['label'] ?? json['name'] ?? json['title'] ?? key).toString();
    final rawStatus = (json['status'] ?? 'pending').toString().toLowerCase();

    String formattedStatus = 'Pending';
    if (rawStatus.contains('complete')) {
      formattedStatus = 'Completed';
    } else if (rawStatus.contains('progress') || rawStatus.contains('inprogress')) {
      formattedStatus = 'In Progress';
    } else if (rawStatus.contains('delay')) {
      formattedStatus = 'Delayed';
    }

    final start = _formatDateStr(json['startedAt'] ?? json['startDate']);
    final end = _formatDateStr(json['completedAt'] ?? json['endDate']);
    final est = _formatDateStr(json['expectedCompletion'] ?? json['estEndDate'] ?? json['estDate']);

    final attList = <Map<String, dynamic>>[];
    final photoUrls = <String>[];
    if (json['attachments'] is List) {
      for (final a in json['attachments'] as List) {
        if (a is Map) {
          final mMap = Map<String, dynamic>.from(a);
          attList.add(mMap);
          final url = (mMap['url'] ?? mMap['fileUrl'])?.toString() ?? '';
          if (url.isNotEmpty) photoUrls.add(url);
        }
      }
    }

    final pct = json['completionPct'] ?? json['percentComplete'] ?? (formattedStatus == 'Completed' ? 100 : 0);
    final parsedPct = pct is num ? pct.toInt() : (int.tryParse(pct.toString()) ?? 0);

    final readableTitle = rawLabel.isEmpty
        ? 'Step $index'
        : rawLabel
            .replaceAll('_', ' ')
            .split(' ')
            .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
            .join(' ')
            .trim();

    return ProjectWorkflowStep(
      stepNumber: index,
      stepKey: key,
      title: readableTitle,
      startDate: start.isNotEmpty ? start : '-',
      endDate: end.isNotEmpty ? end : (est.isNotEmpty ? est : '-'),
      estEndDate: est.isNotEmpty ? est : (end.isNotEmpty ? end : '-'),
      completedDate: formattedStatus == 'Completed' ? (end.isNotEmpty ? end : '-') : '-',
      status: formattedStatus,
      description: (json['notes'] ?? json['description'] ?? '').toString(),
      photos: photoUrls,
      attachments: attList,
      completionPct: parsedPct,
    );
  }

  static String _formatDateStr(dynamic raw) {
    if (raw == null) return '';
    final str = raw.toString().trim();
    if (str.isEmpty || str == 'null') return '';
    final dt = DateTime.tryParse(str);
    if (dt != null) {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';
    }
    return str;
  }

  Color get statusTextColor {
    final s = status.toLowerCase();
    if (s.contains('complete')) return const Color(0xFF16A34A);
    if (s.contains('progress')) return const Color(0xFF2563EB);
    if (s.contains('delay')) return const Color(0xFFDC2626);
    return const Color(0xFFD97706); // Pending
  }

  Color get statusBgColor {
    final s = status.toLowerCase();
    if (s.contains('complete')) return const Color(0xFFDCFCE7);
    if (s.contains('progress')) return const Color(0xFFDBEAFE);
    if (s.contains('delay')) return const Color(0xFFFEE2E2);
    return const Color(0xFFFEF3C7); // Pending
  }

  ProjectWorkflowStep copyWith({
    int? stepNumber,
    String? title,
    String? startDate,
    String? endDate,
    String? estEndDate,
    String? completedDate,
    String? timelineBadge,
    String? status,
    String? description,
    List<String>? photos,
    String? stepKey,
    int? completionPct,
    List<Map<String, dynamic>>? attachments,
  }) {
    return ProjectWorkflowStep(
      stepNumber: stepNumber ?? this.stepNumber,
      title: title ?? this.title,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      estEndDate: estEndDate ?? this.estEndDate,
      completedDate: completedDate ?? this.completedDate,
      timelineBadge: timelineBadge ?? this.timelineBadge,
      status: status ?? this.status,
      description: description ?? this.description,
      photos: photos ?? this.photos,
      stepKey: stepKey ?? this.stepKey,
      completionPct: completionPct ?? this.completionPct,
      attachments: attachments ?? this.attachments,
    );
  }
}

class ProjectTimelineTask {
  const ProjectTimelineTask({
    required this.id,
    required this.title,
    required this.status,
    this.startDate = '-',
    this.estimatedEndDate = '-',
    this.completedDate = '-',
    this.rawStartDate,
    this.rawEstimatedEndDate,
    this.rawCompletedDate,
    this.badgeLabel = 'Pending',
    this.badgeTone = 'info',
    this.timelineStatusLine = '',
    this.canMarkComplete = true,
    this.description = '',
    this.workDescription = '',
    this.attachments = const [],
    this.onTimeStatus = '',
    this.onTime,
    this.daysLateOrEarly,
    this.daysPastDue,
    this.assignedTo = '',
    this.priority = '',
  });

  final String id;
  final String title;
  final String status;
  final String startDate;
  final String estimatedEndDate;
  final String completedDate;
  final DateTime? rawStartDate;
  final DateTime? rawEstimatedEndDate;
  final DateTime? rawCompletedDate;
  final String badgeLabel;
  final String badgeTone;
  final String timelineStatusLine;
  final bool canMarkComplete;
  final String description;
  final String workDescription;
  final List<String> attachments;
  final String onTimeStatus;
  final bool? onTime;
  final int? daysLateOrEarly;
  final int? daysPastDue;
  final String assignedTo;
  final String priority;

  bool get isCompleted =>
      status.toLowerCase() == 'done' ||
      status.toLowerCase().contains('complete') ||
      !canMarkComplete;

  Color get badgeTextColor {
    final t = badgeTone.toLowerCase();
    final l = badgeLabel.toLowerCase();
    if (t == 'success' || l.contains('timeline') || l.contains('late')) {
      return const Color(0xFF15803D); // Green
    }
    if (t == 'danger' || l.contains('delayed') || l.contains('overdue')) {
      return const Color(0xFFB91C1C); // Red
    }
    if (t == 'info' || l.contains('progress')) {
      return const Color(0xFF1D4ED8); // Blue
    }
    return const Color(0xFFD97706); // Amber / Pending
  }

  Color get badgeBgColor {
    final t = badgeTone.toLowerCase();
    final l = badgeLabel.toLowerCase();
    if (t == 'success' || l.contains('timeline') || l.contains('late')) {
      return const Color(0xFFDCFCE7); // Light green
    }
    if (t == 'danger' || l.contains('delayed') || l.contains('overdue')) {
      return const Color(0xFFFEE2E2); // Light red
    }
    if (t == 'info' || l.contains('progress')) {
      return const Color(0xFFDBEAFE); // Light blue
    }
    return const Color(0xFFFEF3C7); // Light amber
  }

  Color get badgeDotColor {
    final t = badgeTone.toLowerCase();
    final l = badgeLabel.toLowerCase();
    if (t == 'success' || l.contains('timeline') || l.contains('late')) {
      return const Color(0xFF16A34A);
    }
    if (t == 'danger' || l.contains('delayed') || l.contains('overdue')) {
      return const Color(0xFFDC2626);
    }
    if (t == 'info' || l.contains('progress')) {
      return const Color(0xFF2563EB);
    }
    return const Color(0xFFD97706);
  }

  factory ProjectTimelineTask.fromJson(Map<String, dynamic> json) {
    final idStr = (json['_id'] ?? json['id'] ?? json['taskId'] ?? '').toString();
    final titleStr = (json['title'] ?? json['name'] ?? 'Task').toString();
    final statusStr = (json['status'] ?? 'todo').toString().toLowerCase();

    final rawStartStr =
        (json['startDate'] ?? json['start_date'])?.toString();
    final rawEstEndStr = (json['estimatedEndDate'] ??
            json['dueDate'] ??
            json['expectedEndDate'] ??
            json['due_date'])
        ?.toString();
    final rawCompletedStr =
        (json['completedDate'] ?? json['completedAt'] ?? json['completed_at'])
            ?.toString();

    DateTime? parseDate(String? str) {
      if (str == null || str.trim().isEmpty || str == 'null') return null;
      return DateTime.tryParse(str.trim());
    }

    final rawStart = parseDate(rawStartStr);
    final rawEstEnd = parseDate(rawEstEndStr);
    final rawCompleted = parseDate(rawCompletedStr);

    String formatDate(DateTime? dt, String? fallbackStr) {
      if (dt != null) {
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
          'Dec'
        ];
        return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
      }
      if (fallbackStr != null &&
          fallbackStr.trim().isNotEmpty &&
          fallbackStr != 'null') {
        return fallbackStr.trim();
      }
      return '-';
    }

    final formattedStart = formatDate(rawStart, rawStartStr);
    final formattedEstEnd = formatDate(rawEstEnd, rawEstEndStr);
    final formattedCompleted = formatDate(rawCompleted, rawCompletedStr);

    String label = 'Pending';
    String tone = 'info';
    if (json['timelineBadge'] is Map) {
      final bMap = json['timelineBadge'] as Map;
      if (bMap['label'] != null && bMap['label'].toString().isNotEmpty) {
        label = bMap['label'].toString();
      }
      if (bMap['tone'] != null && bMap['tone'].toString().isNotEmpty) {
        tone = bMap['tone'].toString();
      }
    } else {
      if (statusStr == 'done' || statusStr.contains('complete')) {
        label = 'Under timeline';
        tone = 'success';
      } else if (statusStr == 'in_progress') {
        label = 'In Progress';
        tone = 'info';
      } else {
        label = 'Pending';
        tone = 'info';
      }
    }

    final attUrls = <String>[];
    final rawAtts = json['attachments'] ?? json['photos'] ?? json['images'] ?? json['media'] ?? json['files'];
    if (rawAtts is List) {
      for (final a in rawAtts) {
        if (a is String && a.isNotEmpty) {
          attUrls.add(a);
        } else if (a is Map) {
          final url = (a['url'] ?? a['fileUrl'] ?? a['mediaUrl'] ?? a['path'])?.toString();
          if (url != null && url.isNotEmpty) attUrls.add(url);
        }
      }
    }

    final canComplete = json['canMarkComplete'] is bool
        ? json['canMarkComplete'] as bool
        : (statusStr != 'done' && !statusStr.contains('complete'));

    final desc = (json['description'] ?? '').toString();
    final workDesc = (json['workDescription'] ?? '').toString();
    final statusLine = (json['timelineStatusLine'] ?? '').toString();

    return ProjectTimelineTask(
      id: idStr,
      title: titleStr,
      status: statusStr,
      startDate: formattedStart,
      estimatedEndDate: formattedEstEnd,
      completedDate: formattedCompleted,
      rawStartDate: rawStart,
      rawEstimatedEndDate: rawEstEnd,
      rawCompletedDate: rawCompleted,
      badgeLabel: label,
      badgeTone: tone,
      timelineStatusLine: statusLine,
      canMarkComplete: canComplete,
      description: desc.isNotEmpty ? desc : workDesc,
      workDescription: workDesc.isNotEmpty ? workDesc : desc,
      attachments: attUrls,
      onTimeStatus: (json['onTimeStatus'] ?? '').toString(),
      onTime: json['onTime'] as bool?,
      daysLateOrEarly: json['daysLateOrEarly'] is num
          ? (json['daysLateOrEarly'] as num).toInt()
          : null,
      daysPastDue: json['daysPastDue'] is num
          ? (json['daysPastDue'] as num).toInt()
          : null,
      assignedTo: (json['assignedTo'] is Map
              ? (json['assignedTo']['name'] ?? json['assignedTo']['_id'])
              : json['assignedTo'])
          ?.toString() ??
          '',
      priority: (json['priority'] ?? '').toString(),
    );
  }

  ProjectWorkflowStep toWorkflowStep([int stepNumber = 1]) {
    return ProjectWorkflowStep(
      stepNumber: stepNumber,
      title: title,
      startDate: startDate,
      endDate: estimatedEndDate,
      estEndDate: estimatedEndDate,
      completedDate: completedDate,
      status: isCompleted ? 'Completed' : 'In Progress',
      timelineBadge: badgeLabel,
      description: description,
      photos: attachments,
      stepKey: id,
    );
  }
}

