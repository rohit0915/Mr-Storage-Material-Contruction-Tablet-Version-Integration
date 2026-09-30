import 'package:flutter/material.dart';

import '../../../app/constants/app_assets.dart';
import '../../../app/theme/app_colors.dart';
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
    final width = (size.width * 0.52).clamp(520.0, 680.0);
    final maxHeight = size.height * 0.85;
    final fontSize = (size.width * 0.010).clamp(12.0, 14.0);

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width, maxHeight: maxHeight),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Back',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Label Preview',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: (size.width * 0.014).clamp(16.0, 20.0),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 56),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        AppAssets.qrCode,
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'project=${item.project}',
                            style: TextStyle(
                              fontSize: fontSize + 2,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _DetailRow(
                            label: 'Shipper',
                            value: 'shipper=${item.shipper}',
                          ),
                          _DetailRow(
                            label: 'Load',
                            value: 'load_id=${item.loadId}',
                          ),
                          _DetailRow(
                            label: 'Bundle',
                            value: 'bundle_id=${item.id}',
                          ),
                          _DetailRow(
                            label: 'Part#',
                            value: 'part=${item.part}',
                          ),
                          _DetailRow(
                            label: 'Weight',
                            value: 'weight=${item.totalWeightLbs}',
                          ),
                          _DetailRow(
                            label: 'Length',
                            value: 'length=${item.lengthFt}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onPrint();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Print',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
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
    final fontSize = (MediaQuery.sizeOf(context).width * 0.010).clamp(
      12.0,
      14.0,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 68,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
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
