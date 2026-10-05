enum BundleScanStatus { staging, ready, pending, assigned }

class BundleSubItem {
  const BundleSubItem({
    required this.index,
    required this.bundleId,
    required this.parts,
    required this.time,
    required this.weight,
    required this.status,
  });

  final String index;
  final String bundleId;
  final String parts;
  final String time;
  final String weight;
  final String status;

  factory BundleSubItem.fromJson(Map<String, dynamic> json, int idx) {
    return BundleSubItem(
      index: (idx + 1).toString(),
      bundleId: (json['bundleId'] ??
              json['code'] ??
              json['bundleCode'] ??
              json['tag'] ??
              'B-${(idx + 1).toString().padLeft(3, '0')}')
          .toString(),
      parts: (json['parts'] ??
              json['part'] ??
              json['partNumber'] ??
              json['description'] ??
              json['name'] ??
              '-')
          .toString(),
      time: (json['time'] ??
              json['scannedAt'] ??
              json['createdAt'] ??
              '11:25 AM')
          .toString(),
      weight: (json['weight'] ?? json['totalWeight'] ?? '4,319.1 LBS')
          .toString(),
      status: (json['status'] ?? 'Staged').toString(),
    );
  }
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
    this.loadId = '',
    this.truck = '',
    this.quantity = '',
    this.length = '',
    this.shipper = '',
    this.driver = '',
    this.totalProducts = '',
    this.isVerified = false,
    this.subItems = const [],
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
  final String shipper;
  final String driver;
  final String totalProducts;
  final bool isVerified;
  final List<BundleSubItem> subItems;

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

    final isVer = json['isVerified'] == true ||
        json['verified'] == true ||
        st == BundleScanStatus.ready;

    final shipperVal = (json['shipper'] ??
            json['shipperNo'] ??
            json['shipperId'] ??
            'SHP-1044')
        .toString();

    final driverVal = (json['driver'] ??
            json['driverName'] ??
            json['carrier'] ??
            'John Miler')
        .toString();

    final totalProductsVal = (json['totalProducts'] ??
            json['productCount'] ??
            json['products'] ??
            '4')
        .toString();

    final loadVal = (json['loadId'] ?? json['load'] ?? 'LOAD-001').toString();
    final truckVal =
        (json['truck'] ?? json['vehicle'] ?? 'TRK-980').toString();
    final qtyVal = (json['quantity'] ?? json['qty'] ?? '4').toString();
    final lengthVal =
        (json['length'] ?? json['lengthFt'] ?? '20 ft').toString();

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
          status: statusStr.contains('STAG') ? 'Staged' : 'Loaded',
        );
      }).toList();
    } else {
      parsedSubItems = [
        BundleSubItem(
          index: '1',
          bundleId: foundBundleCode,
          parts: (json['parts'] ?? json['part'] ?? 'P-101 (Steel Girders)')
              .toString(),
          time: formattedTime,
          weight: formattedWeight,
          status: statusStr.contains('STAG')
              ? 'Staged'
              : (statusStr.contains('LOAD') ? 'Loaded' : 'Ready'),
        ),
      ];
    }

    return BundleScanItem(
      id: realId.isNotEmpty ? realId : foundBundleCode,
      realMongoId: realId,
      bundleId: foundBundleCode,
      project: pName.isNotEmpty ? pName : 'Storage 0011',
      jobId: jId.isNotEmpty ? jId : 'JOB-0011',
      site: (json['site'] ??
              json['location'] ??
              json['destination'] ??
              'Site A')
          .toString(),
      parts: (json['parts'] ??
              json['part'] ??
              json['partNumber'] ??
              'P-101, P-102')
          .toString(),
      totalWeight: formattedWeight,
      time: formattedTime,
      status: st,
      statusText: statusStr.replaceAll('_', ' '),
      loadId: loadVal,
      truck: truckVal,
      quantity: qtyVal,
      length: lengthVal,
      shipper: shipperVal,
      driver: driverVal,
      totalProducts: totalProductsVal,
      isVerified: isVer,
      subItems: parsedSubItems,
    );
  }

  static String _fmtTime(dynamic raw) {
    if (raw == null) return '11:25 AM';
    final s = raw.toString();
    if (s.isEmpty || s == '-') return '11:25 AM';
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
    if (lbs == 0) return '4,319.1 LBS';
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
    String? loadId,
    String? truck,
    String? quantity,
    String? length,
    String? shipper,
    String? driver,
    String? totalProducts,
    bool? isVerified,
    List<BundleSubItem>? subItems,
  }) =>
      BundleScanItem(
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
        loadId: loadId ?? this.loadId,
        truck: truck ?? this.truck,
        quantity: quantity ?? this.quantity,
        length: length ?? this.length,
        shipper: shipper ?? this.shipper,
        driver: driver ?? this.driver,
        totalProducts: totalProducts ?? this.totalProducts,
        isVerified: isVerified ?? this.isVerified,
        subItems: subItems ?? this.subItems,
      );
}
