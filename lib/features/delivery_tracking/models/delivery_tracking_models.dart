enum DeliveryStatus {
  inTransit,
  staged,
  ready,
  delivered,
}

enum DeliveryPriority { high, medium, low }

class DeliveryItem {
  const DeliveryItem({
    required this.id,
    this.realMongoId = '',
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
  final DeliveryPriority priority;
  final String eta;
  final int bundleCount;

  factory DeliveryItem.fromJson(Map<String, dynamic> json) {
    final mongoId = (json['deliveryId'] ?? json['_id'] ?? '').toString();
    final dId = (json['deliveryNumber'] ?? mongoId).toString();
    final desc = json['description'] != null && json['description'].toString().isNotEmpty
        ? json['description'].toString()
        : (json['materialType'] ?? 'Material Delivery').toString();
    final loc = json['deliveryLocation'] != null && json['deliveryLocation'].toString().isNotEmpty
        ? json['deliveryLocation'].toString()
        : 'Location';

    String projName = 'Project';
    if (json['project'] is Map) {
      projName = json['project']['projectName'] ?? json['project']['jobId'] ?? 'Project';
    }

    final weight = json['loadWeight'] != null ? '${json['loadWeight']} lbs' : '45,000 lbs';
    final staging = json['stagingArea'] != null && json['stagingArea'].toString().isNotEmpty
        ? json['stagingArea'].toString()
        : 'Yard-A';

    String carrierName = 'Carrier';
    String carrierPhone = '';
    if (json['carrier'] is Map) {
      carrierName = json['carrier']['email'] ?? json['carrier']['driverName'] ?? 'Carrier';
      carrierPhone = json['carrier']['phone'] ?? '';
    }

    final statusStr = json['status']?.toString().toLowerCase() ?? 'scheduled';
    DeliveryStatus st = DeliveryStatus.ready;
    if (statusStr.contains('transit')) {
      st = DeliveryStatus.inTransit;
    } else if (statusStr.contains('staged')) {
      st = DeliveryStatus.staged;
    } else if (statusStr.contains('delivered') || statusStr.contains('received')) {
      st = DeliveryStatus.delivered;
    }

    return DeliveryItem(
      id: dId,
      realMongoId: mongoId,
      title: desc,
      location: loc,
      project: projName,
      quantity: weight,
      stagingArea: staging,
      carrier: carrierName,
      driver: 'John Miller',
      truck: 'TX-4582',
      phone: carrierPhone.isNotEmpty ? carrierPhone : '+1 555-812-9921',
      finalDestination: loc,
      arrivalAtPlant: '10:00 AM',
      departureFromPlant: '02:00 PM',
      notes: (json['notes'] ?? 'Standard handling').toString(),
      status: st,
      priority: DeliveryPriority.high,
      eta: 'ETA 10:45 AM',
      bundleCount: (json['packageCount'] as int?) ?? 4,
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
