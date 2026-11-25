import 'package:intl/intl.dart';

enum DispatchStatus { pending, verified }

class DispatchBundleItem {
  const DispatchBundleItem({
    required this.index,
    required this.bundleNo,
    required this.bundleId,
    required this.weight,
    required this.status,
    required this.isVerified,
    this.realMongoId = '',
    this.parts = '',
    this.time = '',
    this.quantity = '',
    this.length = '',
    this.statusText = '',
    this.shipper = '',
    this.totalProducts = '',
  });

  final int index;
  final String bundleNo;
  final String bundleId;
  final String realMongoId;
  final String weight;
  final String status;
  final bool isVerified;
  final String parts;
  final String time;
  final String quantity;
  final String length;
  final String statusText;
  final String shipper;
  final String totalProducts;

  factory DispatchBundleItem.fromJson(Map<String, dynamic> json, int idx) {
    final candidateId = (json['bundleId'] ??
            json['bundleNumber'] ??
            json['bundleNo'] ??
            json['code'] ??
            json['id'] ??
            '')
        .toString();

    final rawMongoCandidate = (json['_id'] ?? json['id'] ?? json['bundleId'] ?? '').toString();
    final isHex = rawMongoCandidate.length == 24 && RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(rawMongoCandidate);
    final realMongo = isHex ? rawMongoCandidate : (candidateId.length == 24 && RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(candidateId) ? candidateId : '');

    // Human-readable bundle code: BND-001 or clean code, NOT 24-char hex mongo id
    final bool candIsHex = candidateId.length == 24 && RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(candidateId);
    final humanId = (!candIsHex && candidateId.isNotEmpty)
        ? candidateId
        : 'BND-${(idx + 1).toString().padLeft(3, '0')}';
    final bNo = (json['bundleNo'] ?? json['bundleNumber'] ?? humanId).toString();
    final cleanBNo = (bNo.length == 24 && RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(bNo))
        ? humanId
        : bNo;
    final wVal =
        json['weight'] ?? json['totalWeight'] ?? json['totalWeightLbs'] ?? json['weightLbs'] ?? '-';
    final w = wVal.toString().contains('LBS') ? wVal.toString() : '$wVal LBS';
    final st = (json['status'] ?? json['bundleStatus'] ?? 'READY').toString().toUpperCase();
    final ver = json['isVerified'] == true ||
        json['verified'] == true ||
        st == 'VERIFIED' ||
        st == 'READY';

    final partsStr = (json['parts'] ?? json['part'] ?? json['partCode'] ?? json['partNumber'] ?? json['description'] ?? json['name'] ?? '').toString();

    String timeStr = (json['time'] ?? json['scannedAt'] ?? json['createdAt'] ?? json['updatedAt'] ?? '').toString();
    if (timeStr.isNotEmpty) {
      try {
        final parsed = DateTime.tryParse(timeStr);
        if (parsed != null) {
          timeStr = DateFormat('hh:mm a').format(parsed.toLocal());
        }
      } catch (_) {}
    }

    final qtyStr = (json['quantity'] ?? json['qty'] ?? json['count'] ?? '').toString();
    final lenStr = (json['length'] ?? '').toString();
    final shipperStr = (json['shipper'] ?? json['shipperNo'] ?? '').toString();
    final totalProdStr = (json['totalProducts'] ?? json['productCount'] ?? '').toString();

    String humanStatus = 'Staging';
    if (ver || st == 'READY' || st == 'VERIFIED') {
      humanStatus = 'Ready';
    } else if (st.contains('MISMATCH')) {
      humanStatus = 'Mismatch';
    } else if (st.contains('PENDING')) {
      humanStatus = 'Pending';
    }

    return DispatchBundleItem(
      index: idx + 1,
      bundleNo: cleanBNo,
      bundleId: humanId,
      realMongoId: realMongo,
      weight: w,
      status: st,
      isVerified: ver,
      parts: partsStr,
      time: timeStr,
      quantity: qtyStr,
      length: lenStr,
      statusText: humanStatus,
      shipper: shipperStr,
      totalProducts: totalProdStr,
    );
  }

  DispatchBundleItem copyWith({
    int? index,
    String? bundleNo,
    String? bundleId,
    String? realMongoId,
    String? weight,
    String? status,
    bool? isVerified,
    String? parts,
    String? time,
    String? quantity,
    String? length,
    String? statusText,
    String? shipper,
    String? totalProducts,
  }) =>
      DispatchBundleItem(
        index: index ?? this.index,
        bundleNo: bundleNo ?? this.bundleNo,
        bundleId: bundleId ?? this.bundleId,
        realMongoId: realMongoId ?? this.realMongoId,
        weight: weight ?? this.weight,
        status: status ?? this.status,
        isVerified: isVerified ?? this.isVerified,
        parts: parts ?? this.parts,
        time: time ?? this.time,
        quantity: quantity ?? this.quantity,
        length: length ?? this.length,
        statusText: statusText ?? this.statusText,
        shipper: shipper ?? this.shipper,
        totalProducts: totalProducts ?? this.totalProducts,
      );
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
    this.createdAt,
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
  final DateTime? createdAt;

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
              bundleNo: 'BND-${(i + 1).toString().padLeft(3, '0')}',
              bundleId: 'BND-${(i + 1).toString().padLeft(3, '0')}',
              realMongoId: b.toString(),
              weight: '-',
              status: 'READY',
              isVerified: true,
            ),
          );
        }
      }
    } else if (json['totalBundles'] != null) {
      bCount = int.tryParse(json['totalBundles'].toString()) ?? 0;
    } else if (json['bundlesCount'] != null) {
      bCount = int.tryParse(json['bundlesCount'].toString()) ?? 0;
    } else if (json['bundleCount'] != null) {
      bCount = int.tryParse(json['bundleCount'].toString()) ?? 0;
    } else if (json['bundles'] is num) {
      bCount = (json['bundles'] as num).toInt();
    }

    DateTime? itemCreatedAt;
    for (final k in ['createdAt', 'dispatchDate', 'date', 'updatedAt', 'created_at']) {
      if (json[k] != null && json[k].toString().isNotEmpty) {
        final parsed = DateTime.tryParse(json[k].toString());
        if (parsed != null) {
          itemCreatedAt = parsed;
          break;
        }
      }
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
      createdAt: itemCreatedAt,
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
    DateTime? createdAt,
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
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class DispatchProjectItem {
  const DispatchProjectItem({
    required this.leadId,
    required this.projectId,
    required this.projectName,
    required this.siteLocation,
    this.thumbnailUrl,
    this.totalPackingLists = 0,
    this.totalBundles = 0,
    this.loads = const [],
    this.createdAt,
  });

  final String leadId;
  final String projectId;
  final String projectName;
  final String siteLocation;
  final String? thumbnailUrl;
  final int totalPackingLists;
  int get totalPackingList => totalPackingLists;
  final int totalBundles;
  final List<DispatchItem> loads;
  final DateTime? createdAt;

  DispatchProjectItem copyWith({
    String? leadId,
    String? projectId,
    String? projectName,
    String? siteLocation,
    String? thumbnailUrl,
    int? totalPackingLists,
    int? totalBundles,
    List<DispatchItem>? loads,
    DateTime? createdAt,
  }) {
    return DispatchProjectItem(
      leadId: leadId ?? this.leadId,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      siteLocation: siteLocation ?? this.siteLocation,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      totalPackingLists: totalPackingLists ?? this.totalPackingLists,
      totalBundles: totalBundles ?? this.totalBundles,
      loads: loads ?? this.loads,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

