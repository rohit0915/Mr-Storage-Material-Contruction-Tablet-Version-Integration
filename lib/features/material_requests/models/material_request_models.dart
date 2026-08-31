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

  factory MaterialRequestBoardItem.fromJson(Map<String, dynamic> json) {
    final rId = json['requestId'] ?? json['code'] ?? json['_id'] ?? 'MR-001';

    String pName = 'No Project';
    String loc = 'Site Location';
    if (json['project'] is Map) {
      final pMap = json['project'] as Map;
      pName = pMap['projectName']?.toString() ?? pMap['jobId']?.toString() ?? 'No Project';
      loc = pMap['location']?.toString() ?? 'Site Location';
    } else if (json['projectName'] != null) {
      pName = json['projectName'].toString();
    }
    if (json['siteLocation'] != null && json['siteLocation'].toString().isNotEmpty) {
      loc = json['siteLocation'].toString();
    }

    String reqByStr = 'Unassigned';
    if (json['requestedBy'] is Map) {
      reqByStr = json['requestedBy']['name']?.toString() ?? 'Unassigned';
    } else if (json['requestedBy'] != null) {
      reqByStr = json['requestedBy'].toString();
    }

    DateTime reqDate = DateTime.now();
    if (json['requestDate'] != null || json['createdAt'] != null) {
      try {
        reqDate = DateTime.parse((json['requestDate'] ?? json['createdAt']).toString());
      } catch (_) {}
    }

    DateTime reqByDate = DateTime.now();
    if (json['requiredBy'] != null) {
      try {
        reqByDate = DateTime.parse(json['requiredBy'].toString());
      } catch (_) {}
    }

    final itemsList = <MaterialRequestItemRow>[];
    if (json['requestedItems'] is List) {
      for (final item in (json['requestedItems'] as List)) {
        if (item is Map) {
          itemsList.add(MaterialRequestItemRow(
            name: item['name']?.toString() ?? 'Item',
            unit: item['unit']?.toString() ?? 'pcs',
            quantity: item['quantity'] is num ? (item['quantity'] as num) : 1,
            remarks: item['notes']?.toString() ?? item['remarks']?.toString() ?? '',
          ));
        }
      }
    }

    final itemCount = json['itemCount'] ?? itemsList.length;
    final preview = itemsList.isNotEmpty
        ? itemsList.map((i) => i.name).join(', ')
        : '$itemCount Item(s)';

    final statusRaw = (json['status'] ?? 'pending').toString().toLowerCase();
    MaterialRequestStatus mStatus = MaterialRequestStatus.pending;
    Color sColor = const Color(0xFFFFC107);

    if (statusRaw.contains('approve')) {
      mStatus = MaterialRequestStatus.approved;
      sColor = const Color(0xFF22C55E);
    } else if (statusRaw.contains('reject') || statusRaw.contains('cancel')) {
      mStatus = MaterialRequestStatus.rejected;
      sColor = const Color(0xFFEF4444);
    }

    final prioRaw = (json['priority'] ?? 'medium').toString();
    final prioStr = prioRaw.isNotEmpty
        ? (prioRaw[0].toUpperCase() + prioRaw.substring(1).toLowerCase())
        : 'Medium';
    Color pColor = const Color(0xFFFFC107);
    if (prioRaw.toLowerCase() == 'high' || prioRaw.toLowerCase() == 'urgent') {
      pColor = const Color(0xFFEF4444);
    } else if (prioRaw.toLowerCase() == 'low') {
      pColor = const Color(0xFF22C55E);
    }

    return MaterialRequestBoardItem(
      id: rId.toString(),
      project: pName,
      site: loc,
      department: json['department']?.toString().isNotEmpty == true ? json['department'].toString() : 'Construction',
      requestedBy: reqByStr,
      requestDate: reqDate,
      requiredBy: reqByDate,
      requestedItemsCount: itemCount is num ? itemCount.toInt() : itemsList.length,
      status: mStatus,
      priority: prioStr,
      statusColor: sColor,
      priorityColor: pColor,
      items: itemsList,
      itemsPreview: preview,
    );
  }
}

