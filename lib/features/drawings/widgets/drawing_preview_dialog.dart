import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../models/drawing_models.dart';

class DrawingPreviewDialog extends StatelessWidget {
  const DrawingPreviewDialog({super.key, required this.file});

  final DrawingFileItem file;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.035,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: size.width * 0.88,
          height: size.height * 0.86,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 16, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.title,
                            style: TextStyle(
                              fontSize: (size.width * 0.016).clamp(18.0, 22.0),
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            file.projectCode,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Row(
                        children: [
                          Expanded(
                            child: _MetaCol(
                              label: 'Location',
                              value: file.location,
                            ),
                          ),
                          Expanded(
                            child: _MetaCol(
                              label: 'Uploaded By:',
                              value: file.uploadedBy,
                            ),
                          ),
                          Expanded(
                            child: _MetaCol(
                              label: 'Received on',
                              value: file.receivedOn,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.cardBorder),

              // Image / Preview Content Body
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: file.previewType == DrawingPreviewType.imageGrid
                      ? _ImageGrid2x2(assets: file.previewAssets)
                      : InteractiveViewer(
                          minScale: 0.6,
                          maxScale: 5,
                          child: Center(
                            child: Image.asset(
                              file.previewAssets.first,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                ),
              ),

              // Bottom Action Bar (Download & Approved Badge)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Downloading ${file.name}...'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_downward, size: 16),
                      label: const Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF94A3B8),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        file.status.isNotEmpty ? file.status : 'Approved',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaCol extends StatelessWidget {
  const _MetaCol({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ImageGrid2x2 extends StatelessWidget {
  const _ImageGrid2x2({required this.assets});

  final List<String> assets;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: assets.length.clamp(0, 4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(assets[index], fit: BoxFit.cover),
        );
      },
    );
  }
}
