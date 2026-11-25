enum BundleScanStatus { staging, ready, pending, assigned }

class BundleSubItem {
  const BundleSubItem({
    required this.index,
    required this.bundleId,
    required this.parts,
    required this.time,
    required this.weight,
    required this.status,
    this.itemCode = 'ITEM-1',
    this.color = '-',
    this.quantity = 1,
    this.receivedQuantity = 1,
    this.itemId = '',
    this.partCode = '',
    this.description = '',
  });

  final String index;
  final String bundleId;
  final String parts;
  final String time;
  final String weight;
  final String status;
  final String itemCode;
  final String color;
  final int quantity;
  final int receivedQuantity;
  final String itemId;
  final String partCode;
  final String description;

  factory BundleSubItem.fromJson(Map<String, dynamic> json, int idx) {
    final qty = (json['quantity'] ?? json['qty'] ?? json['count'] ?? 1);
    final parsedQty = qty is num
        ? qty.toInt()
        : (int.tryParse(qty.toString()) ?? 1);
    final recQty = (json['receivedQuantity'] ?? json['receivedQty'] ?? parsedQty);
    final parsedRecQty = recQty is num
        ? recQty.toInt()
        : (int.tryParse(recQty.toString()) ?? parsedQty);

    final rawItemId = (json['_id'] ?? json['itemId'] ?? json['id'] ?? '').toString();
    final rawPartCode = (json['partCode'] ?? json['partNumber'] ?? json['itemCode'] ?? json['code'] ?? 'ITEM-${idx + 1}').toString();
    final rawDesc = (json['description'] ?? json['parts'] ?? json['part'] ?? json['name'] ?? '-').toString();

    return BundleSubItem(
      index: (idx + 1).toString(),
      bundleId: (json['bundleId'] ??
              json['code'] ??
              json['bundleCode'] ??
              json['tag'] ??
              'B-${(idx + 1).toString().padLeft(3, '0')}')
          .toString(),
      parts: rawDesc,
      time: (json['time'] ??
              json['scannedAt'] ??
              json['createdAt'] ??
              '-')
          .toString(),
      weight: (json['weight'] ?? json['totalWeight'] ?? '0.0 LBS')
          .toString(),
      status: (json['status'] ?? 'Staged').toString(),
      itemCode: rawPartCode,
      color: (json['color'] ?? '-').toString(),
      quantity: parsedQty,
      receivedQuantity: parsedRecQty,
      itemId: rawItemId,
      partCode: rawPartCode,
      description: rawDesc,
    );
  }
}

class BundleMismatchItem {
  final String partCode;
  final String description;
  final int expectedQty;
  final int receivedQty;
  final int difference;
  final String status;

  const BundleMismatchItem({
    required this.partCode,
    required this.description,
    required this.expectedQty,
    required this.receivedQty,
    required this.difference,
    required this.status,
  });

  factory BundleMismatchItem.fromJson(Map<String, dynamic> json) {
    final exp = (json['expectedQty'] ?? json['quantity'] ?? json['qty'] ?? 1);
    final expInt = exp is num ? exp.toInt() : (int.tryParse(exp.toString()) ?? 1);
    final rec = (json['receivedQty'] ?? json['receivedQuantity'] ?? 0);
    final recInt = rec is num ? rec.toInt() : (int.tryParse(rec.toString()) ?? 0);
    final diff = json['difference'] != null
        ? (json['difference'] is num
            ? (json['difference'] as num).toInt()
            : (int.tryParse(json['difference'].toString()) ?? (recInt - expInt)))
        : (recInt - expInt);

    String st = (json['status'] ?? '').toString();
    if (st.isEmpty || st.toLowerCase() == 'received' || st.toLowerCase() == 'pending') {
      if (recInt == 0) {
        st = 'Not Received';
      } else if (recInt < expInt) {
        st = 'Partially Received';
      } else if (recInt > expInt) {
        st = 'Excess';
      } else {
        st = 'Received';
      }
    } else if (st.toLowerCase() == 'missing') {
      st = 'Not Received';
    }

    return BundleMismatchItem(
      partCode: (json['partCode'] ?? json['itemCode'] ?? json['code'] ?? 'ITEM-1').toString(),
      description: (json['description'] ?? json['name'] ?? json['parts'] ?? '-').toString(),
      expectedQty: expInt,
      receivedQty: recInt,
      difference: diff,
      status: st,
    );
  }

  Map<String, dynamic> toJson() => {
    'partCode': partCode,
    'description': description,
    'expectedQty': expectedQty,
    'receivedQty': receivedQty,
    'difference': difference,
    'status': status,
  };
}

class BundleMismatchInfo {
  final String reportedAt;
  final String notes;
  final String reason;
  final List<BundleMismatchItem> affectedItems;

  const BundleMismatchInfo({
    required this.reportedAt,
    required this.notes,
    this.reason = '',
    this.affectedItems = const [],
  });

  factory BundleMismatchInfo.fromJson(Map<String, dynamic> json) {
    final rawTime = json['reportedAt'] ??
        json['createdAt'] ??
        json['updatedAt'] ??
        json['date'] ??
        json['timestamp'];
    String fmtTime = '';
    if (rawTime != null) {
      fmtTime = formatReportedAt(rawTime.toString());
    }
    if (fmtTime.isEmpty) {
      final now = DateTime.now();
      fmtTime = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}, ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    }

    final rawItems = json['affectedItems'] ??
        json['items'] ??
        json['mismatchItems'] ??
        json['discrepancies'] ??
        [];
    List<BundleMismatchItem> items = [];
    if (rawItems is List) {
      items = rawItems
          .whereType<Map>()
          .map((m) => BundleMismatchItem.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }

    final n = (json['notes'] ?? json['note'] ?? json['reason'] ?? '').toString();
    final r = (json['reason'] ?? json['notes'] ?? '').toString();

    return BundleMismatchInfo(
      reportedAt: fmtTime,
      notes: n.isNotEmpty ? n : (r.isNotEmpty ? r : 'qty_short'),
      reason: r,
      affectedItems: items,
    );
  }

  static String formatReportedAt(String raw) {
    if (raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  Map<String, dynamic> toJson() => {
    'reportedAt': reportedAt,
    'notes': notes,
    'reason': reason,
    'affectedItems': affectedItems.map((e) => e.toJson()).toList(),
  };
}

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
    this.projectId = '',
    this.loadId = '',
    this.truck = '',
    this.quantity = '',
    this.length = '',
    this.shipper = '',
    this.driver = '',
    this.totalProducts = '',
    this.type = 'Mixed',
    this.title = 'MIXED Bundle',
    this.packingListNo = '-',
    this.isVerified = false,
    this.qrUrl = '',
    this.subItems = const [],
    this.mismatchInfo,
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
  final String projectId;
  final String loadId;
  final String truck;
  final String quantity;
  final String length;
  final String shipper;
  final String driver;
  final String totalProducts;
  final String type;
  final String title;
  final String packingListNo;
  final bool isVerified;
  final String qrUrl;
  final List<BundleSubItem> subItems;
  final BundleMismatchInfo? mismatchInfo;

  /// Helper to check if string is raw 24-character hexadecimal Mongo ObjectId
  static bool isMongoHexId(String? s) {
    if (s == null || s.trim().isEmpty) return false;
    final clean = s.trim();
    return clean.length == 24 && RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(clean);
  }

  factory BundleScanItem.fromJson(Map<String, dynamic> rawInput) {
    Map<String, dynamic> target = rawInput;
    if (rawInput['data'] is Map) {
      target = Map<String, dynamic>.from(rawInput['data'] as Map);
    }
    if (target['bundle'] is Map) {
      target = Map<String, dynamic>.from(target['bundle'] as Map);
    } else if (rawInput['bundle'] is Map) {
      target = Map<String, dynamic>.from(rawInput['bundle'] as Map);
    }
    final json = target;
    final rawStatus =
        (json['status'] ?? json['bundleStatus'] ?? 'PENDING')
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
    String pId = '';
    if (json['project'] is Map) {
      final pMap = json['project'] as Map;
      pName = (pMap['projectName'] ?? pMap['name'] ?? '').toString();
      jId = (pMap['jobId'] ?? pMap['code'] ?? '').toString();
      pId = (pMap['_id'] ?? pMap['id'] ?? pMap['leadId'] ?? pMap['projectId'] ?? '')
          .toString();
    } else if (json['project'] != null &&
        json['project'].toString().isNotEmpty) {
      final pStr = json['project'].toString();
      if (isMongoHexId(pStr)) {
        pId = pStr;
      } else {
        pName = pStr;
      }
      jId = json['jobId']?.toString() ?? '';
    }

    if (pId.isEmpty) {
      pId = (json['projectId'] ?? json['leadId'] ?? '').toString();
    }
    if (pId.isEmpty && json['lead'] is Map) {
      pId = (json['lead']['_id'] ?? json['lead']['id'] ?? '').toString();
    }

    BundleScanStatus st = BundleScanStatus.pending;
    if (rawStatus.contains('STAG')) {
      st = BundleScanStatus.staging;
    } else if (rawStatus.contains('ASSIGN') || rawStatus.contains('TRUCK')) {
      st = BundleScanStatus.assigned;
    } else if (rawStatus.contains('LOAD') || rawStatus.contains('READY')) {
      st = BundleScanStatus.ready;
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

    // 5. Fallback: If only 24-char Mongo ID is available
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

    String realId = '';
    for (final candidate in [
      json['_id'],
      json['id'],
      rawInput['_id'],
      rawInput['id'],
      if (rawInput['bundle'] is Map) rawInput['bundle']['_id'],
      if (rawInput['bundle'] is Map) rawInput['bundle']['id'],
      if (rawInput['data'] is Map) rawInput['data']['_id'],
      if (rawInput['data'] is Map) rawInput['data']['id'],
      if (json['bundle'] is Map) json['bundle']['_id'],
      if (json['bundle'] is Map) json['bundle']['id'],
      if (json['bundleId'] is Map) json['bundleId']['_id'],
      if (json['bundleId'] is Map) json['bundleId']['id'],
      json['bundleId'],
      rawInput['bundleId'],
    ]) {
      if (candidate != null && isMongoHexId(candidate.toString())) {
        realId = candidate.toString().trim();
        break;
      }
    }

    final isVer = json['isVerified'] == true ||
        json['verified'] == true ||
        st == BundleScanStatus.ready;

    final shipperVal = (json['shipper'] ??
            json['shipperNo'] ??
            json['shipperId'] ??
            '-')
        .toString();

    final driverVal = (json['driver'] ??
            json['driverName'] ??
            json['carrier'] ??
            '-')
        .toString();

    final totalProductsVal = (json['totalProducts'] ??
            json['productCount'] ??
            json['products'] ??
            '1')
        .toString();

    final loadVal = (json['loadId'] ?? json['load'] ?? '-').toString();
    final truckVal =
        (json['truck'] ?? json['vehicle'] ?? '-').toString();
    final qtyVal = (json['quantity'] ?? json['qty'] ?? json['totalQty'] ?? '1').toString();
    final lengthVal =
        (json['length'] ?? json['lengthFt'] ?? json['maxLengthFeet'] ?? '0 ft').toString();

    final plNo = (json['packingListNo'] ??
            json['packingList'] ??
            json['packingListNumber'] ??
            json['plNo'] ??
            '-')
        .toString();
    final typeVal =
        (json['type'] ?? json['bundleType'] ?? 'Mixed').toString();
    final titleVal = (json['title'] ??
            json['bundleTitle'] ??
            (typeVal.toLowerCase().contains('bundle')
                ? typeVal
                : '$typeVal Bundle'))
        .toString();

    String foundPart = '-';
    final rawParts = json['parts'] ??
        json['part'] ??
        json['partNumber'] ??
        json['description'] ??
        json['name'];
    if (rawParts is List && rawParts.isNotEmpty) {
      foundPart = rawParts
          .map((p) => p is Map ? (p['partCode'] ?? p['name'] ?? p['code'] ?? '') : p.toString())
          .where((s) => s.isNotEmpty && !RegExp(r'^\.+$').hasMatch(s))
          .join(', ');
    } else if (rawParts != null) {
      final pStr = rawParts.toString().trim();
      if (pStr.isNotEmpty && !RegExp(r'^\.+$').hasMatch(pStr)) {
        foundPart = pStr;
      }
    }

    String formattedStatusText = rawStatus.replaceAll('_', ' ');
    if (rawStatus == 'ASSIGNED_TO_TRUCK') {
      formattedStatusText = 'Assigned to Truck';
    } else if (rawStatus == 'PENDING') {
      formattedStatusText = 'Pending';
    } else if (rawStatus == 'STAGED' || rawStatus == 'STAGING') {
      formattedStatusText = 'Staged';
    } else if (rawStatus == 'LOADED') {
      formattedStatusText = 'Loaded';
    } else if (rawStatus == 'DRAFT') {
      formattedStatusText = 'Draft';
    }

    final rawSubItems = json['subItems'] ??
        json['items'] ??
        json['partsList'] ??
        json['partItems'] ??
        json['bundles'];

    List<BundleSubItem> parsedSubItems = [];
    if (rawSubItems is List && rawSubItems.isNotEmpty) {
      parsedSubItems = rawSubItems.asMap().entries.map((entry) {
        if (entry.value is Map) {
          return BundleSubItem.fromJson(
            Map<String, dynamic>.from(entry.value as Map),
            entry.key,
          );
        }
        return BundleSubItem(
          index: (entry.key + 1).toString(),
          bundleId: foundBundleCode,
          parts: entry.value.toString(),
          time: formattedTime,
          weight: formattedWeight,
          status: formattedStatusText,
        );
      }).toList();
    } else {
      parsedSubItems = [
        BundleSubItem(
          index: '1',
          bundleId: foundBundleCode,
          parts: foundPart,
          time: formattedTime,
          weight: formattedWeight,
          status: formattedStatusText,
        ),
      ];
    }

    final qrLink = (json['qrUrl'] ??
            json['qrCodeUrl'] ??
            json['url'] ??
            json['link'] ??
            json['trackingUrl'] ??
            'https://mr-storage-material-contruction.vercel.app/delivery-tracking/bundle-scan?bundleId=$foundBundleCode')
        .toString();

    BundleMismatchInfo? parsedMismatch;
    for (final candidate in [
      json['mismatchDetails'],
      json['mismatchInfo'],
      json['mismatchReport'],
      json['reportedMismatch'],
      json['mismatchOrder'],
      if (json['mismatch'] is Map) json['mismatch'],
      rawInput['mismatchDetails'],
      rawInput['mismatchInfo'],
      rawInput['mismatchReport'],
      rawInput['reportedMismatch'],
      if (rawInput['mismatch'] is Map) rawInput['mismatch'],
    ]) {
      if (candidate is Map) {
        parsedMismatch =
            BundleMismatchInfo.fromJson(Map<String, dynamic>.from(candidate));
        break;
      }
    }

    return BundleScanItem(
      id: realId.isNotEmpty ? realId : foundBundleCode,
      realMongoId: realId,
      bundleId: foundBundleCode,
      project: pName.isNotEmpty ? pName : 'N/A',
      projectId: pId,
      jobId: jId.isNotEmpty ? jId : '-',
      site: (json['site'] ??
              json['location'] ??
              json['destination'] ??
              '-')
          .toString(),
      parts: foundPart,
      totalWeight: formattedWeight,
      time: formattedTime,
      status: st,
      statusText: formattedStatusText,
      loadId: loadVal.isNotEmpty && !isMongoHexId(loadVal) ? loadVal : '-',
      truck: truckVal.isNotEmpty ? truckVal : '-',
      quantity: qtyVal,
      length: lengthVal,
      shipper: shipperVal.isNotEmpty && !isMongoHexId(shipperVal) ? shipperVal : '-',
      driver: driverVal.isNotEmpty ? driverVal : '-',
      totalProducts: totalProductsVal,
      type: typeVal,
      title: titleVal,
      packingListNo: plNo,
      isVerified: isVer,
      qrUrl: qrLink,
      subItems: parsedSubItems,
      mismatchInfo: parsedMismatch,
    );
  }

  static String _fmtTime(dynamic raw) {
    if (raw == null) return '-';
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
    if (lbs == 0) return '0.0 LBS';
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
    String? id,
    String? realMongoId,
    BundleScanStatus? status,
    String? statusText,
    String? bundleId,
    String? project,
    String? projectId,
    String? jobId,
    String? site,
    String? totalWeight,
    String? time,
    String? loadId,
    String? truck,
    String? quantity,
    String? length,
    String? shipper,
    String? driver,
    String? totalProducts,
    String? type,
    String? title,
    String? packingListNo,
    bool? isVerified,
    String? qrUrl,
    List<BundleSubItem>? subItems,
    BundleMismatchInfo? mismatchInfo,
  }) =>
      BundleScanItem(
        id: id ?? this.id,
        realMongoId: realMongoId ?? this.realMongoId,
        bundleId: bundleId ?? this.bundleId,
        project: project ?? this.project,
        projectId: projectId ?? this.projectId,
        jobId: jobId ?? this.jobId,
        site: site ?? this.site,
        parts: parts,
        totalWeight: totalWeight ?? this.totalWeight,
        time: time ?? this.time,
        status: status ?? this.status,
        statusText: statusText ?? this.statusText,
        loadId: loadId ?? this.loadId,
        truck: truck ?? this.truck,
        quantity: quantity ?? this.quantity,
        length: length ?? this.length,
        shipper: shipper ?? this.shipper,
        driver: driver ?? this.driver,
        totalProducts: totalProducts ?? this.totalProducts,
        type: type ?? this.type,
        title: title ?? this.title,
        packingListNo: packingListNo ?? this.packingListNo,
        isVerified: isVerified ?? this.isVerified,
        qrUrl: qrUrl ?? this.qrUrl,
        subItems: subItems ?? this.subItems,
        mismatchInfo: mismatchInfo ?? this.mismatchInfo,
      );
}
