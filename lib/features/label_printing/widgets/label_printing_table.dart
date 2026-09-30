import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/theme/app_colors.dart';
import '../../tasks/widgets/task_success_dialog.dart';
import '../controllers/label_printing_controller.dart';
import '../models/label_printing_models.dart';
import 'label_preview_dialog.dart';
import 'label_printing_checkbox.dart';

class LabelPrintingTable extends GetView<LabelPrintingController> {
  const LabelPrintingTable({super.key});

  static String _fmtWeight(double lbs) {
    if (lbs == 0) return '0 LBS';
    final isInt = lbs == lbs.roundToDouble();
    final s = isInt ? lbs.toInt().toString() : lbs.toStringAsFixed(1);
    final parts = s.split('.');
    final intPart = parts[0];
    final buf = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buf.write(',');
      buf.write(intPart[i]);
    }
    final formattedInt = buf.toString();
    final res = parts.length > 1 ? '$formattedInt.${parts[1]}' : formattedInt;
    return '$res LBS';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final cellFont = (size.width * 0.008).clamp(11.0, 12.0);

    return Obx(() {
      controller.pageIndex.value;
      final selectedCount = controller.selectedIds.length;
      final rows = controller.pageBundles;
      final totalCount = controller.filteredBundles.length;
      final currentPage = controller.pageIndex.value;
      final totalPages = controller.totalPages;
      final allSelected = controller.isAllOnPageSelected;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final minWidth = constraints.maxWidth.clamp(1100.0, 2400.0);
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: minWidth,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.012,
                            vertical: size.height * 0.012,
                          ),
                          color: AppColors.tableHeader,
                          child: Row(
                            children: [
                              LabelPrintingCheckboxCell(
                                value: allSelected && rows.isNotEmpty,
                                onChanged: rows.isEmpty
                                    ? null
                                    : (_) => controller.toggleSelectAllOnPage(),
                              ),
                              _HeadCell(
                                flex: 2,
                                text: 'Bundle ID',
                                size: cellFont,
                              ),
                              _HeadCell(
                                flex: 2,
                                text: 'Load ID',
                                size: cellFont,
                              ),
                              _HeadCell(flex: 2, text: 'Parts', size: cellFont),
                              _HeadCell(
                                flex: 2,
                                text: 'Total Weight ⇅',
                                size: cellFont,
                              ),
                              _HeadCell(
                                flex: 1,
                                text: 'Length',
                                size: cellFont,
                              ),
                              _HeadCell(
                                flex: 2,
                                text: 'Status',
                                size: cellFont,
                              ),
                              _HeadCell(
                                flex: 2,
                                text: 'Action',
                                size: cellFont,
                                align: TextAlign.end,
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                        ...rows.map(
                          (item) => _DataRow(
                            key: ValueKey('${item.id}-$selectedCount'),
                            item: item,
                            cellFont: cellFont,
                            fmtWeight: _fmtWeight,
                            onPrint: () => _openPreview(context, item),
                          ),
                        ),
                        if (rows.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'No bundles found.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: cellFont,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 1, color: AppColors.cardBorder),
            _PaginationFooter(
              currentPage: currentPage,
              totalPages: totalPages,
              totalCount: totalCount,
              pageSize: controller.pageSize,
            ),
          ],
        ),
      );
    });
  }

  Future<void> _openPreview(BuildContext context, LabelBundleItem item) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => LabelPreviewDialog(
        item: item,
        onPrint: () async {
          controller.markPrinted(item);
          if (!context.mounted) return;
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) =>
                const TaskSuccessDialog(title: 'Label Printed Successfully'),
          );
        },
      ),
    );
  }
}

class _DataRow extends GetView<LabelPrintingController> {
  const _DataRow({
    super.key,
    required this.item,
    required this.cellFont,
    required this.fmtWeight,
    required this.onPrint,
  });

  final LabelBundleItem item;
  final double cellFont;
  final String Function(double) fmtWeight;
  final VoidCallback onPrint;

  @override
  Widget build(BuildContext context) {
    final isSelected = controller.selectedIds.contains(item.id);
    final isPrinted = item.status == LabelPrintStatus.printed;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width * 0.012,
        vertical: MediaQuery.sizeOf(context).height * 0.012,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LabelPrintingCheckboxCell(
            value: isSelected,
            onChanged: (_) => controller.toggleSelect(item.id),
          ),
          _DataCell(
            flex: 2,
            child: Text(
              item.id,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: cellFont,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _DataCell(
            flex: 2,
            child: Text(
              item.loadId,
              style: TextStyle(
                fontSize: cellFont,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          _DataCell(
            flex: 2,
            child: Text(
              item.part,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: cellFont,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _DataCell(
            flex: 2,
            child: Text(
              fmtWeight(item.totalWeightLbs),
              style: TextStyle(
                fontSize: cellFont,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          _DataCell(
            flex: 1,
            child: Text(
              '${item.lengthFt} ft',
              style: TextStyle(
                fontSize: cellFont,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          _DataCell(flex: 2, child: _StatusBadge(item: item)),
          _DataCell(
            flex: 2,
            align: Alignment.centerRight,
            isLast: true,
            child: _ActionButton(
              isReprint: isPrinted || item.status == LabelPrintStatus.assigned,
              cellFont: cellFont,
              onTap: onPrint,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.item});

  final LabelBundleItem item;

  @override
  Widget build(BuildContext context) {
    final fontSize = (MediaQuery.sizeOf(context).width * 0.008).clamp(
      11.0,
      12.0,
    );
    final text = item.statusText.isNotEmpty
        ? item.statusText
        : (item.status == LabelPrintStatus.printed ? 'PRINTED' : 'PENDING');

    Color textColor = const Color(0xFF1D4ED8);
    Color bg = const Color(0xFFEFF6FF);

    if (text.contains('PRINT')) {
      textColor = const Color(0xFF166534);
      bg = const Color(0xFFDCFCE7);
    } else if (text.contains('ASSIGN') || text.contains('TRUCK')) {
      textColor = const Color(0xFF1D4ED8);
      bg = const Color(0xFFDBEAFE);
    } else if (text.contains('PEND')) {
      textColor = const Color(0xFF92400E);
      bg = const Color(0xFFFEF3C7);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: fontSize - 2,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.isReprint,
    required this.cellFont,
    required this.onTap,
  });

  final bool isReprint;
  final double cellFont;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isReprint
              ? const Color(0xFF4F46E5)
              : const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Text(
          isReprint ? 'Reprint' : 'Print',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: cellFont),
        ),
      ),
    );
  }
}

class _PaginationFooter extends GetView<LabelPrintingController> {
  const _PaginationFooter({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.pageSize,
  });

  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int pageSize;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final fontSize = (size.width * 0.009).clamp(11.0, 12.0);
    final pages = _visiblePages(currentPage, totalPages);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.012,
        vertical: size.height * 0.014,
      ),
      child: Row(
        children: [
          Row(
            children: [
              Text(
                'Showing',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.cardBorder),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Text(
                      '$pageSize',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: fontSize,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Results',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize,
                ),
              ),
            ],
          ),
          const Spacer(),
          _PageArrow(
            icon: Icons.chevron_left,
            enabled: currentPage > 0,
            onTap: controller.prevPage,
          ),
          const SizedBox(width: 6),
          ...pages.map((p) {
            if (p == -1) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: fontSize,
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _PageNumber(
                page: p + 1,
                isActive: p == currentPage,
                onTap: () => controller.pageIndex.value = p,
              ),
            );
          }),
          const SizedBox(width: 6),
          _PageArrow(
            icon: Icons.chevron_right,
            enabled: currentPage < totalPages - 1,
            onTap: controller.nextPage,
          ),
        ],
      ),
    );
  }

  List<int> _visiblePages(int current, int total) {
    if (total <= 5) return List.generate(total, (i) => i);
    if (current <= 1) return [0, 1, 2, -1, total - 1];
    if (current >= total - 2) return [0, -1, total - 3, total - 2, total - 1];
    return [0, -1, current, -1, total - 1];
  }
}

class _PageArrow extends StatelessWidget {
  const _PageArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _PageNumber extends StatelessWidget {
  const _PageNumber({
    required this.page,
    required this.isActive,
    required this.onTap,
  });

  final int page;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? AppColors.primaryBlue : AppColors.cardBorder,
            width: isActive ? 2 : 1,
          ),
          color: Colors.white,
        ),
        child: Text(
          '$page',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isActive ? AppColors.primaryBlue : AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _HeadCell extends StatelessWidget {
  const _HeadCell({
    required this.flex,
    required this.text,
    required this.size,
    this.align = TextAlign.start,
    this.isLast = false,
  });

  final int flex;
  final String text;
  final double size;
  final TextAlign align;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  right: BorderSide(
                    color: AppColors.cardBorder.withValues(alpha: 0.7),
                  ),
                ),
        ),
        child: Text(
          text,
          textAlign: align,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
            fontSize: size,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell({
    required this.flex,
    required this.child,
    this.align = Alignment.centerLeft,
    this.isLast = false,
  });

  final int flex;
  final Widget child;
  final Alignment align;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  right: BorderSide(
                    color: AppColors.cardBorder.withValues(alpha: 0.5),
                  ),
                ),
        ),
        child: Align(alignment: align, child: child),
      ),
    );
  }
}
