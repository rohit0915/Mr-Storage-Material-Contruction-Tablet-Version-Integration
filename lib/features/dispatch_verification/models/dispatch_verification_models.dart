enum DispatchStatus { pending, verified }

class DispatchItem {
  const DispatchItem({
    required this.loadId,
    required this.truck,
    required this.driver,
    required this.bundles,
    required this.totalWeight,
    required this.destination,
    required this.status,
    this.isSelected = false,
  });

  final String loadId;
  final String truck;
  final String driver;
  final int bundles;
  final String totalWeight;
  final String destination;
  final DispatchStatus status;
  final bool isSelected;
}
