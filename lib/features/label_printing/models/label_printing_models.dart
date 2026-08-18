enum LabelPrintStatus { pending, printed }

class LabelBundleItem {
  const LabelBundleItem({
    required this.id,
    required this.loadId,
    required this.part,
    required this.totalWeightLbs,
    required this.lengthFt,
    required this.status,
    required this.project,
    required this.shipper,
  });

  final String id;
  final String loadId;
  final String part;
  final int totalWeightLbs;
  final int lengthFt;
  final LabelPrintStatus status;
  final String project;
  final String shipper;

  LabelBundleItem copyWith({LabelPrintStatus? status}) {
    return LabelBundleItem(
      id: id,
      loadId: loadId,
      part: part,
      totalWeightLbs: totalWeightLbs,
      lengthFt: lengthFt,
      status: status ?? this.status,
      project: project,
      shipper: shipper,
    );
  }
}
