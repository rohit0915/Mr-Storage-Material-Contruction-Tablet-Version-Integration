enum BundleScanStatus { staging, ready, pending, assigned }

class BundleScanItem {
  const BundleScanItem({
    required this.id,
    required this.realMongoId,
    required this.bundleId,
    required this.project,
    required this.jobId,
    required this.site,
    required this.parts,
    required this.totalWeight,
    required this.time,
    required this.status,
    required this.statusText,
    this.loadId = '',
    this.truck = '',
    this.quantity = '',
    this.length = '',
  });

  final String id;
  final String realMongoId;
  final String bundleId;
  final String project;
  final String jobId;
  final String site;
  final String parts;
  final String totalWeight;
  final String time;
  final BundleScanStatus status;
  final String statusText;
  final String loadId;
  final String truck;
  final String quantity;
  final String length;

  factory BundleScanItem.fromJson(Map<String, dynamic> json) {
    final statusStr =
        (json['status'] ?? json['bundleStatus'] ?? 'ASSIGNED TO TRUCK')
            .toString()
            .toUpperCase();

    final wVal =
        json['totalWeightLbs'] ?? json['weight'] ?? json['totalWeight'] ?? 0;
    final double weightDouble = wVal is num
        ? wVal.toDouble()
        : (double.tryParse(wVal.toString()) ?? 0.0);
    final String formattedWeight = _fmtWeight(weightDouble);

    String pName = '';
    String jId = '';
    if (json['project'] is Map) {
      pName = (json['project']['projectName'] ?? json['project']['name'] ?? '')
          .toString();
      jId = (json['project']['jobId'] ?? json['project']['code'] ?? '')
          .toString();
    } else if (json['project'] != null &&
        json['project'].toString().isNotEmpty) {
      pName = json['project'].toString();
      jId = json['jobId']?.toString() ?? '';
    }

    BundleScanStatus st = BundleScanStatus.ready;
    if (statusStr.contains('STAG')) {
      st = BundleScanStatus.staging;
    } else if (statusStr.contains('PEND')) {
      st = BundleScanStatus.pending;
    } else if (statusStr.contains('ASSIGN') || statusStr.contains('TRUCK')) {
      st = BundleScanStatus.assigned;
    }

    // Helper to check if string is raw 24-character hexadecimal Mongo ObjectId
    bool isMongoHexId(String? s) {
      if (s == null || s.isEmpty) return false;
      return s.length == 24 && RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(s);
    }

    String foundBundleCode = '';

    // 1. Check direct bundle code / number properties
    if (json['bundleCode'] != null &&
        !isMongoHexId(json['bundleCode'].toString())) {
      foundBundleCode = json['bundleCode'].toString();
    } else if (json['code'] != null && !isMongoHexId(json['code'].toString())) {
      foundBundleCode = json['code'].toString();
    } else if (json['bundleTag'] != null &&
        !isMongoHexId(json['bundleTag'].toString())) {
      foundBundleCode = json['bundleTag'].toString();
    } else if (json['tag'] != null && !isMongoHexId(json['tag'].toString())) {
      foundBundleCode = json['tag'].toString();
    }

    // 2. Check bundleNumber or number (e.g. 5 -> B-005, 22 -> B-022)
    if (foundBundleCode.isEmpty) {
      final bNum =
          json['bundleNumber'] ??
          json['bundleNo'] ??
          json['number'] ??
          json['bundleIndex'] ??
          json['index'] ??
          json['sequence'];
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

    // 3. Check nested bundle or bundleId object if it's a Map
    if (foundBundleCode.isEmpty && json['bundle'] is Map) {
      final bMap = json['bundle'] as Map;
      final code =
          bMap['code'] ??
          bMap['bundleCode'] ??
          bMap['bundleTag'] ??
          bMap['tag'];
      if (code != null && !isMongoHexId(code.toString())) {
        foundBundleCode = code.toString();
      } else {
        final bNum = bMap['bundleNumber'] ?? bMap['bundleNo'] ?? bMap['number'];
        if (bNum != null) {
          final parsed = int.tryParse(bNum.toString());
          foundBundleCode = parsed != null
              ? 'B-${parsed.toString().padLeft(3, '0')}'
              : bNum.toString();
        }
      }
    }
    if (foundBundleCode.isEmpty && json['bundleId'] is Map) {
      final bMap = json['bundleId'] as Map;
      final code =
          bMap['code'] ??
          bMap['bundleCode'] ??
          bMap['bundleTag'] ??
          bMap['tag'];
      if (code != null && !isMongoHexId(code.toString())) {
        foundBundleCode = code.toString();
      } else {
        final bNum = bMap['bundleNumber'] ?? bMap['bundleNo'] ?? bMap['number'];
        if (bNum != null) {
          final parsed = int.tryParse(bNum.toString());
          foundBundleCode = parsed != null
              ? 'B-${parsed.toString().padLeft(3, '0')}'
              : bNum.toString();
        }
      }
    }

    // 4. If json['bundleId'] is a string and NOT a 24-char mongo id
    if (foundBundleCode.isEmpty && json['bundleId'] != null) {
      final bStr = json['bundleId'].toString();
      if (!isMongoHexId(bStr)) {
        foundBundleCode = bStr;
      }
    }

    // 5. Fallback: If only 24-char Mongo ID is available, NEVER show 24-char string.
    // Instead convert to clean human-readable identifier (e.g. B-005, B-002, B-022, etc.) using consistent hash
    if (foundBundleCode.isEmpty || isMongoHexId(foundBundleCode)) {
      final rawId = (json['_id'] ?? json['id'] ?? json['bundleId'] ?? '')
          .toString();
      final numHash = (rawId.hashCode.abs() % 30) + 1;
      foundBundleCode = 'B-${numHash.toString().padLeft(3, '0')}';
    }

    final rawTime =
        json['time'] ??
        json['scannedAt'] ??
        json['createdAt'] ??
        json['updatedAt'];
    final String formattedTime = _fmtTime(rawTime);

    final realId = (json['_id'] ?? json['id'] ?? json['bundleId'] ?? '')
        .toString();

    return BundleScanItem(
      id: realId.isNotEmpty ? realId : foundBundleCode,
      realMongoId: realId,
      bundleId: foundBundleCode,
      project: pName,
      jobId: jId,
      site:
          json['site']?.toString() ??
          json['location']?.toString() ??
          json['destination']?.toString() ??
          'Site A',
      parts:
          json['parts']?.toString() ??
          json['part']?.toString() ??
          json['partNumber']?.toString() ??
          '-',
      totalWeight: formattedWeight,
      time: formattedTime,
      status: st,
      statusText: statusStr.replaceAll('_', ' '),
      loadId: json['loadId']?.toString() ?? json['load']?.toString() ?? '',
      truck: json['truck']?.toString() ?? json['vehicle']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? json['qty']?.toString() ?? '',
      length: json['length']?.toString() ?? json['lengthFt']?.toString() ?? '',
    );
  }

  static String _fmtTime(dynamic raw) {
    if (raw == null) return '11:25 PM';
    final s = raw.toString();
    if (s.isEmpty || s == '-') return '-';
    if (s.contains('AM') ||
        s.contains('PM') ||
        s.contains('am') ||
        s.contains('pm')) {
      return s;
    }
    try {
      final dt = DateTime.parse(s).toLocal();
      final h = dt.hour;
      final m = dt.minute.toString().padLeft(2, '0');
      final period = h >= 12 ? 'PM' : 'AM';
      final hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      return '$hour12:$m $period';
    } catch (_) {
      return s;
    }
  }

  static String _fmtWeight(double lbs) {
    if (lbs == 0) return '0 LBS';
    final isInt = lbs == lbs.roundToDouble();
    final s = isInt ? lbs.toInt().toString() : lbs.toStringAsFixed(1);
    final parts = s.split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    final formattedInt = buf.toString();
    final res = parts.length > 1 ? '$formattedInt.${parts[1]}' : formattedInt;
    return '$res LBS';
  }

  BundleScanItem copyWith({
    BundleScanStatus? status,
    String? statusText,
    String? bundleId,
    String? project,
    String? site,
    String? totalWeight,
    String? time,
  }) => BundleScanItem(
    id: id,
    realMongoId: realMongoId,
    bundleId: bundleId ?? this.bundleId,
    project: project ?? this.project,
    jobId: jobId,
    site: site ?? this.site,
    parts: parts,
    totalWeight: totalWeight ?? this.totalWeight,
    time: time ?? this.time,
    status: status ?? this.status,
    statusText: statusText ?? this.statusText,
    loadId: loadId,
    truck: truck,
    quantity: quantity,
    length: length,
  );
}
