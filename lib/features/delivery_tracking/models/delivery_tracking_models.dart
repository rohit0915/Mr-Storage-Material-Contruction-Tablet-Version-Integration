import 'package:intl/intl.dart';

enum DeliveryStatus { inTransit, staged, ready, delivered }

enum DeliveryPriority { high, medium, low }

class DeliveryItem {
  const DeliveryItem({
    required this.id,
    this.realMongoId = '',
    this.jobId = '',
    required this.title,
    required this.location,
    required this.project,
    required this.quantity,
    required this.stagingArea,
    required this.carrier,
    required this.driver,
    required this.truck,
    required this.phone,
    required this.finalDestination,
    required this.arrivalAtPlant,
    required this.departureFromPlant,
    required this.notes,
    required this.status,
    required this.priority,
    required this.eta,
    this.bundleCount = 0,
  });

  final String id;
  final String realMongoId;
  final String jobId;
  final String title;
  final String location;
  final String project;
  final String quantity;
  final String stagingArea;
  final String carrier;
  final String driver;
  final String truck;
  final String phone;
  final String finalDestination;
  final String arrivalAtPlant;
  final String departureFromPlant;
  final String notes;
  final DeliveryStatus status;
  final DeliveryPriority? priority;
  final String eta;
  final int bundleCount;

  factory DeliveryItem.fromJson(Map<String, dynamic> json) {
    final mongoId = (json['deliveryId'] ?? json['_id'] ?? '').toString();
    final dId = (json['deliveryNumber'] ?? mongoId).toString();
    final desc =
        json['description'] != null && json['description'].toString().isNotEmpty
        ? json['description'].toString()
        : (json['materialType'] ?? 'Material Delivery').toString();
    final project = json['project'] is Map ? json['project'] as Map : const {};
    final loc =
        json['deliveryLocation'] != null &&
            json['deliveryLocation'].toString().isNotEmpty
        ? json['deliveryLocation'].toString()
        : (project['location'] ?? json['pickupLocation'] ?? '').toString();

    String projName = 'Project';
    String jId = '';
    if (json['project'] is Map) {
      projName =
          (json['project']['projectName'] ??
                  json['project']['name'] ??
                  'Project')
              .toString();
      jId = (json['project']['jobId'] ?? json['project']['code'] ?? '')
          .toString();
    } else if (json['project'] != null &&
        json['project'].toString().isNotEmpty) {
      projName = json['project'].toString();
    }
    if (jId.isEmpty && json['jobId'] != null) {
      jId = json['jobId'].toString();
    }

    final weight = json['loadWeight'] != null
        ? (json['loadWeight'].toString().toLowerCase().contains('lb')
              ? json['loadWeight'].toString()
              : '${json['loadWeight']} lbs')
        : (json['weight'] != null
              ? '${json['weight']} lbs'
              : (json['quantity'] != null ? json['quantity'].toString() : '-'));
    final staging =
        json['stagingArea'] != null && json['stagingArea'].toString().isNotEmpty
        ? json['stagingArea'].toString()
        : (json['plant']?.toString().isNotEmpty == true
              ? json['plant'].toString()
              : '');

    String carrierName = 'Not Assigned';
    String carrierPhone = '';
    String driverName = '-';
    if (json['carrier'] != null) {
      if (json['carrier'] is Map) {
        final cMap = json['carrier'] as Map;
        carrierName =
            cMap['name']?.toString() ??
            cMap['carrierName']?.toString() ??
            cMap['company']?.toString() ??
            cMap['email'] ??
            'Carrier';
        carrierPhone = cMap['phone']?.toString() ?? '';
        driverName = cMap['driverName']?.toString() ?? '-';
      } else if (json['carrier'].toString().isNotEmpty) {
        carrierName = json['carrier'].toString();
      }
    }
    if (carrierPhone.isEmpty) {
      carrierPhone =
          (json['pickupContactPhone'] ??
                  json['pocPhone'] ??
                  json['phone'] ??
                  '')
              .toString();
    }

    final statusStr = json['status']?.toString().toLowerCase() ?? '';
    DeliveryStatus st = DeliveryStatus.ready;
    if (statusStr.contains('transit') || statusStr == 'loaded') {
      st = DeliveryStatus.inTransit;
    } else if (statusStr.contains('staged') || statusStr == 'confirmed') {
      st = DeliveryStatus.staged;
    } else if (statusStr.contains('delivered') ||
        statusStr.contains('received')) {
      st = DeliveryStatus.delivered;
    }

    final etaStr =
        json['eta']?.toString() ??
        json['deliveryTime']?.toString() ??
        json['timeWindow']?.toString() ??
        'ETA -';
    final schedule = json['schedule'] is Map
        ? json['schedule'] as Map
        : const {};
    final priority = switch (json['priority']?.toString().toLowerCase()) {
      'high' || 'urgent' => DeliveryPriority.high,
      'medium' => DeliveryPriority.medium,
      'low' => DeliveryPriority.low,
      _ => null,
    };

    return DeliveryItem(
      id: dId,
      realMongoId: mongoId,
      title: desc,
      location: loc,
      project: projName,
      jobId: jId,
      quantity: weight,
      stagingArea: staging,
      carrier: carrierName,
      driver: driverName,
      truck: (json['truck'] ?? json['vehicle'] ?? '-').toString(),
      phone: carrierPhone.isNotEmpty ? carrierPhone : '-',
      finalDestination: loc,
      arrivalAtPlant: _scheduleValue(
        json['arrivalAtPlant'] ?? json['arrivalTime'],
        schedule['pickupDate'],
        schedule['pickupTime'],
      ),
      departureFromPlant: _scheduleValue(
        json['departureFromPlant'] ?? json['departureTime'],
        schedule['deliveryDate'],
        schedule['deliveryTime'],
      ),
      notes: (json['notes'] ?? json['specialInstructions'] ?? '').toString(),
      status: st,
      priority: priority,
      eta: etaStr.startsWith('ETA') ? etaStr : 'ETA $etaStr',
      bundleCount:
          (json['packageCount'] as int?) ?? (json['bundleCount'] as int?) ?? 0,
    );
  }

  DeliveryItem copyWith({DeliveryStatus? status}) {
    return DeliveryItem(
      id: id,
      realMongoId: realMongoId,
      title: title,
      location: location,
      project: project,
      quantity: quantity,
      stagingArea: stagingArea,
      carrier: carrier,
      driver: driver,
      truck: truck,
      phone: phone,
      finalDestination: finalDestination,
      arrivalAtPlant: arrivalAtPlant,
      departureFromPlant: departureFromPlant,
      notes: notes,
      status: status ?? this.status,
      priority: priority,
      eta: eta,
      bundleCount: bundleCount,
    );
  }
}

String _scheduleValue(dynamic direct, dynamic date, dynamic time) {
  if (direct != null && direct.toString().isNotEmpty) return direct.toString();
  if (date == null || date.toString().isEmpty) return '-';
  final parsed = DateTime.tryParse(date.toString());
  final formattedDate = parsed == null
      ? date.toString()
      : DateFormat('MMM d, yyyy').format(parsed.toLocal());
  return time == null || time.toString().isEmpty
      ? formattedDate
      : '$formattedDate ${time.toString()}';
}
