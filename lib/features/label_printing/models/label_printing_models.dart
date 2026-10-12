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
    this.jobId = '',
    this.rawWeight = '',
    this.rawLength = '',
  });

  final String id;
  final String realMongoId;
  final String loadId;
  final String part;
  final double totalWeightLbs;
  final String rawWeight;
  final double lengthFt;
  final String rawLength;
  final LabelPrintStatus status;
  final String statusText;
  final String project;
  final String jobId;
  final String shipper;

  factory LabelBundleItem.fromJson(Map<String, dynamic> json) {
    final rawStatus =
        (json['status'] ??
                json['printStatus'] ??
                json['verificationStatus'] ??
                'PENDING')
            .toString()
            .toUpperCase();

    // Weight parsing (matches web: t.totalWeight)
    final rawWeightVal =
        json['totalWeight'] ?? json['weight'] ?? json['totalWeightLbs'];
    final String rawWeightStr =
        rawWeightVal != null ? rawWeightVal.toString() : '';
    final double weightVal = rawWeightVal is num
        ? rawWeightVal.toDouble()
        : (double.tryParse(rawWeightStr) ?? 0.0);

    // Length parsing (matches web: t.maxLengthFeet)
    final rawLengthVal =
        json['maxLengthFeet'] ?? json['lengthFt'] ?? json['length'];
    final String rawLengthStr =
        rawLengthVal != null ? rawLengthVal.toString() : '';
    final double lengthVal = rawLengthVal is num
        ? rawLengthVal.toDouble()
        : (double.tryParse(rawLengthStr) ?? 0.0);

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

    // Bundle No (matches web: t.bundleNo || t.bundleId)
    String foundBundleCode = '';
    if (json['bundleNo'] != null &&
        json['bundleNo'].toString().trim().isNotEmpty) {
      foundBundleCode = json['bundleNo'].toString().trim();
    } else if (json['bundleCode'] != null &&
        !isMongoHexId(json['bundleCode'].toString())) {
      foundBundleCode = json['bundleCode'].toString().trim();
    } else if (json['code'] != null && !isMongoHexId(json['code'].toString())) {
      foundBundleCode = json['code'].toString().trim();
    } else if (json['bundleTag'] != null &&
        !isMongoHexId(json['bundleTag'].toString())) {
      foundBundleCode = json['bundleTag'].toString().trim();
    }

    if (foundBundleCode.isEmpty) {
      final bNum =
          json['bundleNumber'] ?? json['number'] ?? json['bundleIndex'];
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
      final code = bMap['bundleNo'] ??
          bMap['code'] ??
          bMap['bundleCode'] ??
          bMap['bundleTag'];
      if (code != null && !isMongoHexId(code.toString())) {
        foundBundleCode = code.toString().trim();
      }
    }

    if (foundBundleCode.isEmpty && json['bundleId'] != null) {
      final bStr = json['bundleId'].toString().trim();
      if (!isMongoHexId(bStr)) {
        foundBundleCode = bStr;
      }
    }

    if (foundBundleCode.isEmpty) {
      foundBundleCode = 'B-001';
    }

    // Real Mongo ID
    final realMongoId =
        (json['bundleId'] ?? json['_id'] ?? json['id'] ?? '').toString();

    // Load ID / Packing List ID (matches web: t.packingListId || t.loadId)
    String foundLoadId = '';
    if (json['packingListId'] != null &&
        json['packingListId'].toString().trim().isNotEmpty) {
      foundLoadId = json['packingListId'].toString().trim();
    } else if (json['loadId'] != null &&
        json['loadId'].toString().trim().isNotEmpty) {
      foundLoadId = json['loadId'].toString().trim();
    } else if (json['load'] is Map) {
      final lMap = json['load'] as Map;
      foundLoadId = (lMap['packingListId'] ??
              lMap['loadNumber'] ??
              lMap['loadId'] ??
              lMap['code'] ??
              lMap['name'] ??
              '')
          .toString()
          .trim();
    } else if (json['loadNumber'] != null) {
      foundLoadId = json['loadNumber'].toString().trim();
    } else if (json['load'] != null) {
      foundLoadId = json['load'].toString().trim();
    }
    if (foundLoadId.isEmpty) foundLoadId = '-';

    // Project & Job ID (matches web: t.project?.projectName, t.project?.jobId)
    String foundProject = '';
    String foundJobId = '';
    if (json['project'] is Map) {
      final pMap = json['project'] as Map;
      foundProject =
          (pMap['projectName'] ?? pMap['name'] ?? '').toString().trim();
      foundJobId = (pMap['jobId'] ?? pMap['code'] ?? '').toString().trim();
    } else if (json['project'] != null) {
      foundProject = json['project'].toString().trim();
    }
    if (foundProject.isEmpty) {
      foundProject = (json['projectName'] ?? 'Wood Workshop').toString().trim();
    }
    if (foundJobId.isEmpty && json['jobId'] != null) {
      foundJobId = json['jobId'].toString().trim();
    }

    // Shipper (matches web: t.project?.jobId || t.shipperRef || "")
    String foundShipper = '';
    if (json['shipperRef'] != null &&
        json['shipperRef'].toString().trim().isNotEmpty) {
      foundShipper = json['shipperRef'].toString().trim();
    } else if (json['shipper'] is Map) {
      final sMap = json['shipper'] as Map;
      foundShipper =
          (sMap['name'] ?? sMap['shipperName'] ?? sMap['code'] ?? '').toString().trim();
    } else if (json['shipper'] != null &&
        json['shipper'].toString().trim().isNotEmpty &&
        json['shipper'].toString().trim() != '-') {
      foundShipper = json['shipper'].toString().trim();
    } else if (foundJobId.isNotEmpty && foundJobId != '-') {
      foundShipper = foundJobId;
    } else {
      foundShipper = (json['shipperNo'] ??
              json['carrier'] ??
              json['transporter'] ??
              '')
          .toString()
          .trim();
    }
    if (foundShipper.isEmpty) {
      foundShipper = foundJobId.isNotEmpty ? foundJobId : '-';
    }

    // Parts (matches web: B = a => a && a.split(",").map(d => d.trim()).filter(Boolean).join(", ") || "-")
    String foundPart = '-';
    final rawParts = json['parts'] ??
        json['part'] ??
        json['partNumber'] ??
        json['partName'] ??
        json['component'] ??
        json['components'] ??
        json['item'] ??
        json['description'];
    if (rawParts is List && rawParts.isNotEmpty) {
      final list = rawParts
          .map((p) =>
              p is Map ? (p['partCode'] ?? p['name'] ?? p['code'] ?? '') : p.toString())
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty && !RegExp(r'^[,\.\s]+$').hasMatch(s))
          .toList();
      foundPart = list.isNotEmpty ? list.join(', ') : '-';
    } else if (rawParts != null) {
      final pStr = rawParts.toString().trim();
      final list = pStr
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty && !RegExp(r'^[,\.\s]+$').hasMatch(s))
          .toList();
      foundPart = list.isNotEmpty ? list.join(', ') : '-';
    }

    return LabelBundleItem(
      id: foundBundleCode,
      realMongoId: realMongoId,
      loadId: foundLoadId,
      part: foundPart,
      totalWeightLbs: weightVal,
      rawWeight: rawWeightStr.isNotEmpty
          ? rawWeightStr
          : (weightVal > 0
              ? (weightVal % 1 == 0
                  ? weightVal.toInt().toString()
                  : weightVal.toString())
              : '0'),
      lengthFt: lengthVal,
      rawLength: rawLengthStr.isNotEmpty
          ? rawLengthStr
          : (lengthVal > 0
              ? (lengthVal % 1 == 0
                  ? lengthVal.toInt().toString()
                  : lengthVal.toString())
              : '0'),
      status: parsedStatus,
      statusText: rawStatus.replaceAll('_', ' '),
      project: foundProject,
      jobId: foundJobId,
      shipper: foundShipper,
    );
  }

  LabelBundleItem copyWith({
    LabelPrintStatus? status,
    String? statusText,
    String? loadId,
    String? shipper,
    String? project,
    String? jobId,
  }) {
    return LabelBundleItem(
      id: id,
      realMongoId: realMongoId,
      loadId: loadId ?? this.loadId,
      part: part,
      totalWeightLbs: totalWeightLbs,
      rawWeight: rawWeight,
      lengthFt: lengthFt,
      rawLength: rawLength,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      project: project ?? this.project,
      jobId: jobId ?? this.jobId,
      shipper: shipper ?? this.shipper,
    );
  }
}
