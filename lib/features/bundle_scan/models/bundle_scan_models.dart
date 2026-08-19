enum BundleScanStatus { staging, ready, pending }

class BundleScanItem {
  const BundleScanItem({
    required this.id,
    required this.bundleId,
    required this.project,
    required this.site,
    required this.parts,
    required this.totalWeight,
    required this.time,
    required this.status,
  });

  final String id;
  final String bundleId;
  final String project;
  final String site;
  final String parts;
  final String totalWeight;
  final String time;
  final BundleScanStatus status;

  BundleScanItem copyWith({BundleScanStatus? status}) => BundleScanItem(
        id: id,
        bundleId: bundleId,
        project: project,
        site: site,
        parts: parts,
        totalWeight: totalWeight,
        time: time,
        status: status ?? this.status,
      );
}
