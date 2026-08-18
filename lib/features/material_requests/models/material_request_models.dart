import 'package:flutter/material.dart';

enum MaterialRequestStatus {
  pending,
  approved,
  rejected,
}

class MaterialRequestItemRow {
  const MaterialRequestItemRow({
    required this.name,
    required this.unit,
    required this.quantity,
    required this.remarks,
  });

  final String name;
  final String unit;
  final num quantity;
  final String remarks;
}

class MaterialRequestBoardItem {
  const MaterialRequestBoardItem({
    required this.id,
    required this.project,
    required this.site,
    required this.department,
    required this.requestedBy,
    required this.requestDate,
    required this.requiredBy,
    required this.requestedItemsCount,
    required this.status,
    required this.priority,
    required this.statusColor,
    required this.priorityColor,
    required this.items,
    this.itemsPreview = '',
    this.requestedByRole = 'Site Engineer',
    this.requestNotes =
        'Additional materials required for columns and slab casting on ground floor.',
  });

  final String id;
  final String project;
  final String site;
  final String department;
  final String requestedBy;
  final DateTime requestDate;
  final DateTime requiredBy;
  final int requestedItemsCount;
  final MaterialRequestStatus status;
  final String priority;
  final Color statusColor;
  final Color priorityColor;
  final List<MaterialRequestItemRow> items;
  final String itemsPreview;
  final String requestedByRole;
  final String requestNotes;
}

