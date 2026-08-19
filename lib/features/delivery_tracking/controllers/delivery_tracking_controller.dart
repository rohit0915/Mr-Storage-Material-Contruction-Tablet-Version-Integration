import 'package:get/get.dart';

import '../models/delivery_tracking_models.dart';

class DeliveryTrackingController extends GetxController {
  final deliveries = <DeliveryItem>[
    const DeliveryItem(
      id: 'DEL-2001',
      title: 'Primary Frame Steel',
      location: 'ABC Logistics Warehouse',
      project: 'Riverside Complex',
      quantity: '45,000 lbs',
      stagingArea: 'Yard-A',
      carrier: 'FastFreight Logistics',
      driver: 'John Miller',
      truck: 'TX-4582',
      phone: '+1 555-812-9921',
      finalDestination: 'Construction Site A',
      arrivalAtPlant: 'Mar 24, 10:00 AM',
      departureFromPlant: 'Mar 24, 02:00 PM',
      notes: 'Fragile – handle with care',
      status: DeliveryStatus.inTransit,
      priority: DeliveryPriority.high,
      eta: 'ETA 10:45 AM',
      bundleCount: 4,
    ),
    const DeliveryItem(
      id: 'DEL-2002',
      title: 'Glass Panels',
      location: 'Downtown Office Complex',
      project: 'Downtown Office Complex',
      quantity: '8,500 lbs',
      stagingArea: 'Warehouse-2',
      carrier: 'Regional Freight',
      driver: 'John Miller',
      truck: 'TX-4582',
      phone: '+1 555-812-9921',
      finalDestination: 'Construction Site B',
      arrivalAtPlant: 'Mar 24, 08:00 AM',
      departureFromPlant: 'Mar 24, 11:00 AM',
      notes: 'Fragile – handle with care',
      status: DeliveryStatus.staged,
      priority: DeliveryPriority.medium,
      eta: 'Arrives 30 minutes',
      bundleCount: 3,
    ),
    const DeliveryItem(
      id: 'DEL-2003',
      title: 'Concrete Blocks',
      location: 'Industrial Park Phase 2',
      project: 'Industrial Park Phase 2',
      quantity: '15,000 lbs',
      stagingArea: 'Yard-B',
      carrier: 'Local Delivery Services',
      driver: 'John Miller',
      truck: 'TX-4582',
      phone: '+1 555-812-9921',
      finalDestination: 'Construction Site C',
      arrivalAtPlant: 'Mar 25, 09:00 AM',
      departureFromPlant: 'Mar 25, 05:00 PM',
      notes: 'Standard handling',
      status: DeliveryStatus.ready,
      priority: DeliveryPriority.low,
      eta: 'Scheduled',
      bundleCount: 2,
    ),
  ].obs;

  int get inTransitCount =>
      deliveries.where((d) => d.status == DeliveryStatus.inTransit).length;
  int get stagedCount =>
      deliveries.where((d) => d.status == DeliveryStatus.staged).length;
  int get readyCount =>
      deliveries.where((d) => d.status == DeliveryStatus.ready).length;
  int get totalToday => deliveries.length + 1;

  void markReceived(String id) {
    final idx = deliveries.indexWhere((d) => d.id == id);
    if (idx >= 0) {
      deliveries[idx] = deliveries[idx].copyWith(status: DeliveryStatus.delivered);
    }
  }

  void markPartialReceived(String id) {
    final idx = deliveries.indexWhere((d) => d.id == id);
    if (idx >= 0) {
      deliveries[idx] = deliveries[idx].copyWith(status: DeliveryStatus.staged);
    }
  }
}
