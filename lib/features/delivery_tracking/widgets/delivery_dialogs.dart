import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/constants/app_assets.dart';
import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/utils/app_toast.dart';
import '../controllers/delivery_tracking_controller.dart';
import '../models/delivery_tracking_models.dart';
import '../services/delivery_tracking_service.dart';
import '../../bundle_scan/widgets/scanner_dialog.dart';

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
              Image.asset(
                AppAssets.successCheck,
                width: 96,
                height: 96,
                fit: BoxFit.contain,
              ),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ok',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
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
  const MarkReceivedDialog({
    super.key,
    required this.item,
    required this.onConfirm,
  });

  final DeliveryItem item;
  final VoidCallback onConfirm;

  static Future<void> show(
    BuildContext context,
    DeliveryItem item,
    VoidCallback onConfirm,
  ) => showDialog<void>(
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

class MarkPartialDialog extends StatefulWidget {
  const MarkPartialDialog({
    super.key,
    required this.item,
    required this.onConfirm,
  });

  final DeliveryItem item;
  final Function(String) onConfirm;

  static Future<void> show(
    BuildContext context,
    DeliveryItem item,
    Function(String) onConfirm,
  ) => showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => MarkPartialDialog(item: item, onConfirm: onConfirm),
  );

  @override
  State<MarkPartialDialog> createState() => _MarkPartialDialogState();
}

class _MarkPartialDialogState extends State<MarkPartialDialog> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DialogBase(
      maxWidth: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Mark Delivery Partial',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: (MediaQuery.sizeOf(context).width * 0.015).clamp(18.0, 22.0),
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _closeButton(context),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'ID: ${widget.item.id}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Notes / Reason',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 4,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter reason for partial delivery...',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.cardBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: const Color(0xFFD1D5DB), // Light gray cancel
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'CANCEL',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await widget.onConfirm(_notesController.text);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF4F46E5), // Indigo blue
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'CONFIRM',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
              Image.asset(
                AppAssets.successCheck,
                width: 110,
                height: 110,
                fit: BoxFit.contain,
              ),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ok',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
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
  final _bundleController = TextEditingController();

  @override
  void dispose() {
    _bundleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final fontSize = (size.width * 0.010).clamp(12.0, 14.0);

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
              onPressed: () async {
                final scanned = await ScannerDialog.show(context);
                if (scanned != null && scanned.isNotEmpty && mounted) {
                  setState(() {
                    _bundleController.text = scanned;
                  });
                }
              },
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
              label: const Text(
                'Camera Scan',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: fontSize,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. BND-001',
                filled: true,
                fillColor: AppColors.inputFill,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (Get.isRegistered<DeliveryTrackingController>()) {
                        final success =
                            await Get.find<DeliveryTrackingController>()
                                .scanQrCode(
                                  _bundleController.text.trim(),
                                  projectId: widget.item.projectMongoId.isNotEmpty ? widget.item.projectMongoId : widget.item.project,
                                );
                        if (!success || !mounted) return;
                      }
                      if (!mounted) return;
                      Navigator.of(this.context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Scan',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
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

class ScanResultDialog extends StatelessWidget {
  const ScanResultDialog({super.key, required this.item});

  final DeliveryItem item;

  static Future<void> show(BuildContext context, DeliveryItem item) =>
      showDialog<void>(
        context: context,
        builder: (_) => ScanResultDialog(item: item),
      );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final labelSize = (size.width * 0.009).clamp(11.0, 12.0);
    final valueSize = (size.width * 0.010).clamp(12.0, 13.0);

    final bundles = <Map<String, String>>[];

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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _TopActionBtn(
                          label: 'Download',
                          icon: Icons.download_rounded,
                        ),
                        const SizedBox(width: 6),
                        _TopActionBtn(
                          label: 'Reprint Label',
                          icon: Icons.print_outlined,
                        ),
                        const SizedBox(width: 6),
                        _TopActionBtn(
                          label: 'Report Mismatch',
                          icon: Icons.warning_amber_rounded,
                        ),
                        const SizedBox(width: 6),
                        _TopActionBtn(
                          label: 'Verify Bundle',
                          icon: Icons.verified_outlined,
                        ),
                        const SizedBox(width: 6),
                        _TopActionBtn(
                          label: 'Mark Loaded',
                          icon: Icons.check_box_outlined,
                        ),
                        const SizedBox(width: 6),
                        _TopActionBtn(
                          label: 'Mark Staged',
                          icon: Icons.inventory_2_outlined,
                        ),
                      ],
                    ),
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
                      Text(
                        'Bundle Information',
                        style: TextStyle(
                          fontSize: labelSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _BundleInfoRow('Bundle ID', '', labelSize),
                      _BundleInfoRow('Project', item.project, labelSize),
                      _BundleInfoRow('Load ID', '', labelSize),
                      _BundleInfoRow('Truck', '', labelSize),
                      _BundleInfoRow(
                        'Destination',
                        item.finalDestination,
                        labelSize,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bundle Details',
                        style: TextStyle(
                          fontSize: labelSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _BundleInfoRow('Parts', '', labelSize),
                      _BundleInfoRow('Quantity', '', labelSize),
                      _BundleInfoRow('Weight', '', labelSize),
                      _BundleInfoRow('Length', '', labelSize),
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
                      Text(
                        'Scanned QR Code',
                        style: TextStyle(
                          fontSize: labelSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              AppAssets.qrCode,
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'project=${item.project}',
                                  style: TextStyle(
                                    fontSize: labelSize,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _QrRow(
                                  'Shipper',
                                  'shipper=SHP-1044',
                                  labelSize,
                                  valueSize,
                                ),
                                _QrRow('Load', '', labelSize, valueSize),
                                _QrRow('Bundle', '', labelSize, valueSize),
                                _QrRow('Parts', '', labelSize, valueSize),
                                _QrRow('Weight', '', labelSize, valueSize),
                                _QrRow('Length', '', labelSize, valueSize),
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
                      Text(
                        'Bundle Verification Status',
                        style: TextStyle(
                          fontSize: labelSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Bundle assigned to load',
                            style: TextStyle(
                              fontSize: labelSize,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: AppColors.success,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Load Context Panel',
                        style: TextStyle(
                          fontSize: labelSize,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _ContextRow('Load ID', '', labelSize),
                      _ContextRow('Truck', '', labelSize),
                      _ContextRow('Driver', '', labelSize),
                      _ContextRow('Total Bundles', '', labelSize),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Bundle List',
              style: TextStyle(
                fontSize: (size.width * 0.011).clamp(13.0, 15.0),
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
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
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        bundleListHead('#', 1, labelSize),
                        bundleListHead('Bundle ID', 2, labelSize),
                        bundleListHead('Parts', 2, labelSize),
                        bundleListHead('Time', 2, labelSize),
                        bundleListHead('Weight', 2, labelSize),
                        bundleListHead('Status', 2, labelSize),
                      ],
                    ),
                  ),
                  ...bundles.asMap().entries.map((e) {
                    final idx = e.key;
                    final b = e.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.cardBorder),
                        ),
                      ),
                      child: Row(
                        children: [
                          bundleListCell('${idx + 1}', 1, labelSize),
                          bundleListCell(
                            b['id']!,
                            2,
                            labelSize,
                            bold: true,
                            color: AppColors.textPrimary,
                          ),
                          bundleListCell(b['part']!, 2, labelSize),
                          bundleListCell(b['time']!, 2, labelSize),
                          bundleListCell(b['weight']!, 2, labelSize),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
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
                        ],
                      ),
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
    child: Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: labelSize,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: valueSize,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _ContextRow extends StatelessWidget {
  const _ContextRow(this.label, this.value, this.fontSize);
  final String label, value;
  final double fontSize;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    ),
  );
}

Widget bundleListHead(String text, int flex, double size) => Expanded(
  flex: flex,
  child: Text(
    text,
    style: TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: AppColors.textSecondary,
    ),
  ),
);

Widget bundleListCell(
  String text,
  int flex,
  double size, {
  bool bold = false,
  Color? color,
}) => Expanded(
  flex: flex,
  child: Text(
    text,
    style: TextStyle(
      fontSize: size,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      color: color ?? AppColors.textSecondary,
    ),
  ),
);

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
  final _nameCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _titleCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _hoursCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return _DialogBase(
      maxWidth: 580,
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
                          fontSize: (size.width * 0.015).clamp(18.0, 22.0),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.item.id} - ${widget.item.location}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _closeButton(context),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Contact Name'),
                      _textField(_nameCtrl, 'Enter contact name'),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Contact Title'),
                      _textField(_titleCtrl, 'Enter job title'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Phone number'),
                      _textField(_phoneCtrl, '(555) 123-4567', keyboardType: TextInputType.phone),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Email Address'),
                      _textField(_emailCtrl, 'contact@company.com', keyboardType: TextInputType.emailAddress),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _fieldLabel('Available hours'),
            _textField(_hoursCtrl, 'e.g., 7:00 AM - 5:00 PM, Mon-Fri'),
            const SizedBox(height: 14),
            _fieldLabel('Additional Notes'),
            _textField(
              _notesCtrl,
              'Additional notes about this contact...',
              maxLines: 3,
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.cardBorder),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    if (Get.isRegistered<DeliveryTrackingController>()) {
                      Get.find<DeliveryTrackingController>()
                          .updateSiteContact(widget.item.id, {
                            'name': _nameCtrl.text.trim(),
                            'title': _titleCtrl.text.trim(),
                            'phone': _phoneCtrl.text.trim(),
                            'email': _emailCtrl.text.trim(),
                            'hours': _hoursCtrl.text.trim(),
                            'notes': _notesCtrl.text.trim(),
                          });
                    }
                    Navigator.of(context).pop();
                    if (!context.mounted) return;
                    await _showSuccess(context, 'Contact saved!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Save Contact',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: AppColors.textPrimary,
      ),
    ),
  );

  Widget _textField(
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) => TextField(
    controller: ctrl,
    maxLines: maxLines,
    keyboardType: keyboardType,
    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
    ),
  );
}

// ─── Update Readiness Date ───────────────────────────────────────────────────

class UpdateReadinessDateDialog extends StatefulWidget {
  const UpdateReadinessDateDialog({super.key, required this.item});
  final DeliveryItem item;

  static Future<void> show(BuildContext context, DeliveryItem item) =>
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => UpdateReadinessDateDialog(item: item),
      );

  @override
  State<UpdateReadinessDateDialog> createState() =>
      _UpdateReadinessDateDialogState();
}

class _UpdateReadinessDateDialogState extends State<UpdateReadinessDateDialog> {
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  String _reason = 'Production Delay';

  @override
  void dispose() {
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return _DialogBase(
      maxWidth: 580,
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
                        'Update Readiness Date',
                        style: TextStyle(
                          fontSize: (size.width * 0.015).clamp(18.0, 22.0),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.item.id} - ${widget.item.title}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _closeButton(context),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: RichText(
                text: const TextSpan(
                  text: 'Current Scheduled Departure: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: 'Tuesday, March 24, 2026 at 02:00 PM',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('New Readiness Date'),
                      TextField(
                        controller: _dateCtrl,
                        decoration: _inputDecoration('dd-mm-yyy'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Ready Time'),
                      TextField(
                        controller: _timeCtrl,
                        decoration: _inputDecoration('--:--'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _fieldLabel('Reason for change'),
            DropdownButtonFormField<String>(
              key: ValueKey(_reason),
              initialValue: _reason,
              isExpanded: true,
              decoration: _inputDecoration('Select Reason'),
              items: const [
                DropdownMenuItem(
                  value: 'Production Delay',
                  child: Text('Production Delay'),
                ),
                DropdownMenuItem(
                  value: 'Weather Condition',
                  child: Text('Weather Condition'),
                ),
                DropdownMenuItem(
                  value: 'Transport Issue',
                  child: Text('Transport Issue'),
                ),
              ],
              onChanged: (v) => setState(() => _reason = v!),
            ),
            const SizedBox(height: 14),
            _fieldLabel('Additional details'),
            TextField(
              controller: _detailsCtrl,
              maxLines: 3,
              decoration: _inputDecoration(
                'Provide details about why the readiness data is changing...',
              ),
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.cardBorder),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    if (!context.mounted) return;
                    await _showSuccess(context, 'Readiness Date Updated!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Update',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: AppColors.textPrimary,
      ),
    ),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.cardBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.cardBorder),
    ),
  );
}

// ─── Update Pickup Instructions ──────────────────────────────────────────────

class UpdatePickupInstructionsDialog extends StatefulWidget {
  const UpdatePickupInstructionsDialog({super.key, required this.item});
  final DeliveryItem item;

  static Future<void> show(BuildContext context, DeliveryItem item) =>
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => UpdatePickupInstructionsDialog(item: item),
      );

  @override
  State<UpdatePickupInstructionsDialog> createState() =>
      _UpdatePickupInstructionsDialogState();
}

class _UpdatePickupInstructionsDialogState
    extends State<UpdatePickupInstructionsDialog> {
  final _locationCtrl = TextEditingController();
  final _accessCtrl = TextEditingController();
  final _loadingCtrl = TextEditingController();

  @override
  void dispose() {
    _locationCtrl.dispose();
    _accessCtrl.dispose();
    _loadingCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return _DialogBase(
      maxWidth: 580,
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
                        'Update Pickup Instructions',
                        style: TextStyle(
                          fontSize: (size.width * 0.015).clamp(18.0, 22.0),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.item.id} - ${widget.item.title}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _closeButton(context),
              ],
            ),
            const SizedBox(height: 18),
            _fieldLabel('Pickup Location Details *'),
            TextField(
              controller: _locationCtrl,
              decoration: _inputDecoration('Enter pickup location'),
            ),
            const SizedBox(height: 14),
            _fieldLabel('Access Instructions'),
            TextField(
              controller: _accessCtrl,
              maxLines: 3,
              decoration: _inputDecoration(
                'Enter gate codes, access routes, parking instructions etc.',
              ),
            ),
            const SizedBox(height: 14),
            _fieldLabel('Loading Requirements'),
            TextField(
              controller: _loadingCtrl,
              decoration: _inputDecoration('Requires forklift for unloading'),
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.cardBorder),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    if (!context.mounted) return;
                    await _showSuccess(context, 'Instructions Saved!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: AppColors.textPrimary,
      ),
    ),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.cardBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.cardBorder),
    ),
  );
}

// ─── View Details ─────────────────────────────────────────────────────────────

class ViewDetailsDialog extends StatefulWidget {
  const ViewDetailsDialog({super.key, required this.item});
  final DeliveryItem item;

  static Future<void> show(BuildContext context, DeliveryItem item) =>
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => ViewDetailsDialog(item: item),
      );

  @override
  State<ViewDetailsDialog> createState() => _ViewDetailsDialogState();
}

class _ViewDetailsDialogState extends State<ViewDetailsDialog> {
  bool _isDownloadingPackingList = false;
  bool _isDownloadingBol = false;

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

  Future<void> _downloadPackingList() async {
    if (_isDownloadingPackingList) return;
    setState(() => _isDownloadingPackingList = true);
    try {
      final deliveryId = widget.item.realMongoId.isNotEmpty
          ? widget.item.realMongoId
          : widget.item.id;
      final service = Get.isRegistered<DeliveryTrackingService>()
          ? Get.find<DeliveryTrackingService>()
          : Get.put(DeliveryTrackingService());

      final bytes = await service.downloadPackingListBytes(deliveryId);
      if (bytes != null && bytes.isNotEmpty) {
        final fileName = '${widget.item.id}_packing_list.pdf';
        final savedPath = await file_picker.FilePicker.saveFile(
          dialogTitle: 'Save Packing List',
          fileName: fileName,
          type: file_picker.FileType.custom,
          allowedExtensions: ['pdf'],
          bytes: bytes,
        );
        if (savedPath != null) {
          AppToast.showSuccess(
            title: 'Packing List Saved',
            description: 'Saved to $savedPath',
          );
        }
      } else {
        AppToast.showError(
          title: 'Download Failed',
          description: 'Could not fetch Packing List document.',
        );
      }
    } catch (e) {
      AppToast.showError(
        title: 'Download Failed',
        description: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _isDownloadingPackingList = false);
    }
  }

  Future<void> _downloadBillOfLading() async {
    if (_isDownloadingBol) return;
    setState(() => _isDownloadingBol = true);
    try {
      final deliveryId = widget.item.realMongoId.isNotEmpty
          ? widget.item.realMongoId
          : widget.item.id;
      final service = Get.isRegistered<DeliveryTrackingService>()
          ? Get.find<DeliveryTrackingService>()
          : Get.put(DeliveryTrackingService());

      final bytes = await service.downloadBillOfLadingBytes(deliveryId);
      if (bytes != null && bytes.isNotEmpty) {
        final fileName = '${widget.item.id}_bill_of_lading.pdf';
        final savedPath = await file_picker.FilePicker.saveFile(
          dialogTitle: 'Save Bill of Lading',
          fileName: fileName,
          type: file_picker.FileType.custom,
          allowedExtensions: ['pdf'],
          bytes: bytes,
        );
        if (savedPath != null) {
          AppToast.showSuccess(
            title: 'Bill of Lading Saved',
            description: 'Saved to $savedPath',
          );
        }
      } else {
        AppToast.showError(
          title: 'Download Failed',
          description: 'Could not fetch Bill of Lading document.',
        );
      }
    } catch (e) {
      AppToast.showError(
        title: 'Download Failed',
        description: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _isDownloadingBol = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final size = MediaQuery.sizeOf(context);
    final labelSize = (size.width * 0.009).clamp(11.0, 12.0);
    final valueSize = (size.width * 0.010).clamp(12.0, 13.0);
    final statusColor = _statusColor(item.status);

    return _DialogBase(
      maxWidth: 720,
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
                  child: Image.asset(
                    AppAssets.iconTruckGreen,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Delivery Details',
                            style: TextStyle(
                              fontSize: (size.width * 0.013).clamp(14.0, 18.0),
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (item.priority != null) ...[
                            const SizedBox(width: 8),
                            _PriorityBadge(priority: item.priority!),
                          ],
                        ],
                      ),
                      Text(
                        item.id,
                        style: TextStyle(
                          fontSize: labelSize,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    Get.toNamed(
                      AppRoutes.deliveryDetails,
                      arguments: {
                        'id': item.realMongoId.isNotEmpty
                            ? item.realMongoId
                            : item.id,
                        'deliveryId': item.id,
                        'item': item,
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.open_in_new_rounded,
                          size: 13,
                          color: Color(0xFF2563EB),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Full Page',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
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
                color: switch (item.status) {
                  DeliveryStatus.inTransit => const Color(0xFFEFF6FF),
                  DeliveryStatus.staged => const Color(0xFFF0FDF4),
                  DeliveryStatus.ready => const Color(0xFFFFF7ED),
                  DeliveryStatus.delivered => const Color(0xFFF9FAFB),
                },
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: switch (item.status) {
                    DeliveryStatus.inTransit => const Color(0xFF2563EB),
                    DeliveryStatus.staged => const Color(0xFF22C55E),
                    DeliveryStatus.ready => const Color(0xFFF97316),
                    DeliveryStatus.delivered => const Color(0xFF9CA3AF),
                  },
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Current Status',
                            style: TextStyle(
                              fontSize: labelSize,
                              color: statusColor.withValues(alpha: 0.8),
                            ),
                          ),
                          if (item.status == DeliveryStatus.inTransit) ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '🟡 ETA 10:45 AM',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _statusLabel(item.status),
                        style: TextStyle(
                          fontSize: (size.width * 0.015).clamp(16.0, 20.0),
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Staging Area',
                        style: TextStyle(
                          fontSize: labelSize,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        item.stagingArea.isNotEmpty
                            ? item.stagingArea
                            : 'Plant Yard',
                        style: TextStyle(
                          fontSize: valueSize + 2,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        s.$2
                            ? Icons.check_rounded
                            : Icons.radio_button_unchecked,
                        size: 14,
                        color: s.$2
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        s.$1,
                        style: TextStyle(
                          fontSize: labelSize,
                          fontWeight: s.$2 ? FontWeight.w600 : FontWeight.w500,
                          color: s.$2
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // ─── RED BOX 1: Delivery Flow & Route ───
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.route_outlined,
                        size: 15,
                        color: Color(0xFF2563EB),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'DELIVERY FLOW & ROUTE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Icons row with connecting arrows
                  Row(
                    children: [
                      _buildFlowCircle(
                        icon: Icons.local_shipping_outlined,
                        color: const Color(0xFF2563EB),
                        bgColor: const Color(0xFFEFF6FF),
                      ),
                      Expanded(child: _buildRouteConnector()),
                      _buildFlowCircle(
                        icon: Icons.inventory_2_outlined,
                        color: const Color(0xFF16A34A),
                        bgColor: const Color(0xFFDCFCE7),
                      ),
                      Expanded(child: _buildRouteConnector()),
                      _buildFlowCircle(
                        icon: Icons.location_on_outlined,
                        color: const Color(0xFFEA580C),
                        bgColor: const Color(0xFFFFEDD5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Labels row: 3 equal-width columns
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildRouteLabel(
                          badge: 'ORIGIN',
                          badgeColor: const Color(0xFF2563EB),
                          title: item.carrier.isNotEmpty
                              ? item.carrier
                              : 'Dispatch Facility',
                          subtitle: 'Carrier Origin',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildRouteLabel(
                          badge: 'PLANT STAGING',
                          badgeColor: const Color(0xFF16A34A),
                          title: item.stagingArea.isNotEmpty
                              ? item.stagingArea
                              : 'Plant Yard',
                          subtitle: 'Staging & QA',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildRouteLabel(
                          badge: 'DESTINATION',
                          badgeColor: const Color(0xFFEA580C),
                          title: item.finalDestination.isNotEmpty
                              ? item.finalDestination
                              : (item.location.isNotEmpty
                                  ? item.location
                                  : 'Project Site'),
                          subtitle: 'Final Drop-off',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Info columns
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _InfoCol(
                    'Material Information',
                    [
                      ('Material', item.title),
                      ('Project', item.project),
                      ('Quantity', item.quantity),
                    ],
                    labelSize,
                    valueSize,
                    icons: const [
                      Icons.inventory_2_outlined,
                      Icons.account_balance_outlined,
                      Icons.scale_outlined,
                    ],
                    iconBgs: const [
                      Color(0xFFF3E8FF),
                      Color(0xFFEFF6FF),
                      Color(0xFFFFF7ED),
                    ],
                    iconColors: const [
                      Color(0xFF9333EA),
                      Color(0xFF2563EB),
                      Color(0xFFF97316),
                    ],
                  ),
                ),
                Expanded(
                  child: _InfoCol(
                    'Plant Schedule',
                    [
                      ('Arrival at Plant', item.arrivalAtPlant),
                      ('Departure from Plant', item.departureFromPlant),
                    ],
                    labelSize,
                    valueSize,
                    icons: const [
                      Icons.calendar_today_outlined,
                      Icons.event_available_outlined,
                    ],
                    iconBgs: const [Color(0xFFECFDF3), Color(0xFFFFF7ED)],
                    iconColors: const [Color(0xFF22C55E), Color(0xFFF97316)],
                  ),
                ),
                Expanded(
                  child: _InfoCol(
                    'Carrier & Route',
                    [
                      ('Carrier', item.carrier),
                      ('First Destination', item.finalDestination),
                      ('Truck', item.truck),
                      ('Driver', item.driver),
                      ('Phone', item.phone),
                    ],
                    labelSize,
                    valueSize,
                    icons: const [
                      Icons.local_shipping_outlined,
                      Icons.location_on_outlined,
                      Icons.local_taxi_outlined,
                      Icons.person_outline,
                      Icons.phone_outlined,
                    ],
                    iconBgs: const [
                      Color(0xFFECFDF3),
                      Color(0xFFFFF1F2),
                      Color(0xFFEFF6FF),
                      Color(0xFFF8FAFC),
                      Color(0xFFF8FAFC),
                    ],
                    iconColors: const [
                      Color(0xFF22C55E),
                      Color(0xFFEF4444),
                      Color(0xFF2563EB),
                      Color(0xFF64748B),
                      Color(0xFF64748B),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Weight / material type & Documents
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weight Units + Material Type',
                          style: TextStyle(
                            fontSize: labelSize,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Quantity: ${item.quantity}',
                          style: TextStyle(
                            fontSize: labelSize,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Material Type: Structural Steel',
                          style: TextStyle(
                            fontSize: labelSize,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Packaging: Bundled Frame Components',
                          style: TextStyle(
                            fontSize: labelSize,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // ─── RED BOX 2: Documents Download ───
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Documents',
                              style: TextStyle(
                                fontSize: labelSize,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'PDF & Manifest',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2563EB),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _DocumentCard(
                                label: 'Packing list',
                                isLoading: _isDownloadingPackingList,
                                onTap: _downloadPackingList,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _DocumentCard(
                                label: 'Bill of Lading',
                                isLoading: _isDownloadingBol,
                                onTap: _downloadBillOfLading,
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
                color: item.notes.trim().isNotEmpty
                    ? const Color(0xFFFEFCE8)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: item.notes.trim().isNotEmpty
                      ? const Color(0xFFFDE68A)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Special Instructions',
                    style: TextStyle(
                      fontSize: labelSize,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.notes.trim().isNotEmpty
                        ? item.notes
                        : 'No special instructions provided.',
                    style: TextStyle(
                      fontSize: labelSize,
                      fontStyle: item.notes.trim().isNotEmpty
                          ? FontStyle.normal
                          : FontStyle.italic,
                      color: item.notes.trim().isNotEmpty
                          ? const Color(0xFF92400E)
                          : AppColors.textSecondary,
                    ),
                  ),
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
                    horizontal: 28,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowCircle({
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  Widget _buildRouteConnector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 2,
              color: const Color(0xFFCBD5E1),
            ),
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              size: 12,
              color: Color(0xFF64748B),
            ),
          ),
          Expanded(
            child: Container(
              height: 2,
              color: const Color(0xFFCBD5E1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteLabel({
    required String badge,
    required Color badgeColor,
    required String title,
    required String subtitle,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            badge,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: badgeColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
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
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: labelSize,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...rows.asMap().entries.map((entry) {
          final index = entry.key;
          final r = entry.value;
          final icon = index < icons.length
              ? icons[index]
              : Icons.circle_outlined;
          final bg = index < iconBgs.length
              ? iconBgs[index]
              : AppColors.inputFill;
          final fg = index < iconColors.length
              ? iconColors[index]
              : AppColors.textSecondary;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
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
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: r.$2,
                          style: TextStyle(
                            fontSize: valueSize,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final labelSize = (MediaQuery.sizeOf(context).width * 0.009).clamp(
      11.0,
      12.0,
    );
    return InkWell(
      onTap: isLoading ? null : onTap,
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
              child: Text(
                label,
                style: TextStyle(
                  fontSize: labelSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryBlue,
                ),
              )
            else
              const Icon(
                Icons.download_rounded,
                size: 18,
                color: AppColors.primaryBlue,
              ),
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
    final fontSize = (MediaQuery.sizeOf(context).width * 0.008).clamp(
      10.0,
      11.0,
    );
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 12, color: Colors.white),
      label: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
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
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
