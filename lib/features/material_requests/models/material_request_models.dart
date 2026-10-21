import 'package:flutter/material.dart';

enum MaterialRequestStatus { pending, approved, rejected, cancelled, fulfilled }

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

class MaterialRequestAttachment {
  const MaterialRequestAttachment({
    required this.name,
    this.size = '',
    this.url = '',
  });

  final String name;
  final String size;
  final String url;

  factory MaterialRequestAttachment.fromJson(dynamic json) {
    if (json is String) {
      final fileName = json.split('/').last.split('?').first;
      return MaterialRequestAttachment(
        name: fileName.isNotEmpty ? fileName : 'Attachment',
        url: json,
      );
    }
    if (json is Map) {
      return MaterialRequestAttachment(
        name: (json['name'] ??
                json['fileName'] ??
                json['originalName'] ??
                'Attachment')
            .toString(),
        size: json['size']?.toString() ?? '',
        url: (json['url'] ?? json['path'] ?? '').toString(),
      );
    }
    return const MaterialRequestAttachment(name: 'Attachment');
  }
}

class MaterialRequestBoardItem {
  const MaterialRequestBoardItem({
    required this.id,
    this.databaseId = '',
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
    this.requestedById = '',
    this.requestedByRole = 'Site Engineer',
    this.requestNotes = '',
    this.attachments = const [],
  });

  final String id;
  final String databaseId;
  final String project;
  final String site;
  final String department;
  final String requestedBy;
  final DateTime requestDate;
  final DateTime? requiredBy;
  final int requestedItemsCount;
  final MaterialRequestStatus status;
  final String priority;
  final Color statusColor;
  final Color priorityColor;
  final List<MaterialRequestItemRow> items;
  final String itemsPreview;
  final String requestedById;
  final String requestedByRole;
  final String requestNotes;
  final List<MaterialRequestAttachment> attachments;

  factory MaterialRequestBoardItem.fromJson(Map<String, dynamic> rawJson) {
    final json = rawJson['materialRequest'] is Map ? (rawJson['materialRequest'] as Map<String, dynamic>) : rawJson;
    final rId = json['requestId'] ?? json['code'] ?? json['_id'] ?? 'MR-001';

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
    if (json['siteLocation'] != null &&
        json['siteLocation'].toString().isNotEmpty) {
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
        reqDate = DateTime.parse(
          (json['requestDate'] ?? json['createdAt']).toString(),
        );
      } catch (_) {}
    }

    DateTime? reqByDate;
    if (json['requiredBy'] != null) {
      try {
        reqByDate = DateTime.parse(json['requiredBy'].toString());
      } catch (_) {}
    }

    final itemsList = <MaterialRequestItemRow>[];
    if (json['requestedItems'] is List) {
      for (final item in (json['requestedItems'] as List)) {
        if (item is Map) {
          itemsList.add(
            MaterialRequestItemRow(
              name: item['name']?.toString() ?? 'Item',
              unit: item['unit']?.toString() ?? 'pcs',
              quantity: item['quantity'] is num ? (item['quantity'] as num) : 1,
              remarks:
                  item['notes']?.toString() ??
                  item['remarks']?.toString() ??
                  '',
            ),
          );
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
    } else if (statusRaw.contains('cancel')) {
      mStatus = MaterialRequestStatus.cancelled;
      sColor = const Color(0xFFEF4444);
    } else if (statusRaw.contains('fulfill')) {
      mStatus = MaterialRequestStatus.fulfilled;
      sColor = const Color(0xFF22C55E);
    } else if (statusRaw.contains('reject')) {
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
      databaseId: (json['_id'] ?? json['id'] ?? '').toString(),
      project: pName,
      site: loc,
      department: json['department']?.toString().isNotEmpty == true
          ? json['department'].toString()
          : 'Construction',
      requestedBy: reqByStr,
      requestDate: reqDate,
      requiredBy: reqByDate,
      requestedItemsCount: itemCount is num
          ? itemCount.toInt()
          : itemsList.length,
      status: mStatus,
      priority: prioStr,
      statusColor: sColor,
      priorityColor: pColor,
      items: itemsList,
      itemsPreview: preview,
      requestedById: json['requestedBy'] is Map
          ? (json['requestedBy']['userId'] ?? json['requestedBy']['_id'] ?? '')
                .toString()
          : '',
      requestedByRole: json['requestedBy'] is Map
          ? (json['requestedBy']['role']?.toString() ?? '')
          : '',
      requestNotes: (json['notes'] ??
              json['specialInstructions'] ??
              json['remarks'] ??
              '')
          .toString(),
      attachments: (json['attachments'] is List)
          ? (json['attachments'] as List)
              .map((a) => MaterialRequestAttachment.fromJson(a))
              .toList()
          : const [],
    );
  }
}
