enum PackingListStatus { loading, ready, pending }

class PackingListItem {
  const PackingListItem({
    required this.id,
    required this.packingListId,
    required this.loadId,
    required this.truck,
    required this.bundles,
    required this.totalWeight,
    required this.destination,
    required this.status,
    this.isSelected = false,
  });

  final String id;
  final String packingListId;
  final String loadId;
  final String truck;
  final int bundles;
  final String totalWeight;
  final String destination;
  final PackingListStatus status;
  final bool isSelected;

  PackingListItem copyWith({
    String? id,
    String? packingListId,
    String? loadId,
    String? truck,
    int? bundles,
    String? totalWeight,
    String? destination,
    PackingListStatus? status,
    bool? isSelected,
  }) {
    return PackingListItem(
      id: id ?? this.id,
      packingListId: packingListId ?? this.packingListId,
      loadId: loadId ?? this.loadId,
      truck: truck ?? this.truck,
      bundles: bundles ?? this.bundles,
      totalWeight: totalWeight ?? this.totalWeight,
      destination: destination ?? this.destination,
      status: status ?? this.status,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
