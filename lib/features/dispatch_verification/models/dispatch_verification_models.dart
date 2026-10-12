enum DispatchStatus { pending, verified }

class DispatchBundleItem {
  const DispatchBundleItem({
    required this.index,
    required this.bundleNo,
    required this.bundleId,
    required this.weight,
    required this.status,
    required this.isVerified,
  });

  final int index;
  final String bundleNo;
  final String bundleId;
  final String weight;
  final String status;
  final bool isVerified;

  factory DispatchBundleItem.fromJson(Map<String, dynamic> json, int idx) {
    final rawId = (json['bundleId'] ??
            json['bundleNumber'] ??
            json['bundleNo'] ??
            json['code'] ??
            json['id'] ??
            json['_id'] ??
            'B-${(idx + 1).toString().padLeft(3, '0')}')
        .toString();
    final bNo = (json['bundleNo'] ??
            json['bundleNumber'] ??
            json['bundleId'] ??
            json['code'] ??
            '${idx + 1}')
        .toString();
    final wVal =
        json['weight'] ?? json['totalWeight'] ?? json['weightLbs'] ?? '-';
    final w = wVal.toString().contains('LBS') ? wVal.toString() : '$wVal LBS';
    final st = (json['status'] ?? 'READY').toString().toUpperCase();
    final ver = json['isVerified'] == true ||
        json['verified'] == true ||
        st == 'VERIFIED' ||
        st == 'READY';

    return DispatchBundleItem(
      index: idx + 1,
      bundleNo: bNo,
      bundleId: rawId,
      weight: w,
      status: st,
      isVerified: ver,
    );
  }
}

class DispatchItem {
  const DispatchItem({
    required this.loadId,
    this.displayLoadId = '',
    this.mongoId = '',
    this.packingListNo = '',
    this.packingListMongoId = '',
    this.project = '',
    this.jobId = '',
    required this.truck,
    required this.driver,
    required this.bundles,
    required this.totalWeight,
    required this.destination,
    required this.status,
    this.statusText = '',
    this.weightVerified = false,
    this.loadingVerified = false,
    this.bundleList = const [],
    this.isSelected = false,
  });

  final String loadId;
  final String displayLoadId;
  final String mongoId;
  final String packingListNo;
  final String packingListMongoId;
  final String project;
  final String jobId;
  final String truck;
  final String driver;
  final int bundles;
  final String totalWeight;
  final String destination;
  final DispatchStatus status;
  final String statusText;
  final bool weightVerified;
  final bool loadingVerified;
  final List<DispatchBundleItem> bundleList;
  final bool isSelected;

  factory DispatchItem.fromJson(Map<String, dynamic> json) {
    final statusStr =
        (json['status'] ?? json['verificationStatus'] ?? 'CONFIRMED')
            .toString()
            .toUpperCase();

    final rawId = (json['_id'] ?? json['id'] ?? json['loadId'] ?? '')
        .toString();
    final lId = rawId;

    String pkl = '';
    String pklMongoId = '';
    
    if (json['packingListId'] != null) {
      final pklStr = json['packingListId'].toString();
      if (pklStr.startsWith('PL-')) {
        pkl = pklStr;
      } else if (pklStr.length == 24) {
        pklMongoId = pklStr;
      }
    }
    
    if (json['packingListNo'] != null && json['packingListNo'].toString().startsWith('PL-')) {
      pkl = json['packingListNo'].toString();
    }

    // Determine clean human-readable Load ID (e.g. LOAD-001, LOAD-002, etc.)
    String displayId = '';
    for (final k in ['loadNumber', 'loadNo', 'loadCode', 'code']) {
      if (json[k] != null && json[k].toString().isNotEmpty) {
        displayId = json[k].toString();
        break;
      }
    }
    if (displayId.isEmpty && json['loadId'] != null && json['loadId'].toString().length != 24) {
      displayId = json['loadId'].toString();
    }
    if (displayId.isEmpty && pkl.isNotEmpty) {
      displayId = 'LOAD-${pkl.replaceAll('PL-', '')}';
    }
    if (displayId.isEmpty) {
      if (rawId.length == 24) {
        displayId = 'LOAD-${rawId.substring(rawId.length - 4).toUpperCase()}';
      } else {
        displayId = rawId;
      }
    }

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

    final wVal =
        json['totalWeightLbs'] ?? json['weight'] ?? json['totalWeight'] ?? 0;
    String formattedWeight;
    if (wVal is num) {
      formattedWeight = '${wVal.toStringAsFixed(1)} LBS';
    } else {
      final wStr = wVal.toString();
      formattedWeight = wStr.contains('LBS') ? wStr : '$wStr LBS';
    }

    final List<DispatchBundleItem> parsedBundles = [];
    int bCount = 0;
    final rawBundles = json['bundles'] ?? json['items'] ?? json['bundleItems'];
    if (rawBundles is List) {
      bCount = rawBundles.length;
      for (var i = 0; i < rawBundles.length; i++) {
        final b = rawBundles[i];
        if (b is Map) {
          parsedBundles.add(
            DispatchBundleItem.fromJson(Map<String, dynamic>.from(b), i),
          );
        } else {
          parsedBundles.add(
            DispatchBundleItem(
              index: i + 1,
              bundleNo: '${i + 1}',
              bundleId: b.toString(),
              weight: '-',
              status: 'READY',
              isVerified: true,
            ),
          );
        }
      }
    } else if (json['bundleCount'] != null) {
      bCount = int.tryParse(json['bundleCount'].toString()) ?? 0;
    }

    return DispatchItem(
      loadId: lId,
      displayLoadId: displayId,
      mongoId: rawId.length == 24 ? rawId : '',
      packingListNo: pkl,
      packingListMongoId: pklMongoId,
      project: pName,
      jobId: jId,
      truck:
          json['truck']?.toString() ??
          json['truckType']?.toString() ??
          json['vehicleNo']?.toString() ??
          '',
      driver:
          json['driver']?.toString() ?? json['driverName']?.toString() ?? '-',
      bundles: bCount,
      totalWeight: formattedWeight,
      destination:
          json['destination']?.toString() ??
          json['siteLocation']?.toString() ??
          '',
      status: statusStr.contains('VERIF')
          ? DispatchStatus.verified
          : DispatchStatus.pending,
      statusText: statusStr.replaceAll('_', ' '),
      weightVerified: json['weightVerified'] == true,
      loadingVerified: json['loadingVerified'] == true,
      bundleList: parsedBundles,
    );
  }

  DispatchItem copyWith({
    String? loadId,
    String? displayLoadId,
    String? mongoId,
    String? packingListNo,
    String? packingListMongoId,
    String? project,
    String? jobId,
    String? truck,
    String? driver,
    int? bundles,
    String? totalWeight,
    String? destination,
    DispatchStatus? status,
    String? statusText,
    bool? weightVerified,
    bool? loadingVerified,
    List<DispatchBundleItem>? bundleList,
    bool? isSelected,
  }) {
    return DispatchItem(
      loadId: loadId ?? this.loadId,
      displayLoadId: displayLoadId ?? this.displayLoadId,
      mongoId: mongoId ?? this.mongoId,
      packingListNo: packingListNo ?? this.packingListNo,
      packingListMongoId: packingListMongoId ?? this.packingListMongoId,
      project: project ?? this.project,
      jobId: jobId ?? this.jobId,
      truck: truck ?? this.truck,
      driver: driver ?? this.driver,
      bundles: bundles ?? this.bundles,
      totalWeight: totalWeight ?? this.totalWeight,
      destination: destination ?? this.destination,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      weightVerified: weightVerified ?? this.weightVerified,
      loadingVerified: loadingVerified ?? this.loadingVerified,
      bundleList: bundleList ?? this.bundleList,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
