import 'package:flutter/material.dart';

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
}

class CalendarDayEvent {
  const CalendarDayEvent({
    required this.title,
    this.color = const Color(0xFF2563EB),
  });

  final String title;
  final Color color;
}

class DeliveryItem {
  const DeliveryItem({
    required this.id,
    required this.title,
    required this.location,
    required this.quantity,
    required this.stagingArea,
    required this.arrival,
    required this.departure,
  });

  final String id;
  final String title;
  final String location;
  final String quantity;
  final String stagingArea;
  final String arrival;
  final String departure;
}

class ProjectCardItem {
  const ProjectCardItem({
    required this.title,
    required this.location,
    required this.projectId,
    required this.status,
    required this.statusColor,
    required this.priority,
    required this.priorityColor,
    required this.imageAsset,
  });

  final String title;
  final String location;
  final String projectId;
  final String status;
  final Color statusColor;
  final String priority;
  final Color priorityColor;
  final String imageAsset;
}
