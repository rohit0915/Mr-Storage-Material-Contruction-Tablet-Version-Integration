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
    final rawId = (json['bundleId'] ?? json['_id'] ?? json['id'] ?? '')
        .toString();
    final bNo = (json['bundleNo'] ?? json['code'] ?? '').toString();
    final w = json['weight'] != null
        ? '${json['weight']} LBS'
        : (json['totalWeight']?.toString() ?? '');
    final st = (json['status'] ?? '').toString();
    final ver = json['isVerified'] == true || json['verified'] == true;

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
    this.packingListNo = '',
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
  final String packingListNo;
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
    if (json['packingListNo'] != null &&
        json['packingListNo'].toString().startsWith('PL-')) {
      pkl = json['packingListNo'].toString();
    } else if (json['packingListId'] != null &&
        json['packingListId'].toString().startsWith('PL-')) {
      pkl = json['packingListId'].toString();
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
    if (json['bundles'] is List) {
      final bList = json['bundles'] as List;
      bCount = bList.length;
      for (var i = 0; i < bList.length; i++) {
        final b = bList[i];
        if (b is Map) {
          parsedBundles.add(
            DispatchBundleItem.fromJson(Map<String, dynamic>.from(b), i),
          );
        } else {
          parsedBundles.add(
            DispatchBundleItem(
              index: i + 1,
              bundleNo: '',
              bundleId: b.toString(),
              weight: '',
              status: '',
              isVerified: false,
            ),
          );
        }
      }
    } else if (json['bundleCount'] != null) {
      bCount = int.tryParse(json['bundleCount'].toString()) ?? 0;
    }

    return DispatchItem(
      loadId: lId,
      packingListNo: pkl,
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
    DispatchStatus? status,
    String? statusText,
    bool? isSelected,
  }) {
    return DispatchItem(
      loadId: loadId,
      packingListNo: packingListNo,
      project: project,
      jobId: jobId,
      truck: truck,
      driver: driver,
      bundles: bundles,
      totalWeight: totalWeight,
      destination: destination,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      weightVerified: weightVerified,
      loadingVerified: loadingVerified,
      bundleList: bundleList,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
