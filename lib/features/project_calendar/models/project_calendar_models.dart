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
    final codeStr = json['jobId'] ?? json['leadNumber'] ?? json['code'] ?? '';
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
  });

  final String title;
  final Color color;

  factory CalendarDayEvent.fromJson(Map<String, dynamic> json) {
    String tStr = 'Event';
    if (json['description'] != null &&
        json['description'].toString().isNotEmpty) {
      tStr = json['description'].toString();
    } else if (json['project'] is Map &&
        json['project']['projectName'] != null) {
      tStr = json['project']['projectName'].toString();
    } else {
      tStr =
          json['code'] ??
          json['deliveryNumber'] ??
          json['title'] ??
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

    return CalendarDayEvent(title: tStr, color: eventColor);
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
  });

  final String id;
  final String code;
  final String projectName;
  final String location;
  final String date;
  final String status;
  final Color statusColor;
  final String description;

  factory DeliveryItem.fromJson(Map<String, dynamic> json) {
    final deliveryCode =
        json['code'] ??
        json['deliveryNumber'] ??
        json['deliveryCode'] ??
        json['deliveryId'] ??
        json['_id'] ??
        '';

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

    if (json['location'] != null && (loc == 'Site Location' || loc.isEmpty)) {
      loc = json['location'].toString();
    }

    final deliveryDate =
        json['date'] ?? json['deliveryDate'] ?? json['expectedArrival'] ?? '';
    final statusStr = json['status'] ?? json['deliveryStatus'] ?? 'Confirmed';
    final descStr = json['description']?.toString() ?? '';

    Color sColor = AppColors.badgeGreen;
    final sLower = statusStr.toString().toLowerCase();
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

    return DeliveryItem(
      id: json['_id'] ?? json['id'] ?? deliveryCode.toString(),
      code: deliveryCode.toString(),
      projectName: pName,
      location: loc,
      date: deliveryDate.toString(),
      status: statusStr.toString(),
      statusColor: sColor,
      description: descStr,
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
    final displayCode = (json['jobId'] ?? json['code'] ?? mongoId).toString();

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
    );
  }
}
