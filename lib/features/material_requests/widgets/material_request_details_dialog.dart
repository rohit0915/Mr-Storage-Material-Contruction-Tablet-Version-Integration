import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/constants/app_assets.dart';
import '../../../app/theme/app_colors.dart';
import '../models/material_request_models.dart';

class MaterialRequestDetailsDialog extends StatelessWidget {
  const MaterialRequestDetailsDialog({super.key, required this.item});

  final MaterialRequestBoardItem item;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = (size.width * 0.62).clamp(640.0, 820.0);
    final labelSize = (size.width * 0.009).clamp(11.0, 12.0);
    final valueSize = (size.width * 0.010).clamp(12.0, 14.0);
    final dateFmt = DateFormat('MMM d, yyyy');
    final timeFmt = DateFormat('hh:mm a');

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: width,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Material Request Details',
                      style: TextStyle(
                        fontSize: (size.width * 0.014).clamp(16.0, 18.0),
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _StatusBadge(status: item.status),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.id,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: valueSize + 2,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _InfoBlock(
                          label: 'Project / Site',
                          lines: [item.project, item.site],
                          labelSize: labelSize,
                          valueSize: valueSize,
                        ),
                        const SizedBox(height: 12),
                        _InfoBlock(
                          label: 'Requested By',
                          lines: [item.requestedBy, item.requestedByRole],
                          labelSize: labelSize,
                          valueSize: valueSize,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: size.width * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoBlock(
                          label: 'Priority',
                          labelSize: labelSize,
                          child: _PriorityPill(priority: item.priority),
                        ),
                        const SizedBox(height: 12),
                        _InfoBlock(
                          label: 'Status',
                          labelSize: labelSize,
                          child: _StatusBadge(status: item.status, compact: true),
                        ),
                        const SizedBox(height: 12),
                        _InfoBlock(
                          label: 'Request Date',
                          lines: [
                            dateFmt.format(item.requestDate),
                            timeFmt.format(item.requestDate),
                          ],
                          labelSize: labelSize,
                          valueSize: valueSize,
                        ),
                        const SizedBox(height: 12),
                        _InfoBlock(
                          label: 'Required By',
                          lines: [dateFmt.format(item.requiredBy)],
                          labelSize: labelSize,
                          valueSize: valueSize,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Requested Items (${item.items.length})',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: valueSize,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _ItemsTable(items: item.items),
              const SizedBox(height: 18),
              Text(
                'Request Notes',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: valueSize,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.requestNotes,
                style: TextStyle(
                  fontSize: labelSize + 1,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Attachment (2)',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: valueSize,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const _AttachmentTile(
                name: 'Material_List.xlsx',
                size: '12KB',
                iconAsset: AppAssets.iconMaterialExcel,
              ),
              const SizedBox(height: 8),
              const _AttachmentTile(
                name: 'Site_Drawing.Pdf',
                size: '2.4 MB',
                iconAsset: AppAssets.iconMaterialPdf,
              ),
              const SizedBox(height: 22),
              Center(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Cancel Request',
                    style: TextStyle(fontWeight: FontWeight.w700),
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

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.label,
    this.lines,
    this.child,
    required this.labelSize,
    this.valueSize,
  });

  final String label;
  final List<String>? lines;
  final Widget? child;
  final double labelSize;
  final double? valueSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: labelSize,
          ),
        ),
        const SizedBox(height: 4),
        if (child != null)
          child!
        else if (lines != null)
          ...lines!.asMap().entries.map((e) {
            final isTitle = e.key == 0;
            return Text(
              e.value,
              style: TextStyle(
                fontWeight: isTitle ? FontWeight.w800 : FontWeight.w500,
                fontSize: isTitle ? (valueSize ?? labelSize) : labelSize,
                color: isTitle ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            );
          }),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, this.compact = false});

  final MaterialRequestStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      MaterialRequestStatus.pending => ('Pending', const Color(0xFFD97706)),
      MaterialRequestStatus.approved => ('Approved', const Color(0xFF16A34A)),
      MaterialRequestStatus.rejected => ('Rejected', const Color(0xFFDC2626)),
    };

    return Text(
      label,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w800,
        fontSize: compact ? 13 : 15,
      ),
    );
  }
}

class _PriorityPill extends StatelessWidget {
  const _PriorityPill({required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    final color = priority == 'High'
        ? const Color(0xFFBE185D)
        : priority == 'Medium'
            ? const Color(0xFFD97706)
            : const Color(0xFF2563EB);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority,
        style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}

class _ItemsTable extends StatelessWidget {
  const _ItemsTable({required this.items});

  final List<MaterialRequestItemRow> items;

  @override
  Widget build(BuildContext context) {
    final cellFont = (MediaQuery.sizeOf(context).width * 0.008).clamp(11.0, 12.0);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.tableHeader,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                _Head('#', cellFont),
                _Head('Item Description', cellFont, flex: 3),
                _Head('Unit', cellFont),
                _Head('Requested Qty', cellFont, flex: 2),
                _Head('Remarks', cellFont, flex: 2),
              ],
            ),
          ),
          ...List.generate(items.length, (i) {
            final it = items[i];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
              ),
              child: Row(
                children: [
                  _Cell('${i + 1}', cellFont),
                  _Cell(it.name, cellFont, flex: 3),
                  _Cell(it.unit, cellFont),
                  _Cell(_fmtQty(it.quantity), cellFont, flex: 2),
                  _Cell(it.remarks, cellFont, flex: 2),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _fmtQty(num q) {
    final n = q.round();
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _Head extends StatelessWidget {
  const _Head(this.text, this.size, {this.flex = 1});
  final String text;
  final double size;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          fontSize: size,
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(this.text, this.size, {this.flex = 1});
  final String text;
  final double size;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: size,
        ),
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({
    required this.name,
    required this.size,
    required this.iconAsset,
  });

  final String name;
  final String size;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Image.asset(iconAsset, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  size,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.download_outlined, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
