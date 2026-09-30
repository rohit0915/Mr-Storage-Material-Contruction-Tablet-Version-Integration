enum LabelPrintStatus { pending, printed, assigned }

class LabelBundleItem {
  const LabelBundleItem({
    required this.id,
    required this.realMongoId,
    required this.loadId,
    required this.part,
    required this.totalWeightLbs,
    required this.lengthFt,
    required this.status,
    required this.statusText,
    required this.project,
    required this.shipper,
  });

  final String id;
  final String realMongoId;
  final String loadId;
  final String part;
  final double totalWeightLbs;
  final double lengthFt;
  final LabelPrintStatus status;
  final String statusText;
  final String project;
  final String shipper;

  factory LabelBundleItem.fromJson(Map<String, dynamic> json) {
    final rawStatus =
        (json['status'] ??
                json['printStatus'] ??
                json['verificationStatus'] ??
                'PENDING')
            .toString()
            .toUpperCase();

    final wNum =
        (json['totalWeightLbs'] ?? json['weight'] ?? json['totalWeight'] ?? 0);
    final double weightVal = wNum is num
        ? wNum.toDouble()
        : (double.tryParse(wNum.toString()) ?? 0.0);

    final lNum = (json['lengthFt'] ?? json['length'] ?? 0);
    final double lengthVal = lNum is num
        ? lNum.toDouble()
        : (double.tryParse(lNum.toString()) ?? 0.0);

    LabelPrintStatus parsedStatus = LabelPrintStatus.pending;
    if (rawStatus.contains('PRINT')) {
      parsedStatus = LabelPrintStatus.printed;
    } else if (rawStatus.contains('ASSIGN')) {
      parsedStatus = LabelPrintStatus.assigned;
    }

    bool isMongoHexId(String? s) {
      if (s == null || s.isEmpty) return false;
      return s.length == 24 && RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(s);
    }

    String foundBundleCode = '';
    if (json['bundleCode'] != null &&
        !isMongoHexId(json['bundleCode'].toString())) {
      foundBundleCode = json['bundleCode'].toString();
    } else if (json['code'] != null && !isMongoHexId(json['code'].toString())) {
      foundBundleCode = json['code'].toString();
    } else if (json['bundleTag'] != null &&
        !isMongoHexId(json['bundleTag'].toString())) {
      foundBundleCode = json['bundleTag'].toString();
    }

    if (foundBundleCode.isEmpty) {
      final bNum =
          json['bundleNumber'] ??
          json['bundleNo'] ??
          json['number'] ??
          json['bundleIndex'];
      if (bNum != null && bNum.toString().isNotEmpty) {
        final parsed = int.tryParse(bNum.toString());
        if (parsed != null) {
          foundBundleCode = 'B-${parsed.toString().padLeft(3, '0')}';
        } else if (!isMongoHexId(bNum.toString())) {
          foundBundleCode = bNum.toString().startsWith('B-')
              ? bNum.toString()
              : 'B-${bNum.toString().padLeft(3, '0')}';
        }
      }
    }

    if (foundBundleCode.isEmpty && json['bundle'] is Map) {
      final bMap = json['bundle'] as Map;
      final code = bMap['code'] ?? bMap['bundleCode'] ?? bMap['bundleTag'];
      if (code != null && !isMongoHexId(code.toString())) {
        foundBundleCode = code.toString();
      } else {
        final bNum = bMap['bundleNumber'] ?? bMap['bundleNo'];
        if (bNum != null) {
          final parsed = int.tryParse(bNum.toString());
          foundBundleCode = parsed != null
              ? 'B-${parsed.toString().padLeft(3, '0')}'
              : bNum.toString();
        }
      }
    }

    if (foundBundleCode.isEmpty && json['bundleId'] != null) {
      final bStr = json['bundleId'].toString();
      if (!isMongoHexId(bStr)) {
        foundBundleCode = bStr;
      }
    }

    if (foundBundleCode.isEmpty || isMongoHexId(foundBundleCode)) {
      final rawId = (json['_id'] ?? json['id'] ?? json['bundleId'] ?? '')
          .toString();
      final numHash = (rawId.hashCode.abs() % 30) + 1;
      foundBundleCode = 'B-${numHash.toString().padLeft(3, '0')}';
    }

    return LabelBundleItem(
      id: foundBundleCode,
      realMongoId: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      loadId: json['loadId']?.toString() ?? json['load']?.toString() ?? '-',
      part:
          json['part']?.toString() ??
          json['parts']?.toString() ??
          json['partNumber']?.toString() ??
          '-',
      totalWeightLbs: weightVal,
      lengthFt: lengthVal,
      status: parsedStatus,
      statusText: rawStatus.replaceAll('_', ' '),
      project: json['project'] is Map
          ? (json['project']['projectName'] ?? json['project']['name'] ?? '-')
                .toString()
          : (json['project']?.toString() ??
                json['projectName']?.toString() ??
                '-'),
      shipper:
          json['shipper']?.toString() ?? json['shipperNo']?.toString() ?? '-',
    );
  }

  LabelBundleItem copyWith({LabelPrintStatus? status, String? statusText}) {
    return LabelBundleItem(
      id: id,
      realMongoId: realMongoId,
      loadId: loadId,
      part: part,
      totalWeightLbs: totalWeightLbs,
      lengthFt: lengthFt,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      project: project,
      shipper: shipper,
    );
  }
}
