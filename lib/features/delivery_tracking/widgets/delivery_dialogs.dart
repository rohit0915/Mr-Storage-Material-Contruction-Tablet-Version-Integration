import 'package:flutter/material.dart';
import '../../../app/constants/app_assets.dart';
import '../../../app/theme/app_colors.dart';
import '../models/delivery_tracking_models.dart';

// ─── Reusable helpers ────────────────────────────────────────────────────────

class _DialogBase extends StatelessWidget {
  const _DialogBase({required this.child, this.maxWidth = 640});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth.clamp(320, size.width * 0.85),
          maxHeight: size.height * 0.88,
        ),
        child: child,
      ),
    );
  }
}

Widget _closeButton(BuildContext context) => IconButton(
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
    );

class _SuccessPopup extends StatelessWidget {
  const _SuccessPopup({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: (size.width * 0.34).clamp(340.0, 440.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: (size.width * 0.016).clamp(18.0, 22.0),
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Image.asset(AppAssets.successCheck,
                  width: 96, height: 96, fit: BoxFit.contain),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ok',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showSuccess(BuildContext context, String title) =>
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SuccessPopup(title: title),
    );

// ─── Mark as Received ────────────────────────────────────────────────────────

class MarkReceivedDialog extends StatelessWidget {
  const MarkReceivedDialog({super.key, required this.item, required this.onConfirm});

  final DeliveryItem item;
  final VoidCallback onConfirm;

  static Future<void> show(
      BuildContext context, DeliveryItem item, VoidCallback onConfirm) =>
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => MarkReceivedDialog(item: item, onConfirm: onConfirm),
      );

  @override
  Widget build(BuildContext context) {
    return _ConfirmDialog(
      title: 'Marked Received',
      message: '',
      confirmLabel: 'Ok',
      confirmColor: AppColors.primaryBlue,
      onConfirm: () async {
        onConfirm();
      },
    );
  }
}

// ─── Mark as Partial Received ─────────────────────────────────────────────────

class MarkPartialDialog extends StatelessWidget {
  const MarkPartialDialog({super.key, required this.item, required this.onConfirm});

  final DeliveryItem item;
  final VoidCallback onConfirm;

  static Future<void> show(
      BuildContext context, DeliveryItem item, VoidCallback onConfirm) =>
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => MarkPartialDialog(item: item, onConfirm: onConfirm),
      );

  @override
  Widget build(BuildContext context) {
    return _ConfirmDialog(
      title: 'Mark as Partial\nReceived',
      message: '',
      confirmLabel: 'Ok',
      confirmColor: AppColors.primaryBlue,
      onConfirm: () async {
        onConfirm();
      },
    );
  }
}

// ─── Shared confirm dialog with success check image ───────────────────────────

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.title,
    required this.confirmColor,
    required this.onConfirm,
    this.message = '',
    this.confirmLabel = 'Ok',
  });

  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;
  final Future<void> Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: (size.width * 0.36).clamp(360.0, 460.0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: (size.width * 0.016).clamp(18.0, 22.0),
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              Image.asset(AppAssets.successCheck,
                  width: 110, height: 110, fit: BoxFit.contain),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Ok',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Scan QR Code ─────────────────────────────────────────────────────────────

class ScanQrDialog extends StatefulWidget {
  const ScanQrDialog({super.key, required this.item});

  final DeliveryItem item;

  static Future<void> show(BuildContext context, DeliveryItem item) =>
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => ScanQrDialog(item: item),
      );

  @override
  State<ScanQrDialog> createState() => _ScanQrDialogState();
}

class _ScanQrDialogState extends State<ScanQrDialog> {
  final _bundleController = TextEditingController(text: 'BND-001');
  bool _scanned = false;

  @override
  void dispose() {
    _bundleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final fontSize = (size.width * 0.010).clamp(12.0, 14.0);

    if (_scanned) return _ScanResultDialog(item: widget.item);

    return _DialogBase(
      maxWidth: 560,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Scan QR Code',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: (size.width * 0.015).clamp(18.0, 22.0),
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _closeButton(context),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
              label: const Text('Camera Scan',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Enter Bundle ID',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.textLabel,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bundleController,
              style: TextStyle(fontSize: fontSize, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. BND-001',
                filled: true,
                fillColor: AppColors.inputFill,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.cardBorder),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => _scanned = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Scan',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanResultDialog extends StatelessWidget {
  const _ScanResultDialog({required this.item});

  final DeliveryItem item;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final labelSize = (size.width * 0.009).clamp(11.0, 12.0);
    final valueSize = (size.width * 0.010).clamp(12.0, 13.0);

    final bundles = [
      {'id': 'BND-001', 'part': 'STL-B12 + 30', 'time': '10:22 AM', 'weight': '3800 lbs', 'status': 'Staged'},
      {'id': 'BND-002', 'part': 'STL-B13 + 31', 'time': '10:35 AM', 'weight': '2400 lbs', 'status': 'Pending'},
      {'id': 'BND-003', 'part': 'STL-B14', 'time': '10:48 AM', 'weight': '2100 lbs', 'status': 'Staged'},
    ];

    return _DialogBase(
      maxWidth: 720,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar: Back + action buttons
            Row(
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.arrow_back_ios_new_rounded,
                          size: 13, color: AppColors.textSecondary),
                      SizedBox(width: 4),
                      Text('Back',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    alignment: WrapAlignment.end,
                    children: [
                      _TopActionBtn(label: 'Download', icon: Icons.download_rounded),
                      _TopActionBtn(label: 'Reprint Label', icon: Icons.print_outlined),
                      _TopActionBtn(label: 'Report Mismatch', icon: Icons.warning_amber_rounded),
                      _TopActionBtn(label: 'Verify Bundle', icon: Icons.verified_outlined),
                      _TopActionBtn(label: 'Mark Loaded', icon: Icons.check_box_outlined),
                      _TopActionBtn(label: 'Mark Staged', icon: Icons.inventory_2_outlined),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Bundle info two-column grid
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bundle Information',
                          style: TextStyle(
                              fontSize: labelSize,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      _BundleInfoRow('Bundle ID', 'BND-001', labelSize),
                      _BundleInfoRow('Project', item.project, labelSize),
                      _BundleInfoRow('Load ID', 'LOAD-001', labelSize),
                      _BundleInfoRow('Truck', 'TX-9876', labelSize),
                      _BundleInfoRow('Destination', item.finalDestination, labelSize),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bundle Details',
                          style: TextStyle(
                              fontSize: labelSize,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      _BundleInfoRow('Parts', 'STL-B12', labelSize),
                      _BundleInfoRow('Quantity', '30', labelSize),
                      _BundleInfoRow('Weight', '36,000 lbs', labelSize),
                      _BundleInfoRow('Length', '20 ft', labelSize),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scanned QR Code section
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Scanned QR Code',
                          style: TextStyle(
                              fontSize: labelSize,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(AppAssets.qrCode,
                                width: 90, height: 90, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('project=${item.project}',
                                    style: TextStyle(
                                        fontSize: labelSize,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary)),
                                const SizedBox(height: 6),
                                _QrRow('Shipper', 'shipper=SHP-1044', labelSize, valueSize),
                                _QrRow('Load', 'load_id=LOAD-001', labelSize, valueSize),
                                _QrRow('Bundle', 'bundle_id=BND-001', labelSize, valueSize),
                                _QrRow('Parts', 'parts=STL-B12', labelSize, valueSize),
                                _QrRow('Weight', 'weight=3800', labelSize, valueSize),
                                _QrRow('Length', 'length=20', labelSize, valueSize),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Bundle Verification + Load Context
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bundle Verification Status',
                          style: TextStyle(
                              fontSize: labelSize,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Row(children: [
                        Text('Bundle assigned to load',
                            style: TextStyle(
                                fontSize: labelSize,
                                color: AppColors.textSecondary)),
                        const SizedBox(width: 6),
                        const Icon(Icons.check_rounded,
                            size: 16, color: AppColors.success),
                      ]),
                      const SizedBox(height: 14),
                      Text('Load Context Panel',
                          style: TextStyle(
                              fontSize: labelSize,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      _ContextRow('Load ID', 'LOAD-001', labelSize),
                      _ContextRow('Truck', 'TX-9876', labelSize),
                      _ContextRow('Driver', 'John Miller', labelSize),
                      _ContextRow('Total Bundles', '4', labelSize),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Bundle List',
                style: TextStyle(
                    fontSize: (size.width * 0.011).clamp(13.0, 15.0),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  Container(
                    color: AppColors.tableHeader,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    child: Row(children: [
                      bundleListHead('#', 1, labelSize),
                      bundleListHead('Bundle ID', 2, labelSize),
                      bundleListHead('Parts', 2, labelSize),
                      bundleListHead('Time', 2, labelSize),
                      bundleListHead('Weight', 2, labelSize),
                      bundleListHead('Status', 2, labelSize),
                    ]),
                  ),
                  ...bundles.asMap().entries.map((e) {
                    final idx = e.key;
                    final b = e.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: const BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: AppColors.cardBorder)),
                      ),
                      child: Row(children: [
                        bundleListCell('${idx + 1}', 1, labelSize),
                        bundleListCell(b['id']!, 2, labelSize,
                            bold: true, color: AppColors.textPrimary),
                        bundleListCell(b['part']!, 2, labelSize),
                        bundleListCell(b['time']!, 2, labelSize),
                        bundleListCell(b['weight']!, 2, labelSize),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: b['status'] == 'Staged'
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              b['status']!,
                              style: TextStyle(
                                fontSize: labelSize - 1,
                                fontWeight: FontWeight.w700,
                                color: b['status'] == 'Staged'
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                            ),
                          ),
                        ),
                      ]),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrRow extends StatelessWidget {
  const _QrRow(this.label, this.value, this.labelSize, this.valueSize);
  final String label, value;
  final double labelSize, valueSize;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          SizedBox(
            width: 56,
            child: Text('$label:',
                style: TextStyle(
                    fontSize: labelSize,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ),
          Text(value,
              style: TextStyle(
                  fontSize: valueSize,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700)),
        ]),
      );
}

class _ContextRow extends StatelessWidget {
  const _ContextRow(this.label, this.value, this.fontSize);
  final String label, value;
  final double fontSize;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(children: [
          SizedBox(
            width: 96,
            child: Text(label,
                style: TextStyle(
                    fontSize: fontSize, color: AppColors.textSecondary)),
          ),
          Text(value,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ]),
      );
}

Widget bundleListHead(String text, int flex, double size) => Expanded(
    flex: flex,
    child: Text(text,
        style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary)));

Widget bundleListCell(String text, int flex, double size,
        {bool bold = false, Color? color}) =>
    Expanded(
        flex: flex,
        child: Text(text,
            style: TextStyle(
                fontSize: size,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: color ?? AppColors.textSecondary)));

// ─── Update Site Contact ───────────────────────────────────────────────────────

class UpdateSiteContactDialog extends StatefulWidget {
  const UpdateSiteContactDialog({super.key, required this.item});
  final DeliveryItem item;

  static Future<void> show(BuildContext context, DeliveryItem item) =>
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => UpdateSiteContactDialog(item: item),
      );

  @override
  State<UpdateSiteContactDialog> createState() =>
      _UpdateSiteContactDialogState();
}

class _UpdateSiteContactDialogState extends State<UpdateSiteContactDialog> {
  final _hoursCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _hoursCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final labelSize = (size.width * 0.010).clamp(12.0, 14.0);

    return _DialogBase(
      maxWidth: 540,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Update Site Contact',
                        style: TextStyle(
                          fontSize: (size.width * 0.014).clamp(16.0, 20.0),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${widget.item.id} - ${widget.item.location}',
                        style: TextStyle(
                            fontSize: labelSize - 2,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                _closeButton(context),
              ],
            ),
            const SizedBox(height: 20),
            Text('Available hours',
                style: TextStyle(
                    fontSize: labelSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLabel)),
            const SizedBox(height: 6),
            TextField(
              controller: _hoursCtrl,
              style: TextStyle(fontSize: labelSize, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g., 7:00 AM – 5:00 PM, Mon-Fri',
                filled: true,
                fillColor: AppColors.inputFill,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            Text('Additional Notes',
                style: TextStyle(
                    fontSize: labelSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLabel)),
            const SizedBox(height: 6),
            TextField(
              controller: _notesCtrl,
              maxLines: 4,
              style: TextStyle(fontSize: labelSize, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Additional notes about this contact...',
                filled: true,
                fillColor: AppColors.inputFill,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.cardBorder),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    if (!context.mounted) return;
                    await _showSuccess(context, 'Contact saved!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Save Contact',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── View Details ─────────────────────────────────────────────────────────────

class ViewDetailsDialog extends StatelessWidget {
  const ViewDetailsDialog({super.key, required this.item});
  final DeliveryItem item;

  static Future<void> show(BuildContext context, DeliveryItem item) =>
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => ViewDetailsDialog(item: item),
      );

  static const _steps = [
    ('Scheduled', true),
    ('Material Prepared', true),
    ('Loaded', true),
    ('Picked Up', true),
    ('In Transit', true),
    ('Arrived at Plant', false),
    ('Staged', false),
    ('Dispatched to Site', false),
    ('Delivered', false),
  ];

  static Color _statusColor(DeliveryStatus s) => switch (s) {
        DeliveryStatus.inTransit => const Color(0xFF2563EB),
        DeliveryStatus.staged => const Color(0xFF22C55E),
        DeliveryStatus.ready => const Color(0xFFF97316),
        DeliveryStatus.delivered => const Color(0xFF6B7280),
      };

  static String _statusLabel(DeliveryStatus s) => switch (s) {
        DeliveryStatus.inTransit => 'In Transit to Plant',
        DeliveryStatus.staged => 'Staged at Plant',
        DeliveryStatus.ready => 'Ready for Departure',
        DeliveryStatus.delivered => 'Delivered',
      };

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final labelSize = (size.width * 0.009).clamp(11.0, 12.0);
    final valueSize = (size.width * 0.010).clamp(12.0, 13.0);
    final statusColor = _statusColor(item.status);

    return _DialogBase(
      maxWidth: 700,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7539FF).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(AppAssets.iconTruckGreen, fit: BoxFit.contain),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text('Delivery Details',
                            style: TextStyle(
                                fontSize: (size.width * 0.013).clamp(14.0, 18.0),
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary)),
                        const SizedBox(width: 8),
                        _PriorityBadge(priority: item.priority),
                      ]),
                      Text(item.id,
                          style: TextStyle(
                              fontSize: labelSize,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                _closeButton(context),
              ],
            ),
            const SizedBox(height: 16),
            // Status banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Current Status',
                      style: TextStyle(
                          fontSize: labelSize,
                          color: statusColor.withValues(alpha: 0.8))),
                  Text(_statusLabel(item.status),
                      style: TextStyle(
                          fontSize: (size.width * 0.013).clamp(14.0, 18.0),
                          fontWeight: FontWeight.w800,
                          color: statusColor)),
                ]),
                const Spacer(),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('Staging Area', style: TextStyle(fontSize: labelSize, color: AppColors.textSecondary)),
                  Text(item.stagingArea,
                      style: TextStyle(
                          fontSize: valueSize + 1,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                ]),
              ]),
            ),
            const SizedBox(height: 16),
            // Progress checklist
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FBFF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF9DBCF5)),
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                children: _steps.map((s) {
                  return Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      s.$2 ? Icons.check_rounded : Icons.radio_button_unchecked,
                      size: 14,
                      color: s.$2 ? AppColors.success : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(s.$1,
                        style: TextStyle(
                            fontSize: labelSize,
                            fontWeight: s.$2 ? FontWeight.w600 : FontWeight.w500,
                            color: s.$2
                                ? AppColors.textPrimary
                                : AppColors.textSecondary)),
                  ]);
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // Delivery flow
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder)),
              child: Row(
                children: [
                  _FlowNode(label: item.carrier, sublabel: 'Origin', color: AppColors.primaryBlue, iconData: Icons.local_shipping_outlined),
                  _FlowArrow(),
                  _FlowNode(label: item.stagingArea, sublabel: 'Plant Staging', color: AppColors.success, iconData: Icons.inventory_2_outlined),
                  _FlowArrow(),
                  _FlowNode(label: item.finalDestination, sublabel: 'Destination', color: AppColors.orange, iconData: Icons.location_on_outlined),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Info columns
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _InfoCol('Material Information', [
                  ('Material', item.title),
                  ('Project', item.project),
                  ('Quantity', item.quantity),
                ], labelSize, valueSize, icons: const [
                  Icons.inventory_2_outlined,
                  Icons.account_balance_outlined,
                  Icons.scale_outlined,
                ], iconBgs: const [
                  Color(0xFFF3E8FF),
                  Color(0xFFEFF6FF),
                  Color(0xFFFFF7ED),
                ], iconColors: const [
                  Color(0xFF9333EA),
                  Color(0xFF2563EB),
                  Color(0xFFF97316),
                ])),
                Expanded(child: _InfoCol('Plant Schedule', [
                  ('Arrival at Plant', item.arrivalAtPlant),
                  ('Departure from Plant', item.departureFromPlant),
                ], labelSize, valueSize, icons: const [
                  Icons.calendar_today_outlined,
                  Icons.event_available_outlined,
                ], iconBgs: const [
                  Color(0xFFECFDF3),
                  Color(0xFFFFF7ED),
                ], iconColors: const [
                  Color(0xFF22C55E),
                  Color(0xFFF97316),
                ])),
                Expanded(child: _InfoCol('Carrier & Route', [
                  ('Carrier', item.carrier),
                  ('First Destination', item.finalDestination),
                  ('Truck', item.truck),
                  ('Driver', item.driver),
                  ('Phone', item.phone),
                ], labelSize, valueSize, icons: const [
                  Icons.local_shipping_outlined,
                  Icons.location_on_outlined,
                  Icons.local_taxi_outlined,
                  Icons.person_outline,
                  Icons.phone_outlined,
                ], iconBgs: const [
                  Color(0xFFECFDF3),
                  Color(0xFFFFF1F2),
                  Color(0xFFEFF6FF),
                  Color(0xFFF8FAFC),
                  Color(0xFFF8FAFC),
                ], iconColors: const [
                  Color(0xFF22C55E),
                  Color(0xFFEF4444),
                  Color(0xFF2563EB),
                  Color(0xFF64748B),
                  Color(0xFF64748B),
                ])),
              ],
            ),
            const SizedBox(height: 16),
            // Weight / material type
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.cardBorder)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Weight Units + Material Type',
                            style: TextStyle(
                                fontSize: labelSize,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        Text('Quantity: ${item.quantity}',
                            style: TextStyle(
                                fontSize: labelSize,
                                color: AppColors.textSecondary)),
                        Text('Material Type: Structural Steel',
                            style: TextStyle(
                                fontSize: labelSize,
                                color: AppColors.textSecondary)),
                        Text('Packaging: Bundled Frame Components',
                            style: TextStyle(
                                fontSize: labelSize,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.cardBorder)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Documents',
                            style: TextStyle(
                                fontSize: labelSize,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _DocumentCard(
                                label: 'Packing list',
                                onTap: (ctx) async {
                                  if (!ctx.mounted) return;
                                  await _showSuccess(ctx, 'Packing List Downloaded');
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _DocumentCard(
                                label: 'Bill of loading',
                                onTap: (ctx) async {
                                  if (!ctx.mounted) return;
                                  await _showSuccess(ctx, 'Bill of Loading Downloaded');
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Special instructions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: const Color(0xFFFEFCE8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Special Instructions',
                      style: TextStyle(
                          fontSize: labelSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Text(item.notes,
                      style: TextStyle(
                          fontSize: labelSize,
                          color: const Color(0xFF92400E))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.cardBorder),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Close',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});
  final DeliveryPriority priority;
  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      DeliveryPriority.high => ('High Priority', const Color(0xFFEF4444)),
      DeliveryPriority.medium => ('Medium Priority', const Color(0xFFF59E0B)),
      DeliveryPriority.low => ('Low Priority', const Color(0xFF22C55E)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }
}

class _FlowNode extends StatelessWidget {
  const _FlowNode({
    required this.label,
    required this.sublabel,
    required this.color,
    this.iconData,
  });
  final String label, sublabel;
  final Color color;
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    final inner = iconData != null
        ? Icon(iconData, color: Colors.white, size: 20)
        : const Icon(Icons.circle, color: Colors.white, size: 10);

    return Column(children: [
      CircleAvatar(
        radius: 22,
        backgroundColor: color,
        child: inner,
      ),
      const SizedBox(height: 6),
      Text(sublabel,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      const SizedBox(height: 2),
      Text(label,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
    ]);
  }
}

class _FlowArrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Divider(thickness: 1.5, color: AppColors.cardBorder),
    );
  }
}

class _InfoCol extends StatelessWidget {
  const _InfoCol(
    this.title,
    this.rows,
    this.labelSize,
    this.valueSize, {
    this.icons = const [],
    this.iconBgs = const [],
    this.iconColors = const [],
  });
  final String title;
  final List<(String, String)> rows;
  final double labelSize, valueSize;
  final List<IconData> icons;
  final List<Color> iconBgs;
  final List<Color> iconColors;
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: TextStyle(
              fontSize: labelSize,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
      const SizedBox(height: 8),
      ...rows.asMap().entries.map((entry) {
            final index = entry.key;
            final r = entry.value;
            final icon =
                index < icons.length ? icons[index] : Icons.circle_outlined;
            final bg = index < iconBgs.length ? iconBgs[index] : AppColors.inputFill;
            final fg =
                index < iconColors.length ? iconColors[index] : AppColors.textSecondary;
            return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Container(
                width: 22,
                height: 22,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 12, color: fg),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: '${r.$1}\n',
                    style: TextStyle(
                        fontSize: labelSize - 1,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500),
                    children: [
                      TextSpan(
                        text: r.$2,
                        style: TextStyle(
                            fontSize: valueSize,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          );
          }),
    ]);
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.label,
    required this.onTap,
  });
  final String label;
  final void Function(BuildContext ctx) onTap;

  @override
  Widget build(BuildContext context) {
    final labelSize =
        (MediaQuery.sizeOf(context).width * 0.009).clamp(11.0, 12.0);
    return InkWell(
      onTap: () => onTap(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: labelSize, color: AppColors.textSecondary)),
            ),
            const SizedBox(width: 6),
            Icon(Icons.download_rounded, size: 17, color: AppColors.primaryBlue),
          ],
        ),
      ),
    );
  }
}

// ─── Small helpers ────────────────────────────────────────────────────────────

class _TopActionBtn extends StatelessWidget {
  const _TopActionBtn({required this.label, required this.icon});
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final fontSize =
        (MediaQuery.sizeOf(context).width * 0.008).clamp(10.0, 11.0);
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 12, color: Colors.white),
      label: Text(label,
          style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}

class _BundleInfoRow extends StatelessWidget {
  const _BundleInfoRow(this.label, this.value, this.fontSize);
  final String label, value;
  final double fontSize;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        SizedBox(
          width: 90,
          child: Text(label,
              style: TextStyle(
                  fontSize: fontSize, color: AppColors.textSecondary)),
        ),
        Expanded(
          child: Text(value,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ),
      ]),
    );
  }
}
