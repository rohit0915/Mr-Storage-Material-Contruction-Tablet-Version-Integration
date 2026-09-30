enum PackingListStatus { loading, ready, pending, confirmed }

class PackingListItem {
  const PackingListItem({
    required this.id,
    required this.realMongoId,
    required this.packingListId,
    required this.loadId,
    required this.project,
    required this.jobId,
    required this.truck,
    required this.bundles,
    required this.totalWeight,
    required this.destination,
    required this.status,
    required this.statusText,
    this.isSelected = false,
  });

  final String id;
  final String realMongoId;
  final String packingListId;
  final String loadId;
  final String project;
  final String jobId;
  final String truck;
  final int bundles;
  final String totalWeight;
  final String destination;
  final PackingListStatus status;
  final String statusText;
  final bool isSelected;

  factory PackingListItem.fromJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] ?? json['packingStatus'] ?? 'CONFIRMED')
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

    PackingListStatus st = PackingListStatus.confirmed;
    if (statusStr.contains('LOAD')) {
      st = PackingListStatus.loading;
    } else if (statusStr.contains('READY')) {
      st = PackingListStatus.ready;
    } else if (statusStr.contains('PEND')) {
      st = PackingListStatus.pending;
    } else if (statusStr.contains('CONFIRM')) {
      st = PackingListStatus.confirmed;
    }

    bool isMongoHexId(String? s) {
      if (s == null || s.isEmpty) return false;
      return s.length == 24 && RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(s);
    }

    String foundPklCode = '';

    // 1. Check direct properties
    if (json['packingListNo'] != null &&
        !isMongoHexId(json['packingListNo'].toString())) {
      foundPklCode = json['packingListNo'].toString();
    } else if (json['packingListId'] != null &&
        !isMongoHexId(json['packingListId'].toString())) {
      foundPklCode = json['packingListId'].toString();
    } else if (json['code'] != null && !isMongoHexId(json['code'].toString())) {
      foundPklCode = json['code'].toString();
    } else if (json['number'] != null &&
        !isMongoHexId(json['number'].toString())) {
      foundPklCode = json['number'].toString();
    } else if (json['plNumber'] != null &&
        !isMongoHexId(json['plNumber'].toString())) {
      foundPklCode = json['plNumber'].toString();
    }

    // 2. Check loadId or load (e.g. "LOAD-001" -> "PL-001", "LOAD-002" -> "PL-002", "LOAD-003" -> "PL-003")
    if (foundPklCode.isEmpty) {
      final rawLoad =
          (json['loadId'] ??
                  json['load'] ??
                  json['loadNo'] ??
                  json['loadNumber'])
              ?.toString() ??
          '';
      if (rawLoad.isNotEmpty) {
        if (rawLoad.contains('LOAD-') || rawLoad.contains('L-')) {
          foundPklCode = rawLoad
              .replaceAll('LOAD-', 'PL-')
              .replaceAll('L-', 'PL-');
        } else if (int.tryParse(rawLoad) != null) {
          foundPklCode = 'PL-${int.parse(rawLoad).toString().padLeft(3, '0')}';
        }
      }
    }

    if (isMongoHexId(foundPklCode)) foundPklCode = '';

    // Parse bundle count: handle when json['bundles'] is an Array of bundles
    int bundleCount = 0;
    if (json['bundles'] is List) {
      bundleCount = (json['bundles'] as List).length;
    } else if (json['bundleCount'] != null) {
      bundleCount = int.tryParse(json['bundleCount'].toString()) ?? 0;
    } else if (json['bundlesCount'] != null) {
      bundleCount = int.tryParse(json['bundlesCount'].toString()) ?? 0;
    } else if (json['bundles'] is num) {
      bundleCount = (json['bundles'] as num).toInt();
    } else if (json['bundles'] != null) {
      bundleCount = int.tryParse(json['bundles'].toString()) ?? 0;
    }

    final realId = (json['_id'] ?? json['id'] ?? '').toString();
    final loadName = foundPklCode.replaceAll('PL-', 'LOAD-');

    return PackingListItem(
      id: realId.isNotEmpty ? realId : foundPklCode,
      realMongoId: realId,
      packingListId: foundPklCode,
      loadId:
          json['loadId']?.toString() ?? json['load']?.toString() ?? loadName,
      project: pName,
      jobId: jId,
      truck:
          json['truck']?.toString() ??
          json['truckType']?.toString() ??
          json['vehicleNo']?.toString() ??
          '',
      bundles: bundleCount,
      totalWeight: formattedWeight,
      destination:
          json['destination']?.toString() ??
          json['siteLocation']?.toString() ??
          '',
      status: st,
      statusText: statusStr.replaceAll('_', ' '),
    );
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

  PackingListItem copyWith({
    String? id,
    String? packingListId,
    String? loadId,
    String? project,
    String? jobId,
    String? truck,
    int? bundles,
    String? totalWeight,
    String? destination,
    PackingListStatus? status,
    String? statusText,
    bool? isSelected,
  }) {
    return PackingListItem(
      id: id ?? this.id,
      realMongoId: realMongoId,
      packingListId: packingListId ?? this.packingListId,
      loadId: loadId ?? this.loadId,
      project: project ?? this.project,
      jobId: jobId ?? this.jobId,
      truck: truck ?? this.truck,
      bundles: bundles ?? this.bundles,
      totalWeight: totalWeight ?? this.totalWeight,
      destination: destination ?? this.destination,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
