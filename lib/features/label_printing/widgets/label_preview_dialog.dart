import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/label_printing_models.dart';

class LabelPreviewDialog extends StatelessWidget {
  const LabelPreviewDialog({
    super.key,
    required this.item,
    required this.onPrint,
  });

  final LabelBundleItem item;
  final VoidCallback onPrint;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = (size.width * 0.55).clamp(540.0, 700.0);
    final maxHeight = size.height * 0.88;

    final cleanProject = item.project.isNotEmpty && item.project != '-'
        ? item.project.replaceAll(' ', '')
        : 'WoodWorkshop';

    final shipperVal = item.shipper.isNotEmpty && item.shipper != '-'
        ? item.shipper
        : (item.jobId.isNotEmpty ? item.jobId : 'PRO-007');

    final loadVal = item.loadId.isNotEmpty && item.loadId != '-'
        ? item.loadId
        : '';

    final bundleVal = item.id.isNotEmpty ? item.id : 'B-001';

    final partsVal = item.part.isNotEmpty && item.part != '-' ? item.part : '-';

    final weightVal = item.rawWeight.isNotEmpty
        ? item.rawWeight
        : (item.totalWeightLbs > 0
            ? (item.totalWeightLbs % 1 == 0
                ? item.totalWeightLbs.toInt().toString()
                : item.totalWeightLbs.toString())
            : '0');

    final lengthVal = item.rawLength.isNotEmpty
        ? item.rawLength
        : (item.lengthFt > 0
            ? (item.lengthFt % 1 == 0
                ? item.lengthFt.toInt().toString()
                : item.lengthFt.toString())
            : '0');

    final qrData = item.realMongoId.isNotEmpty
        ? 'https://mr-storage-vendor.vercel.app/bundle/${item.realMongoId}'
        : 'https://mr-storage-vendor.vercel.app/bundle/${item.id}';

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width, maxHeight: maxHeight),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top header: Back button on left, Title in center
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF334155),
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      'Label Preview',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Content row: QR Code on left, details on right
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 170,
                      height: 170,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 162.0,
                        padding: const EdgeInsets.all(4),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'project=$cleanProject',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _DetailRow(
                            label: 'Shipper :',
                            value: 'shipper=$shipperVal',
                          ),
                          _DetailRow(
                            label: 'Load :',
                            value: 'load_id=$loadVal',
                          ),
                          _DetailRow(
                            label: 'Bundle :',
                            value: 'bundle_id=$bundleVal',
                          ),
                          _DetailRow(
                            label: 'Parts :',
                            value: 'parts=$partsVal',
                          ),
                          _DetailRow(
                            label: 'Weight :',
                            value: 'weight=$weightVal',
                          ),
                          _DetailRow(
                            label: 'Length :',
                            value: 'Length=$lengthVal',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Centered Print button
                Center(
                  child: Container(
                    width: 320,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF4F46E5)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x332563EB),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onPrint();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Print',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
