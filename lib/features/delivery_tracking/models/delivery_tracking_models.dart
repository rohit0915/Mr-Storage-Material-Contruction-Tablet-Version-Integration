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

  DeliveryItem copyWith({DeliveryStatus? status}) {
    return DeliveryItem(
      id: id,
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
